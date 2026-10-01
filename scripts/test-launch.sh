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

T=$(mktemp -d) && T=$(realpath "$T") || setup "mktemp -d failed"
trap 'chmod -R u+rwx "$T" 2>/dev/null; rm -rf "$T"' EXIT
export HOME=$T/home
mkdir -p "$T/home/real" "$T/home/adir" "$T/wt" "$T/res" "$T/brief" "$T/b" "$T/r" \
  "$T/bin" "$T/log" "$T/exp" "$T/k" "$T/c" "$T/g" "$T/outdir" "$T/s1" "$T/s2" "$T/o2" "$T/o3" \
  || setup "cannot create fixture directories"

LF=$T/brief/launch.md
printf 'launch prompt %s.%s\n' "$$" "$RANDOM" >"$LF" || setup "cannot write the launch file"
LAUNCH_CONTENT=$(cat "$LF")
: >"$T/res/r.md" || setup "cannot write fixtures"

for b in claude codex; do
  cat >"$T/bin/$b" <<'EOF' || setup "cannot write stub $b"
#!/usr/bin/env bash
echo "cwd=$PWD"
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
COMMON=(--worktree "$T/wt" --launch-file "$LF" --model m1 --effort high --add-dir "$T/res" --add-dir "$T/brief")

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
cwd=$T/wt
arg=exec
arg=-C
arg=$T/wt
arg=-s
arg=read-only
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

k_case() { # NAME KIND EXPECTED [ARGS...]: build from $T/b, run from $T/r, diff, mode, check
  local name=$1 kind=$2 exp=$3 out=$T/k/$1.sh rc
  shift 3
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$kind" --out "$out" "${COMMON[@]}" "$@") \
    >"$T/log/$name.out" 2>"$T/log/$name.err"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "write exited $rc: $(first "$T/log/$name.err")"; return 1; }
  [ "$(mode "$out")" = -rwx------ ] || { echo "mode is $(mode "$out"), not -rwx------"; return 1; }
  (cd "$T/r" && PATH="$T/bin:$PATH" "$out") >"$T/log/$name.run" 2>&1
  rc=$?
  [ "$rc" -eq 0 ] || { echo "run script exited $rc: $(first "$T/log/$name.run")"; return 1; }
  diff "$exp" "$T/log/$name.run" >"$T/log/$name.diff" \
    || { echo "argv differs: $(grep '^[<>]' "$T/log/$name.diff" | head -n 1)"; return 1; }
  (cd "$T/r" && bash "$LAUNCH_SH" check "$out") 2>"$T/log/$name.chk"
  rc=$?
  [ "$rc" -eq 0 ] || { echo "check exited $rc: $(first "$T/log/$name.chk")"; return 1; }
  case $kind in
    claude-write*) [ "$(cat "$T/log/$name.out")" = "$LEDGER" ] || { echo "ledger is: $(first "$T/log/$name.out")"; return 1; } ;;
  esac
}
K1() { k_case K1 claude-write "$T/exp/K1" --allow "$ALLOW" --host-source "$T/home/src.md"; }
K2() { k_case K2 claude-read "$T/exp/K2" --allow "$ALLOW"; }
K3() { k_case K3 claude-write-probe "$T/exp/K3" --allow "$ALLOW" --host-source "$T/home/src.md"; }
K4() { k_case K4 codex-write "$T/exp/K4" --result "$T/res/result.md"; }
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

# ---- AC 3: check (C1-C7) ----

c_build() { # NAME KIND: build the unedited fixture $T/c/NAME.base
  local -a args=(--worktree "$T/wt" --launch-file "$LF" --add-dir "$T/res" --add-dir "$T/brief")
  case $2 in claude-*) args+=(--allow "$ALLOW") ;; esac
  case $2 in claude-write*) args+=(--host-source "$T/home/src.md") ;; codex-*) args+=(--result "$T/res/result.md") ;; esac
  (cd "$T/b" && bash "$LAUNCH_SH" write --kind "$2" --out "$T/c/$1.base" "${args[@]}") >/dev/null 2>"$T/log/$1.build" \
    || { echo "fixture build exited non-zero: $(first "$T/log/$1.build")"; return 1; }
  [ -f "$T/c/$1.base" ] || { echo "fixture was not built"; return 1; }
}
c_expect() { # NAME CWD MESSAGE: check $T/c/NAME.sh from CWD; want exit 1 and MESSAGE on stderr
  local rc
  cmp -s "$T/c/$1.base" "$T/c/$1.sh" && { echo "fixture edit did not apply"; return 1; }
  (cd "$2" && bash "$LAUNCH_SH" check "$T/c/$1.sh") 2>"$T/log/$1.chk"
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

for c in K1 K2 K3 K4 K5 K6 K7 P1 P2 G1 G2 G3 G4 G5 G6 G7 G8 C1 C2 C3 C3b C4 C5 C6 C7 S1 S2 O1 O2 O3; do
  t "$c" "$c"
done
[ "$fails" -eq 0 ] || exit 1
echo PASS
