#!/usr/bin/env bash
# Tests for scripts/launch.sh, the launch builder. Run: bash scripts/test-launch.sh
# Prints "ok CASE" or "FAIL CASE: REASON" for every case, then PASS when all pass.
# Exit 0: every case passed. 1: a case failed. 2: setup failed (SETUP: line).
# LAUNCH_SH overrides the builder under test; it is always run as bash "$LAUNCH_SH".
set -u

setup() { echo "SETUP: $*"; exit 2; }

[ "$(id -u)" != 0 ] || setup "run as a non-root user; root can read chmod 000 fixtures"
here=$(cd "$(dirname "$0")" && pwd) || setup "cannot resolve the script directory"
LAUNCH_SH=${LAUNCH_SH:-$here/launch.sh}
case $LAUNCH_SH in /*) ;; *) LAUNCH_SH=$PWD/$LAUNCH_SH ;; esac
[ -f "$LAUNCH_SH" ] || setup "no builder at $LAUNCH_SH"

# Fixture directories must not be group- or other-writable unless a case makes them so.
umask 022
T=$(mktemp -d) && T=$(realpath "$T") || setup "mktemp -d failed"
trap 'chmod -R u+rwx "$T" 2>/dev/null; rm -rf "$T"' EXIT
export HOME=$T/home
mkdir -p "$T/home/real" "$T/home/adir" "$T/wt" "$T/res" "$T/brief" "$T/b" "$T/r" \
  "$T/bin" "$T/log" "$T/exp" "$T/k" "$T/c" "$T/g" "$T/outdir" "$T/s1" "$T/s2" "$T/s3" "$T/s4" "$T/s5" \
  "$T/s6/h" "$T/s6o" "$T/c13" "$T/c14wt/in" "$T/c15/wt" "$T/c16wt/in" "$T/c17/h" "$T/wt/s5" "$T/o2" "$T/o3" \
  "$T/s7" "$T/s7o" "$T/s8" "$T/s9" "$T/s9sh" "$T/c19" "$T/c21" "$T/c22" "$T/s10" "$T/s11" "$T/w1" \
  "$T/cap" "$T/w1cap" "$T/pbin" "$T/fbin" "$T/pc" "$T/pc1res" "$T/pc5" "$T/pc5res" || setup "cannot create fixture directories"
chmod 1777 "$T/s7" "$T/c19" "$T/s9sh" || setup "cannot chmod the shared fixture directories"
# A private result directory beneath a shared temp-style directory (S9).
mkdir -m 700 "$T/s9sh/p" || setup "cannot create the private fixture directory"
ln -s "$T/wt" "$T/s5l" && ln -s "$T/s6/h" "$T/s6l" && ln -s "$T/c16wt" "$T/c16l" && ln -s "$T/c17/h" "$T/c17l" \
  && ln -s "$T/s7" "$T/s7l" && ln -s "$T/c19" "$T/c19l" || setup "cannot create fixture links"

LF=$T/brief/launch.md
printf 'launch prompt %s.%s\n' "$$" "$RANDOM" >"$LF" || setup "cannot write the launch file"
LAUNCH_CONTENT=$(cat "$LF")
: >"$T/res/r.md" || setup "cannot write fixtures"

# Echo stubs: print cwd, TMPDIR, argv and stdin; a probe's run script captures its
# stdout, so with STUB_LOG set they also append the same lines to that file.
for b in claude codex; do
  cat >"$T/bin/$b" <<'EOF' || setup "cannot write stub $b"
#!/usr/bin/env bash
out=$(echo "cwd=$PWD"; echo "tmpdir=${TMPDIR-}"; for a in "$@"; do printf 'arg=%s\n' "$a"; done; echo "stdin=$(cat)")
printf '%s\n' "$out"
[ -z "${STUB_LOG-}" ] || printf '%s\n' "$out" >>"$STUB_LOG"
EOF
  chmod 755 "$T/bin/$b" || setup "cannot chmod stub $b"
done

# Stream stubs for the probe capture (PC1-PC7): read stdin, print STUB_STREAM on
# stdout and STUB_ERR on stderr, and exit STUB_RC. With STUB_PROBE set they first
# record whether both streams are pipes (STUB_FD), print STUB_MARK on both, wait,
# and record the status of a search for it under STUB_CAP (STUB_SCAN).
for b in claude codex; do
  cat >"$T/pbin/$b" <<'EOF' || setup "cannot write stream stub $b"
#!/usr/bin/env bash
[ -z "${STUB_LOG-}" ] || { echo "cwd=$PWD"; for a in "$@"; do printf 'arg=%s\n' "$a"; done; } >"$STUB_LOG"
cat >/dev/null
if [ -n "${STUB_PROBE-}" ]; then
  o=other e=other
  if [ -p /dev/stdout ]; then o=pipe; fi
  if [ -p /dev/stderr ]; then e=pipe; fi
  printf 'out=%s\nerr=%s\n' "$o" "$e" >"$STUB_FD"
  printf '%s\n' "$STUB_MARK"
  printf '%s\n' "$STUB_MARK" >&2
  sleep 1
  grep -rqF -- "$STUB_MARK" "$STUB_CAP"
  echo "$?" >"$STUB_SCAN"
fi
cat -- "$STUB_STREAM"
cat -- "$STUB_ERR" >&2
exit "${STUB_RC:-0}"
EOF
  chmod 755 "$T/pbin/$b" || setup "cannot chmod stream stub $b"
done
# A failing awk for PC7: STUB_AWK_FAIL=1 fails the stage that writes the capture's
# stderr file, 2 the stage that writes its stdout file, after draining stdin.
REAL_AWK=$(command -v awk) || setup "no awk on PATH"
cat >"$T/fbin/awk" <<EOF || setup "cannot write the awk wrapper"
#!/usr/bin/env bash
case \${STUB_AWK_FAIL-}:\$(readlink -f /proc/\$\$/fd/1) in
  1:*/stderr | 2:*/stdout) cat >/dev/null; exit 9 ;;
esac
exec '$REAL_AWK' "\$@"
EOF
chmod 755 "$T/fbin/awk" || setup "cannot chmod the awk wrapper"

# Host source for the Claude write kinds: one plain file and one symlink.
printf 'plain\n' >"$T/home/plain.md" && printf 'target\n' >"$T/home/real/target.md" \
  && ln -s "$T/home/real/target.md" "$T/home/link.md" \
  && printf 'Read `~/plain.md` and `~/link.md`.\n' >"$T/home/src.md" || setup "cannot write host fixtures"
LEDGER="Host grant: $T/home/plain.md, $T/home/link.md -> $T/home/real/target.md"
ALLOW='Bash(make check)'
COMMON=(--worktree "$T/wt" --launch-file "$LF" --model m1 --effort high)
ADDS=(--add-dir "$T/res" --add-dir "$T/brief")

fails=0
t() { # NAME FUNCTION: run one case and report it
  local name=$1 reason
  if reason=$("$2"); then echo "ok $name"; else echo "FAIL $name: ${reason:-case failed}"; fails=$((fails + 1)); fi
}
mode() { local m; m=$(ls -ld -- "$1" 2>/dev/null) && printf '%s' "${m:0:10}"; }
no_tmp() { ! ls -A "$1" | grep -q '^\.launch\.'; } # no .launch.* temp file in DIR
first() { head -n 1 "$1" | tr -d '\n'; }

# ---- AC 1: argv per kind (K1-K7) ----

cat >"$T/exp/K1" <<EOF
cwd=$T/wt
tmpdir=$T/ambient
arg=-p
arg=--permission-mode
arg=acceptEdits
arg=--output-format
arg=json
arg=--model
arg=m1
arg=--effort
arg=high
arg=--disable-slash-commands
arg=--strict-mcp-config
arg=--mcp-config
arg={"mcpServers":{}}
arg=--add-dir
arg=$T/res
arg=--add-dir
arg=$T/brief
arg=--permission-prompts
arg=none
arg=--allowedTools
arg=Bash(git add *)
arg=Bash(git commit *)
arg=Bash(git status *)
arg=Bash(git diff *)
arg=Bash(git log *)
arg=Bash(git rev-parse *)
arg=Bash(git show *)
arg=Bash(git restore -- *)
arg=Bash(make check)
arg=Read(/$T/home/plain.md)
arg=Read(/$T/home/link.md)
arg=Read(/$T/home/real/target.md)
arg=--disallowedTools
arg=Bash(git checkout *)
arg=Bash(git reset --hard *)
arg=Bash(git push *)
arg=Bash(gh *)
stdin=$LAUNCH_CONTENT
EOF

cat >"$T/exp/K2" <<EOF
cwd=$T/wt
tmpdir=$T/ambient
arg=-p
arg=--permission-mode
arg=plan
arg=--output-format
arg=json
arg=--model
arg=m1
arg=--effort
arg=high
arg=--disable-slash-commands
arg=--strict-mcp-config
arg=--mcp-config
arg={"mcpServers":{}}
arg=--add-dir
arg=$T/res
arg=--add-dir
arg=$T/brief
arg=--permission-prompts
arg=none
arg=--tools
arg=Read,Bash
arg=--allowedTools
arg=Bash(git status *)
arg=Bash(git rev-parse *)
arg=Bash(git diff *)
arg=Bash(make check)
arg=--disallowedTools
arg=Bash(grep -r*)
arg=Bash(grep -R*)
arg=Bash(grep --recursive*)
arg=Bash(grep --dereference-recursive*)
arg=Bash(rg *)
arg=Bash(find *)
stdin=$LAUNCH_CONTENT
EOF

cat >"$T/exp/K3" <<EOF
cwd=$T/wt
tmpdir=$T/ambient
arg=-p
arg=--permission-mode
arg=acceptEdits
arg=--output-format
arg=stream-json
arg=--verbose
arg=--model
arg=m1
arg=--effort
arg=high
arg=--disable-slash-commands
arg=--strict-mcp-config
arg=--mcp-config
arg={"mcpServers":{}}
arg=--add-dir
arg=$T/res
arg=--add-dir
arg=$T/brief
arg=--permission-prompts
arg=none
arg=--allowedTools
arg=Bash(git add *)
arg=Bash(git commit *)
arg=Bash(git status *)
arg=Bash(git diff *)
arg=Bash(git log *)
arg=Bash(git rev-parse *)
arg=Bash(git show *)
arg=Bash(git restore -- *)
arg=Bash(make check)
arg=Read(/$T/home/plain.md)
arg=Read(/$T/home/link.md)
arg=Read(/$T/home/real/target.md)
arg=--disallowedTools
arg=Bash(git checkout *)
arg=Bash(git reset --hard *)
arg=Bash(git push *)
arg=Bash(gh *)
stdin=$LAUNCH_CONTENT
EOF

cat >"$T/exp/K4" <<EOF
cwd=$T/wt
tmpdir=$T/ambient
arg=exec
arg=-C
arg=$T/wt
arg=-s
arg=workspace-write
arg=-c
arg=approval_policy="never"
arg=--model
arg=m1
arg=-c
arg=model_reasoning_effort="high"
arg=--add-dir
arg=$T/res
arg=--add-dir
arg=$T/brief
arg=--json
arg=--output-last-message
arg=$T/res/result.md
arg=-
stdin=$LAUNCH_CONTENT
EOF

cat >"$T/exp/K5" <<EOF
cwd=$T/res/work
tmpdir=$T/res/work/tmp
arg=exec
arg=-C
arg=$T/res/work
arg=-s
arg=workspace-write
arg=--skip-git-repo-check
arg=-c
arg=sandbox_workspace_write.exclude_slash_tmp=true
arg=-c
arg=approval_policy="never"
arg=--model
arg=m1
arg=-c
arg=model_reasoning_effort="high"
arg=--json
arg=--output-last-message
arg=$T/res/result.md
arg=-
stdin=$LAUNCH_CONTENT
EOF

k_case() { # NAME KIND EXPECTED [ARGS...]: build from $T/b, run from $T/r, diff, mode, check
  local name=$1 kind=$2 exp=$3 out=$T/k/$1.sh rc got=$T/log/$1.run
  local -a cap=()
  shift 3
  # A probe's run script captures its stdout, so its argv is read from the stub's log.
  case $kind in *-probe) cap=(--capture "$T/cap/$name") got=$T/log/$name.argv ;; esac
  rm -f -- "$T/log/$name.argv"
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$kind" --out "$out" "${COMMON[@]}" "$@" ${cap[@]+"${cap[@]}"}) \
    >"$T/log/$name.out" 2>"$T/log/$name.err"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "write exited $rc: $(first "$T/log/$name.err")"; return 1; }
  [ "$(mode "$out")" = -rwx------ ] || { echo "mode is $(mode "$out"), not -rwx------"; return 1; }
  (cd "$T/r" && TMPDIR=$T/ambient PATH="$T/bin:$PATH" STUB_LOG=$T/log/$name.argv "$out") >"$T/log/$name.run" 2>&1
  rc=$?
  [ "$rc" -eq 0 ] || { echo "run script exited $rc: $(first "$T/log/$name.run")"; return 1; }
  diff "$exp" "$got" >"$T/log/$name.diff" \
    || { echo "argv differs: $(grep '^[<>]' "$T/log/$name.diff" | head -n 1)"; return 1; }
  (cd "$T/r" && bash "$LAUNCH_SH" check "$out" --worktree "$T/wt") 2>"$T/log/$name.chk"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "check exited $rc: $(first "$T/log/$name.chk")"; return 1; }
  case $kind in
    claude-write*) [ "$(cat "$T/log/$name.out")" = "$LEDGER" ] || { echo "ledger is: $(first "$T/log/$name.out")"; return 1; } ;;
    codex-read*) [ "$(mode "$T/res/work")" = drwx------ ] && [ "$(mode "$T/res/work/tmp")" = drwx------ ] \
      || { echo "work or tmp mode is not drwx------"; return 1; } ;;
  esac
}
K1() { k_case K1 claude-write "$T/exp/K1" "${ADDS[@]}" --allow "$ALLOW" --host-source "$T/home/src.md"; }
K2() { k_case K2 claude-read "$T/exp/K2" "${ADDS[@]}" --allow "$ALLOW"; }
K3() { k_case K3 claude-write-probe "$T/exp/K3" "${ADDS[@]}" --allow "$ALLOW" --host-source "$T/home/src.md"; }
K4() { k_case K4 codex-write "$T/exp/K4" "${ADDS[@]}" --result "$T/res/result.md"; }
K5() { k_case K5 codex-read "$T/exp/K5" --result "$T/res/result.md"; }
K6() { k_case K6 codex-read-probe "$T/exp/K5" --result "$T/res/result.md"; }
K7() {
  [ -s "$T/log/K5.run" ] && [ -s "$T/log/K6.argv" ] || { echo "K5 or K6 produced no output"; return 1; }
  cmp -s "$T/log/K5.run" "$T/log/K6.argv" || { echo "codex-read-probe output differs from codex-read"; return 1; }
}

# ---- #253 AC 2-3: the result lies outside the worker's only writable root (W1) ----

W1() { # build and run both read kinds; the result is not in the start directory, -C, or TMPDIR
  local k rc d cwd tdir cv res log
  local -a cap
  for k in codex-read codex-read-probe; do
    cap=() log=$T/log/W1-$k.argv
    [ "$k" = codex-read ] || cap=(--capture "$T/w1cap/$k")
    rm -f -- "$log"
    (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$k" --out "$T/w1/$k.sh" --worktree "$T/wt" \
      --launch-file "$LF" --result "$T/w1/result.md" ${cap[@]+"${cap[@]}"}) >/dev/null 2>"$T/log/W1.err"
    rc=$?
    [ "$rc" -eq 0 ] || { echo "$k: write exited $rc: $(first "$T/log/W1.err")"; return 1; }
    (cd "$T/r" && PATH="$T/bin:$PATH" STUB_LOG=$log "$T/w1/$k.sh") >"$T/log/W1.run" 2>&1
    rc=$?
    [ "$rc" -eq 0 ] || { echo "$k: run script exited $rc"; return 1; }
    cwd=$(sed -n 's/^cwd=//p' "$log") tdir=$(sed -n 's/^tmpdir=//p' "$log")
    cv=$(sed -n '/^arg=-C$/{n;s/^arg=//p;}' "$log")
    res=$(sed -n '/^arg=--output-last-message$/{n;s/^arg=//p;}' "$log")
    [ "$res" = "$T/w1/result.md" ] || { echo "$k: --output-last-message is $res"; return 1; }
    for d in "$cwd" "$cv" "$tdir"; do
      case $res/ in "${d%/}"/*) echo "$k: the result $res is inside the writable root $d"; return 1 ;; esac
    done
  done
}

# ---- F1: relative paths (P1, P2) ----

P1() { # from cwd $T, one relative value that names an existing path per flag
  local flag rc wt lf out ad hs res
  local -a kind
  for flag in --worktree --launch-file --out --add-dir --host-source --result; do
    wt=$T/wt lf=$LF out=$T/p1.sh ad=$T/res hs=$T/home/src.md res=$T/res/r.md
    case $flag in
      --worktree) wt=wt ;;
      --launch-file) lf=brief/launch.md ;;
      --out) out=p1.sh ;;
      --add-dir) ad=res ;;
      --host-source) hs=home/src.md ;;
      --result) res=res/r.md ;;
    esac
    case $flag in
      --result) kind=(--kind codex-read --result "$res") ;;
      *) kind=(--kind claude-write --host-source "$hs") ;;
    esac
    (cd "$T" && bash "$LAUNCH_SH" write "${kind[@]}" --worktree "$wt" --launch-file "$lf" --out "$out" --add-dir "$ad") \
      >/dev/null 2>"$T/log/P1.err"
    rc=$?
    [ "$rc" -eq 2 ] || { echo "relative $flag: exit $rc, not 2"; return 1; }
    grep -qF -- "$flag must be an absolute path" "$T/log/P1.err" || { echo "relative $flag: stderr lacks: $flag must be an absolute path"; return 1; }
    [ ! -e "$T/p1.sh" ] || { echo "relative $flag: OUT was written"; return 1; }
    no_tmp "$T" || { echo "relative $flag: a .launch.* file was left"; return 1; }
  done
}
P2() {
  local rc
  (cd "$T" && bash "$LAUNCH_SH" grant --source home/src.md --worktree "$T/wt") >/dev/null 2>"$T/log/P2.err"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "relative grant --source: exit $rc, not 2"; return 1; }
  (cd "$T" && bash "$LAUNCH_SH" check k/K1.sh) >/dev/null 2>"$T/log/P2.err"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "relative check RUN_SCRIPT: exit $rc, not 2"; return 1; }
  (cd "$T" && bash "$LAUNCH_SH" check "$T/k/K5.sh" --worktree wt) >/dev/null 2>"$T/log/P2.err"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "relative check --worktree: exit $rc, not 2"; return 1; }
}

# ---- AC 2: host grant (G1-G8) ----

g_case() { # NAME SOURCE EXPECTED
  local out rc
  out=$(bash "$LAUNCH_SH" grant --source "$2" --worktree "$T/wt" 2>"$T/log/$1.err")
  rc=$?
  [ "$rc" -eq 0 ] || { echo "grant exited $rc: $(first "$T/log/$1.err")"; return 1; }
  [ "$out" = "$3" ] || { echo "ledger is: $out"; return 1; }
}
bt='`'
G1() {
  printf 'nested\n' >"$T/home/nested.md"
  printf 'names %s~/nested.md%s\n' "$bt" "$bt" >"$T/home/g-plain.md"
  printf 'target\n' >"$T/home/real/g-target.md"
  ln -s "$T/home/real/g-target.md" "$T/home/g-link.md"
  printf 'locked\n' >"$T/home/locked.md" && chmod 000 "$T/home/locked.md"
  printf 'inside\n' >"$T/wt/inside.md"
  printf 'weird\n' >"$T/home/we!rd.md"
  printf 'fenced\n' >"$T/home/fenced.md"
  {
    printf 'Read %s~/g-plain.md%s and %s~/g-link.md%s.\n' "$bt" "$bt" "$bt" "$bt"
    printf 'Also %s~/nope.md%s, %s~/adir%s, %s/dev/null%s,\n' "$bt" "$bt" "$bt" "$bt" "$bt" "$bt"
    printf '%s~/locked.md%s, %s%s/wt/inside.md%s and %s~/we!rd.md%s.\n' "$bt" "$bt" "$bt" "$T" "$bt" "$bt" "$bt"
    printf 'Again %s%s/home/g-plain.md%s.\n' "$bt" "$T" "$bt"
    printf '\n```\nsee %s~/fenced.md%s\n```\n' "$bt" "$bt"
  } >"$T/g/g1.md"
  g_case G1 "$T/g/g1.md" "Host grant: $T/home/g-plain.md, $T/home/g-link.md -> $T/home/real/g-target.md; skipped ~/nope.md (missing), ~/adir (directory), /dev/null (not a regular file), ~/locked.md (unreadable), $T/wt/inside.md (inside the worktree), ~/we!rd.md (unsafe path)"
}
G2() {
  printf 'Only %s~/nope.md%s and %s/dev/null%s.\n' "$bt" "$bt" "$bt" "$bt" >"$T/g/g2.md"
  g_case G2 "$T/g/g2.md" "Host grant: no host-directed files; skipped ~/nope.md (missing), /dev/null (not a regular file)"
}
G3() {
  printf 'No path here, only %snot a path%s and ~/bare.md.\n' "$bt" "$bt" >"$T/g/g3.md"
  g_case G3 "$T/g/g3.md" "Host grant: no host-directed files; source names no path"
}
G4() { g_case G4 "$T/g/absent.md" "Host grant: no host-directed files; source missing"; }
G5() { g_case G5 "$T/home/adir" "Host grant: no host-directed files; source not a regular file"; }
G6() {
  printf 'Read %s~/plain.md%s.\n' "$bt" "$bt" >"$T/g/g6.md" && chmod 000 "$T/g/g6.md"
  g_case G6 "$T/g/g6.md" "Host grant: no host-directed files; source unreadable"
}
G7() {
  printf 'dbl\n' >"$T/home/dbl.md" && printf 'sp\n' >"$T/home/sp.md"
  printf 'Read %s%s~/dbl.md%s%s and %s%s ~/sp.md %s%s.\n' "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" >"$T/g/g7.md"
  g_case G7 "$T/g/g7.md" "Host grant: $T/home/dbl.md, $T/home/sp.md"
}
G8() {
  local f
  for f in in1 in2 in3 out; do printf '%s\n' "$f" >"$T/home/$f.md"; done
  {
    printf '```\n~~~\n%s~/in1.md%s\n```\n' "$bt" "$bt"
    printf '````\n```\n%s~/in2.md%s\n````\n' "$bt" "$bt"
    printf 'Read %s~/out.md%s.\n' "$bt" "$bt"
    printf '~~~\n%s~/in3.md%s\n' "$bt" "$bt"
  } >"$T/g/g8.md"
  g_case G8 "$T/g/g8.md" "Host grant: $T/home/out.md"
}
G9() { # a fence inside a blockquote, a list item, or a nested blockquote grants nothing
  local f rc
  for f in sec1 sec2 sec3 sec4 sec5 quoted after; do printf '%s\n' "$f" >"$T/home/$f.md"; done
  {
    printf '# Notes\n\nSee %s~/plain.md%s.\n\n' "$bt" "$bt"
    printf '> ~~~\n> Read %s~/sec1.md%s.\n> ~~~\n\n' "$bt" "$bt"
    printf -- '- item\n\n    ~~~\n    %s~/sec2.md%s\n    ~~~\n\n' "$bt" "$bt"
    printf '> > ~~~\n> > %s~/sec3.md%s\n> > ~~~\n\n' "$bt" "$bt"
    printf '> Quoted %s~/quoted.md%s.\n\n' "$bt" "$bt"
    printf '> ~~~\n> %s~/sec4.md%s\n\nAfter %s~/after.md%s.\n\n' "$bt" "$bt" "$bt" "$bt"
    printf '    ```\n\n```\n%s~/sec5.md%s\n```\n' "$bt" "$bt"
  } >"$T/g/g9.md"
  g_case G9 "$T/g/g9.md" "Host grant: $T/home/plain.md, $T/home/quoted.md, $T/home/after.md" || return 1
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind claude-write --out "$T/k/G9.sh" --worktree "$T/wt" \
    --launch-file "$LF" --host-source "$T/g/g9.md") >"$T/log/G9.out" 2>"$T/log/G9.err"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "write exited $rc: $(first "$T/log/G9.err")"; return 1; }
  grep -qxF "'Read(/$T/home/plain.md)'" "$T/k/G9.sh" && grep -qxF "'Read(/$T/home/quoted.md)'" "$T/k/G9.sh" \
    || { echo "run script lacks the plain.md or quoted.md Read entry"; return 1; }
  ! grep -q 'sec[1-5]' "$T/k/G9.sh" || { echo "run script grants a fenced path: $(grep 'sec[1-5]' "$T/k/G9.sh" | head -n 1)"; return 1; }
}

# ---- AC 3: check (C1-C7) ----

c_build() { # NAME KIND [RESULT]: build the unedited fixture $T/c/NAME.base
  local -a args=(--worktree "$T/wt" --launch-file "$LF")
  case $2 in codex-read*) ;; *) args+=(--add-dir "$T/res" --add-dir "$T/brief") ;; esac
  case $2 in claude-*) args+=(--allow "$ALLOW") ;; esac
  case $2 in claude-write*) args+=(--host-source "$T/home/src.md") ;; codex-*) args+=(--result "${3:-$T/res/result.md}") ;; esac
  case $2 in *-probe) args+=(--capture "$T/cap/$1") ;; esac
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$2" --out "$T/c/$1.base" "${args[@]}") >/dev/null 2>"$T/log/$1.build" \
    || { echo "fixture build exited non-zero: $(first "$T/log/$1.build")"; return 1; }
  [ -f "$T/c/$1.base" ] || { echo "fixture was not built"; return 1; }
}
c_expect() { # NAME CWD MESSAGE: check $T/c/NAME.sh from CWD against $T/wt; want exit 1 and MESSAGE on stderr
  local rc
  cmp -s "$T/c/$1.base" "$T/c/$1.sh" && { echo "fixture edit did not apply"; return 1; }
  (cd "$2" && bash "$LAUNCH_SH" check "$T/c/$1.sh" --worktree "$T/wt") 2>"$T/log/$1.chk"
  rc=$?
  [ "$rc" -eq 1 ] || { echo "check exited $rc, not 1"; return 1; }
  grep -qF -- "$3" "$T/log/$1.chk" || { echo "stderr lacks: $3"; return 1; }
  ! grep -qF -- --capture "$T/log/$1.chk" || { echo "stopped at --capture"; return 1; }
}
after_gh() { sed -e "/^'Bash(gh \\*)'\$/a\\" -e "$2" "$T/c/$1.base" >"$T/c/$1.sh"; }
C1() {
  c_build C1 claude-write || return 1
  after_gh C1 "'Read(//x)'"
  c_expect C1 "$T/r" "Read( entry outside --allowedTools: Read(//x)"
}
C2() {
  c_build C2 claude-write || return 1
  sed "s|^'$T/res'\$|'$T/nope'|" "$T/c/C2.base" >"$T/c/C2.sh"
  c_expect C2 "$T/r" "--add-dir is not an existing directory: $T/nope"
}
C3() {
  c_build C3 claude-write || return 1
  after_gh C3 "'do the task'"
  c_expect C3 "$T/r" "positional argument after list-taking flag --disallowedTools: do the task" || return 1
  # A Read( entry is not an accepted --allowedTools item for claude-read.
  c_build C3r claude-read || return 1
  sed -e "/^'Bash(make check)'\$/a\\" -e "'Read(//x)'" "$T/c/C3r.base" >"$T/c/C3r.sh"
  c_expect C3r "$T/r" "positional argument after list-taking flag --allowedTools: Read(//x)"
}
C3b() {
  c_build C3b claude-write || return 1
  after_gh C3b "'Hello'"
  c_expect C3b "$T/r" "positional argument after list-taking flag --disallowedTools: Hello"
}
C4() {
  c_build C4 claude-write || return 1
  sed "s/ < '[^']*'\$//" "$T/c/C4.base" >"$T/c/C4.sh"
  c_expect C4 "$T/r" "prompt not attached on stdin"
}
C5() {
  c_build C5 codex-read || return 1
  sed "/^'-'\$/d" "$T/c/C5.base" >"$T/c/C5.sh"
  c_expect C5 "$T/r" "prompt not attached on stdin"
}
C6() {
  c_build C6 claude-write || return 1
  sed -e "/^cd -- /a\\" -e "argv+=('Read(//x)')" "$T/c/C6.base" >"$T/c/C6.sh"
  c_expect C6 "$T/r" "not a launch-builder run script"
}
C7() {
  c_build C7 claude-write || return 1
  sed "s|^'$T/res'\$|'wt'|" "$T/c/C7.base" >"$T/c/C7.sh"
  c_expect C7 "$T" "--add-dir is not an existing directory: wt"
}

# ---- #225 AC 2: codex read recipe rejections (C8-C13) ----

C8() { # -C is the worktree (cd moved with it)
  c_build C8 codex-read || return 1
  sed -e "s|^'$T/res/work'\$|'$T/wt'|" -e "s|^cd -- '$T/res/work'\$|cd -- '$T/wt'|" "$T/c/C8.base" >"$T/c/C8.sh"
  [ "$(grep -cxF -e "'$T/wt'" -e "cd -- '$T/wt'" "$T/c/C8.sh")" = 2 ] || { echo "the two start-directory edits did not both apply"; return 1; }
  c_expect C8 "$T/r" "-C must be $T/res/work for codex-read: $T/wt"
}
C9() { # -s read-only, on the probe kind
  c_build C9 codex-read-probe || return 1
  sed "s|^'workspace-write'\$|'read-only'|" "$T/c/C9.base" >"$T/c/C9.sh"
  c_expect C9 "$T/r" "-s must be workspace-write for codex-read-probe: read-only"
}
C10() { # exclude_slash_tmp=true omitted (its -c and value deleted)
  c_build C10 codex-read || return 1
  sed "/^'--skip-git-repo-check'\$/{n;N;d;}" "$T/c/C10.base" >"$T/c/C10.sh"
  c_expect C10 "$T/r" "missing flag: -c sandbox_workspace_write.exclude_slash_tmp=true"
}
C11() { # TMPDIR outside the result directory
  c_build C11 codex-read || return 1
  sed "s|^'TMPDIR=$T/res/work/tmp'\$|'TMPDIR=$T/brief'|" "$T/c/C11.base" >"$T/c/C11.sh"
  c_expect C11 "$T/r" "TMPDIR must be $T/res/work/tmp for codex-read: $T/brief"
}
C12() { # --add-dir in a read-kind script
  c_build C12 codex-read || return 1
  sed -e "/^'--json'\$/i\\" -e "'--add-dir'" -e "/^'--json'\$/i\\" -e "'$T/brief'" "$T/c/C12.base" >"$T/c/C12.sh"
  c_expect C12 "$T/r" "flag not in the codex-read recipe: --add-dir"
}
C13() { # a TMPDIR directory loosened after write
  local rc
  c_build C13 codex-read "$T/c13/result.md" || return 1
  chmod 755 "$T/c13/work/tmp" || { echo "cannot chmod $T/c13/work/tmp"; return 1; }
  (cd "$T/r" && bash "$LAUNCH_SH" check "$T/c/C13.base" --worktree "$T/wt") 2>"$T/log/C13.chk"
  rc=$?
  [ "$rc" -eq 1 ] || { echo "check exited $rc, not 1"; return 1; }
  grep -qF -- "TMPDIR is not an owner-only directory: $T/c13/work/tmp" "$T/log/C13.chk" || { echo "stderr lacks: TMPDIR is not an owner-only directory"; return 1; }
}

# ---- #225 PR1/PR2/R1: check refuses a root at, in, around, or aliasing the worktree, at or above HOME, or shared (C14-C19) ----

c_roots() { # NAME KIND DIR WORKTREE HOME MESSAGE: move -C, cd, the result and TMPDIR of a KIND build into DIR; check wants exit 1 and MESSAGE
  local rc d
  c_build "$1" "$2" || return 1
  for d in "$3/work" "$3/work/tmp"; do [ -d "$d" ] || mkdir -m 700 -- "$d" || { echo "cannot create $d"; return 1; }; done
  sed -e "s|^'$T/res/work'\$|'$3/work'|" -e "s|^cd -- '$T/res/work'\$|cd -- '$3/work'|" -e "s|^'$T/res/result.md'\$|'$3/result.md'|" \
    -e "s|^'TMPDIR=$T/res/work/tmp'\$|'TMPDIR=$3/work/tmp'|" "$T/c/$1.base" >"$T/c/$1.sh"
  [ "$(grep -cxF -e "'$3/work'" -e "cd -- '$3/work'" -e "'$3/result.md'" -e "'TMPDIR=$3/work/tmp'" "$T/c/$1.sh")" = 4 ] \
    || { echo "the four path edits did not all apply"; return 1; }
  (cd "$T/r" && HOME=$5 bash "$LAUNCH_SH" check "$T/c/$1.sh" --worktree "$4") 2>"$T/log/$1.chk"
  rc=$?
  [ "$rc" -eq 1 ] || { echo "check exited $rc, not 1"; return 1; }
  grep -qF -- "$6" "$T/log/$1.chk" || { echo "stderr lacks: $6"; return 1; }
  ! grep -qF -- --capture "$T/log/$1.chk" || { echo "stopped at --capture"; return 1; }
}
C14() { # -C, cd, result and TMPDIR moved together to the worktree or inside it, both read kinds
  local k
  for k in codex-read codex-read-probe; do
    c_roots "C14-$k-eq" "$k" "$T/c14wt" "$T/c14wt" "$HOME" "result directory $T/c14wt is inside the worktree $T/c14wt" || return 1
    c_roots "C14-$k-in" "$k" "$T/c14wt/in" "$T/c14wt" "$HOME" "result directory $T/c14wt/in is inside the worktree $T/c14wt" || return 1
  done
}
C15() { # the moved result directory holds the worktree, both read kinds
  local k
  for k in codex-read codex-read-probe; do
    c_roots "C15-$k" "$k" "$T/c15" "$T/c15/wt" "$HOME" "result directory $T/c15 contains the worktree $T/c15/wt" || return 1
  done
}
C16() { # a symlink to the worktree on the script side or on the --worktree side, both read kinds
  local k
  for k in codex-read codex-read-probe; do
    c_roots "C16-$k-res" "$k" "$T/c16l/in" "$T/c16wt" "$HOME" "result directory $T/c16wt/in is inside the worktree $T/c16wt" || return 1
    c_roots "C16-$k-wt" "$k" "$T/c16wt/in" "$T/c16l" "$HOME" "result directory $T/c16wt/in is inside the worktree $T/c16wt" || return 1
  done
}
C17() { # the moved result directory is HOME, above HOME, or a symlink to HOME, both read kinds
  local k d
  for k in codex-read codex-read-probe; do
    for d in "$T/c17/h" "$T/c17" "$T/c17l"; do
      c_roots "C17-$k-${d##*/}" "$k" "$d" "$T/wt" "$T/c17/h" "is HOME or an ancestor of it" || return 1
    done
  done
}
C18() { # check without --worktree for a read kind is a usage error
  local rc
  c_build C18 codex-read || return 1
  (cd "$T/r" && bash "$LAUNCH_SH" check "$T/c/C18.base") 2>"$T/log/C18.chk"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "check exited $rc, not 2"; return 1; }
  grep -qF -- "--worktree is required for codex-read" "$T/log/C18.chk" || { echo "stderr lacks: --worktree is required for codex-read"; return 1; }
}
C19() { # the moved result directory is a shared (1777) directory or a symlink to it, both read kinds
  local k d
  for k in codex-read codex-read-probe; do
    for d in "$T/c19" "$T/c19l"; do
      c_roots "C19-$k-${d##*/}" "$k" "$d" "$T/wt" "$HOME" "result directory $T/c19 is writable by group or others" || return 1
    done
  done
}

# ---- #253 AC 2-3: check refuses a read script whose writable root holds or aliases the result (C20-C23) ----

C20() { # the two-writer recipe: -C, cd and TMPDIR moved back to the result directory, both read kinds
  local k
  for k in codex-read codex-read-probe; do
    c_build "C20-$k" "$k" || return 1
    sed -e "s|^'$T/res/work'\$|'$T/res'|" -e "s|^cd -- '$T/res/work'\$|cd -- '$T/res'|" \
      -e "s|^'TMPDIR=$T/res/work/tmp'\$|'TMPDIR=$T/res/tmp'|" "$T/c/C20-$k.base" >"$T/c/C20-$k.sh"
    c_expect "C20-$k" "$T/r" "-C must be $T/res/work for $k: $T/res" || return 1
  done
}
C21() { # a work directory loosened after write
  local rc
  c_build C21 codex-read "$T/c21/result.md" || return 1
  chmod 755 "$T/c21/work" || { echo "cannot chmod $T/c21/work"; return 1; }
  (cd "$T/r" && bash "$LAUNCH_SH" check "$T/c/C21.base" --worktree "$T/wt") 2>"$T/log/C21.chk"
  rc=$?
  [ "$rc" -eq 1 ] || { echo "check exited $rc, not 1"; return 1; }
  grep -qF -- "-C is not an owner-only directory: $T/c21/work" "$T/log/C21.chk" || { echo "stderr lacks: -C is not an owner-only directory"; return 1; }
}
C22() { # a result that became a symlink into the writable root after write
  local rc
  c_build C22 codex-read "$T/c22/result.md" || return 1
  ln -s "$T/c22/work/result.md" "$T/c22/result.md" || { echo "cannot create the result link"; return 1; }
  (cd "$T/r" && bash "$LAUNCH_SH" check "$T/c/C22.base" --worktree "$T/wt") 2>"$T/log/C22.chk"
  rc=$?
  [ "$rc" -eq 1 ] || { echo "check exited $rc, not 1"; return 1; }
  grep -qF -- "--output-last-message is a symlink: $T/c22/result.md" "$T/log/C22.chk" || { echo "stderr lacks: --output-last-message is a symlink"; return 1; }
}
C23() { # the result moved onto the writable root itself
  c_build C23 codex-read || return 1
  sed "s|^'$T/res/result.md'\$|'$T/res/work'|" "$T/c/C23.base" >"$T/c/C23.sh"
  c_expect C23 "$T/r" "--output-last-message resolves into the writable root: $T/res/work"
}

# ---- AC 4: self-check and rejected inputs (S1, S2) ----

S1() {
  local rc
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind claude-write --out "$T/s1/run.sh" --worktree "$T/wt" \
    --launch-file "$LF" --add-dir "$T/nope" --host-source "$T/home/src.md") >/dev/null 2>"$T/log/S1.err"
  rc=$?
  [ "$rc" -ne 0 ] || { echo "write exited 0 with a missing --add-dir"; return 1; }
  [ ! -e "$T/s1/run.sh" ] || { echo "OUT was written"; return 1; }
  no_tmp "$T/s1" || { echo "a .launch.* file was left"; return 1; }
}
S2() {
  local rc
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind codex-read --out "$T/s2/run.sh" --worktree "$T/wt" \
    --launch-file "$LF" --result "$T/res/result.md" --host-source "$T/home/src.md") >/dev/null 2>"$T/log/S2.err"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "write exited $rc, not 2"; return 1; }
  [ ! -e "$T/s2/run.sh" ] || { echo "OUT was written"; return 1; }
}
S3() { # write --add-dir for a read kind: exit 2, no script, no tmp
  local rc
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind codex-read --out "$T/s3/run.sh" --worktree "$T/wt" \
    --launch-file "$LF" --result "$T/s3/result.md" --add-dir "$T/brief") >/dev/null 2>"$T/log/S3.err"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "write exited $rc, not 2"; return 1; }
  grep -qF -- "--add-dir is not accepted for codex-read" "$T/log/S3.err" || { echo "stderr lacks: --add-dir is not accepted for codex-read"; return 1; }
  [ ! -e "$T/s3/run.sh" ] && [ ! -e "$T/s3/work" ] || { echo "OUT or work was written"; return 1; }
  no_tmp "$T/s3" || { echo "a .launch.* file was left"; return 1; }
}
S4() { # an existing work/ or work/tmp/ that is not owner-only is refused
  local rc d
  mkdir -m 755 "$T/s4/work" && mkdir -m 755 "$T/s4/work/tmp" || { echo "cannot create $T/s4/work/tmp"; return 1; }
  for d in "$T/s4/work" "$T/s4/work/tmp"; do
    (cd "$T/b" && bash "$LAUNCH_SH" write --kind codex-read --out "$T/s4/run.sh" --worktree "$T/wt" \
      --launch-file "$LF" --result "$T/s4/result.md") >/dev/null 2>"$T/log/S4.err"
    rc=$?
    [ "$rc" -eq 2 ] || { echo "write exited $rc, not 2"; return 1; }
    grep -qF -- "not an owner-only directory: $d" "$T/log/S4.err" || { echo "stderr lacks: not an owner-only directory: $d"; return 1; }
    [ ! -e "$T/s4/run.sh" ] || { echo "OUT was written"; return 1; }
    chmod 700 "$d" || { echo "cannot chmod $d"; return 1; }
  done
}
S5() { # write refuses a result directory at, inside, aliasing, or holding the worktree, both read kinds
  local rc k res msg
  local -a cap
  for k in codex-read codex-read-probe; do
    cap=()
    [ "$k" = codex-read ] || cap=(--capture "$T/cap/S5")
    while IFS='|' read -r res msg; do
      (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$k" --out "$T/s5/run.sh" --worktree "$T/wt" \
        --launch-file "$LF" --result "$res" ${cap[@]+"${cap[@]}"}) >/dev/null 2>"$T/log/S5.err"
      rc=$?
      [ "$rc" -eq 2 ] || { echo "$k --result $res: write exited $rc, not 2"; return 1; }
      grep -qF -- "$msg" "$T/log/S5.err" || { echo "$k --result $res: stderr lacks: $msg"; return 1; }
      ! grep -qF -- --capture "$T/log/S5.err" || { echo "$k --result $res: stopped at --capture"; return 1; }
      [ ! -e "$T/s5/run.sh" ] && [ ! -e "${res%/*}/work" ] || { echo "$k --result $res: OUT or work was written"; return 1; }
    done <<EOF
$T/wt/result.md|result directory $T/wt is inside the worktree $T/wt
$T/wt/s5/result.md|result directory $T/wt/s5 is inside the worktree $T/wt
$T/s5l/result.md|result directory $T/wt is inside the worktree $T/wt
$T/s5l/s5/result.md|result directory $T/wt/s5 is inside the worktree $T/wt
$T/result.md|result directory $T contains the worktree $T/wt
EOF
  done
}
S6() { # write refuses a result directory that is HOME, above HOME, or a symlink to HOME, both read kinds
  local rc k res
  local -a cap
  for k in codex-read codex-read-probe; do
    cap=()
    [ "$k" = codex-read ] || cap=(--capture "$T/cap/S6")
    for res in "$T/s6/h/result.md" "$T/s6/result.md" "$T/s6l/result.md"; do
      (cd "$T/b" && HOME=$T/s6/h bash "$LAUNCH_SH" write --kind "$k" --out "$T/s6o/run.sh" --worktree "$T/wt" \
        --launch-file "$LF" --result "$res" ${cap[@]+"${cap[@]}"}) >/dev/null 2>"$T/log/S6.err"
      rc=$?
      [ "$rc" -eq 2 ] || { echo "$k --result $res: write exited $rc, not 2"; return 1; }
      grep -qF -- "is HOME or an ancestor of it" "$T/log/S6.err" || { echo "$k --result $res: stderr lacks: is HOME or an ancestor of it"; return 1; }
      ! grep -qF -- --capture "$T/log/S6.err" || { echo "$k --result $res: stopped at --capture"; return 1; }
      [ ! -e "$T/s6o/run.sh" ] && [ ! -e "${res%/*}/work" ] || { echo "$k --result $res: OUT or work was written"; return 1; }
      no_tmp "$T/s6o" || { echo "$k --result $res: a .launch.* file was left"; return 1; }
    done
  done
}
S7() { # write refuses a shared (1777) result directory or a symlink to it, both read kinds
  local rc k res
  local -a cap
  for k in codex-read codex-read-probe; do
    cap=()
    [ "$k" = codex-read ] || cap=(--capture "$T/cap/S7")
    for res in "$T/s7/result.md" "$T/s7l/result.md"; do
      (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$k" --out "$T/s7o/run.sh" --worktree "$T/wt" \
        --launch-file "$LF" --result "$res" ${cap[@]+"${cap[@]}"}) >/dev/null 2>"$T/log/S7.err"
      rc=$?
      [ "$rc" -eq 2 ] || { echo "$k --result $res: write exited $rc, not 2"; return 1; }
      grep -qF -- "result directory $T/s7 is writable by group or others" "$T/log/S7.err" \
        || { echo "$k --result $res: stderr lacks: result directory $T/s7 is writable by group or others"; return 1; }
      ! grep -qF -- --capture "$T/log/S7.err" || { echo "$k --result $res: stopped at --capture"; return 1; }
      [ ! -e "$T/s7o/run.sh" ] && [ ! -e "$T/s7/work" ] || { echo "$k --result $res: OUT or work was written"; return 1; }
      no_tmp "$T/s7o" || { echo "$k --result $res: a .launch.* file was left"; return 1; }
    done
  done
}
S8() { # write refuses --result /tmp/NAME.md and leaves /tmp/work as it was, both read kinds
  # The worktree and HOME are this script's directory, so that neither the worktree
  # nor the HOME rule refuses /tmp first; the fixtures under $T may sit beneath /tmp.
  local rc k before after
  local -a cap
  case $(realpath "$here")/ in "$(realpath /tmp)"/*) echo "this case needs the repository outside /tmp: $here"; return 1 ;; esac
  for k in codex-read codex-read-probe; do
    before=0 after=0 cap=()
    [ "$k" = codex-read ] || cap=(--capture "$T/cap/S8")
    [ ! -e /tmp/work ] || before=1
    (cd "$T/b" && HOME=$here bash "$LAUNCH_SH" write --kind "$k" --out "$T/s8/run.sh" --worktree "$here" \
      --launch-file "$LF" --result "/tmp/launch-test-$$.md" ${cap[@]+"${cap[@]}"}) >/dev/null 2>"$T/log/S8.err"
    rc=$?
    [ ! -e /tmp/work ] || after=1
    [ "$rc" -eq 2 ] || { echo "$k: write exited $rc, not 2"; return 1; }
    grep -qF -- "is not owned by the current user" "$T/log/S8.err" || { echo "$k: stderr lacks: is not owned by the current user"; return 1; }
    ! grep -qF -- --capture "$T/log/S8.err" || { echo "$k: stopped at --capture"; return 1; }
    [ "$before" = "$after" ] || { echo "$k: /tmp/work was created"; return 1; }
    [ ! -e "$T/s8/run.sh" ] || { echo "$k: OUT was written"; return 1; }
  done
}
S9() { # a private directory beneath a shared (1777) directory still builds and checks, both read kinds
  local rc k
  local -a cap
  for k in codex-read codex-read-probe; do
    cap=()
    [ "$k" = codex-read ] || cap=(--capture "$T/cap/S9")
    (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$k" --out "$T/s9/$k.sh" --worktree "$T/wt" \
      --launch-file "$LF" --result "$T/s9sh/p/result.md" ${cap[@]+"${cap[@]}"}) >/dev/null 2>"$T/log/S9.err"
    rc=$?
    [ "$rc" -eq 0 ] || { echo "$k: write exited $rc: $(first "$T/log/S9.err")"; return 1; }
    [ "$(mode "$T/s9sh/p/work/tmp")" = drwx------ ] || { echo "$k: tmp mode is $(mode "$T/s9sh/p/work/tmp"), not drwx------"; return 1; }
    (cd "$T/r" && bash "$LAUNCH_SH" check "$T/s9/$k.sh" --worktree "$T/wt") 2>"$T/log/S9.chk"
    rc=$?
    [ "$rc" -eq 0 ] || { echo "$k: check exited $rc: $(first "$T/log/S9.chk")"; return 1; }
  done
}
S10() { # write refuses a --result that resolves into the writable root, both read kinds
  local rc k
  local -a cap
  for k in codex-read codex-read-probe; do
    cap=()
    [ "$k" = codex-read ] || cap=(--capture "$T/cap/S10")
    (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$k" --out "$T/s10/$k.sh" --worktree "$T/wt" \
      --launch-file "$LF" --result "$T/s10/work" ${cap[@]+"${cap[@]}"}) >/dev/null 2>"$T/log/S10.err"
    rc=$?
    [ "$rc" -eq 2 ] || { echo "$k: write exited $rc, not 2"; return 1; }
    grep -qF -- "--result resolves into the writable root: $T/s10/work" "$T/log/S10.err" || { echo "$k: stderr lacks: --result resolves into the writable root"; return 1; }
    ! grep -qF -- --capture "$T/log/S10.err" || { echo "$k: stopped at --capture"; return 1; }
    [ ! -e "$T/s10/$k.sh" ] && [ ! -e "$T/s10/work" ] || { echo "$k: OUT or work was written"; return 1; }
  done
}
S11() { # write refuses a --result that is a symlink into the writable root, both read kinds
  local rc k
  local -a cap
  ln -s "$T/s11/work/result.md" "$T/s11/result.md" || { echo "cannot create the result link"; return 1; }
  for k in codex-read codex-read-probe; do
    cap=()
    [ "$k" = codex-read ] || cap=(--capture "$T/cap/S11")
    (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$k" --out "$T/s11/$k.sh" --worktree "$T/wt" \
      --launch-file "$LF" --result "$T/s11/result.md" ${cap[@]+"${cap[@]}"}) >/dev/null 2>"$T/log/S11.err"
    rc=$?
    [ "$rc" -eq 2 ] || { echo "$k: write exited $rc, not 2"; return 1; }
    grep -qF -- "--result is a symlink: $T/s11/result.md" "$T/log/S11.err" || { echo "$k: stderr lacks: --result is a symlink"; return 1; }
    ! grep -qF -- --capture "$T/log/S11.err" || { echo "$k: stopped at --capture"; return 1; }
    [ ! -e "$T/s11/$k.sh" ] && [ ! -e "$T/s11/work" ] || { echo "$k: OUT or work was written"; return 1; }
  done
}

# ---- F5: destination (O1-O3) ----

o_write() { # NAME OUT
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind claude-read --out "$2" --worktree "$T/wt" \
    --launch-file "$LF" --add-dir "$T/res") >/dev/null 2>"$T/log/$1.err"
}
O1() {
  local rc
  o_write O1 "$T/outdir"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "write exited $rc, not 2"; return 1; }
  grep -qF -- "--out is not a regular file path: $T/outdir" "$T/log/O1.err" || { echo "stderr lacks: --out is not a regular file path"; return 1; }
  [ -z "$(ls -A "$T/outdir")" ] || { echo "the OUT directory is not empty"; return 1; }
  no_tmp "$T" && no_tmp "$T/outdir" || { echo "a .launch.* file was left"; return 1; }
}
O2() {
  local rc
  printf 'old\n' >"$T/o2/run.sh" && chmod 600 "$T/o2/run.sh"
  o_write O2 "$T/o2/run.sh"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "write exited $rc: $(first "$T/log/O2.err")"; return 1; }
  [ "$(first "$T/o2/run.sh")" = '#!/usr/bin/env bash' ] || { echo "OUT was not replaced"; return 1; }
  [ "$(mode "$T/o2/run.sh")" = -rwx------ ] || { echo "mode is $(mode "$T/o2/run.sh")"; return 1; }
  bash "$LAUNCH_SH" check "$T/o2/run.sh" 2>"$T/log/O2.chk" || { echo "check exited non-zero"; return 1; }
  no_tmp "$T/o2" || { echo "a .launch.* file was left"; return 1; }
}
O3() {
  local rc
  printf 'target\n' >"$T/o3/target" && ln -s "$T/o3/target" "$T/o3/run.sh"
  o_write O3 "$T/o3/run.sh"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "write exited $rc, not 2"; return 1; }
  [ -L "$T/o3/run.sh" ] && [ "$(readlink "$T/o3/run.sh")" = "$T/o3/target" ] || { echo "the link changed"; return 1; }
  [ "$(cat "$T/o3/target")" = target ] || { echo "the link target changed"; return 1; }
  no_tmp "$T/o3" || { echo "a .launch.* file was left"; return 1; }
}

# ---- #256: the probe capture (PC1-PC7) ----

P=$$
ESC_SECRET='a\"b\\c-'$P # MY_SECRET's value, JSON-escaped
PC_CREDS=(TESTTOKEN="tok-$P-secretvalue" GH_TOKEN=Zq7 DBCRED="dbc-$P-x" MY_SECRET="a\"b\\c-$P" NUM_TOKEN="4242$P")
printf 'Read %s~/plain.md%s.\n' "$bt" "$bt" >"$T/home/pc2src.md"
PC_SHELLS='bash sh'
if command -v zsh >/dev/null 2>&1; then PC_SHELLS='bash sh zsh'; fi

# PC1 streams: a passing Claude write probe (AC 4) and a Codex read probe's lifecycle.
cat >"$T/pc/claude.stdout" <<'EOF'
{"type":"system","subtype":"init","session_id":"s1","model":"m1","cwd":"/somewhere","tools":["Bash","Read"]}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"tu1","name":"Bash","input":{"command":"git add --refresh -- .","description":"Refresh the index"}}]},"session_id":"s1"}
{"type":"user","message":{"role":"user","content":[{"tool_use_id":"tu1","type":"tool_result","content":"","is_error":false}]},"session_id":"s1"}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"CAPSTAN_PROBE_OK"}]},"session_id":"s1"}
{"type":"result","subtype":"success","is_error":false,"num_turns":2,"result":"CAPSTAN_PROBE_OK","session_id":"s1","permission_denials":[],"usage":{"input_tokens":10,"output_tokens":4}}
EOF
printf 'warning: a plain diagnostic\n' >"$T/pc/claude.stderr"
cat >"$T/exp/PC1-claude-write-probe.stdout" <<'EOF'
{"type":"system","subtype":"init","session_id":"s1","model":"m1","cwd":"[removed]","tools":["[removed]","[removed]"]}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"tu1","name":"Bash","input":{"command":"git add --refresh -- .","description":"[removed]"}}]},"session_id":"s1"}
{"type":"user","message":{"role":"user","content":[{"tool_use_id":"tu1","type":"tool_result","content":"[removed]","is_error":false}]},"session_id":"s1"}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"[removed]"}]},"session_id":"s1"}
{"type":"result","subtype":"success","is_error":false,"num_turns":2,"result":"CAPSTAN_PROBE_OK","session_id":"s1","permission_denials":[],"usage":{"input_tokens":10,"output_tokens":4}}
EOF
printf '[removed]\n' >"$T/exp/PC1-claude-write-probe.stderr"
cat >"$T/pc/codex.stdout" <<'EOF'
{"type":"thread.started","thread_id":"th-1"}
{"type":"turn.started"}
{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"CAPSTAN_PROBE_OK"}}
{"type":"turn.completed","usage":{"input_tokens":5,"cached_input_tokens":0,"output_tokens":2}}
EOF
printf 'warning: a plain diagnostic\n' >"$T/pc/codex.stderr"
cp "$T/pc/codex.stdout" "$T/exp/PC1-codex-read-probe.stdout" && cp "$T/pc/codex.stderr" "$T/exp/PC1-codex-read-probe.stderr" \
  || setup "cannot write the PC1 goldens"

# PC2: a Claude stream with a granted Read, arguments under an unlisted field, chatter,
# and each credential raw, JSON-escaped, and as a bare number; stderr holds host text.
cat >"$T/pc/pc2.stdout" <<EOF
{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"tu1","name":"Bash","input":{"command":"git add --refresh -- .","description":"Refresh the index"}}]}}
{"type":"user","message":{"role":"user","content":[{"tool_use_id":"tu1","type":"tool_result","content":"","is_error":false}]}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"tu2","name":"Read","input":{"file_path":"$T/home/plain.md"}}]}}
{"type":"user","message":{"role":"user","content":[{"tool_use_id":"tu2","type":"tool_result","content":[{"type":"text","text":"HOSTTEXT-$P \"quoted\" line"},{"type":"text","text":"tail","nested":[1,["HOSTTEXT-$P"]]}],"is_error":false}]},"tool_use_result":{"type":"text","file":{"filePath":"$T/home/plain.md","content":"HOSTTEXT-$P \"quoted\"","numLines":[1,[2,3]]}}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"tu3","name":"Probe","params":{"note":"ARGTEXT-$P","command":"ARGCMD-$P"}}]}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"CHATTER-$P tok-$P-secretvalue"}]}}
{"type":"system","subtype":"note","id":"tok-$P-secretvalue","name":"x Zq7 y","model":"dbc-$P-x","session_id":"$ESC_SECRET","uuid":"pre-4242$P","n":4242$P,"list":[4242$P, 7]}
{"type":"result","subtype":"success","is_error":false,"num_turns":3,"result":"CAPSTAN_PROBE_OK","permission_denials":[],"usage":{"input_tokens":12,"output_tokens":3}}
EOF
cat >"$T/pc/pc2.stderr" <<EOF
{"type":"user","message":{"content":[{"tool_use_id":"tu2","type":"tool_result","content":"HOSTTEXT-$P","is_error":false}]}}
diag HOSTTEXT-$P TESTTOKEN=tok-$P-secretvalue
{"type":"system","subtype":"warn","model":"tok-$P-secretvalue Zq7 dbc-$P-x $ESC_SECRET","n":4242$P}
EOF
cat >"$T/exp/PC2.stdout" <<EOF
{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"tu1","name":"Bash","input":{"command":"git add --refresh -- .","description":"[removed]"}}]}}
{"type":"user","message":{"role":"user","content":[{"tool_use_id":"tu1","type":"tool_result","content":"[removed]","is_error":false}]}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"tu2","name":"Read","input":{"file_path":"$T/home/plain.md"}}]}}
{"type":"user","message":{"role":"user","content":[{"tool_use_id":"tu2","type":"tool_result","content":"[host file content removed]","is_error":false}]},"tool_use_result":"[host file content removed]"}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"tu3","name":"Probe","params":{"note":"[removed]","command":"[removed]"}}]}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"[removed]"}]}}
{"type":"system","subtype":"note","id":"[redacted]","name":"x [redacted] y","model":"[redacted]","session_id":"[redacted]","uuid":"pre-[redacted]","n":"[redacted]","list":["[redacted]", 7]}
{"type":"result","subtype":"success","is_error":false,"num_turns":3,"result":"CAPSTAN_PROBE_OK","permission_denials":[],"usage":{"input_tokens":12,"output_tokens":3}}
EOF
cat >"$T/exp/PC2.stderr" <<'EOF'
{"type":"user","message":{"content":[{"tool_use_id":"tu2","type":"tool_result","content":"[removed]","is_error":false}]}}
[removed]
{"type":"system","subtype":"warn","model":"[redacted] [redacted] [redacted] [redacted]","n":"[redacted]"}
EOF

# PC3: a Codex stream with the same credentials; stderr is a plain line.
cat >"$T/pc/pc3.stdout" <<EOF
{"type":"thread.started","thread_id":"th-1"}
{"type":"turn.started"}
{"type":"item.completed","item":{"id":"item_1","type":"command_execution","command":"bash -lc 'git status --short'","aggregated_output":"tok-$P-secretvalue Zq7 dbc-$P-x $ESC_SECRET","exit_code":0,"status":"completed"}}
{"type":"turn.completed","usage":{"input_tokens":4242$P,"cached_input_tokens":0,"output_tokens":2}}
EOF
printf 'warning: TESTTOKEN=tok-%s-secretvalue in plain text\n' "$P" >"$T/pc/pc3.stderr"
cat >"$T/exp/PC3.stdout" <<'EOF'
{"type":"thread.started","thread_id":"th-1"}
{"type":"turn.started"}
{"type":"item.completed","item":{"id":"item_1","type":"command_execution","command":"bash -lc 'git status --short'","aggregated_output":"[redacted] [redacted] [redacted] [redacted]","exit_code":0,"status":"completed"}}
{"type":"turn.completed","usage":{"input_tokens":"[redacted]","cached_input_tokens":0,"output_tokens":2}}
EOF
printf 'warning: TESTTOKEN=[redacted] in plain text\n' >"$T/exp/PC3.stderr"

pc_build() { # NAME KIND CAPTURE_DIR [ARGS...]: write $T/pc/NAME.sh
  local name=$1 kind=$2 rc
  local -a args=(--worktree "$T/wt" --launch-file "$LF" --capture "$3")
  shift 3
  case $kind in claude-*) args+=(--host-source "$T/home/pc2src.md") ;; *) args+=(--result "$T/pc1res/result.md") ;; esac
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$kind" --out "$T/pc/$name.sh" "${args[@]}" "$@") >/dev/null 2>"$T/log/$name.build"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "$name: write exited $rc: $(first "$T/log/$name.build")"; return 1; }
}
pc_run() { # SHELL RUN_SCRIPT [NAME=VALUE...]: start RUN_SCRIPT as a command from SHELL, in a clean environment
  local sh=$1 rs=$2
  shift 2
  (cd "$T/r" && env -i PATH="$T/pbin:$PATH" HOME="$HOME" "$@" "$sh" -c '"$1"' _ "$rs") >/dev/null 2>&1
}
pc_golden() { # NAME CAPTURE_DIR: both captured streams equal the goldens $T/exp/NAME.stdout and .stderr
  local f
  for f in stdout stderr; do
    diff "$T/exp/$1.$f" "$2/$f" >"$T/log/$1.diff" \
      || { echo "capture differs from golden: $f: $(grep '^[<>]' "$T/log/$1.diff" | head -n 1)"; return 1; }
  done
}
pc_leak() { # CAPTURE_DIR [TEXT...]: no credential value and no TEXT appears under CAPTURE_DIR
  local cap=$1 x rc
  local -a e=()
  shift
  for x in "$@" "tok-$P-secretvalue" Zq7 "dbc-$P-x" "$ESC_SECRET" "a\"b\\c-$P" "4242$P"; do e+=(-e "$x"); done
  grep -rF "${e[@]}" "$cap" >/dev/null
  rc=$?
  case $rc in
    1) ;;
    0) echo "secret or host text in capture: $(grep -rhoF "${e[@]}" "$cap" | head -n 1)"; return 1 ;;
    *) echo "leak search error: grep exited $rc"; return 1 ;;
  esac
}

PC1() { # both probe kinds x exits 0 and 3 x bash, sh and zsh: same exit, same exit file, same captures
  local k sh rc got cap f why
  for k in claude-write-probe codex-read-probe; do
    cap=$T/pc/cap1-$k
    pc_build "PC1-$k" "$k" "$cap" || return 1
    for rc in 0 3; do
      for sh in $PC_SHELLS; do
        pc_run "$sh" "$T/pc/PC1-$k.sh" STUB_STREAM="$T/pc/${k%%-*}.stdout" STUB_ERR="$T/pc/${k%%-*}.stderr" STUB_RC=$rc
        got=$?
        [ "$got" -eq "$rc" ] || { echo "$k $sh rc=$rc script exit=$got"; return 1; }
        [ "$(cat "$cap/exit" 2>/dev/null)" = "$rc" ] || { echo "$k $sh rc=$rc exit file=$(cat "$cap/exit" 2>/dev/null)"; return 1; }
        why=$(pc_golden "PC1-$k" "$cap") || { echo "$k $sh rc=$rc: $why"; return 1; }
        for f in exit stderr stdout; do
          [ "$(mode "$cap/$f")" = -rw------- ] || { echo "$k $sh: $f mode is $(mode "$cap/$f")"; return 1; }
        done
        [ "$(ls -A "$cap" | tr '\n' ' ')" = 'exit stderr stdout ' ] || { echo "$k $sh: the capture holds: $(ls -A "$cap" | tr '\n' ' ')"; return 1; }
      done
    done
  done
}
PC2() { # Claude: host-grant and credential redaction on both streams, exact goldens, no leak
  local cap=$T/pc/cap2 rc
  pc_build PC2 claude-write-probe "$cap" --redact-env DBCRED || return 1
  pc_run bash "$T/pc/PC2.sh" STUB_STREAM="$T/pc/pc2.stdout" STUB_ERR="$T/pc/pc2.stderr" "${PC_CREDS[@]}"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "run script exited $rc"; return 1; }
  pc_golden PC2 "$cap" || return 1
  pc_leak "$cap" "HOSTTEXT-$P" "CHATTER-$P" "ARGTEXT-$P" "ARGCMD-$P"
}
PC3() { # Codex: credential redaction on both streams keeps the lifecycle, command and exit code
  local cap=$T/pc/cap3 rc
  pc_build PC3 codex-read-probe "$cap" --redact-env DBCRED || return 1
  pc_run bash "$T/pc/PC3.sh" STUB_STREAM="$T/pc/pc3.stdout" STUB_ERR="$T/pc/pc3.stderr" "${PC_CREDS[@]}"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "run script exited $rc"; return 1; }
  pc_golden PC3 "$cap" || return 1
  pc_leak "$cap"
}
PC4() { # check accepts both generated probe scripts and rejects each tampered copy
  local n rc
  for n in PC4c:claude-write-probe PC4x:codex-read-probe; do
    c_build "${n%%:*}" "${n#*:}" || return 1
    (cd "$T/r" && bash "$LAUNCH_SH" check "$T/c/${n%%:*}.base" --worktree "$T/wt") 2>"$T/log/${n%%:*}.chk"
    rc=$?
    [ "$rc" -eq 0 ] || { echo "check rejected the generated ${n#*:} script: $(first "$T/log/${n%%:*}.chk")"; return 1; }
  done
  for n in 1 2 3 4 6 7 8; do c_build "PC4-$n" claude-write-probe || return 1; done
  c_build PC4-5 claude-write || return 1
  sed 's#} 3>&1 | awk -v names="$redact_env" "$red" >"$cap/stdout"$#} 3>\&1 >"$cap/stdout"#' "$T/c/PC4-1.base" >"$T/c/PC4-1.sh"
  pc4 1 "capture block differs from the claude-write-probe block" || return 1
  mkdir -m 700 "$T/wt/pc4cap" && sed "s|^cap='.*'\$|cap='$T/wt/pc4cap'|" "$T/c/PC4-2.base" >"$T/c/PC4-2.sh"
  pc4 2 "cap is inside the worktree: $T/wt/pc4cap" || return 1
  mkdir -m 755 "$T/pc/m755" && sed "s|^cap='.*'\$|cap='$T/pc/m755'|" "$T/c/PC4-3.base" >"$T/c/PC4-3.sh"
  pc4 3 "cap is not an owner-only directory: $T/pc/m755" || return 1
  { sed '/^redact_env=/q' "$T/c/PC4-4.base"; printf '%s\n' 'exec "${argv[@]}" <"$lf"'; } >"$T/c/PC4-4.sh"
  pc4 4 "exec line in a claude-write-probe run script" || return 1
  { cat "$T/c/PC4-5.base"; sed -n '/^umask 077$/,$p' "$T/c/PC4-1.base"; } >"$T/c/PC4-5.sh"
  pc4 5 "text after the exec line of a claude-write run script" || return 1
  sed 's/"\[redacted\]"/"[redactex]"/' "$T/c/PC4-6.base" >"$T/c/PC4-6.sh"
  pc4 6 "capture block differs from the claude-write-probe block" || return 1
  : >"$T/cap/PC4-7/stdout" && sed "s|^lf='.*'\$|lf='$T/cap/PC4-7/stdout'|" "$T/c/PC4-7.base" >"$T/c/PC4-7.sh"
  pc4 7 "cap $T/cap/PC4-7/stdout is the launch file" || return 1
  sed "s|^redact_env='.*'\$|redact_env='A-B'|" "$T/c/PC4-8.base" >"$T/c/PC4-8.sh"
  pc4 8 "redact_env is not a list of environment variable names: A-B"
}
pc4() { # N MESSAGE: check rejects tampered copy N with MESSAGE
  local why
  why=$(c_expect "PC4-$1" "$T/r" "$2") || { echo "check accepted tampered copy $1 or named another defect: $why"; return 1; }
}
pc5() { # LABEL MESSAGE OUT ARGS...: write exits 2 with MESSAGE, writes no OUT, and leaves no .launch.* file
  local label=$1 msg=$2 out=$3 rc
  shift 3
  (cd "$T/b" && bash "$LAUNCH_SH" write --out "$out" --worktree "$T/wt" "$@") >/dev/null 2>"$T/log/PC5.err"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "($label) write exited $rc, not 2: $(first "$T/log/PC5.err")"; return 1; }
  grep -qF -- "launch.sh: $msg" "$T/log/PC5.err" || { echo "($label) stderr lacks: $msg"; return 1; }
  [ ! -e "$out" ] || { echo "($label) OUT was written"; return 1; }
  no_tmp "${out%/*}" || { echo "($label) a .launch.* file was left"; return 1; }
}
PC5() { # write refuses each bad --capture or --redact-env input; an owner-only capture beside the brief is accepted
  local o=$T/pc5/run.sh rc
  local -a cl=(--kind claude-write-probe --launch-file "$LF" --host-source "$T/home/src.md")
  local -a cx=(--kind codex-read-probe --launch-file "$LF" --result "$T/pc5res/result.md")
  mkdir -m 700 "$T/pc5/ok" "$T/pc5/g" "$T/pc5/h" "$T/pc5/i" && mkdir -m 1777 "$T/pc5/open" && : >"$T/pc5/g/stdout" \
    || { echo "cannot create the PC5 fixtures"; return 1; }
  pc5 a "--capture is required for claude-write-probe" "$o" "${cl[@]}" || return 1
  pc5 b "--capture is only for probe kinds, not claude-write" "$o" --kind claude-write --launch-file "$LF" \
    --host-source "$T/home/src.md" --capture "$T/pc5/ok" || return 1
  pc5 c "--redact-env is only for probe kinds, not codex-read" "$o" --kind codex-read --launch-file "$LF" \
    --result "$T/pc5res/result.md" --redact-env DBCRED || return 1
  pc5 d "--capture is inside the worktree: $T/wt/pc5cap" "$o" "${cl[@]}" --capture "$T/wt/pc5cap" || return 1
  [ ! -e "$T/wt/pc5cap" ] || { echo "(d) the capture directory was created inside the worktree"; return 1; }
  pc5 e "--capture is not an owner-only directory: $T/pc5/open" "$o" "${cl[@]}" --capture "$T/pc5/open" || return 1
  pc5 f "--capture resolves into the writable root: $T/pc5res/work/c" "$o" "${cx[@]}" --capture "$T/pc5res/work/c" || return 1
  pc5 g "--capture $T/pc5/g/stdout is the launch file" "$o" --kind claude-write-probe --launch-file "$T/pc5/g/stdout" \
    --host-source "$T/home/src.md" --capture "$T/pc5/g" || return 1
  pc5 h "--capture $T/pc5/h/stderr is the run script" "$T/pc5/h/stderr" "${cl[@]}" --capture "$T/pc5/h" || return 1
  pc5 i "--capture $T/pc5/i/exit is the result" "$o" --kind codex-read-probe --launch-file "$LF" \
    --result "$T/pc5/i/exit" --capture "$T/pc5/i" || return 1
  pc5 j "--redact-env must be an environment variable name: A-B" "$o" "${cl[@]}" --capture "$T/pc5/ok" --redact-env A-B || return 1
  (cd "$T/b" && bash "$LAUNCH_SH" write --out "$T/pc5/ok.sh" --worktree "$T/wt" "${cl[@]}" --capture "$T/pc5/ok") \
    >/dev/null 2>"$T/log/PC5.err"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "(accepted) write exited $rc: $(first "$T/log/PC5.err")"; return 1; }
}
PC6() { # the harness streams reach the redactors as pipes, and no raw text is on disk during the run
  local k cap rc
  for k in claude-write-probe codex-read-probe; do
    cap=$T/pc/cap6-$k
    rm -f -- "$T/log/PC6-$k.fd" "$T/log/PC6-$k.scan"
    pc_build "PC6-$k" "$k" "$cap" || return 1
    pc_run bash "$T/pc/PC6-$k.sh" STUB_STREAM="$T/pc/${k%%-*}.stdout" STUB_ERR="$T/pc/${k%%-*}.stderr" STUB_PROBE=1 \
      STUB_CAP="$cap" STUB_MARK="tok-$P-secretvalue" TESTTOKEN="tok-$P-secretvalue" STUB_FD="$T/log/PC6-$k.fd" STUB_SCAN="$T/log/PC6-$k.scan"
    rc=$?
    [ "$rc" -eq 0 ] || { echo "$k: run script exited $rc"; return 1; }
    [ "$(sed -n 1p "$T/log/PC6-$k.fd" 2>/dev/null)" = out=pipe ] || { echo "$k: harness stdout is not a pipe"; return 1; }
    [ "$(sed -n 2p "$T/log/PC6-$k.fd" 2>/dev/null)" = err=pipe ] || { echo "$k: harness stderr is not a pipe"; return 1; }
    case $(cat "$T/log/PC6-$k.scan" 2>/dev/null) in
      1) ;;
      0) echo "$k: raw marker on disk during run"; return 1 ;;
      *) echo "$k: the mid-run scan did not run or failed"; return 1 ;;
    esac
  done
}
PC7() { # a failed redaction stage keeps the harness status, writes capture-error, and exits 70
  local cap=$T/pc/cap7 n rc want
  pc_build PC7 claude-write-probe "$cap" || return 1
  for n in 1 2; do
    (cd "$T/r" && env -i PATH="$T/fbin:$T/pbin:$PATH" HOME="$HOME" STUB_STREAM="$T/pc/claude.stdout" \
      STUB_ERR="$T/pc/claude.stderr" STUB_AWK_FAIL=$n bash -c '"$1"' _ "$T/pc/PC7.sh") >/dev/null 2>&1
    rc=$?
    [ "$rc" -eq 70 ] || { echo "stage $n failure: script exit $rc, not 70"; return 1; }
    [ "$(cat "$cap/exit" 2>/dev/null)" = 0 ] || { echo "stage $n failure: exit file is $(cat "$cap/exit" 2>/dev/null)"; return 1; }
    case $n in 1) want='harness-side=72 ' ;; *) want='stdout-redactor=9' ;; esac
    grep -qF -- "$want" "$cap/capture-error" 2>/dev/null || { echo "stage $n failure not recorded"; return 1; }
    [ "$(mode "$cap/capture-error")" = -rw------- ] || { echo "stage $n: capture-error mode is $(mode "$cap/capture-error")"; return 1; }
  done
}

# PC8: Claude tool arguments under kept metadata names (name, id, type), of every
# value type, nested, and in containers named input, tool_input and wire_tool_inputs.
cat >"$T/pc/pc8.stdout" <<EOF
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"tu8","name":"Probe","input":{"name":"ARGNAME-$P","id":"ARGID-$P","type":"ARGTYPE-$P","count":7$P,"flag":true,"none":null,"nested":{"name":"DEEP-$P","list":[1,"x"]},"file_path":"/f.md"}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"tu9","name":"Bash","input":{"command":"git add --refresh -- .","timeout":1200$P,"run_in_background":false}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"tu10","name":"Read","input":{"file_path":"/h/x.md","limit":4$P}}]}}
{"type":"system","subtype":"hook","tool_name":"Probe","tool_input":{"name":"HOOKNAME-$P","n":5$P},"wire_tool_inputs":[{"id":"WIRE-$P"}]}
{"type":"result","subtype":"success","is_error":false,"result":"CAPSTAN_PROBE_OK","permission_denials":[{"tool_name":"Bash","tool_use_id":"tu11","tool_input":{"command":"git push","timeout":9}}]}
EOF
: >"$T/pc/pc8.stderr"
cat >"$T/exp/PC8.stdout" <<'EOF'
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"tu8","name":"Probe","input":{"name":"[removed]","id":"[removed]","type":"[removed]","count":"[removed]","flag":"[removed]","none":"[removed]","nested":{"name":"[removed]","list":["[removed]","[removed]"]},"file_path":"/f.md"}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"tu9","name":"Bash","input":{"command":"git add --refresh -- .","timeout":"[removed]","run_in_background":"[removed]"}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"tu10","name":"Read","input":{"file_path":"/h/x.md","limit":"[removed]"}}]}}
{"type":"system","subtype":"hook","tool_name":"Probe","tool_input":{"name":"[removed]","n":"[removed]"},"wire_tool_inputs":[{"id":"[removed]"}]}
{"type":"result","subtype":"success","is_error":false,"result":"CAPSTAN_PROBE_OK","permission_denials":[{"tool_name":"Bash","tool_use_id":"tu11","tool_input":{"command":"git push","timeout":"[removed]"}}]}
EOF
: >"$T/exp/PC8.stderr"

# PC9: a one-character credential and one inside a kept value, against JSON escapes;
# @u stands for the JSON escape backslash-u.
sed 's/@u/\\u/g' >"$T/pc/pc9.stdout" <<'EOF'
{"type":"thread.started","thread_id":"th-1"}
{"type":"item.completed","item":{"id":"i1","type":"agent_message","text":"line1\nline2 \"q\" \\n @u006e@u0041 \/"}}
{"type":"item.completed","item":{"id":"i2","type":"command_execution","command":"git add --refresh -- .","exit_code":0}}
EOF
sed 's/@u/\\u/g' >"$T/pc/pc9.stderr" <<'EOF'
{"type":"error","message":"a\\nb @u006e"}
EOF
sed 's/@u/\\u/g' >"$T/exp/PC9.stdout" <<'EOF'
{"type":"thread.started","thread_id":"th-1"}
{"type":"item.completed","item":{"id":"i1","type":"age[redacted]t_message","text":"li[redacted]e1\nli[redacted]e2 \"q\" \\[redacted] [redacted]@u0041 \/"}}
{"type":"item.completed","item":{"id":"i2","type":"com[redacted]utio[redacted]","comma[redacted]d":"git add --refresh -- .","exit_code":0}}
EOF
printf '%s\n' '{"type":"error","message":"a\\[redacted]b [redacted]"}' >"$T/exp/PC9.stderr"

PC8() { # Claude: every tool argument is removed whatever its name or value type, except a Bash command and a file_path
  local cap=$T/pc/cap8 rc
  pc_build PC8 claude-write-probe "$cap" || return 1
  pc_run bash "$T/pc/PC8.sh" STUB_STREAM="$T/pc/pc8.stdout" STUB_ERR="$T/pc/pc8.stderr"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "run script exited $rc"; return 1; }
  pc_golden PC8 "$cap" || return 1
  pc_leak "$cap" "ARGNAME-$P" "ARGID-$P" "ARGTYPE-$P" "DEEP-$P" "HOOKNAME-$P" "WIRE-$P" "7$P" "1200$P" "4$P" "5$P"
}
PC9() { # Codex: short and embedded credentials are removed and every object line stays the same valid JSON
  local cap=$T/pc/cap9 rc
  pc_build PC9 codex-read-probe "$cap" --redact-env DBCRED || return 1
  pc_run bash "$T/pc/PC9.sh" STUB_STREAM="$T/pc/pc9.stdout" STUB_ERR="$T/pc/pc9.stderr" TESTTOKEN=n DBCRED=mand_exec
  rc=$?
  [ "$rc" -eq 0 ] || { echo "run script exited $rc"; return 1; }
  pc_golden PC9 "$cap"
}

case $PC_SHELLS in *zsh*) ;; *) echo "skip PC1-zsh: zsh not on PATH" ;; esac
for c in K1 K2 K3 K4 K5 K6 K7 W1 P1 P2 G1 G2 G3 G4 G5 G6 G7 G8 G9 C1 C2 C3 C3b C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 \
  C14 C15 C16 C17 C18 C19 C20 C21 C22 C23 S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 O1 O2 O3 PC1 PC2 PC3 PC4 PC5 PC6 PC7 PC8 PC9; do
  t "$c" "$c"
done
[ "$fails" -eq 0 ] || exit 1
echo PASS
