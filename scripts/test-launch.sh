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
# P is a private result directory directly beneath /tmp (S9).
P=
trap 'chmod -R u+rwx "$T" 2>/dev/null; rm -rf "$T" ${P:+"$P"}' EXIT
P=$(mktemp -d /tmp/launch-test.XXXXXX) || setup "mktemp -d /tmp/launch-test.XXXXXX failed"
export HOME=$T/home
mkdir -p "$T/home/real" "$T/home/adir" "$T/wt" "$T/res" "$T/brief" "$T/b" "$T/r" \
  "$T/bin" "$T/log" "$T/exp" "$T/k" "$T/c" "$T/g" "$T/outdir" "$T/s1" "$T/s2" "$T/s3" "$T/s4" "$T/s5" \
  "$T/s6/h" "$T/s6o" "$T/c13" "$T/c14wt/in" "$T/c15/wt" "$T/c16wt/in" "$T/c17/h" "$T/wt/s5" "$T/o2" "$T/o3" \
  "$T/s7" "$T/s7o" "$T/s8" "$T/s9" "$T/c19" || setup "cannot create fixture directories"
chmod 1777 "$T/s7" "$T/c19" || setup "cannot chmod the shared fixture directories"
ln -s "$T/wt" "$T/s5l" && ln -s "$T/s6/h" "$T/s6l" && ln -s "$T/c16wt" "$T/c16l" && ln -s "$T/c17/h" "$T/c17l" \
  && ln -s "$T/s7" "$T/s7l" && ln -s "$T/c19" "$T/c19l" || setup "cannot create fixture links"

LF=$T/brief/launch.md
printf 'launch prompt %s.%s\n' "$$" "$RANDOM" >"$LF" || setup "cannot write the launch file"
LAUNCH_CONTENT=$(cat "$LF")
: >"$T/res/r.md" || setup "cannot write fixtures"

for b in claude codex; do
  cat >"$T/bin/$b" <<'EOF' || setup "cannot write stub $b"
#!/usr/bin/env bash
echo "cwd=$PWD"
echo "tmpdir=${TMPDIR-}"
for a in "$@"; do printf 'arg=%s\n' "$a"; done
echo "stdin=$(cat)"
EOF
  chmod 755 "$T/bin/$b" || setup "cannot chmod stub $b"
done

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
cwd=$T/res
tmpdir=$T/res/tmp
arg=exec
arg=-C
arg=$T/res
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
  local name=$1 kind=$2 exp=$3 out=$T/k/$1.sh rc
  shift 3
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$kind" --out "$out" "${COMMON[@]}" "$@") \
    >"$T/log/$name.out" 2>"$T/log/$name.err"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "write exited $rc: $(first "$T/log/$name.err")"; return 1; }
  [ "$(mode "$out")" = -rwx------ ] || { echo "mode is $(mode "$out"), not -rwx------"; return 1; }
  (cd "$T/r" && TMPDIR=$T/ambient PATH="$T/bin:$PATH" "$out") >"$T/log/$name.run" 2>&1
  rc=$?
  [ "$rc" -eq 0 ] || { echo "run script exited $rc: $(first "$T/log/$name.run")"; return 1; }
  diff "$exp" "$T/log/$name.run" >"$T/log/$name.diff" \
    || { echo "argv differs: $(grep '^[<>]' "$T/log/$name.diff" | head -n 1)"; return 1; }
  (cd "$T/r" && bash "$LAUNCH_SH" check "$out" --worktree "$T/wt") 2>"$T/log/$name.chk"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "check exited $rc: $(first "$T/log/$name.chk")"; return 1; }
  case $kind in
    claude-write*) [ "$(cat "$T/log/$name.out")" = "$LEDGER" ] || { echo "ledger is: $(first "$T/log/$name.out")"; return 1; } ;;
    codex-read*) [ "$(mode "$T/res/tmp")" = drwx------ ] || { echo "tmp mode is $(mode "$T/res/tmp"), not drwx------"; return 1; } ;;
  esac
}
K1() { k_case K1 claude-write "$T/exp/K1" "${ADDS[@]}" --allow "$ALLOW" --host-source "$T/home/src.md"; }
K2() { k_case K2 claude-read "$T/exp/K2" "${ADDS[@]}" --allow "$ALLOW"; }
K3() { k_case K3 claude-write-probe "$T/exp/K3" "${ADDS[@]}" --allow "$ALLOW" --host-source "$T/home/src.md"; }
K4() { k_case K4 codex-write "$T/exp/K4" "${ADDS[@]}" --result "$T/res/result.md"; }
K5() { k_case K5 codex-read "$T/exp/K5" --result "$T/res/result.md"; }
K6() { k_case K6 codex-read-probe "$T/exp/K5" --result "$T/res/result.md"; }
K7() {
  [ -s "$T/log/K5.run" ] && [ -s "$T/log/K6.run" ] || { echo "K5 or K6 produced no output"; return 1; }
  cmp -s "$T/log/K5.run" "$T/log/K6.run" || { echo "codex-read-probe output differs from codex-read"; return 1; }
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
  sed -e "s|^'$T/res'\$|'$T/wt'|" -e "s|^cd -- '$T/res'\$|cd -- '$T/wt'|" "$T/c/C8.base" >"$T/c/C8.sh"
  c_expect C8 "$T/r" "-C must be the result directory for codex-read: $T/wt"
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
  sed "s|^'TMPDIR=$T/res/tmp'\$|'TMPDIR=$T/brief'|" "$T/c/C11.base" >"$T/c/C11.sh"
  c_expect C11 "$T/r" "TMPDIR must be $T/res/tmp for codex-read: $T/brief"
}
C12() { # --add-dir in a read-kind script
  c_build C12 codex-read || return 1
  sed -e "/^'--json'\$/i\\" -e "'--add-dir'" -e "/^'--json'\$/i\\" -e "'$T/brief'" "$T/c/C12.base" >"$T/c/C12.sh"
  c_expect C12 "$T/r" "flag not in the codex-read recipe: --add-dir"
}
C13() { # a TMPDIR directory loosened after write
  local rc
  c_build C13 codex-read "$T/c13/result.md" || return 1
  chmod 755 "$T/c13/tmp" || { echo "cannot chmod $T/c13/tmp"; return 1; }
  (cd "$T/r" && bash "$LAUNCH_SH" check "$T/c/C13.base" --worktree "$T/wt") 2>"$T/log/C13.chk"
  rc=$?
  [ "$rc" -eq 1 ] || { echo "check exited $rc, not 1"; return 1; }
  grep -qF -- "TMPDIR is not an owner-only directory: $T/c13/tmp" "$T/log/C13.chk" || { echo "stderr lacks: TMPDIR is not an owner-only directory"; return 1; }
}

# ---- #225 PR1/PR2/R1: check refuses a root at, in, around, or aliasing the worktree, at or above HOME, or shared (C14-C19) ----

c_roots() { # NAME KIND DIR WORKTREE HOME MESSAGE: move -C, cd, the result and TMPDIR of a KIND build into DIR; check wants exit 1 and MESSAGE
  local rc
  c_build "$1" "$2" || return 1
  [ -d "$3/tmp" ] || mkdir -m 700 -- "$3/tmp" || { echo "cannot create $3/tmp"; return 1; }
  sed -e "s|^'$T/res'\$|'$3'|" -e "s|^cd -- '$T/res'\$|cd -- '$3'|" -e "s|^'$T/res/result.md'\$|'$3/result.md'|" \
    -e "s|^'TMPDIR=$T/res/tmp'\$|'TMPDIR=$3/tmp'|" "$T/c/$1.base" >"$T/c/$1.sh"
  [ "$(grep -cxF -e "'$3'" -e "cd -- '$3'" -e "'$3/result.md'" -e "'TMPDIR=$3/tmp'" "$T/c/$1.sh")" = 4 ] \
    || { echo "the four path edits did not all apply"; return 1; }
  (cd "$T/r" && HOME=$5 bash "$LAUNCH_SH" check "$T/c/$1.sh" --worktree "$4") 2>"$T/log/$1.chk"
  rc=$?
  [ "$rc" -eq 1 ] || { echo "check exited $rc, not 1"; return 1; }
  grep -qF -- "$6" "$T/log/$1.chk" || { echo "stderr lacks: $6"; return 1; }
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
  [ ! -e "$T/s3/run.sh" ] && [ ! -e "$T/s3/tmp" ] || { echo "OUT or tmp was written"; return 1; }
  no_tmp "$T/s3" || { echo "a .launch.* file was left"; return 1; }
}
S4() { # an existing tmp/ that is not owner-only is refused
  local rc
  mkdir -m 755 "$T/s4/tmp" || { echo "cannot create $T/s4/tmp"; return 1; }
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind codex-read --out "$T/s4/run.sh" --worktree "$T/wt" \
    --launch-file "$LF" --result "$T/s4/result.md") >/dev/null 2>"$T/log/S4.err"
  rc=$?
  [ "$rc" -eq 2 ] || { echo "write exited $rc, not 2"; return 1; }
  grep -qF -- "not an owner-only directory: $T/s4/tmp" "$T/log/S4.err" || { echo "stderr lacks: not an owner-only directory"; return 1; }
  [ ! -e "$T/s4/run.sh" ] || { echo "OUT was written"; return 1; }
}
S5() { # write refuses a result directory at, inside, aliasing, or holding the worktree, both read kinds
  local rc k res msg
  for k in codex-read codex-read-probe; do
    while IFS='|' read -r res msg; do
      (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$k" --out "$T/s5/run.sh" --worktree "$T/wt" \
        --launch-file "$LF" --result "$res") >/dev/null 2>"$T/log/S5.err"
      rc=$?
      [ "$rc" -eq 2 ] || { echo "$k --result $res: write exited $rc, not 2"; return 1; }
      grep -qF -- "$msg" "$T/log/S5.err" || { echo "$k --result $res: stderr lacks: $msg"; return 1; }
      [ ! -e "$T/s5/run.sh" ] && [ ! -e "${res%/*}/tmp" ] || { echo "$k --result $res: OUT or tmp was written"; return 1; }
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
  for k in codex-read codex-read-probe; do
    for res in "$T/s6/h/result.md" "$T/s6/result.md" "$T/s6l/result.md"; do
      (cd "$T/b" && HOME=$T/s6/h bash "$LAUNCH_SH" write --kind "$k" --out "$T/s6o/run.sh" --worktree "$T/wt" \
        --launch-file "$LF" --result "$res") >/dev/null 2>"$T/log/S6.err"
      rc=$?
      [ "$rc" -eq 2 ] || { echo "$k --result $res: write exited $rc, not 2"; return 1; }
      grep -qF -- "is HOME or an ancestor of it" "$T/log/S6.err" || { echo "$k --result $res: stderr lacks: is HOME or an ancestor of it"; return 1; }
      [ ! -e "$T/s6o/run.sh" ] && [ ! -e "${res%/*}/tmp" ] || { echo "$k --result $res: OUT or tmp was written"; return 1; }
      no_tmp "$T/s6o" || { echo "$k --result $res: a .launch.* file was left"; return 1; }
    done
  done
}
S7() { # write refuses a shared (1777) result directory or a symlink to it, both read kinds
  local rc k res
  for k in codex-read codex-read-probe; do
    for res in "$T/s7/result.md" "$T/s7l/result.md"; do
      (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$k" --out "$T/s7o/run.sh" --worktree "$T/wt" \
        --launch-file "$LF" --result "$res") >/dev/null 2>"$T/log/S7.err"
      rc=$?
      [ "$rc" -eq 2 ] || { echo "$k --result $res: write exited $rc, not 2"; return 1; }
      grep -qF -- "result directory $T/s7 is writable by group or others" "$T/log/S7.err" \
        || { echo "$k --result $res: stderr lacks: result directory $T/s7 is writable by group or others"; return 1; }
      [ ! -e "$T/s7o/run.sh" ] && [ ! -e "$T/s7/tmp" ] || { echo "$k --result $res: OUT or tmp was written"; return 1; }
      no_tmp "$T/s7o" || { echo "$k --result $res: a .launch.* file was left"; return 1; }
    done
  done
}
S8() { # write refuses --result /tmp/NAME.md and leaves /tmp/tmp as it was, both read kinds
  # The worktree and HOME are this script's directory, so that neither the worktree
  # nor the HOME rule refuses /tmp first; the fixtures under $T may sit beneath /tmp.
  local rc k before after
  case $(realpath "$here")/ in "$(realpath /tmp)"/*) echo "this case needs the repository outside /tmp: $here"; return 1 ;; esac
  for k in codex-read codex-read-probe; do
    before=0 after=0
    [ ! -e /tmp/tmp ] || before=1
    (cd "$T/b" && HOME=$here bash "$LAUNCH_SH" write --kind "$k" --out "$T/s8/run.sh" --worktree "$here" \
      --launch-file "$LF" --result "/tmp/launch-test-$$.md") >/dev/null 2>"$T/log/S8.err"
    rc=$?
    [ ! -e /tmp/tmp ] || after=1
    [ "$rc" -eq 2 ] || { echo "$k: write exited $rc, not 2"; return 1; }
    grep -qF -- "is not owned by the current user" "$T/log/S8.err" || { echo "$k: stderr lacks: is not owned by the current user"; return 1; }
    [ "$before" = "$after" ] || { echo "$k: /tmp/tmp was created"; return 1; }
    [ ! -e "$T/s8/run.sh" ] || { echo "$k: OUT was written"; return 1; }
  done
}
S9() { # a private directory beneath /tmp still builds and checks, both read kinds
  local rc k
  for k in codex-read codex-read-probe; do
    (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$k" --out "$T/s9/$k.sh" --worktree "$T/wt" \
      --launch-file "$LF" --result "$P/result.md") >/dev/null 2>"$T/log/S9.err"
    rc=$?
    [ "$rc" -eq 0 ] || { echo "$k: write exited $rc: $(first "$T/log/S9.err")"; return 1; }
    [ "$(mode "$P/tmp")" = drwx------ ] || { echo "$k: tmp mode is $(mode "$P/tmp"), not drwx------"; return 1; }
    (cd "$T/r" && bash "$LAUNCH_SH" check "$T/s9/$k.sh" --worktree "$T/wt") 2>"$T/log/S9.chk"
    rc=$?
    [ "$rc" -eq 0 ] || { echo "$k: check exited $rc: $(first "$T/log/S9.chk")"; return 1; }
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

for c in K1 K2 K3 K4 K5 K6 K7 P1 P2 G1 G2 G3 G4 G5 G6 G7 G8 G9 C1 C2 C3 C3b C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 \
  C14 C15 C16 C17 C18 C19 S1 S2 S3 S4 S5 S6 S7 S8 S9 O1 O2 O3; do
  t "$c" "$c"
done
[ "$fails" -eq 0 ] || exit 1
echo PASS
