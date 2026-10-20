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
  "$T/cap" "$T/w1cap" "$T/pbin" "$T/fbin" "$T/pc" "$T/pc1res" "$T/pc5" "$T/pc5res" "$T/ev" "$T/ts" "$T/ts/res" "$T/th2" \
  "$T/y1py" "$T/ybin" "$T/y1/res" "$T/y2/res" "$T/pk" "$T/pkr" "$T/ct" \
  || setup "cannot create fixture directories"
chmod 1777 "$T/s7" "$T/c19" "$T/s9sh" || setup "cannot chmod the shared fixture directories"
# A private result directory beneath a shared temp-style directory (S9).
mkdir -m 700 "$T/s9sh/p" || setup "cannot create the private fixture directory"
ln -s "$T/wt" "$T/s5l" && ln -s "$T/s6/h" "$T/s6l" && ln -s "$T/c16wt" "$T/c16l" && ln -s "$T/c17/h" "$T/c17l" \
  && ln -s "$T/s7" "$T/s7l" && ln -s "$T/c19" "$T/c19l" || setup "cannot create fixture links"

LF=$T/brief/launch.md
printf 'launch prompt %s.%s\n' "$$" "$RANDOM" >"$LF" || setup "cannot write the launch file"
LAUNCH_CONTENT=$(cat "$LF")
: >"$T/res/r.md" || setup "cannot write fixtures"

# Echo stubs: print cwd, TMPDIR, TMPPREFIX when set, argv and stdin; a run script captures their
# stdout, so with STUB_LOG set they also append the same lines to that file.
for b in claude codex; do
  cat >"$T/bin/$b" <<'EOF' || setup "cannot write stub $b"
#!/usr/bin/env bash
out=$(echo "cwd=$PWD"; echo "tmpdir=${TMPDIR-}"; [ -z "${TMPPREFIX+x}" ] || echo "tmpprefix=$TMPPREFIX"; for a in "$@"; do printf 'arg=%s\n' "$a"; done; echo "stdin=$(cat)")
printf '%s\n' "$out"
[ -z "${STUB_LOG-}" ] || printf '%s\n' "$out" >>"$STUB_LOG"
EOF
  chmod 755 "$T/bin/$b" || setup "cannot chmod stub $b"
done

# Policy stub for Y1, a stand-in for codex exec at the CLI boundary: it applies
# the emitted shell_environment_policy.set.PATH to one worker command. The fake
# python3 is what that PATH's python link must reach.
cat >"$T/ybin/codex" <<'EOF' || setup "cannot write the policy stub"
#!/usr/bin/env bash
# Stand-in for codex exec: apply the emitted shell_environment_policy.set.PATH to one worker command.
cat >/dev/null
p=
for a in "$@"; do case $a in shell_environment_policy.set.PATH=*) p=${a#shell_environment_policy.set.PATH=} ;; esac; done
p=${p#\"} p=${p%\"}
o=$(env -i PATH="${p:-/nonexistent}" python -c 'print(1)' 2>&1); rc=$?
printf 'policy=%s\npy_rc=%s\npy_out=%s\n' "${p:-none}" "$rc" "$o"
EOF
printf '#!/bin/sh\necho fake-python3 "$@"\n' >"$T/y1py/python3" \
  && chmod 755 "$T/ybin/codex" "$T/y1py/python3" || setup "cannot write the Y1 fixtures"

# Stream stubs for the capture (PC1-PC9, TS1-TS5, TC3, TC5, TH1, TH2): read stdin,
# print STUB_STREAM on stdout, or run the bash file STUB_RUN in its place, print
# STUB_ERR on stderr, and exit STUB_RC. With STUB_PROBE set they first record
# whether both streams are pipes (STUB_FD), print STUB_MARK on both, wait, and
# record the status of a search for it under STUB_CAP (STUB_SCAN).
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
if [ -n "${STUB_RUN-}" ]; then . "$STUB_RUN"; else cat -- "$STUB_STREAM"; fi
cat -- "${STUB_ERR:-/dev/null}" >&2
exit "${STUB_RC:-0}"
EOF
  chmod 755 "$T/pbin/$b" || setup "cannot chmod stream stub $b"
done
# A failing awk for PC7 and TC3, after draining stdin: STUB_AWK_FAIL=1 fails the
# stage that writes the capture's stderr file, 2 the stdout redactor, whose
# stdout is a pipe, and 3 the tool-call stage, which appends to events.jsonl.
REAL_AWK=$(command -v awk) || setup "no awk on PATH"
cat >"$T/fbin/awk" <<EOF || setup "cannot write the awk wrapper"
#!/usr/bin/env bash
case \${STUB_AWK_FAIL-}:\$(readlink /proc/\$\$/fd/1) in
  1:*/stderr | 2:pipe:* | 3:*/events.jsonl) cat >/dev/null; exit 9 ;;
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
# The tool-call event flags every kind takes; cases that read events use their own file.
EV=(--events "$T/ev/events.jsonl" --delivery 'o/r#1' --station implementing --attempt 1)

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
arg=Bash(time *)
arg=Bash(nice *)
arg=Bash(timeout *)
arg=Bash(nohup *)
stdin=$LAUNCH_CONTENT
EOF

cat >"$T/exp/K2" <<EOF
cwd=$T/wt
tmpdir=$T/ambient
arg=-p
arg=--permission-mode
arg=manual
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
arg=Bash(time *)
arg=Bash(nice *)
arg=Bash(timeout *)
arg=Bash(nohup *)
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
arg=Bash(time *)
arg=Bash(nice *)
arg=Bash(timeout *)
arg=Bash(nohup *)
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
tmpprefix=$T/res/work/tmp/zsh
arg=exec
arg=-C
arg=$T/res/work
arg=-s
arg=workspace-write
arg=--skip-git-repo-check
arg=-c
arg=sandbox_workspace_write.exclude_slash_tmp=true
arg=-c
arg=shell_environment_policy.set.PATH="$T/res/bin:$PATH"
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
  local name=$1 kind=$2 exp=$3 out=$T/k/$1.sh rc got=$T/cap/$1/stdout
  shift 3
  # Every run script captures its stdout; under a host grant the redactor removes
  # the stub's plain lines, so those kinds read the argv from the stub's log.
  case $kind in claude-write*) got=$T/log/$name.argv ;; esac
  rm -f -- "$T/log/$name.argv"
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$kind" --out "$out" "${COMMON[@]}" "$@" --capture "$T/cap/$name" "${EV[@]}") \
    >"$T/log/$name.out" 2>"$T/log/$name.err"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "write exited $rc: $(first "$T/log/$name.err")"; return 1; }
  [ "$(mode "$out")" = -rwx------ ] || { echo "mode is $(mode "$out"), not -rwx------"; return 1; }
  (cd "$T/r" && env -i TMPDIR="$T/ambient" PATH="$T/bin:$PATH" STUB_LOG="$T/log/$name.argv" "$out") >"$T/log/$name.run" 2>&1
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
  [ -s "$T/cap/K5/stdout" ] && [ -s "$T/cap/K6/stdout" ] || { echo "K5 or K6 produced no output"; return 1; }
  cmp -s "$T/cap/K5/stdout" "$T/cap/K6/stdout" || { echo "codex-read-probe output differs from codex-read"; return 1; }
}

# ---- #253 AC 2-3: the result lies outside the worker's only writable root (W1) ----

W1() { # build and run both read kinds; the result is not in the start directory, -C, or TMPDIR
  local k rc d cwd tdir cv res log
  for k in codex-read codex-read-probe; do
    log=$T/log/W1-$k.argv
    rm -f -- "$log"
    (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$k" --out "$T/w1/$k.sh" --worktree "$T/wt" \
      --launch-file "$LF" --result "$T/w1/result.md" --capture "$T/w1cap/$k" "${EV[@]}") >/dev/null 2>"$T/log/W1.err"
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
      case $T/w1/bin/ in "${d%/}"/*) echo "$k: $T/w1/bin is inside the writable root $d"; return 1 ;; esac
    done
  done
}

# ---- #314 AC 5: the worker's python resolves through the emitted PATH policy (Y1, Y2) ----

Y1() { # build codex-read with a fake python3 on PATH; the run script's codex applies the emitted policy word
  local rc t
  (cd "$T/b" && PATH="$T/y1py:$PATH" bash "$LAUNCH_SH" write --kind codex-read --out "$T/y1/r.sh" --worktree "$T/wt" \
    --launch-file "$LF" --result "$T/y1/res/result.md" --capture "$T/cap/Y1" "${EV[@]}") >/dev/null 2>"$T/log/Y1.err"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "write exited $rc: $(first "$T/log/Y1.err")"; return 1; }
  (cd "$T/r" && PATH="$T/ybin:$PATH" "$T/y1/r.sh") >"$T/log/Y1.run" 2>&1
  rc=$?
  [ "$rc" -eq 0 ] || { echo "run script exited $rc: $(first "$T/log/Y1.run")"; return 1; }
  grep -qxF 'py_rc=0' "$T/cap/Y1/stdout" && grep -qxF 'py_out=fake-python3 -c print(1)' "$T/cap/Y1/stdout" \
    || { echo "worker python under the emitted policy: $(tr '\n' ' ' <"$T/cap/Y1/stdout")"; return 1; }
  t=$(readlink -- "$T/y1/res/bin/python")
  [ "$t" = "$T/y1py/python3" ] || { echo "bin/python is not a link to $T/y1py/python3: $t"; return 1; }
  [ "$(mode "$T/y1/res/bin")" = drwx------ ] || { echo "bin mode is $(mode "$T/y1/res/bin"), not drwx------"; return 1; }
}
Y2() { # a PATH holding a quote, backslash or line feed is refused before anything is written
  local rc b
  for b in "'" '"' '\' $'\n'; do
    (cd "$T/b" && PATH="$PATH:$T/y2/a${b}b" bash "$LAUNCH_SH" write --kind codex-read --out "$T/y2/r.sh" --worktree "$T/wt" \
      --launch-file "$LF" --result "$T/y2/res/result.md" --capture "$T/cap/Y2" "${EV[@]}") >/dev/null 2>"$T/log/Y2.err"
    rc=$?
    [ "$rc" -eq 2 ] || { echo "PATH with $(printf %q "$b"): write exited $rc, not 2"; return 1; }
    grep -qF 'PATH holds a single quote, double quote, backslash or control character' "$T/log/Y2.err" \
      || { echo "PATH with $(printf %q "$b"): stderr lacks the PATH refusal"; return 1; }
    [ ! -e "$T/y2/r.sh" ] && [ ! -e "$T/y2/res/bin" ] || { echo "PATH with $(printf %q "$b"): run script written or bin created"; return 1; }
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
    --launch-file "$LF" --host-source "$T/g/g9.md" --capture "$T/cap/G9" "${EV[@]}") >"$T/log/G9.out" 2>"$T/log/G9.err"
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
  args+=(--capture "$T/cap/$1" "${EV[@]}")
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
  sed "s|^lf='.*'\$|lf='$T/nope.md'|" "$T/c/C4.base" >"$T/c/C4.sh"
  c_expect C4 "$T/r" "prompt not attached on stdin: not a regular file: $T/nope.md"
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

# ---- #314 AC 2 and 5: check refuses a read script without the zsh TMPPREFIX or the worker PATH policy (C29-C32) ----

C29() { # the TMPPREFIX word deleted, both read kinds
  local k
  for k in codex-read codex-read-probe; do
    c_build "C29-$k" "$k" || return 1
    sed "/^'TMPPREFIX=/d" "$T/c/C29-$k.base" >"$T/c/C29-$k.sh"
    c_expect "C29-$k" "$T/r" "missing TMPPREFIX=RESULT_DIR/work/tmp/zsh after TMPDIR" || return 1
  done
}
C30() { # TMPPREFIX moved back to the zsh default under /tmp, both read kinds
  local k
  for k in codex-read codex-read-probe; do
    c_build "C30-$k" "$k" || return 1
    sed "s|^'TMPPREFIX=.*'\$|'TMPPREFIX=/tmp/zsh'|" "$T/c/C30-$k.base" >"$T/c/C30-$k.sh"
    c_expect "C30-$k" "$T/r" "TMPPREFIX must be $T/res/work/tmp/zsh for $k: /tmp/zsh" || return 1
  done
}
C31() { # the worker PATH policy omitted (its -c and value deleted), both read kinds
  local k
  for k in codex-read codex-read-probe; do
    c_build "C31-$k" "$k" || return 1
    sed "/^'sandbox_workspace_write.exclude_slash_tmp=true'\$/{n;N;d;}" "$T/c/C31-$k.base" >"$T/c/C31-$k.sh"
    c_expect "C31-$k" "$T/r" 'missing flag: -c shell_environment_policy.set.PATH="RESULT_DIR/bin:PATH"' || return 1
  done
}
C32() { # the worker PATH policy led by a directory other than RESULT_DIR/bin, both read kinds
  local k
  for k in codex-read codex-read-probe; do
    c_build "C32-$k" "$k" || return 1
    sed "s|^'shell_environment_policy.set.PATH=\"$T/res/bin:|'shell_environment_policy.set.PATH=\"$T/brief:|" "$T/c/C32-$k.base" >"$T/c/C32-$k.sh"
    c_expect "C32-$k" "$T/r" "shell_environment_policy.set.PATH must start with $T/res/bin: for $k" || return 1
  done
}

# ---- AC 4: self-check and rejected inputs (S1, S2) ----

S1() {
  local rc
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind claude-write --out "$T/s1/run.sh" --worktree "$T/wt" \
    --launch-file "$LF" --add-dir "$T/nope" --host-source "$T/home/src.md" --capture "$T/cap/S1" "${EV[@]}") >/dev/null 2>"$T/log/S1.err"
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
    --launch-file "$LF" --result "$T/s3/result.md" --add-dir "$T/brief" --capture "$T/cap/S3" "${EV[@]}") >/dev/null 2>"$T/log/S3.err"
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
      --launch-file "$LF" --result "$T/s4/result.md" --capture "$T/cap/S4" "${EV[@]}") >/dev/null 2>"$T/log/S4.err"
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
    cap=(--capture "$T/cap/S5" "${EV[@]}")
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
    cap=(--capture "$T/cap/S6" "${EV[@]}")
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
    cap=(--capture "$T/cap/S7" "${EV[@]}")
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
    before=0 after=0 cap=(--capture "$T/cap/S8" "${EV[@]}")
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
    cap=(--capture "$T/cap/S9-$k" "${EV[@]}")
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
    cap=(--capture "$T/cap/S10" "${EV[@]}")
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
    cap=(--capture "$T/cap/S11" "${EV[@]}")
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
    --launch-file "$LF" --add-dir "$T/res" --capture "$T/cap/$1" "${EV[@]}") >/dev/null 2>"$T/log/$1.err"
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
  local -a args=(--worktree "$T/wt" --launch-file "$LF" --capture "$3" "${EV[@]}")
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
pc_unclock() { # FILE: FILE's text without its well-formed clock values, which are digits no worker wrote:
  # the ISO and EPOCH columns that start a stream record, and the time, start, end and duration_s
  # values of an events.jsonl line. The stream payload and every other value are kept.
  local iso='[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{6}Z'
  case ${1##*/} in
    stream) sed -E "s/^$iso"$'\t''[0-9]+\.[0-9]{6}'$'\t'"//" "$1" ;;
    events.jsonl) sed -E -e "s/\"(time|start|end)\":\"$iso\"/\"\\1\":\"\"/g" -e 's/"duration_s":[0-9]+\.[0-9]{6}/"duration_s":""/g' "$1" ;;
    *) cat -- "$1" ;;
  esac
}
pc_leak() { # PATH [TEXT...]: no credential value and no TEXT appears in a file under PATH, outside its clock values
  local cap=$1 x rc f
  local -a e=()
  shift
  for x in "$@" "tok-$P-secretvalue" Zq7 "dbc-$P-x" "$ESC_SECRET" "a\"b\\c-$P" "4242$P"; do e+=(-e "$x"); done
  [ -e "$cap" ] || { echo "leak search error: no $cap"; return 1; }
  while IFS= read -r f; do
    pc_unclock "$f" >"$T/log/leak" || { echo "leak search error: cannot read $f"; return 1; }
    grep -F "${e[@]}" "$T/log/leak" >/dev/null
    rc=$?
    case $rc in
      1) ;;
      0) echo "secret or host text in capture: $(grep -hoF "${e[@]}" "$T/log/leak" | head -n 1)"; return 1 ;;
      *) echo "leak search error: grep exited $rc"; return 1 ;;
    esac
  done < <(find "$cap" -type f)
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
        for f in exit stderr stdout stream; do
          [ "$(mode "$cap/$f")" = -rw------- ] || { echo "$k $sh: $f mode is $(mode "$cap/$f")"; return 1; }
        done
        [ "$(ls -A "$cap" | tr '\n' ' ')" = 'exit stderr stdout stream ' ] || { echo "$k $sh: the capture holds: $(ls -A "$cap" | tr '\n' ' ')"; return 1; }
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
  sed 's#} 3>&1 | awk -v names="$redact_env" "$red" | {$#} 3>\&1 | {#' "$T/c/PC4-1.base" >"$T/c/PC4-1.sh"
  pc4 1 "capture block differs from the claude-write-probe block" || return 1
  mkdir -m 700 "$T/wt/pc4cap" && sed "s|^cap='.*'\$|cap='$T/wt/pc4cap'|" "$T/c/PC4-2.base" >"$T/c/PC4-2.sh"
  pc4 2 "cap is inside the worktree: $T/wt/pc4cap" || return 1
  mkdir -m 755 "$T/pc/m755" && sed "s|^cap='.*'\$|cap='$T/pc/m755'|" "$T/c/PC4-3.base" >"$T/c/PC4-3.sh"
  pc4 3 "cap is not an owner-only directory: $T/pc/m755" || return 1
  { sed '/^attempt=/q' "$T/c/PC4-4.base"; printf '%s\n' 'exec "${argv[@]}" <"$lf"'; } >"$T/c/PC4-4.sh"
  pc4 4 "exec line in a claude-write-probe run script" || return 1
  { cat "$T/c/PC4-5.base"; printf '%s\n' 'exec "${argv[@]}" <"$lf"'; } >"$T/c/PC4-5.sh"
  pc4 5 "exec line in a claude-write run script, which captures its run" || return 1
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
PC5() { # write refuses each bad --capture, --events, --delivery or --redact-env input; an owner-only capture beside the brief is accepted
  local o=$T/pc5/run.sh rc
  local -a cl=(--kind claude-write-probe --launch-file "$LF" --host-source "$T/home/src.md" "${EV[@]}")
  local -a cx=(--kind codex-read-probe --launch-file "$LF" --result "$T/pc5res/result.md" "${EV[@]}")
  mkdir -m 700 "$T/pc5/ok" "$T/pc5/g" "$T/pc5/h" "$T/pc5/i" && mkdir -m 1777 "$T/pc5/open" && : >"$T/pc5/g/stdout" \
    || { echo "cannot create the PC5 fixtures"; return 1; }
  pc5 a "--capture is required for claude-write-probe" "$o" "${cl[@]}" || return 1
  pc5 b "--events must be an absolute path ending in /events.jsonl: $T/ev/events.json" "$o" --kind claude-write --launch-file "$LF" \
    --host-source "$T/home/src.md" --capture "$T/pc5/ok" --events "$T/ev/events.json" || return 1
  pc5 c "--delivery must have the form OWNER/REPO#N: o/r" "$o" --kind codex-read --launch-file "$LF" \
    --result "$T/pc5res/result.md" --capture "$T/pc5/ok" --delivery o/r || return 1
  pc5 d "--capture is inside the worktree: $T/wt/pc5cap" "$o" "${cl[@]}" --capture "$T/wt/pc5cap" || return 1
  [ ! -e "$T/wt/pc5cap" ] || { echo "(d) the capture directory was created inside the worktree"; return 1; }
  pc5 e "--capture is not an owner-only directory: $T/pc5/open" "$o" "${cl[@]}" --capture "$T/pc5/open" || return 1
  pc5 f "--capture resolves into the writable root: $T/pc5res/work/c" "$o" "${cx[@]}" --capture "$T/pc5res/work/c" || return 1
  pc5 g "--capture $T/pc5/g/stdout is the launch file" "$o" --kind claude-write-probe --launch-file "$T/pc5/g/stdout" \
    --host-source "$T/home/src.md" --capture "$T/pc5/g" "${EV[@]}" || return 1
  pc5 h "--capture $T/pc5/h/stderr is the run script" "$T/pc5/h/stderr" "${cl[@]}" --capture "$T/pc5/h" || return 1
  pc5 i "--capture $T/pc5/i/exit is the result" "$o" --kind codex-read-probe --launch-file "$LF" \
    --result "$T/pc5/i/exit" --capture "$T/pc5/i" "${EV[@]}" || return 1
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
PC7() { # a failed redaction stage keeps the harness status, writes capture-error, and exits 70; a stdout-redactor failure is not telemetry
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

# ---- #299: every kind captures; worker tool-call events (C24, C25, S12, TS1-TS5, TC1-TC5, TH1, TH2) ----

C24() { # a station kind's run script that ends in a bare exec is rejected
  local k
  for k in claude-read codex-write; do
    c_build "C24-$k" "$k" || return 1
    { sed '/^cd -- /q' "$T/c/C24-$k.base"; printf '%s < %s\n' 'exec "${argv[@]}"' "'$LF'"; } >"$T/c/C24-$k.sh"
    c_expect "C24-$k" "$T/r" "exec line in a $k run script, which captures its run" || return 1
  done
}
C25() { # a run script with no delivery identity, a bad delivery, or a bad events path is rejected
  c_build C25 claude-read || return 1
  cp "$T/c/C25.base" "$T/c/C25a.base" && cp "$T/c/C25.base" "$T/c/C25b.base" && cp "$T/c/C25.base" "$T/c/C25c.base" \
    && cp "$T/c/C25.base" "$T/c/C25d.base" || { echo "cannot copy the C25 fixture"; return 1; }
  sed '/^delivery=/d' "$T/c/C25.base" >"$T/c/C25a.sh"
  c_expect C25a "$T/r" "missing delivery= line in a claude-read run script" || return 1
  sed "s|^delivery='.*'\$|delivery='x'|" "$T/c/C25.base" >"$T/c/C25b.sh"
  c_expect C25b "$T/r" "delivery is not OWNER/REPO#N: x" || return 1
  sed "s|^events='.*'\$|events='ev/events.jsonl'|" "$T/c/C25.base" >"$T/c/C25c.sh"
  c_expect C25c "$T/r" "events is not an absolute path ending in /events.jsonl: ev/events.jsonl" || return 1
  sed "s|^events='.*'\$|events='$T/ev/tool-calls.jsonl'|" "$T/c/C25.base" >"$T/c/C25d.sh"
  c_expect C25d "$T/r" "events is not an absolute path ending in /events.jsonl: $T/ev/tool-calls.jsonl"
}
C26() { # claude-read mode left as plan
  c_build C26 claude-read || return 1
  sed "s|^'manual'\$|'plan'|" "$T/c/C26.base" >"$T/c/C26.sh"
  c_expect C26 "$T/r" "--permission-mode must be manual for claude-read: plan"
}
C27() { # the trailing wrapper deny entry deleted
  c_build C27 claude-write || return 1
  sed "/^'Bash(nohup \\*)'\$/d" "$T/c/C27.base" >"$T/c/C27.sh"
  c_expect C27 "$T/r" "missing recipe entry in --disallowedTools: Bash(nohup *)"
}
C28() { # a declared check that starts with a denied wrapper
  local rc
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind claude-read --out "$T/c/C28a.sh" --worktree "$T/wt" --launch-file "$LF" \
    --add-dir "$T/res" --add-dir "$T/brief" --allow 'Bash(time make check)' --capture "$T/cap/C28a" "${EV[@]}") >/dev/null 2>"$T/log/C28a.build"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "write exited $rc, not 2"; return 1; }
  grep -qF -- "--allow starts with a denied wrapper: Bash(time make check)" "$T/log/C28a.build" || { echo "stderr lacks the denied-wrapper refusal"; return 1; }
  [ ! -e "$T/c/C28a.sh" ] || { echo "a run script was written"; return 1; }
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind claude-read --out "$T/c/C28t.sh" --worktree "$T/wt" --launch-file "$LF" \
    --add-dir "$T/res" --add-dir "$T/brief" --allow 'Bash(timed-check)' --capture "$T/cap/C28t" "${EV[@]}") >/dev/null 2>"$T/log/C28t.build" \
    || { echo "Bash(timed-check) was refused: $(first "$T/log/C28t.build")"; return 1; }
  c_build C28 claude-write || return 1
  sed "s|^'Bash(make check)'\$|'Bash(time make check)'|" "$T/c/C28.base" >"$T/c/C28.sh"
  c_expect C28 "$T/r" "--allowedTools entry starts with a denied wrapper: Bash(time make check)"
}
S12() { # write refuses a station kind without --capture, --events or --delivery and writes no OUT
  local k f rc
  local -a args
  for k in claude-read codex-write; do
    for f in --capture --events --delivery; do
      args=(--kind "$k" --worktree "$T/wt" --launch-file "$LF" --out "$T/ts/S12.sh")
      [ "$k" = claude-read ] || args+=(--result "$T/res/result.md")
      [ "$f" = --capture ] || args+=(--capture "$T/cap/S12")
      [ "$f" = --events ] || args+=(--events "$T/ev/events.jsonl")
      [ "$f" = --delivery ] || args+=(--delivery 'o/r#1')
      args+=(--station implementing --attempt 1)
      (cd "$T/b" && bash "$LAUNCH_SH" write "${args[@]}") >/dev/null 2>"$T/log/S12.err"
      rc=$?
      [ "$rc" -eq 2 ] || { echo "$k without $f: write exited $rc, not 2"; return 1; }
      grep -qF -- "$f is required for $k" "$T/log/S12.err" || { echo "$k without $f: stderr lacks: $f is required for $k"; return 1; }
      [ ! -e "$T/ts/S12.sh" ] || { echo "$k without $f: OUT was written"; return 1; }
    done
  done
}

TCH='"kind":"tool-call","delivery":"o/r#1","station":"implementing","attempt":"1","source":"worker"'
tab=$'\t'
printf 'No host path here.\n' >"$T/home/nogrant.md" || setup "cannot write the no-grant source"

ts_build() { # NAME KIND [ARGS...]: write $T/ts/NAME.sh with capture $T/ts/NAME.cap and events $T/ts/NAME.ev/events.jsonl
  local name=$1 kind=$2 rc
  local -a args=(--worktree "$T/wt" --launch-file "$LF" --capture "$T/ts/$1.cap" --events "$T/ts/$1.ev/events.jsonl"
    --delivery 'o/r#1' --station implementing --attempt 1)
  shift 2
  mkdir -p "$T/ts/$name.ev" || { echo "$name: cannot create the events directory"; return 1; }
  case $kind in codex-*) args+=(--result "$T/ts/res/result.md") ;; esac
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$kind" --out "$T/ts/$name.sh" "${args[@]}" "$@") >/dev/null 2>"$T/log/$name.build"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "$name: write exited $rc: $(first "$T/log/$name.build")"; return 1; }
}
ev_field() { # FIELD LINE: the value of a string or number FIELD in one event line
  printf '%s\n' "$2" | sed -n "s/.*\"$1\":\"\\{0,1\\}\\([^\",}]*\\).*/\\1/p"
}

# A Claude pair for TS1, TS5, TC3 and TC5.
printf '%s\n' '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"t1","name":"Bash","input":{"command":"git status"}}]}}' \
  '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t1","content":"ok","is_error":false}]}}' >"$T/ts/pair.in" \
  || setup "cannot write the TS pair"
printf '%s\n' 'sed -n 1p "$TS_IN"' 'sleep 1' 'sed -n 2p "$TS_IN"' >"$T/ts/ts1.run" \
  && printf '%s\n' 'printf "%s\n%s" "$(sed -n 1p "$TS_IN")" "$(sed -n 2p "$TS_IN")"' >"$T/ts/ts5.run" \
  && printf '%s\n' 'cat -- "$TS_IN"' 'r=absent i=0' \
    'while [ "$i" -lt 100 ]; do if [ -s "$TS_EV" ]; then r=found; break; fi; sleep 0.1; i=$((i + 1)); done' \
    'printf "%s\n" "$r" >"$TS_FOUND"' >"$T/ts/tc5.run" || setup "cannot write the TS stub programs"

TS1() { # each record carries its own arrival time, and the event takes its start and end from the stamped records
  local s ev n d l1 l2
  s=$T/ts/TS1.cap ev=$T/ts/TS1.ev/events.jsonl
  ts_build TS1 claude-read || return 1
  pc_run bash "$T/ts/TS1.sh" STUB_RUN="$T/ts/ts1.run" TS_IN="$T/ts/pair.in" || { echo "run script exited $?"; return 1; }
  n=$(grep -cE "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\\.[0-9]{6}Z$tab[0-9]+\\.[0-9]{6}$tab" "$s/stream")
  [ "$n" = 2 ] && [ "$(wc -l <"$s/stream")" -eq 2 ] || { echo "stream has $n stamped lines of $(wc -l <"$s/stream")"; return 1; }
  [ "$(wc -l <"$ev")" -eq 1 ] || { echo "events holds $(wc -l <"$ev") lines, not 1"; return 1; }
  l1=$(sed -n 1p "$s/stream" | cut -f1) l2=$(sed -n 2p "$s/stream" | cut -f1)
  [ "$(ev_field start "$(cat "$ev")")" = "$l1" ] || { echo "start is not the first record's time $l1"; return 1; }
  [ "$(ev_field end "$(cat "$ev")")" = "$l2" ] && [ "$(ev_field time "$(cat "$ev")")" = "$l2" ] \
    || { echo "end or time is not the second record's time $l2"; return 1; }
  d=$(ev_field duration_s "$(cat "$ev")")
  awk -v d="$d" 'BEGIN { exit !(d ~ /^[0-9]+\.[0-9]{6}$/ && d >= 1 && d <= 5) }' || { echo "duration_s $d is not within [1, 5]"; return 1; }
}

# TS2 and TS3: a Claude pair whose id is a credential, and credentials in its arguments, result, and a plain line.
cat >"$T/ts/ts2.stdout" <<EOF
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"tok-$P-secretvalue","name":"Bash","input":{"command":"echo Zq7 dbc-$P-x"}}]}}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"tok-$P-secretvalue","content":"$ESC_SECRET 4242$P","is_error":false}]}}
plain tok-$P-secretvalue line
EOF
TS2() { # no credential reaches stdout, stream, or events: the stream is stamped and paired only after redaction
  local s=$T/ts/TS2.cap ev=$T/ts/TS2.ev/events.jsonl
  ts_build TS2 claude-read --redact-env DBCRED || return 1
  pc_run bash "$T/ts/TS2.sh" STUB_STREAM="$T/ts/ts2.stdout" "${PC_CREDS[@]}" || { echo "run script exited $?"; return 1; }
  [ "$(grep -c '"id":"\[redacted\]"' "$ev")" = 1 ] || { echo "events lacks the one redacted-id pair: $(head -c 200 "$ev")"; return 1; }
  pc_leak "$s" || return 1
  pc_leak "$ev"
}
TS3() { # the stream records are the stdout records: the same stage feeds both
  local s=$T/ts/TS2.cap
  [ -s "$s/stdout" ] && [ -s "$s/stream" ] || { echo "TS2 left no stdout or stream"; return 1; }
  cut -f3- "$s/stream" | cmp -s - "$s/stdout" || { echo "the stream records differ from stdout"; return 1; }
}

# TS4: the PC3 stream with an item.started record before its command_execution item.
sed '2a\
{"type":"item.started","item":{"id":"item_1","type":"command_execution","command":"bash -lc '"'"'git status --short'"'"'","aggregated_output":"","exit_code":null,"status":"in_progress"}}' \
  "$T/pc/pc3.stdout" >"$T/ts/ts4.stdout" && sed '2a\
{"type":"item.started","item":{"id":"item_1","type":"command_execution","command":"bash -lc '"'"'git status --short'"'"'","aggregated_output":"","exit_code":null,"status":"in_progress"}}' \
  "$T/exp/PC3.stdout" >"$T/exp/TS4.stdout" || setup "cannot write the TS4 stream"
TS4() { # a stream that cannot be written keeps stdout, the harness status, and the events, and records a telemetry error
  local s=$T/ts/TS4.cap ev=$T/ts/TS4.ev/events.jsonl rc
  ts_build TS4 codex-read --redact-env DBCRED || return 1
  mkdir "$s/stream" || { echo "cannot create the stream directory"; return 1; }
  pc_run bash "$T/ts/TS4.sh" STUB_STREAM="$T/ts/ts4.stdout" STUB_ERR="$T/pc/pc3.stderr" STUB_RC=3 "${PC_CREDS[@]}"
  rc=$?
  [ "$rc" -eq 3 ] || { echo "run script exited $rc, not 3"; return 1; }
  [ "$(cat "$s/exit" 2>/dev/null)" = 3 ] || { echo "exit file is $(cat "$s/exit" 2>/dev/null)"; return 1; }
  diff "$T/exp/TS4.stdout" "$s/stdout" >"$T/log/TS4.diff" || { echo "stdout differs: $(grep '^[<>]' "$T/log/TS4.diff" | head -n 1)"; return 1; }
  grep -qF 'stream=1' "$s/telemetry-error" 2>/dev/null || { echo "telemetry-error does not name stream=1"; return 1; }
  [ ! -e "$s/capture-error" ] || { echo "capture-error was written: $(cat "$s/capture-error")"; return 1; }
  [ "$(wc -l <"$ev")" -eq 1 ] && grep -qF '"tool":"command_execution","id":"item_1",' "$ev" && grep -qF '"exit":0}' "$ev" \
    || { echo "events lacks the item_1 pair: $(head -c 300 "$ev")"; return 1; }
}
TS5() { # a final record with no newline is kept once, ends in one newline in stdout, and completes its pair
  local s=$T/ts/TS5.cap ev=$T/ts/TS5.ev/events.jsonl
  ts_build TS5 claude-read || return 1
  pc_run bash "$T/ts/TS5.sh" STUB_RUN="$T/ts/ts5.run" TS_IN="$T/ts/pair.in" || { echo "run script exited $?"; return 1; }
  diff "$T/ts/pair.in" "$s/stdout" >"$T/log/TS5.diff" || { echo "stdout differs: $(grep '^[<>]' "$T/log/TS5.diff" | head -n 1)"; return 1; }
  [ "$(wc -l <"$s/stream")" -eq 2 ] && [ "$(tail -n 1 "$s/stream" | cut -f3-)" = "$(sed -n 2p "$T/ts/pair.in")" ] \
    || { echo "the stream's last line is not the final record"; return 1; }
  [ "$(wc -l <"$ev")" -eq 1 ] && grep -qF '"tool":"Bash","id":"t1",' "$ev" || { echo "events lacks the t1 pair"; return 1; }
}

# TC1, TC2, TC4: the tool-call program of a generated run script on fixed stamped input.
tc_case() { # NAME: run the tc program on $T/ts/NAME.in and compare with $T/exp/NAME.events
  local prog
  [ -f "$T/c/TCP.base" ] || c_build TCP claude-read || return 1
  prog=$(sed -n "/^tc='\$/,/^'\$/p" "$T/c/TCP.base" | sed '1d;$d')
  [ -n "$prog" ] || { echo "no tc program in the run script"; return 1; }
  awk -v delivery='o/r#1' -v station=implementing -v attempt=1 "$prog" "$T/ts/$1.in" >"$T/ts/$1.out" 2>"$T/log/$1.err" \
    || { echo "tc exited non-zero: $(first "$T/log/$1.err")"; return 1; }
  diff "$T/exp/$1.events" "$T/ts/$1.out" >"$T/log/$1.diff" || { echo "events differ: $(grep '^[<>]' "$T/log/$1.diff" | head -n 1)"; return 1; }
}
D='2026-10-16T00:00:'
{
  printf '%s\t%s\t%s\n' "${D}01.250000Z" 1792108801.250000 '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"a","name":"Bash","input":{"command":"x"}},{"type":"tool_use","id":"b","name":"Read","input":{"file_path":"/f"}}]}}'
  printf '%s\t%s\t%s\n' "${D}02.000000Z" 1792108802.000000 '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"c","name":"Grep","input":{}}]}}'
  printf '%s\t%s\t%s\n' "${D}03.500000Z" 1792108803.500000 '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"b","content":"x","is_error":false}]}}'
  printf '%s\t%s\t%s\n' "${D}04.750000Z" 1792108804.750000 '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"a","content":"x","is_error":true}]}}'
} >"$T/ts/TC1.in" && {
  printf '{"time":"%s",%s,"tool":"Read","id":"b","start":"%s","end":"%s","duration_s":2.250000,"error":false}\n' "${D}03.500000Z" "$TCH" "${D}01.250000Z" "${D}03.500000Z"
  printf '{"time":"%s",%s,"tool":"Bash","id":"a","start":"%s","end":"%s","duration_s":3.500000,"error":true}\n' "${D}04.750000Z" "$TCH" "${D}01.250000Z" "${D}04.750000Z"
} >"$T/exp/TC1.events" && {
  printf '%s\t%s\t%s\n' "${D}10.000000Z" 1792108810.000000 '{"type":"item.started","item":{"id":"item_1","type":"command_execution","command":"git status","status":"in_progress"}}'
  printf '%s\t%s\t%s\n' "${D}10.400000Z" 1792108810.400000 '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"hi"}}'
  printf '%s\t%s\t%s\n' "${D}12.125000Z" 1792108812.125000 '{"type":"item.completed","item":{"id":"item_1","type":"command_execution","command":"git status","exit_code":1,"status":"failed"}}'
} >"$T/ts/TC2.in" && {
  printf '{"time":"%s",%s,"tool":"command_execution","id":"item_1","start":"%s","end":"%s","duration_s":2.125000,"exit":1}\n' "${D}12.125000Z" "$TCH" "${D}10.000000Z" "${D}12.125000Z"
} >"$T/exp/TC2.events" && {
  printf '%s\t%s\t%s\n' unknown unknown '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"u1","name":"Bash","input":{"command":"x"}}]}}'
  printf '%s\t%s\t%s\n' unknown unknown '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"u1","content":"x","is_error":false}]}}'
  printf '%s\t%s\t%s\n' "${D}10.000000Z" 1792108810.000000 '{"type":"item.started","item":{"id":"item_2","type":"command_execution","command":"x"}}'
  printf '%s\t%s\t%s\n' unknown unknown '{"type":"item.completed","item":{"id":"item_2","type":"command_execution","command":"x","exit_code":0}}'
} >"$T/ts/TC4.in" && {
  printf '{"time":"unknown",%s,"tool":"Bash","id":"u1","start":"unknown","end":"unknown","duration_s":"unknown","error":false}\n' "$TCH"
  printf '{"time":"unknown",%s,"tool":"command_execution","id":"item_2","start":"%s","end":"unknown","duration_s":"unknown","exit":0}\n' "$TCH" "${D}10.000000Z"
} >"$T/exp/TC4.events" || setup "cannot write the TC fixtures"
TC1() { tc_case TC1; } # Claude: pairs by id in completion order, exact times and durations, no event for an unanswered call
TC2() { tc_case TC2; } # Codex: pairs item.started with item.completed by item id; a completed-only item is not a call
TC4() { tc_case TC4; } # a missing clock is "unknown", never zero or an estimate
TC3() { # a failed tool-call stage keeps stdout and the harness status and records a telemetry error, not a capture error
  local s=$T/ts/TC3.cap rc
  ts_build TC3 claude-read || return 1
  (cd "$T/r" && env -i PATH="$T/fbin:$T/pbin:$PATH" HOME="$HOME" STUB_STREAM="$T/ts/pair.in" STUB_RC=3 STUB_AWK_FAIL=3 \
    bash -c '"$1"' _ "$T/ts/TC3.sh") >/dev/null 2>&1
  rc=$?
  [ "$rc" -eq 3 ] || { echo "run script exited $rc, not 3"; return 1; }
  grep -qF 'tool-call' "$s/telemetry-error" 2>/dev/null || { echo "telemetry-error does not name the tool-call stage"; return 1; }
  [ ! -e "$s/capture-error" ] || { echo "capture-error was written: $(cat "$s/capture-error")"; return 1; }
  cmp -s "$T/ts/pair.in" "$s/stdout" || { echo "stdout differs from its golden"; return 1; }
}
TC5() { # a completed call reaches events while the worker still runs
  local ev=$T/ts/TC5.ev/events.jsonl
  ts_build TC5 claude-read || return 1
  rm -f -- "$T/ts/TC5.found"
  pc_run bash "$T/ts/TC5.sh" STUB_RUN="$T/ts/tc5.run" TS_IN="$T/ts/pair.in" TS_EV="$ev" TS_FOUND="$T/ts/TC5.found" \
    || { echo "run script exited $?"; return 1; }
  [ "$(cat "$T/ts/TC5.found" 2>/dev/null)" = found ] || { echo "events was $(cat "$T/ts/TC5.found" 2>/dev/null) while the worker ran"; return 1; }
}

TH1() { # claude-write under a host grant redacts host text from stdout and stream as the probe does
  local s=$T/ts/TH1.cap
  ts_build TH1 claude-write --host-source "$T/home/pc2src.md" --redact-env DBCRED || return 1
  pc_run bash "$T/ts/TH1.sh" STUB_STREAM="$T/pc/pc2.stdout" STUB_ERR="$T/pc/pc2.stderr" "${PC_CREDS[@]}" \
    || { echo "run script exited $?"; return 1; }
  pc_golden PC2 "$s" || return 1
  pc_leak "$s" "HOSTTEXT-$P" "CHATTER-$P" "ARGTEXT-$P" "ARGCMD-$P"
}
cat >"$T/ts/th2.stdout" <<EOF
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"r1","name":"Read","input":{"file_path":"$T/home/plain.md"}}]}}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"r1","content":"HOSTTEXT-$P","is_error":false}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"w1","name":"Write","input":{"file_path":"$T/th2/result.md","content":"## Outcome\nHOSTTEXT-$P"}}]}}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"w1","content":"File created","is_error":false}]}}
{"type":"result","subtype":"success","is_error":false,"result":"## Outcome\nHOSTTEXT-$P","permission_denials":[]}
EOF
printf '## Outcome\nDone.\n## Steps completed\n## Evidence\n## Checks\nPack: %s/brief/pack.md\n' "$T" >"$T/exp/TH2.result" \
  && printf '%s\n' 'cat -- "$STUB_STREAM"' 'cp -- "$TH2_SRC" "$TH2_RESULT"' >"$T/ts/th2.run" || setup "cannot write the TH2 fixtures"
TH2() { # a granted write station's result is its result file; no host text in stdout, stream, or events
  local s=$T/ts/TH2.cap ev=$T/ts/TH2.ev/events.jsonl
  ts_build TH2 claude-write --host-source "$T/home/pc2src.md" || return 1
  rm -f -- "$T/th2/result.md"
  pc_run bash "$T/ts/TH2.sh" STUB_RUN="$T/ts/th2.run" STUB_STREAM="$T/ts/th2.stdout" TH2_SRC="$T/exp/TH2.result" \
    TH2_RESULT="$T/th2/result.md" || { echo "run script exited $?"; return 1; }
  pc_leak "$s" "HOSTTEXT-$P" || return 1
  pc_leak "$ev" "HOSTTEXT-$P" || return 1
  grep '"type":"result"' "$s/stdout" | tail -n 1 | grep -qF '"result":"[removed]"' || { echo "the result field was not removed"; return 1; }
  grep -qF '"tool":"Read","id":"r1",' "$ev" && grep -qF '"tool":"Write","id":"w1",' "$ev" && [ "$(grep -cF '"error":false}' "$ev")" = 2 ] \
    || { echo "events lacks the Read and Write lines with error false"; return 1; }
  cmp -s "$T/exp/TH2.result" "$T/th2/result.md" || { echo "the result file changed"; return 1; }
}

# Pack check (PK1-PK9). pk_run NAME PACK: run launch.sh pack with worktree $T/pk; sets rc.
pk_run() { bash "$LAUNCH_SH" pack "$2" --worktree "$T/pk" >"$T/log/$1.out" 2>"$T/log/$1.err"; rc=$?; }
# pk_fail NAME PACK FILE...: exit 1 with exactly one fix-naming error line per FILE.
pk_fail() {
  local n=$1 p=$2 f; shift 2
  pk_run "$n" "$p"
  [ "$rc" -eq 1 ] || { echo "pack exited $rc, not 1: $(first "$T/log/$n.err")"; return 1; }
  [ "$(grep -c . "$T/log/$n.err")" = "$#" ] || { echo "expected $# error lines, got: $(cat "$T/log/$n.err")"; return 1; }
  for f in "$@"; do
    grep -F "launch.sh: pack: $f is cited at " "$T/log/$n.err" | grep -qF "add a" \
      || { echo "no fix-naming error for $f"; return 1; }
  done
}
# pk_pass NAME PACK: exit 0 and no stderr.
pk_pass() {
  pk_run "$1" "$2"
  [ "$rc" -eq 0 ] && [ ! -s "$T/log/$1.err" ] || { echo "pack exited $rc: $(first "$T/log/$1.err")"; return 1; }
}
PK1() {   # #259 review r1 pack at head 7f31b54, verbatim, with its ~~~~~ separator
  cat >"$T/pk/259.md" <<'EOF'
# #259 review r1 pack (head 7f31b54, base e9f6228): ## Rules that apply and ## Named files, verbatim
## Rules that apply


- `AGENTS.md:6` — "Acceptance is the bar under `README.md` "Development and provenance". It is not a help check or a document-only review." (policy row: applies; planned: review evidence on the diff plus the declared check; unresolved)
- `README.md:224` — "CI runs the declared check, `bash scripts/test-launch.sh`, from [.github/workflows/check.yml](.github/workflows/check.yml)." (policy row: applies; planned: declared check exit 0 and CI green; unresolved)
- `CONTRIBUTING.md:9` — "**Restated rule.** Review reads each sentence that a plan or diff adds outside the file that owns the rule the sentence concerns, and compares it with that owner's text; a reworded sentence, and a sentence next to an owner link, get the same comparison. Review reports each sentence that states behavior the owner's text already states, and cites that owner and its stable anchor." (policy row: applies; planned: every added sentence outside review-convergence.md is a pointer, not a restatement, or a deliberate both-cases summary justified in the plan; unresolved)
- `CONTRIBUTING.md:10` — "**Misattributed owner.** For each owner link and quoted anchor that a plan or diff adds, review opens the owner at the quoted text and reads the sentence or section that holds it. Review reports the pointer when that text does not state the rule the pointer cites it for, even when the quoted phrase is present." (policy row: applies; planned: each added anchor resolves to text stating the exhaustion condition; unresolved)
- `CONTRIBUTING.md:11` — "**Dropped inventory or case.** A procedure covers every item of the inventory it names, every part of the coverage its criteria require, and every case its criteria require." (policy row: applies; planned: AC 2 inventory of three files fully covered; both exhaustion cases covered; unresolved)
- `CONTRIBUTING.md:12` — "**Section contradiction.** No section of a mode contradicts another section of that mode, or an inherited rule that governs the mode, such as [SKILL.md](SKILL.md) ("Stop only at") or [references/contract.md](references/contract.md) ("## Stage projection")." (policy row: applies; planned: recovery.md no longer contradicts review-convergence.md; unresolved)
- `.capstan/vocabulary.md:79` — "**Rule owner**: the single file that states a behavioral rule. Other files name it and do not restate the rule." (policy row: applies; planned: review-convergence.md stays the single owner; unresolved)
- `.capstan/vocabulary.md:111` — "**Stable anchor**: a heading's exact text or a verbatim phrase of the target rule, named next to the owner-file link. Rejected: a line number." (policy row: applies; planned: added pointers use heading-text anchors; unresolved)


Effective code-review policy (`references/review-convergence.md`, quoted; config: block_threshold medium, min_confidence 0.7, max_review_fix_rounds 3, surface_recurrence_rounds 3, residual_effect_approval false; no trusted operator dispositions). This is round 1 of 3 counted; remaining round allowance after this census: 2 if counted; evidence-only allowance 3. Round 1 reviews the complete cumulative diff.

~~~~~
## Named files

- `references/recovery.md:55-72` ("## Blocked overlays") — changed paragraph (Documentation impact path).
- `README.md:174-183` ("Code re-review is a ratchet") — changed paragraph (Documentation impact path).
- `.capstan/features/issue-delivery.md:19-22` ("Other stops:") — changed line (Documentation impact path; feature map entry).
- `references/review-convergence.md:84-193` ("## Coordinator-evidence findings") — the owner the new pointers cite; also holds "## Bounded rounds and recurrence".
- `references/review.md:165-175` ("a final allowed review with blockers adds the review-exhausted blocked") — unchanged caller that names the condition; AC 2 inventory decision.
- `references/contract.md:278-284` ("A blocker adds only `capstan:blocked`") — unchanged (AC 3).
- `templates/blocker.md:1-15` ("Blocker kind:") — unchanged (AC 3).
EOF
  pk_fail PK1 "$T/pk/259.md" AGENTS.md CONTRIBUTING.md .capstan/vocabulary.md || return 1
  printf -- '- `%s` ("%s") — quoted rule.\n' 'AGENTS.md:1-10' 'Acceptance is the bar' \
    'CONTRIBUTING.md:1-13' '## Rules' '.capstan/vocabulary.md:79-114' '**Rule owner**' >>"$T/pk/259.md"
  pk_pass PK1b "$T/pk/259.md"
}
PK2() {   # #281 review r1 · 1 pack at head f2dbbd4, verbatim; bare-path citations and absolute named paths
  cat >"$T/pk/281.md" <<'EOF'
# #281 review r1 · 1 pack (head f2dbbd4, base 2a69df1): ## Rules that apply and ## Named files, verbatim
## Rules that apply

- `CONTRIBUTING.md:9` — "**Restated rule.** Review reads each sentence that a plan or diff adds outside the file that owns the rule the sentence concerns, and compares it with that owner's text; a reworded sentence, and a sentence next to an owner link, get the same comparison. Review reports each sentence that states behavior the owner's text already states, and cites that owner and its stable anchor." (policy row: applies; planned; unresolved)
- `CONTRIBUTING.md:10` — "**Misattributed owner.** For each owner link and quoted anchor that a plan or diff adds, review opens the owner at the quoted text and reads the sentence or section that holds it. Review reports the pointer when that text does not state the rule the pointer cites it for, even when the quoted phrase is present." (policy row: applies; planned; unresolved)
- `CONTRIBUTING.md:12` — "**Section contradiction.** No section of a mode contradicts another section of that mode, or an inherited rule that governs the mode, such as [SKILL.md](SKILL.md) ("Stop only at") or [references/contract.md](references/contract.md) ("## Stage projection")." (policy row: applies; planned; unresolved)
- `.capstan/vocabulary.md` "**Rule owner**" — "the single file that states a behavioral rule. Other files name it and do not restate the rule." (policy row: applies, mandatory; planned; unresolved)
- `.capstan/vocabulary.md` "**Stable anchor**" — "a heading's exact text or a verbatim phrase of the target rule, named next to the owner-file link. Rejected: a line number." (policy row: applies; planned; unresolved)
- `AGENTS.md:6` — "Acceptance is the bar under `README.md` "Development and provenance". It is not a help check or a document-only review." (policy row: applies; planned; unresolved)

Effective code-review policy (`references/review-convergence.md`, quoted; config: block_threshold medium, min_confidence 0.7, max_review_fix_rounds 3, surface_recurrence_rounds 3, residual_effect_approval false; no trusted operator dispositions). This is round 1 of 3 counted; round 1 reviews the complete cumulative diff.

## Named files

- `references/plan-review.md:1-60` ("# Plan review — fresh secondary, read-only") — edit target (G5a-C1–C6)
- `references/fix.md:1-40` ("# Fix — fresh primary, write") — edit target (G5a-C7–C11)
- `references/implementing.md:1-141` ("# Implementing — fresh primary, write") — edit target (G5a-C12, C14–C19)
- `references/findings.md:1-90` ("# Finding resolution") — edit target (G5a-C20)
- `templates/brief.md:1-80` ("## Worker constraints") — owner for reads, gaps, operation count, ceiling stop (G5a-C2, C8, C15, C16)
- `templates/review.md:1-70` ("## Finding format") — owner for finding fields (G5a-C5)
- `references/plan-convergence.md:1-80` ("## Fixed sequence") — owner for routing, single review, correction as proposed treatment (G5a-C1, C6, C12, C20); "## Prerequisites versus implementation obligations"
- `references/pack.md:1-120` ("An evidence check the initial plan writes") — owner for G5a-C4
- `SKILL.md:1-90` ("## Coordinator loop") — owner for steps 3–5 (G5a-C8, C10, C16)
- `references/triage.md:1-30` ("When `.capstan/vocabulary.md` exists, read it after repository instructions") — owner for G5a-C17
- `/home/mcomardo/.local/state/capstan/comamitc/capstan/281/checks/spike-g5a-rows.md:1-40` ("Spike #257 G5a rows") — each cut's anchor, class, bytes, owner after cut, guarded failure, why kept.
- `/home/mcomardo/.local/state/capstan/comamitc/capstan/281/checks/spike-g5a.diff:1-244` ("diff --git") — the spike candidate's applied text (cd38fa1 → 45534b2) for these files, to re-derive against current main.
EOF
  pk_fail PK2 "$T/pk/281.md" CONTRIBUTING.md .capstan/vocabulary.md AGENTS.md || return 1
  printf -- '- `%s` ("%s") — quoted rule.\n' 'CONTRIBUTING.md:1-13' '## Rules' \
    '.capstan/vocabulary.md:79-114' '**Rule owner**' 'AGENTS.md:1-10' 'Acceptance is the bar' >>"$T/pk/281.md"
  pk_pass PK2b "$T/pk/281.md"
}
PK3() {   # compact form: the pre-change example fails; the new example passes
  printf '%s\n' '# Pack — owner/repo#N, implementing attempt 1, candidate: plan comment URL, revision R' '## Candidate' \
    '<the one plan item, verbatim>' 'Criterion: AC 2 — "<quoted criterion>"' 'Rule: `CONTRIBUTING.md:14` — "<quoted sentence>"' \
    'Check: `make test` in WORKTREE, expected exit 0' \
    'Named file: `src/cli.py:40-58` ("<anchor>") — the option parser this item edits' >"$T/pk/compact.md"
  pk_fail PK3 "$T/pk/compact.md" CONTRIBUTING.md || return 1
  grep -qF 'on a Rule: line' "$T/log/PK3.err" || { echo "compact error does not name the Rule: line"; return 1; }
  printf '%s\n' 'Named file: `CONTRIBUTING.md:1-14` ("<quoted sentence>") — the rule the Rule: line quotes' >>"$T/pk/compact.md"
  pk_pass PK3b "$T/pk/compact.md"
}
PK4() {   # range hints, ./ and in-worktree absolute paths; an outside absolute path; input errors
  printf '%s\n' '## Rules that apply' '- `references/contract.md:131-132` — "a Capstan executable"' '- `./README.md:11` — "Issue #181"' \
    '## Named files' "- \`$T/pk/references/contract.md:126-153\` (\"## Global non-goals\") — exception" \
    '- `README.md:1-20` ("launch builder") — builder' >"$T/pk/abs.md"
  pk_pass PK4 "$T/pk/abs.md" || return 1
  sed "s#$T/pk/references#/elsewhere/references#" "$T/pk/abs.md" >"$T/pk/out.md"
  pk_fail PK4b "$T/pk/out.md" references/contract.md || return 1
  bash "$LAUNCH_SH" pack pk/abs.md --worktree "$T/pk" 2>/dev/null; [ $? -eq 2 ] || { echo "relative pack not exit 2"; return 1; }
  bash "$LAUNCH_SH" pack "$T/pk/none.md" --worktree "$T/pk" 2>/dev/null; [ $? -eq 2 ] || { echo "missing pack not exit 2"; return 1; }
  bash "$LAUNCH_SH" pack "$T/pk/abs.md" 2>/dev/null; [ $? -eq 2 ] || { echo "no --worktree not exit 2"; return 1; }
}
PK5() {   # PR1: unbulleted, * bullet, numbered, and blockquote quotes, an inline path:line, a non-path token
  printf '%s\n' '## Rules that apply' \
    '`CONTRIBUTING.md:9` — "unbulleted quote"' \
    '* `AGENTS.md:3` — "star bullet"' \
    '1. `SKILL.md:40` — "numbered"' \
    '> `README.md:11` — "blockquote"' \
    '- Correction review blocks (references/modes/correction.md:40-54, quoted): "Block a class."' \
    '- `none` — no further rule; spec revision 2026-10-20T15:12:49Z' \
    '## Named files' '- `scripts/launch.sh:1-69` ("Capstan launch builder") — builder' >"$T/pk/forms.md"
  pk_fail PK5 "$T/pk/forms.md" CONTRIBUTING.md AGENTS.md SKILL.md README.md references/modes/correction.md || return 1
  printf -- '- `%s` ("%s") — quoted rule.\n' 'CONTRIBUTING.md:1-13' '## Rules' 'AGENTS.md:1-10' 'integration base' \
    'SKILL.md:1-90' 'Stop only at' 'README.md:1-20' 'launch builder' \
    'references/modes/correction.md:1-54' 'This file owns correction' >>"$T/pk/forms.md"
  pk_pass PK5b "$T/pk/forms.md"
}
PK6() {   # PR2: candidate text, fenced or under an unclosed fence, is not pack metadata (full form)
  printf '%s\n' '# Pack — o/r#1, implementing attempt 1' '## Candidate' '~~~~' \
    '## Rules that apply' '- `docs/only-in-candidate.md:3` — "a candidate example citation"' \
    '## Named files' '- `AGENTS.md:1-10` ("integration base") — a candidate example entry' '~~~~' \
    '```' '## Named files' '```' \
    '## Open findings' 'none — initial attempt' \
    '## Rules that apply' '- `AGENTS.md:3` — "The integration base is `main`."' \
    '## Checks' '- `README.md:11` under Checks is not a rule citation' \
    '~~~~~' \
    '## Named files' '- `scripts/launch.sh:1-69` ("Capstan launch builder") — builder' >"$T/pk/cand.md"
  pk_fail PK6 "$T/pk/cand.md" AGENTS.md || return 1
  printf -- '- `AGENTS.md:1-10` ("integration base") — quoted rule.\n' >>"$T/pk/cand.md"
  pk_pass PK6b "$T/pk/cand.md" || return 1
  # No real ## Named files heading: the candidate's fenced heading and entry cannot stand in for it.
  printf '%s\n' '## Candidate' '```' '## Named files' '- `AGENTS.md:1-10` ("integration base") — a candidate example entry' '```' \
    '## Rules that apply' '- `AGENTS.md:3` — "The integration base is `main`."' '## Checks' 'none — no check' >"$T/pk/nonamed.md"
  pk_fail PK6c "$T/pk/nonamed.md" AGENTS.md
}
PK7() {   # PR2: compact pack whose candidate carries a fenced ## Named files heading, Rule:, and Named file: lines
  printf '%s\n' '# Pack — o/r#1, implementing attempt 1, candidate: plan comment URL, revision R' '## Candidate' \
    'Item 5 example:' '```' '## Named files' 'Rule: `docs/only-in-candidate.md:3` — "example"' \
    'Named file: `CONTRIBUTING.md:1-14` ("example") — example' '```' \
    'Criterion: AC 2 — "<quoted criterion>"' 'Rule: `CONTRIBUTING.md:14` — "<quoted sentence>"' \
    'Check: `make test` in WORKTREE, expected exit 0' \
    'Named file: `src/cli.py:40-58` ("<anchor>") — the option parser this item edits' >"$T/pk/ccand.md"
  pk_fail PK7 "$T/pk/ccand.md" CONTRIBUTING.md || return 1
  grep -qF 'on a Rule: line' "$T/log/PK7.err" || { echo "compact pack read as full form"; return 1; }
  printf '%s\n' 'Named file: `CONTRIBUTING.md:1-14` ("<quoted sentence>") — the rule the Rule: line quotes' >>"$T/pk/ccand.md"
  pk_pass PK7b "$T/pk/ccand.md"
}
PK8() {   # #316 F1: an inline extensionless path:line, a blockquote-then-list bare path; timestamps cite nothing
  printf '%s\n' '## Rules that apply' '- Source (LICENSE:9): rule' \
    '## Named files' '- `README.md:1-20` ("launch builder") — builder' >"$T/pk/inline.md"
  pk_fail PK8 "$T/pk/inline.md" LICENSE || return 1
  printf -- '- `LICENSE:1-21` ("Permission is hereby granted") — quoted rule.\n' >>"$T/pk/inline.md"
  pk_pass PK8b "$T/pk/inline.md" || return 1
  printf '%s\n' '## Rules that apply' '> - `.capstan/vocabulary.md` "**Rule owner**" — "Other files name it."' \
    '## Named files' '- `README.md:1-20` ("launch builder") — builder' >"$T/pk/bqlist.md"
  pk_fail PK8c "$T/pk/bqlist.md" .capstan/vocabulary.md || return 1
  printf -- '- `.capstan/vocabulary.md:79-114` ("**Rule owner**") — quoted rule.\n' >>"$T/pk/bqlist.md"
  pk_pass PK8d "$T/pk/bqlist.md" || return 1
  printf '%s\n' '## Rules that apply' '- `AGENTS.md:3` — rule' '- spec revision 2026-10-20T15:12:49Z, round 1, at 15:12 UTC' \
    '## Named files' '- `AGENTS.md:1-10` ("integration base") — rule' >"$T/pk/stamp.md"
  pk_pass PK8e "$T/pk/stamp.md"
}
PK9() {   # #316 F2: the quotes end at the first ## Checks heading, not the last
  printf '%s\n' '## Rules that apply' '- `AGENTS.md:3` — rule' '## Checks' '- `README.md:11` — check description' \
    '## Checks repeated' 'none' '## Named files' '- `AGENTS.md:1-10` ("integration base") — rule' >"$T/pk/checks2.md"
  pk_pass PK9 "$T/pk/checks2.md"
}

# Citation check (CT1-CT10). ct_run NAME ARGS...: run launch.sh cite; sets rc.
ct_run() { local n=$1; shift; bash "$LAUNCH_SH" cite "$@" >"$T/log/$n.out" 2>"$T/log/$n.err"; rc=$?; }
# ct_fail NAME WANT ARGS...: exit 1 with exactly WANT error lines, each naming its fix.
ct_fail() {
  local n=$1 w=$2; shift 2
  ct_run "$n" "$@"
  [ "$rc" -eq 1 ] || { echo "cite exited $rc, not 1: $(first "$T/log/$n.err")"; return 1; }
  [ "$(grep -c . "$T/log/$n.err")" = "$w" ] || { echo "expected $w error lines, got: $(cat "$T/log/$n.err")"; return 1; }
  [ "$(grep -c '; fix: ' "$T/log/$n.err")" = "$w" ] || { echo "an error line names no fix: $(cat "$T/log/$n.err")"; return 1; }
}
# ct_pass NAME ARGS...: exit 0 and no stderr.
ct_pass() { local n=$1; shift; ct_run "$n" "$@"; [ "$rc" -eq 0 ] && [ ! -s "$T/log/$n.err" ] || { echo "cite exited $rc: $(first "$T/log/$n.err")"; return 1; }; }
# ct_err NAME TEXT: NAME's error output holds TEXT.
ct_err() { grep -qF -- "$2" "$T/log/$1.err" || { echo "$1 error lacks: $2"; return 1; }; }
# ct_is NAME LINE: one line of NAME's error output is exactly LINE.
ct_is() { grep -qxF -- "$2" "$T/log/$1.err" || { echo "$1 has no error line: $2"; return 1; }; }
# ct_put DIR PATH LINE...: write PATH under DIR, one LINE per line, and stage it in DIR's git index.
ct_put() {
  local d=$1 p=$2; shift 2
  mkdir -p "$(dirname "$d/$p")" && printf '%s\n' "$@" >"$d/$p" || return 1
  [ -d "$d/.git" ] || git -C "$d" init -q || return 1
  git -C "$d" add -- "$p"
}
CT1() {   # AC 1, #311 R1 at 1daa66b, then lists, sentence ends, anchors with parentheses, a missing target
  local d=$T/ct/r311
  ct_put "$d" references/contract.md '## Review' '' 'Any new head gets a fresh cumulative review before merge.' 'Rounds are bounded (three by default).' || return 1
  ct_put "$d" references/pre-merge.md \
    '   obligation. (a) When it needs a code change, implementing or fix follows,' \
    '   and the new head gets the fresh cumulative review' \
    '   [contract.md](contract.md) requires' \
    '   ("A new head requires fresh cumulative review"). (b) When the planner shows' || return 1
  ct_fail CT1 1 --worktree "$d" || return 1
  ct_err CT1 'launch.sh: cite: references/pre-merge.md: link contract.md ("A new head requires fresh cumulative review"): the anchor "A new head requires fresh cumulative review" does not occur in references/contract.md; fix: quote a heading or verbatim phrase that references/contract.md holds' || return 1
  ct_put "$d" references/pre-merge.md '   [contract.md](contract.md) requires' '   ("Any new head gets a' '   fresh cumulative review"). (b)' || return 1
  ct_pass CT1b --worktree "$d" || return 1
  ct_put "$d" README.md \
    '[contract](references/contract.md) ("## Review" and "No such phrase"), [gone](gone.md) ("x"), [run](https://example.com/x) ("y").' \
    '[contract](references/contract.md) ("## Review", "Also absent") and [contract](references/contract.md) ("A missing phrase (detail)").' \
    '[contract](references/contract.md) "## Review." ("Absent after a quoted heading")' || return 1
  ct_fail CT1c 5 --worktree "$d" || return 1
  ct_err CT1c 'the anchor "No such phrase" does not occur in references/contract.md' || return 1
  ct_err CT1c 'the anchor "Also absent" does not occur in references/contract.md' || return 1
  ct_err CT1c 'the anchor "A missing phrase (detail)" does not occur in references/contract.md' || return 1
  ct_err CT1c 'the anchor "Absent after a quoted heading" does not occur in references/contract.md' || return 1
  ct_is CT1c 'launch.sh: cite: README.md: link gone.md ("x"): the target gone.md is not in the tree; fix: link a file the tree holds, and quote a heading or verbatim phrase that it holds, as ("anchor")' || return 1
  ct_put "$d" README.md \
    'See [contract](references/contract.md). ("Not in the contract") opens the next sentence, so it is no anchor.' \
    'Is it [contract](references/contract.md)? ("Nor this") opens one too.' \
    '[contract](references/contract.md) ("Rounds are bounded (three by default)") and [contract](references/contract.md) "## Review." ("Any new head gets a").' || return 1
  ct_pass CT1d --worktree "$d"
}
CT2() {   # AC 1: the checked-out repository tree passes; usage and input errors exit 2
  local root; root=$(cd "$here/.." && pwd) || return 1
  ct_pass CT2 --worktree "$root" || return 1
  bash "$LAUNCH_SH" cite 2>/dev/null; [ $? -eq 2 ] || { echo "no --worktree not exit 2"; return 1; }
  bash "$LAUNCH_SH" cite --worktree ct 2>/dev/null; [ $? -eq 2 ] || { echo "relative --worktree not exit 2"; return 1; }
  bash "$LAUNCH_SH" cite --worktree "$T/log" 2>/dev/null; [ $? -eq 2 ] || { echo "non-git worktree not exit 2"; return 1; }
  bash "$LAUNCH_SH" cite --worktree "$root" --plan "$T/ct/none.md" 2>/dev/null; [ $? -eq 2 ] || { echo "missing plan not exit 2"; return 1; }
  bash "$LAUNCH_SH" cite --worktree "$root" --rev 0000000000000000000000000000000000000000 2>/dev/null; [ $? -eq 2 ] || { echo "bad --rev not exit 2"; return 1; }
}
CT3() {   # AC 3, #306 PR1-02 at baa6eee: line-only citations at plan lines 257 and 264
  local d=$T/ct/t306
  ct_put "$d" CONTRIBUTING.md '| **Misattributed owner.** For each owner link and quoted anchor that a plan or diff adds, review opens the owner at the quoted text. | x | review | y |' || return 1
  cat >"$T/ct/p306.md" <<'EOF'
   The reviewer should find no restated behavior, and each pointer's anchor should state the rule it is cited for (`CONTRIBUTING.md:10`).
| `CONTRIBUTING.md:10` | applies | Each new anchor is checked in its owner (G2–G4) and by review |
EOF
  ct_fail CT3 2 --plan "$T/ct/p306.md" --worktree "$d" || return 1
  ct_err CT3 "$T/ct/p306.md:1: CONTRIBUTING.md:10: no quoted anchor; fix: quote a heading or verbatim phrase that CONTRIBUTING.md holds" || return 1
  ct_err CT3 "$T/ct/p306.md:2: CONTRIBUTING.md:10: no quoted anchor" || return 1
  cat >"$T/ct/p306.md" <<'EOF'
   The reviewer should find no restated behavior, and each pointer's anchor should state the rule it is cited for (`CONTRIBUTING.md:10` ("**Misattributed owner.**")).
| `CONTRIBUTING.md:10` ("**Misattributed owner.**") | applies | Each new anchor is checked in its owner (G2–G4) and by review |
EOF
  ct_pass CT3b --plan "$T/ct/p306.md" --worktree "$d"
}
CT4() {   # AC 3, #316 PR7 at 0c4b366: line 38 line-only; line 102 ellipsis anchor and a planned anchor cited as present
  local d=$T/ct/t316
  ct_put "$d" scripts/launch.sh '#   launch.sh pack PACK --worktree DIR' '# Exit: 0 ok; 1 check violation; 2 usage or' || return 1
  ct_put "$d" references/pack.md 'An evidence check is bitten before the brief that depends on it launches, except for the deferred assertions named below.' || return 1
  ct_put "$d" .capstan/vocabulary.md '**Evidence check**: a script or multi-step command.' || return 1
  cat >"$T/ct/p316.md" <<'EOF'
- Output: exit 0 when the pack is clean. Otherwise exit 1 with one stderr line per missing file. Exit 2 for a usage or input error. The exit codes reuse the header contract at `scripts/launch.sh:36`.
| Base-case and changed-check bite (AC 1) | `references/pack.md` ("A check group whose planned assertion requires") | `.capstan/vocabulary.md` ("**Evidence check**") already links to `references/pack.md` ("An evidence check is bitten before…"); unchanged. `CONTRIBUTING.md` row "Dropped inventory or case" links to the same anchor; unchanged. The new feature Gotcha links and states no behavior. |
EOF
  ct_fail CT4 3 --plan "$T/ct/p316.md" --worktree "$d" || return 1
  ct_err CT4 "$T/ct/p316.md:1: scripts/launch.sh:36: no quoted anchor" || return 1
  ct_err CT4 "$T/ct/p316.md:2: references/pack.md (\"An evidence check is bitten before…\"): the anchor \"An evidence check is bitten before…\" does not occur in references/pack.md; an ellipsis is not verbatim text; fix:" || return 1
  ct_err CT4 "$T/ct/p316.md:2: references/pack.md (\"A check group whose planned assertion requires\")" || return 1
  cat >"$T/ct/p316.md" <<'EOF'
- Output: exit 0 when the pack is clean. Otherwise exit 1 with one stderr line per missing file. Exit 2 for a usage or input error. The exit codes reuse the header contract at `scripts/launch.sh:36` ("# Exit: 0 ok; 1 check violation").
| Base-case and changed-check bite (AC 1) | `references/pack.md`, new sentence "A check group whose planned assertion requires" | `.capstan/vocabulary.md` ("**Evidence check**") already links to `references/pack.md` ("An evidence check is bitten before the brief that depends on it launches"); unchanged. `CONTRIBUTING.md` row "Dropped inventory or case" links to the same anchor; unchanged. The new feature Gotcha links and states no behavior. |
EOF
  ct_pass CT4b --plan "$T/ct/p316.md" --worktree "$d"
}
CT5() {   # AC 3, #278 F3 at 2a69df1: line 77's ellipsis anchor fails; lines 43 and 64 (no citation) pass
  local d=$T/ct/t278
  ct_put "$d" references/contract.md 'Budget begins at spec admission. Loss of local telemetry does not reset it.' || return 1
  ct_put "$d" references/telemetry.md 'On a failed attempt, `exit=N error=REDACTED;` follows EFFORT.' || return 1
  cat >"$T/ct/p278.md" <<'EOF'
   - Remove "`toolchain/` and `tooling/` are pile when present." Owner: this file, "The pile is exactly `briefs/`, … `toolchain/`, `tooling/`, and `events.jsonl` when present." Guards #10.
   - "A failed attempt's notes line carries its exit status and redacted raw error." Owner: the notes rule. In that rule, change "On a failed attempt, `exit=N error=REDACTED;` follows EFFORT." to "… follows EFFORT, with the exit status and the redacted raw error." so the owner states the whole rule.
9. **G2-C14, `run.md`/events paragraph.** Replace "Budget start still survives from the earliest remote activity or summary timestamp. Loss of the pile does not reset the budget. Resume does not reset budgets." with "Remote progress evidence preserves budget and rerun history across local deletion; loss of the pile or a resume does not reset a budget." Also remove "Unreported usage is `unknown`, never zero and never estimated." Owners: `contract.md` ("Budget begins … Loss of local telemetry does not reset it.") and the Tokens bullet ("never zero or an estimate").
EOF
  ct_fail CT5 1 --plan "$T/ct/p278.md" --worktree "$d" || return 1
  ct_err CT5 "$T/ct/p278.md:3: contract.md (\"Budget begins … Loss of local telemetry does not reset it.\"): the anchor \"Budget begins … Loss of local telemetry does not reset it.\" does not occur in references/contract.md; an ellipsis is not verbatim text" || return 1
  sed 's/("Budget begins … Loss of local telemetry does not reset it.")/("Loss of local telemetry does not reset it.")/' "$T/ct/p278.md" >"$T/ct/p278b.md" || return 1
  ct_pass CT5b --plan "$T/ct/p278b.md" --worktree "$d" || return 1
  ct_put "$d" templates/contract.md 'A second file with the same name.' || return 1
  ct_fail CT5c 1 --plan "$T/ct/p278b.md" --worktree "$d" || return 1
  ct_err CT5c 'contract.md: 2 files in the tree have this name; fix: cite it by its path from the repository root'
}
CT6() {   # AC 3, #318 PR4 at 7349d97: "(step 3)" and "(item 7)" in place of an anchor; --rev reads the commit
  local d=$T/ct/t318
  ct_put "$d" references/planning.md 'For each rule sentence the plan adds or changes in a procedure file, the plan lists its owners.' || return 1
  printf '%s\n' '- What the plan lists for each changed rule sentence: `references/planning.md` (step 3).' \
    '- The same file by item: `references/planning.md` (item 7).' >"$T/ct/p318.md"
  ct_fail CT6 2 --plan "$T/ct/p318.md" --worktree "$d" || return 1
  ct_err CT6 "$T/ct/p318.md:1: references/planning.md (step 3): a step or item number is not an anchor; fix: quote a heading or verbatim phrase that references/planning.md holds" || return 1
  ct_err CT6 "$T/ct/p318.md:2: references/planning.md (item 7): a step or item number is not an anchor" || return 1
  printf '%s\n' '- What the plan lists for each changed rule sentence: `references/planning.md` ("For each rule sentence the plan adds or changes in a procedure file").' >"$T/ct/p318.md"
  ct_pass CT6b --plan "$T/ct/p318.md" --worktree "$d" || return 1
  git -C "$d" -c user.name=t -c user.email=t@example.invalid commit -qm base || return 1
  printf '%s\n' 'Rewritten.' >"$d/references/planning.md"
  ct_fail CT6c 1 --plan "$T/ct/p318.md" --worktree "$d" || return 1
  ct_pass CT6d --plan "$T/ct/p318.md" --worktree "$d" --rev HEAD
}
CT7() {   # AC 3, #280 PR3 at 31591d9: row G4-C7 links references/toolchain.md with no anchor
  local d=$T/ct/t280
  ct_put "$d" references/toolchain.md 'The brief carries the exact invocation.' || return 1
  ct_put "$d" templates/brief.md '## Worker constraints' || return 1
  cat >"$T/ct/p280.md" <<'EOF'
| G4-C7 | AC 1, 2, 3 | File: `templates/brief.md` · anchor "- Declared-check invocation" · denied-shape list kept (L8) · Removed: «(one plain command, tool path, provenance; [references/harnesses/claude.md](../references/harnesses/claude.md) owns the write-station shell grant; no» Replacement: «([references/toolchain.md](../references/toolchain.md) preflight result: one plain command, tool path, provenance; no» · Owners: ⟨templates/brief.md ("## Worker constraints"); templates/brief.md ("owns the write-station grant"); references/toolchain.md ("The brief carries the exact invocation.")⟩ | Markdown-only rule. Groups B, F, G; denied list dropped → `FAIL B: templates/brief.md paragraph 1 differs` | claude.md not named (gap) |
EOF
  ct_fail CT7 1 --plan "$T/ct/p280.md" --worktree "$d" || return 1
  ct_err CT7 "$T/ct/p280.md:1: [references/toolchain.md](../references/toolchain.md): no quoted anchor; fix: quote a heading or verbatim phrase that references/toolchain.md holds" || return 1
  sed 's#«(\[references/toolchain.md\](../references/toolchain.md) preflight#«([references/toolchain.md](../references/toolchain.md) ("The brief carries the exact invocation.") preflight#' "$T/ct/p280.md" >"$T/ct/p280b.md" || return 1
  ct_pass CT7b --plan "$T/ct/p280b.md" --worktree "$d"
}
CT8() {   # AC 3: #310 plan revision 1 (https://github.com/comamitc/capstan/issues/310#issuecomment-6277110623), review found no citation finding
  local d=$T/ct/t310
  ct_put "$d" CONTRIBUTING.md '## Rules' '| **Dropped inventory or case.** A procedure covers every item. | this file | review | x |' || return 1
  ct_put "$d" references/pack.md 'An evidence check is bitten before the brief that depends on it launches, except for the deferred assertions named below.' || return 1
  ct_put "$d" references/planning.md 'Each check group names the planted defect it rejects.' || return 1
  ct_put "$d" .capstan/features/issue-delivery.md '- Bite timing for evidence checks the initial plan writes: owned elsewhere.' || return 1
  ct_put "$d" README.md '## Development and provenance' || return 1
  cat >"$T/ct/p310.md" <<'PLAN310'
<!-- source: https://github.com/comamitc/capstan/issues/310#issuecomment-6277110623 author_association=OWNER created_at=2026-10-19T20:54:44Z -->
<!-- capstan:plan comamitc/capstan#310 -->
# Plan

Plan revision: 1 (initial), 2026-10-19T20:54:41Z; planning worker result: planning-1 (claude opus-5-5)

Specification revision / issue body updatedAt: 2026-10-19T20:43:31Z
Observed head / base: 834ada7c7d38169faef9d5aa5f565ce7166aa0ea / 834ada7c7d38169faef9d5aa5f565ce7166aa0ea
Planning step (initial / single correction) / review artifact / correction launch: initial / none / none

## Current behavior and data shape

- **The row.** `CONTRIBUTING.md` ("## Rules") holds a four-column table: Rule | Owner | Enforcer | Occurrences. The "Dropped inventory or case" row (`:11`) states a procedure-coverage rule and the review sentences. Its owner is `this file`, its enforcer is `review`, and it has five occurrence entries. It places no obligation on the author before writing.
- **The bite.** `references/pack.md` states the bite one sentence per line, from "An evidence check is bitten before the brief that depends on it launches" (`:100`) to "The next review pack carries the change …" (`:115`). It requires one planted defect per evidence check and one per carried finding (`:108`). It does not require one per item of an inventory the check claims to preserve.
- **Why that matters.** A check like #263 G3 matches only some phrases. It can pass a plant that deletes an unmatched duty, and it reaches plan review undetected (#263 R2).

## Simplicity decision

- **Level:** standards text plus a coordinator procedure change (D7). There is no new script, lint or row (D12), and no edits to planning, plan-review or templates (D13).
- **`CONTRIBUTING.md`:** one row rewrite.
- **`references/pack.md`:** five added lines.
- **`.capstan/features/issue-delivery.md`:** one pointer line.
- **Reuse:** the existing bite (known-good case, fixture, deferred assertions, ledger line) and the existing defective-check rules, by reference.

## Ordered items

| Item | Acceptance criterion | Observable outcome / affected area | Verification command and failure signal | Risk |
| --- | --- | --- | --- | --- |
| 1 | AC 1 | `CONTRIBUTING.md:11`, the "Dropped inventory or case" row: replace the whole line with the row below this table. | Markdown-only rule (text checks): evidence groups C1a–C1e. Failure: `FAIL C1*`. Review reads the row on the PR diff. | Restating the bite in the row. Mitigated by the owner pointer and gate C1e. |
| 2 | AC 2(a) | `references/pack.md`: insert the five lines below this table directly after "Plant at least one defect per evidence check and one per carried finding the check claims to close." (`:108`) and before "When no known-good candidate exists yet, …" (`:109`). Change no existing line. | Markdown-only rule: groups P1 (rejects base), P2 (gate), P3 (rejects base) and P4 (gate). Failure: `FAIL P*`. | #316 overlap (D14). Only lines are added. |
| 3 | AC 2 (doc impact) | `.capstan/features/issue-delivery.md`: after the line "- Bite timing for evidence checks the initial plan writes: …" (`:39`), add the pointer line below this table. | Markdown-only rule: group F1 (rejects base). Failure: `FAIL F1`. | None. |
| 4 | AC 2(b) | Reviewer walkthrough of the new rule over #263 G3 (below this table). The implementer copies it into the PR body. | Review reads the walkthrough against the PR diff and the carried G3 text. Failure: no per-item plant passes G3, or the new text would not class G3 as defective. | `count_flat` is not carried (gap). |
| 5 | AC 3 | CI runs `bash scripts/test-launch.sh` (`.github/workflows/check.yml`) on the PR head. | CI check on the PR. Failure: a non-zero exit or a last line other than `PASS`. | None. Markdown only. |
| 6 | D12, D13, scope | Only `CONTRIBUTING.md`, `references/pack.md` and `.capstan/features/issue-delivery.md` change. No untracked files are added. | Markdown-only rule: group S (gate). Failure: `FAIL S`. | None. |

**Item 1: replacement row** (the whole line):

```
| **Dropped inventory or case.** Before the author of a plan or diff writes a step, rewrite, or check, the author lists each inventory item, each part of the required coverage, and each case that the criteria require, and names for each one the step that covers it and the check that fails when it is removed or changed; [references/pack.md](references/pack.md) ("An evidence check is bitten before the brief that depends on it launches") owns how that check is bitten. A procedure covers every item of the inventory it names, every part of the coverage its criteria require, and every case its criteria require. Review lists that inventory, coverage, and those cases from the criteria, looks for each one in the procedure, and reports each one it cannot find. | this file | review | #200 F2, F5 @ 592fced; #208 PR1, PR3 @ ebd36de; #209 F3, F4 @ 33df6d4; #210 F3 @ 4199f58; #229 PR1 @ 40a9bf6; #256 R6 @ e9f6228; #262 PR2 @ 3246d15; #263 R2, R3 @ 93cf81e; #265 F3 @ 548861e; #279 PR1 @ d78e384; #280 PR4 @ 31591d9; #295 PR2 @ 29c68b8; #297 F10 @ ee0b04d; #298 PR1 @ fde779c; #299 PR5, PR7 @ 6afd13c; #303 PR6 @ 4818ef3; #308 R3 @ 6687c75 |
```

- The authoring obligation comes first and binds the plan or diff author before writing.
- The two existing sentences stay word for word. Owner `this file` and enforcer `review` stay.
- The five existing entries are followed by the twelve D4 entries in delivery-number order, 17 deliveries in all, which matches D4's count.
- The bite is stated only by owner and anchor.

**Item 2: five lines added to `references/pack.md`**:

```
When an evidence check claims to preserve an inventory or a set of cases, the bite plants, for each item, a defect that removes or changes only that item, and the check must fail on each such plant.
A check claims this when its group's named planted defect, the plan item it verifies, or the criterion it is derived from names items to keep, such as rows, sentences, duties, entries, or cases.
A per-item plant deletes that one item, or rewrites only its required behavior, and keeps every other item and every phrase the check matches outside that item; every item is planted, with no sample.
Per-item plants are planted defects, so this paragraph's known-good case, synthetic fixture, named deferred assertions, and `ledger.md` notes line apply to each one.
A check that passes on one of these plants is a defective evidence check.
```

How each point the brief asks for is settled:
- **How the coordinator knows a check claims an inventory:** line 2 names the group's planted defect, the plan item and the source criterion.
- **What a per-item plant is:** line 3 covers rows, sentences, duties, entries and cases. Per D8 every item is planted, with no sample.
- **How plants fit the fixture, deferred-assertion and ledger rules:** line 4 names those rules without restating them.
- **What a passing plant means:** line 5 makes the check defective. The existing `:103` and `:114` sentences and the `:98` gap-table row then apply, so no new row is added.
- **D14:** the insertion touches only the per-item plant and edits no existing line.

**Item 3: pointer line for `.capstan/features/issue-delivery.md`**:

```
- Per-item plants when an evidence check claims to preserve an inventory or a set of cases: [pack](../../references/pack.md) ("When an evidence check claims to preserve an inventory or a set of cases") owns that rule.
```

**Item 4: walkthrough over #263 G3** (plan revision 1, base 93cf81e85015420762aee9816caf2dec28acd492, review R2 https://github.com/comamitc/capstan/issues/263#issuecomment-6173495752)

**Is G3 an inventory check?** Yes, on two grounds from line 2 of the new text:
- G3's named planted defect is "vocabulary write left unplanned, or a duty deleted".
- Plan item 2 says "The feature-map and doc-page duties stay word-for-word".

**The items G3 claims to keep, in `references/implementing.md` step 3** (anchors from the carried R2 row):
- (i) the new vocabulary plan-naming sentence;
- (ii) the feature-map plan-naming phrase "the plan names the feature file and the index line";
- (iii) the doc-page plan-naming phrase "The plan names that page.";
- (iv) the feature-map same-commit duty "Write that update in the same commit as the behavior";
- (v) the documentation-correction same-commit duty "Write the correction in the same commit as the behavior";
- (vi) the vocabulary same-commit duty "The implementation commit for a repository-scoped term creates or updates `.capstan/vocabulary.md`".

**Per-item plants and the outcome read from the carried G3 lines:**

| Item | Per-item plant | Carried G3 line that decides | Outcome |
| --- | --- | --- | --- |
| (i) | Delete the sentence | G3a needs `n -eq 1`; `n=0` | `FAIL G3a`: caught |
| (ii) | Delete the phrase | G3b `count_flat` finds no match, `rc≠0` | `FAIL G3b`: caught |
| (iii) | Delete the phrase | G3c, `rc≠0` | `FAIL G3c`: caught |
| (iv) | Delete "Write that update in the same commit as the behavior" and keep (i)–(iii) | No G3 line matches this text. G3a, G3b and G3c all still match. | **G3 passes** |
| (v) | Delete "Write the correction in the same commit as the behavior" and keep the rest | Same as (iv) | **G3 passes** |
| (vi) | Delete "The implementation commit for a repository-scoped term creates or updates `.capstan/vocabulary.md`" and keep the rest | G3a matches the plan-naming sentence, not the duty | **G3 passes** |

- Under new line 5, a pass on plant (iv), (v) or (vi) makes G3 a defective evidence check.
- The bite runs after plan publication and before the plan-review brief launches (`pack.md:102`). So `:103` repairs G3 before plan review and records old and new in `ledger.md`. R2 would not have needed plan review to find it.

## Documentation impact

| Changed behavior | Canonical path | Decision | Verification |
| --- | --- | --- | --- |
| Authoring obligation for dropped inventory | `CONTRIBUTING.md` ("## Rules") | change (item 1) | C1a–C1e |
| Per-item plant in the bite | `references/pack.md` ("An evidence check is bitten before the brief that depends on it launches") | change (item 2) | P1–P4 |
| Issue-delivery feature map | `.capstan/features/issue-delivery.md` ("Bite timing for evidence checks the initial plan writes") | change: add one owner pointer (item 3), the same pattern as `:36-42` | F1 |
| Planning, plan review, templates | `references/planning.md`, `references/plan-review.md`, `templates/` | no change (D13): `planning.md:103` already points to the bite owner | S |
| Acceptance bar | `README.md` ("Development and provenance") | no change: the declared check is unchanged | item 5 |

## Final proof

| Order | Declared check (exact command) | Heavy |
| --- | --- | --- |
| 1 | `bash scripts/test-launch.sh` (cwd the worktree; CI `.github/workflows/check.yml`) | no (pack carries no heavy mark; gap) |

**Evidence check** (Markdown-only rule). The coordinator bites it under the delivery's evidence root, per `references/pack.md` ("An evidence check is bitten before the brief that depends on it launches"). It runs under `bash`.

```bash
#!/usr/bin/env bash
# Evidence check, comamitc/capstan#310, criteria 1 and 2 (Markdown-only rule).
cd "${CHECK_ROOT:-/home/mcomardo/dev/capstan/.worktrees/capstan+310}" || exit 2
BASE=834ada7c7d38169faef9d5aa5f565ce7166aa0ea
C=CONTRIBUTING.md P=references/pack.md F=.capstan/features/issue-delivery.md
fail=0
ok()  { echo "ok $1"; }
bad() { echo "FAIL $1"; fail=1; }
once() { local n rc; n=$(grep -Fxc -- "$1" "$2"); rc=$?; [ "$rc" -eq 0 ] && [ "$n" -eq 1 ]; }
pos()  { local o rc; o=$(grep -nFx -- "$1" "$P"); rc=$?; [ "$rc" -eq 0 ] || { echo 0; return 1; }; echo "${o%%:*}"; }

# C1 row: exactly one "Dropped inventory or case" row.
n=$(grep -Fc '| **Dropped inventory or case.** ' "$C"); rc=$?
row=$(grep -F '| **Dropped inventory or case.** ' "$C"); rc2=$?
{ [ "$rc" -eq 0 ] && [ "$n" -eq 1 ] && [ "$rc2" -eq 0 ]; } && ok C1row || { bad "C1row rc=$rc n=$n"; row=; }

# C1a (rejects base) planted defect: any part of the authoring obligation removed or changed; variant: sentence moved within the row.
AUTH='Before the author of a plan or diff writes a step, rewrite, or check, the author lists each inventory item, each part of the required coverage, and each case that the criteria require, and names for each one the step that covers it and the check that fails when it is removed or changed'
[[ $row == *"$AUTH"* ]] && ok C1a || bad C1a

# C1b (gate) planted defect: either review sentence removed or changed; variant: sentences follow the new one.
R1='A procedure covers every item of the inventory it names, every part of the coverage its criteria require, and every case its criteria require.'
R2='Review lists that inventory, coverage, and those cases from the criteria, looks for each one in the procedure, and reports each one it cannot find.'
[[ $row == *"$R1"* ]] && ok C1b1 || bad C1b1
[[ $row == *"$R2"* ]] && ok C1b2 || bad C1b2

# C1c (rejects base) planted defect: owner, enforcer, or any one occurrence entry removed, changed, or reordered; variant: rule cell reworded.
OCC='#200 F2, F5 @ 592fced; #208 PR1, PR3 @ ebd36de; #209 F3, F4 @ 33df6d4; #210 F3 @ 4199f58; #229 PR1 @ 40a9bf6; #256 R6 @ e9f6228; #262 PR2 @ 3246d15; #263 R2, R3 @ 93cf81e; #265 F3 @ 548861e; #279 PR1 @ d78e384; #280 PR4 @ 31591d9; #295 PR2 @ 29c68b8; #297 F10 @ ee0b04d; #298 PR1 @ fde779c; #299 PR5, PR7 @ 6afd13c; #303 PR6 @ 4818ef3; #308 R3 @ 6687c75'
[[ $row == *"| this file | review | $OCC |" ]] && ok C1c || bad C1c

# C1d (rejects base) planted defect: bite-owner pointer removed or its anchor changed; variant: pointer placed elsewhere in the rule cell.
PTR='[references/pack.md](references/pack.md) ("An evidence check is bitten before the brief that depends on it launches")'
n=$(grep -Fc 'An evidence check is bitten before the brief that depends on it launches' "$P"); rc=$?
{ [[ $row == *"$PTR"* ]] && [ "$rc" -eq 0 ] && [ "$n" -ge 1 ]; } && ok C1d || bad "C1d rc=$rc n=$n"

# C1e (gate, negative) planted defect: the row restates bite terms; variant: the owner pointer alone.
printf '%s\n' "$row" | grep -Fiq -e 'planted' -e 'known-good' -e 'synthetic fixture' -e 'ledger.md' -e 'deferred assertion'; rc=$?
[ "$rc" -eq 1 ] && ok C1e || bad "C1e rc=$rc"

# P1 (rejects base) planted defect: any new line removed or changed; variant: other pack.md lines edited.
mapfile -t NEW <<'EOF'
When an evidence check claims to preserve an inventory or a set of cases, the bite plants, for each item, a defect that removes or changes only that item, and the check must fail on each such plant.
A check claims this when its group's named planted defect, the plan item it verifies, or the criterion it is derived from names items to keep, such as rows, sentences, duties, entries, or cases.
A per-item plant deletes that one item, or rewrites only its required behavior, and keeps every other item and every phrase the check matches outside that item; every item is planted, with no sample.
Per-item plants are planted defects, so this paragraph's known-good case, synthetic fixture, named deferred assertions, and `ledger.md` notes line apply to each one.
A check that passes on one of these plants is a defective evidence check.
EOF
for i in "${!NEW[@]}"; do once "${NEW[$i]}" "$P" && ok "P1.$((i+1))" || bad "P1.$((i+1))"; done

# P2 (gate) planted defect: any existing bite line removed or changed; variant: lines inserted between them.
mapfile -t KEEP <<'EOF'
An evidence check is bitten before the brief that depends on it launches, except for the deferred assertions named below.
A command the coordinator writes from plan text for a pack's `## Checks` is an evidence check even when the plan quotes it; a declared check is not an evidence check, and [references/toolchain.md](toolchain.md) owns its preflight.
An evidence check the initial plan writes is bitten after the coordinator publishes that plan and before the plan-review brief launches, by the method below.
When that bite shows a defective check, the coordinator repairs it before plan review, records the old and new check in `ledger.md`, and repeats the bite; later packs carry the repaired check until the single correction changes it.
A check that passes that bite goes to plan review unchanged, and no repair is recorded.
The plan-review pack carries the bite outcomes and any repair as carried evidence, and the plan reviewer judges whether a repair weakened the check.
A check that the single correction changes, or that a worker reports defective, is bitten again before the brief that depends on it launches.
The coordinator runs the evidence check against at least one known-good case, which it passes, and at least one planted defect, which it fails.
Plant at least one defect per evidence check and one per carried finding the check claims to close.
When no known-good candidate exists yet, the coordinator either bites the check on a synthetic fixture or names the assertions that cannot run until the candidate exists.
A synthetic fixture is a scratch copy with a representative edit built from the plan's text; it stays outside the product worktree, is a scratch git clone with a commit when the check inspects commits or diffs, and is never given to a worker.
Named deferred assertions are the only exception to the pre-launch bite; the coordinator bites them at the closure proof gate, before review starts.
The coordinator records a notes line in `ledger.md` naming each check's command, the known-good outcome, and each planted defect's outcome and exit.
Evidence scripts stay under the delivery's evidence root, outside the repository.
When a worker reports a defective evidence check, the worker does not repair it; the coordinator repairs it, records the old and new check in `ledger.md`, and repeats the bite.
The next review pack carries the change, and the reviewer judges whether it weakened the check.
EOF
for i in "${!KEEP[@]}"; do once "${KEEP[$i]}" "$P" && ok "P2.$((i+1))" || bad "P2.$((i+1))"; done

# P3 (rejects base) planted defect: a new line placed outside the bite rule; variant: the five lines in another order inside it.
lo=$(pos "${KEEP[8]}") || bad P3lo
hi=$(pos "${KEEP[9]}") || bad P3hi
for i in "${!NEW[@]}"; do
  p=$(pos "${NEW[$i]}") && [ "$p" -gt "$lo" ] && [ "$p" -lt "$hi" ] && ok "P3.$((i+1))" || bad "P3.$((i+1))"
done

# P4 (gate) planted defect: a new row in the gap table, or the defective-check row changed; variant: rows added to other tables.
IFS= read -r DEFROW <<'EOF'
| any station reporting a defective evidence check | repair the check as the coordinator, record old and new in ledger.md, and repeat the bite; then continue by that station's row above, so after single correction the pass stays consumed and the repaired check is carried in the implementing pack |
EOF
t=$(awk '/^\| Station returning a pack gap \|/{f=1} f&&/^$/{exit} f' "$P"); rc=$?
n=$(printf '%s\n' "$t" | grep -c '^| '); rc2=$?
{ [ "$rc" -eq 0 ] && [ "$rc2" -eq 0 ] && [ "$n" -eq 6 ] && once "$DEFROW" "$P"; } && ok P4 || bad "P4 rc=$rc/$rc2 n=$n"

# F1 (rejects base) planted defect: feature pointer removed or its anchor changed; variant: other feature lines edited.
FB='- Per-item plants when an evidence check claims to preserve an inventory or a set of cases: [pack](../../references/pack.md) ("When an evidence check claims to preserve an inventory or a set of cases") owns that rule.'
once "$FB" "$F" && ok F1 || bad F1

# S (gate) planted defect: planning.md, plan-review.md, templates/, or a new script changed or added; variant: edits to the three named files only.
ch=$(git diff --name-only "$BASE" --); rc=$?
un=$(git ls-files --others --exclude-standard); rc2=$?
extra=$(printf '%s\n' "$ch" "$un" | grep -v '^$' | grep -vFx -e "$C" -e "$P" -e "$F"); rc3=$?
{ [ "$rc" -eq 0 ] && [ "$rc2" -eq 0 ] && [ "$rc3" -eq 1 ]; } && ok S || bad "S rc=$rc/$rc2/$rc3 extra=$extra"

[ "$fail" -eq 0 ] && { echo PASS; exit 0; }
echo FAIL; exit 1
```

**Per-item plants the bite runs** (new `pack.md` line 1; each must print `FAIL`):

| Group | Inventory item → plant |
| --- | --- |
| C1a | Each of 7 parts of the obligation, one plant each: actor "author of a plan or diff" → "reviewer"; "Before" → "After"; drop "each inventory item"; drop "each part of the required coverage"; drop "each case that the criteria require"; drop "the step that covers it"; drop "the check that fails when it is removed or changed". |
| C1b | Delete R1. Delete R2. Change R2's "reports each one" to "reports the first one". |
| C1c | Owner → `references/pack.md`. Enforcer → `named check`. Delete each one of the 17 entries (17 plants). Swap two entries. Change one SHA, for example `93cf81e` → `93cf81f`. |
| C1d | Delete the pointer. Change its anchor to "An evidence check is bitten". |
| C1e | Append "the bite plants each item as a planted defect" to the row. |
| P1 | Delete each of the 5 lines (5 plants). Also change "for each item" → "for a sample of items", drop "the plan item it verifies", drop "with no sample", drop "named deferred assertions", and change "is a defective evidence check" → "is reported". |
| P2 | Delete each of the 16 existing lines (16 plants), including known-good `:107`, plant floor `:108`, fixture `:109-110`, deferred `:111` and ledger `:112`. |
| P3 | Move each new line after `:115` (5 plants). |
| P4 | Add the row "\| per-item plant passes \| … \|". Change "repeat the bite" in the defective-check row. |
| F1 | Delete the pointer. Change its anchor. |
| S | Edit `references/planning.md`. Edit `references/plan-review.md`. Edit `templates/plan.md`. Add an untracked `scripts/check-inventory.sh`. |

- **Known-good case:** the candidate head after items 1–3. The coordinator builds it as a synthetic fixture (a scratch clone with a commit made from this plan's text) until the candidate exists. No assertion is deferred.
- **Reject the base (exit 1 at 834ada7):** C1a, C1c, C1d, P1, P3, F1.
- **Gates (pass at the base):** C1row, C1b, C1e, P2, P4, S.

## Revision response

none (initial plan)

PLAN310
  ct_pass CT8 --plan "$T/ct/p310.md" --worktree "$d"
}
CT9() {   # D14 forms: whole-file path, timestamp, URL, policy-row key, non-anchor ellipsis, fence, outside paths, a range
  local d=$T/ct/t9
  ct_put "$d" references/pack.md 'Pack check: every file.' || return 1
  ct_put "$d" AGENTS.md '- The integration base is `main`.' || return 1
  cat >"$T/ct/p9.md" <<'EOF'
- `references/pack.md` names the rule; see `references/pack.md`.
- spec revision 2026-10-20T15:12:49Z, round 1, at 15:12 UTC; run https://example.com:8080/x and [run](https://github.com/o/r/actions/runs/1).
- `AGENTS.md:3` — "The integration base is `main`."
- `AGENTS.md:3` — "The integration base is `staging`."
   - In that rule, change "On a failed attempt, `exit=N error=REDACTED;` follows EFFORT." to "… follows EFFORT, with the exit status."
```
- Pointer: [pack](references/pack.md) ("A planned anchor") owns that rule.
```
- Pointer: [pack](references/pack.md) ("A planned anchor") owns that rule.
- `docs/elsewhere.md:4` and `checks/occurrences/plan-306-r1.md:257` ("`CONTRIBUTING.md:10`") are outside the tree.
- `references/pack.md`, new sentence "A planned anchor".
- See `AGENTS.md:1-3` for the base.
EOF
  ct_fail CT9 3 --plan "$T/ct/p9.md" --worktree "$d" || return 1
  ct_err CT9 "$T/ct/p9.md:4: AGENTS.md:3 (\"The integration base is \`staging\`.\"): the anchor" || return 1
  ct_err CT9 "$T/ct/p9.md:9: [pack](references/pack.md) (\"A planned anchor\"): the anchor \"A planned anchor\" does not occur in references/pack.md" || return 1
  ct_err CT9 "$T/ct/p9.md:12: AGENTS.md:1-3: no quoted anchor"
}
CT10() {   # D14: an anchor's own text is never read as a citation; a citation after the anchor still is
  local d=$T/ct/t10
  ct_put "$d" AGENTS.md 'See CONTRIBUTING.md:10 for the row.' || return 1
  ct_put "$d" CONTRIBUTING.md '| **Misattributed owner.** x |' || return 1
  printf '%s\n' '- `AGENTS.md` ("See CONTRIBUTING.md:10") names the row.' \
    '- [agents](AGENTS.md) ("See CONTRIBUTING.md:10") and `AGENTS.md:1` ("See CONTRIBUTING.md:10") name it too.' >"$T/ct/p10.md"
  ct_pass CT10 --plan "$T/ct/p10.md" --worktree "$d" || return 1
  printf '%s\n' '- `AGENTS.md` ("See CONTRIBUTING.md:10") names the row, and so does `CONTRIBUTING.md:10` with no anchor.' >"$T/ct/p10.md"
  ct_fail CT10b 1 --plan "$T/ct/p10.md" --worktree "$d" || return 1
  ct_is CT10b "launch.sh: cite: $T/ct/p10.md:1: CONTRIBUTING.md:10: no quoted anchor; fix: quote a heading or verbatim phrase that CONTRIBUTING.md holds, as (\"anchor\")"
}
# pkr_tree: $T/pkr/references/contract.md with "## Global non-goals" at line 124, as at 6afd13c.
pkr_tree() {
  local i
  mkdir -p "$T/pkr/references" || return 1
  { for ((i = 1; i <= 123; i++)); do echo "filler line $i"; done
    printf '%s\n' '## Global non-goals' '' 'These global non-goals apply to every Capstan file and every mode file. Capstan' 'never adds:'
    for ((i = 128; i <= 155; i++)); do echo "filler line $i"; done
  } >"$T/pkr/references/contract.md"
}
# pkr_run NAME PACK WANT [TEXT]: launch.sh pack with worktree $T/pkr exits WANT; with WANT 1, one error line holding TEXT.
pkr_run() {
  bash "$LAUNCH_SH" pack "$2" --worktree "$T/pkr" >"$T/log/$1.out" 2>"$T/log/$1.err"; rc=$?
  [ "$rc" -eq "$3" ] || { echo "pack exited $rc, not $3: $(first "$T/log/$1.err")"; return 1; }
  if [ "$3" -eq 0 ]; then [ ! -s "$T/log/$1.err" ] || { echo "stderr: $(first "$T/log/$1.err")"; return 1; }; return 0; fi
  [ "$(grep -c . "$T/log/$1.err")" = 1 ] && grep -qF -- "$4" "$T/log/$1.err" || { echo "expected one error with: $4; got: $(cat "$T/log/$1.err")"; return 1; }
}
PK10() {   # AC 2, #299 PR8: the planning-pack entry's range 126-150 misses "## Global non-goals" at line 124 (6afd13c)
  pkr_tree || return 1
  printf '%s\n' '## Rules that apply' '- `references/contract.md:131-132` — "a Capstan executable"' '## Named files' \
    '- `references/contract.md:126-150` ("## Global non-goals") — executable non-goal, #181 exception, permit list.' >"$T/pk/r299.md"
  pkr_run PK10 "$T/pk/r299.md" 1 'launch.sh: pack: references/contract.md:126-150 ("## Global non-goals"): the anchor is not inside lines 126-150 of references/contract.md; fix: widen the range to the lines that hold it' || return 1
  printf '%s\n' '## Rules that apply' '- `references/contract.md:131-132` — "a Capstan executable"' '## Named files' \
    '- `references/contract.md:124-150` ("## Global non-goals") — executable non-goal, #181 exception, permit list.' >"$T/pk/r299.md"
  pkr_run PK10b "$T/pk/r299.md" 0
}
PK11() {   # AC 2: no anchor (full, compact), a compact range miss, a whole-file entry, and paths outside the worktree
  local R='Rule: `references/contract.md:131-132` — "a Capstan executable"' H='## Rules that apply' Q='- `references/contract.md:131-132` — "a Capstan executable"'
  pkr_tree || return 1
  printf '%s\n' "$H" "$Q" '## Named files' '- `references/contract.md:124-150` — executable non-goal' >"$T/pk/r-none.md"
  pkr_run PK11 "$T/pk/r-none.md" 1 'launch.sh: pack: references/contract.md:124-150: no quoted anchor; fix: write' || return 1
  printf '%s\n' '## Candidate' 'item' 'Criterion: AC 2 — "x"' "$R" 'Check: `true`, expected exit 0' \
    'Named file: `references/contract.md:126-150` ("## Global non-goals") — exception' >"$T/pk/r-compact.md"
  pkr_run PK11b "$T/pk/r-compact.md" 1 'the anchor is not inside lines 126-150 of references/contract.md; fix: widen' || return 1
  printf '%s\n' '## Candidate' 'item' 'Criterion: AC 2 — "x"' "$R" 'Check: `true`, expected exit 0' \
    'Named file: `references/contract.md:124-150` — exception' >"$T/pk/r-compact.md"
  pkr_run PK11c "$T/pk/r-compact.md" 1 'launch.sh: pack: references/contract.md:124-150: no quoted anchor; fix: write' || return 1
  printf '%s\n' '## Candidate' 'item' 'Criterion: AC 2 — "x"' "$R" 'Check: `true`, expected exit 0' \
    'Named file: `references/contract.md:124-150` ("## Global non-goals") — exception' >"$T/pk/r-compact.md"
  pkr_run PK11d "$T/pk/r-compact.md" 0 || return 1
  printf '%s\n' "$H" "$Q" '## Named files' '- `references/contract.md` ("never adds:") — whole file' \
    '- `checks/occurrences/x.md:1-5` ("not in the worktree") — evidence-root file' \
    '- `/elsewhere/y.md:1-2` ("outside the worktree") — absolute path' >"$T/pk/r-out.md"
  pkr_run PK11e "$T/pk/r-out.md" 0 || return 1
  printf '%s\n' "$H" "$Q" '## Named files' '- `references/contract.md` ("never adds anything") — whole file' >"$T/pk/r-whole.md"
  pkr_run PK11f "$T/pk/r-whole.md" 1 'launch.sh: pack: references/contract.md ("never adds anything"): the anchor does not occur in references/contract.md; fix:'
}

case $PC_SHELLS in *zsh*) ;; *) echo "skip PC1-zsh: zsh not on PATH" ;; esac
for c in K1 K2 K3 K4 K5 K6 K7 W1 P1 P2 PK1 PK2 PK3 PK4 PK5 PK6 PK7 PK8 PK9 PK10 PK11 CT1 CT2 CT3 CT4 CT5 CT6 CT7 CT8 CT9 CT10 G1 G2 G3 G4 G5 G6 G7 G8 G9 C1 C2 C3 C3b C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 \
  C14 C15 C16 C17 C18 C19 C20 C21 C22 C23 S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 O1 O2 O3 PC1 PC2 PC3 PC4 PC5 PC6 PC7 PC8 PC9 \
  C24 C25 C26 C27 C28 C29 C30 C31 C32 Y1 Y2 S12 TS1 TS2 TS3 TS4 TS5 TC1 TC2 TC3 TC4 TC5 TH1 TH2; do
  t "$c" "$c"
done
[ "$fails" -eq 0 ] || exit 1
echo PASS
