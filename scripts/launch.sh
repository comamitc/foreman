#!/usr/bin/env bash
# Capstan launch builder. The coordinator runs it; workers never do. It writes
# and checks the run script for one Claude or Codex worker launch. It does not
# launch, supervise, or redact. The recipes in references/harnesses/claude.md,
# codex.md, and shared.md ("Launch probe") are the specification: where this
# file differs, this file is wrong.
#
#   launch.sh write --kind K --worktree DIR --launch-file FILE --out RUN_SCRIPT
#       [--model M] [--effort E] [--add-dir DIR]... [--allow ENTRY]...
#       [--host-source FILE] [--result FILE]
#     K: claude-write, claude-read, claude-write-probe, codex-write, codex-read,
#     codex-read-probe. Prints the Host grant: line for claude-write*.
#     codex-read and codex-read-probe start in work/ beneath the --result
#     directory, create work/ and work/tmp/ owner-only with work/tmp as TMPDIR,
#     and refuse --add-dir and a --result that is a symlink or resolves into
#     work/. references/harnesses/codex.md ("owns the Codex read-station result
#     rule") governs the result file. They refuse
#     a --result directory that is, holds, or sits inside --worktree, or that is
#     $HOME or above it, compared by canonical path, or that is not owned by
#     the user or is writable by group or others.
#   launch.sh check RUN_SCRIPT [--worktree DIR]
#     --worktree is required for codex-read and codex-read-probe: their run
#     script does not name the worktree, and check applies the --result rule above.
#   launch.sh grant --source FILE --worktree DIR
#
# Exit: 0 ok; 1 check violation (for write, no script was written); 2 usage or
# input error. Every path input must be absolute.
set -u

MCP='{"mcpServers":{}}'
CLAUDE_WRITE_ALLOW=('Bash(git add *)' 'Bash(git commit *)' 'Bash(git status *)' 'Bash(git diff *)'
  'Bash(git log *)' 'Bash(git rev-parse *)' 'Bash(git show *)' 'Bash(git restore -- *)')
CLAUDE_WRITE_DENY=('Bash(git checkout *)' 'Bash(git reset --hard *)' 'Bash(git push *)' 'Bash(gh *)')
CLAUDE_READ_ALLOW=('Bash(git status *)' 'Bash(git rev-parse *)' 'Bash(git diff *)')
CLAUDE_READ_DENY=('Bash(grep -r*)' 'Bash(grep -R*)' 'Bash(grep --recursive*)'
  'Bash(grep --dereference-recursive*)' 'Bash(rg *)' 'Bash(find *)')
CLAUDE_FLAGS=' -p --verbose --disable-slash-commands --strict-mcp-config --permission-mode --output-format --model --effort --permission-prompts --add-dir --allowedTools --disallowedTools --mcp-config --tools '
KINDS=' claude-write claude-read claude-write-probe codex-write codex-read codex-read-probe '
ALLOW_RE='^Bash\(.+\)$'
READ_RE='^Read\(/(/.*)\)$'
SAFE_RE='^/[A-Za-z0-9._+@-]+(/[A-Za-z0-9._+@-]+)*$'
EFFORT_RE='^model_reasoning_effort="[^"]*"$'
HEAD_RE='^# Capstan launch \((claude-write|claude-read|claude-write-probe|codex-write|codex-read|codex-read-probe)\)\. Written by scripts/launch\.sh; verify with scripts/launch\.sh check\.$'
CD_RE="^cd -- '(/[^']*)'\$"
EXEC0='exec "${argv[@]}"'

die() { printf 'launch.sh: %s\n' "$*" >&2; exit 2; }
need_abs() { case $2 in /*) ;; *) die "$1 must be an absolute path: $2" ;; esac; }
need_plain() { case $2 in *"'"* | *$'\n'*) die "$1 cannot hold a quote or newline: $2" ;; esac; }
is_abs_dir() { case $1 in /*) [ -d "$1" ] ;; *) return 1 ;; esac; }
safe_path() { [[ $1 =~ $SAFE_RE ]] || return 1; case "$1/" in */./* | */../*) return 1 ;; esac; }
mode_of() { local m; m=$(ls -ld -- "$1" 2>/dev/null) && printf '%s' "${m:0:10}"; }

# root_bad RESULT_DIR WORKTREE: prints why RESULT_DIR cannot be the parent of a
# codex read kind's private writable root, RESULT_DIR/work, by canonical path;
# prints nothing when it can. Its location and permissions bound that root.
root_bad() {
  local rd rw hm
  rd=$(realpath -e -- "$1" 2>/dev/null) || { printf 'result directory does not resolve: %s' "$1"; return 0; }
  rw=$(realpath -e -- "$2" 2>/dev/null) || { printf 'worktree does not resolve: %s' "$2"; return 0; }
  hm=$(realpath -e -- "${HOME:-}" 2>/dev/null) || { printf 'HOME does not resolve: %s' "${HOME-}"; return 0; }
  case ${rd%/}/ in "${rw%/}"/*) printf 'result directory %s is inside the worktree %s' "$rd" "$rw"; return 0 ;; esac
  case ${rw%/}/ in "${rd%/}"/*) printf 'result directory %s contains the worktree %s' "$rd" "$rw"; return 0 ;; esac
  case ${hm%/}/ in "${rd%/}"/*) printf 'result directory %s is HOME or an ancestor of it' "$rd"; return 0 ;; esac
  # A shared directory such as /tmp, /var/tmp, or /dev/shm cannot be the parent of that root.
  [ -O "$rd" ] || { printf 'result directory %s is not owned by the current user' "$rd"; return 0; }
  case $(mode_of "$rd") in ?????w???? | ????????w?) printf 'result directory %s is writable by group or others' "$rd" ;; esac
  return 0
}

# ---- grant: the host-grant rule of references/harnesses/claude.md ----

# Prints each inline code span of a Markdown file whose whole content is a path
# starting with ~/ or /, in source order. Fenced blocks are skipped: a fence is
# closed only by the same character, at least as long, with nothing after it.
# A fence inside a blockquote or list item is a fence too: each line is first
# matched against the open containers (tabs expanded to 4 columns), and a fence
# also ends where its container ends.
SPAN_AWK='
function opens(s,   i, n, c) {
  i = 1; while (i <= 3 && substr(s, i, 1) == " ") i++
  c = substr(s, i, 1)
  if (c != "`" && c != "~") return 0
  n = 0; while (substr(s, i + n, 1) == c) n++
  if (n < 3) return 0
  if (c == "`" && index(substr(s, i + n), "`")) return 0
  fc = c; fl = n; return 1
}
function closes(s,   i, n) {
  i = 1; while (i <= 3 && substr(s, i, 1) == " ") i++
  n = 0; while (substr(s, i + n, 1) == fc) n++
  return n >= fl && substr(s, i + n) ~ /^[ \t]*$/
}
function scan(s,   i, j, n, m, len, span) {
  len = length(s); i = 1
  while (i <= len) {
    if (substr(s, i, 1) == "\\") { i += 2; continue }
    if (substr(s, i, 1) != "`") { i++; continue }
    n = 0; while (substr(s, i + n, 1) == "`") n++
    j = i + n
    while (j <= len) {
      if (substr(s, j, 1) != "`") { j++; continue }
      m = 0; while (substr(s, j + m, 1) == "`") m++
      if (m == n) break
      j += m
    }
    if (j > len) { i += n; continue }
    span = substr(s, i + n, j - i - n)
    gsub(/\n/, " ", span)
    if (span ~ /^ .* $/ && span !~ /^ *$/) span = substr(span, 2, length(span) - 2)
    if (span ~ /^(~\/|\/)[^[:space:]]*$/) print span
    i = j + n
  }
}
function flush() { if (blk != "") scan(blk); blk = "" }
function untab(s,   o, c, i) {
  o = ""
  for (i = 1; i <= length(s); i++) {
    c = substr(s, i, 1)
    if (c != "\t") o = o c
    else do { o = o " " } while (length(o) % 4)
  }
  return o
}
function sp(s,   n) { n = 0; while (substr(s, n + 1, 1) == " ") n++; return n }
# rest(s): matches s against the open containers (ct[i] "q" for a blockquote,
# "l" for a list item with content column cw[i]); sets km to the number
# matched and returns what follows them.
function rest(s,   n) {
  for (km = 0; km < nc; km++) {
    n = sp(s)
    if (ct[km + 1] == "q") {
      if (n > 3 || substr(s, n + 1, 1) != ">") break
      s = substr(s, n + 2); if (substr(s, 1, 1) == " ") s = substr(s, 2)
    } else if (s !~ /^ *$/) {
      if (n < cw[km + 1]) break
      s = substr(s, cw[km + 1] + 1)
    }
  }
  return s
}
# starts(s): opens each blockquote or list item that starts s; returns the rest.
function starts(s,   n, m, k, t, c) {
  while (1) {
    n = sp(s)
    if (n > 3) return s
    t = substr(s, n + 1)
    if (substr(t, 1, 1) == ">") {
      ct[++nc] = "q"; s = substr(t, 2); if (substr(s, 1, 1) == " ") s = substr(s, 2)
      continue
    }
    if (!match(t, /^([-+*]|[0-9]+[.)])/)) return s
    m = RLENGTH; c = substr(t, m + 1, 1)
    if (c != " " && c != "") return s
    k = sp(substr(t, m + 1))
    if (k > 4 || substr(t, m + k + 1) == "") k = 1
    ct[++nc] = "l"; cw[nc] = n + m + k; s = substr(s, n + m + k + 1)
  }
}
{
  s = rest(untab($0))
  if (infence) {
    if (km == nc) { if (closes(s)) infence = 0; next }
    infence = 0
  }
  k = nc; nc = km; s = starts(s)
  if (opens(s)) { flush(); infence = 1; next }
  if (nc == km && km < k && blk != "" && s !~ /^ *$/) nc = k # lazy paragraph line
}
/^[ \t]*$/ { flush(); next }
{ blk = (blk == "" ? $0 : blk "\n" $0) }
END { flush() }
'

# grant SOURCE WORKTREE: sets GRANT_LINE (the ledger line) and GRANT_READS
# (the Read(//...) entries, each E then R when R differs).
grant() {
  local src=$1 wtr p e r why paths seen=$'\n' granted= skipped=
  GRANT_READS=()
  if ! [ -e "$src" ]; then GRANT_LINE='Host grant: no host-directed files; source missing'; return; fi
  if ! [ -f "$src" ]; then GRANT_LINE='Host grant: no host-directed files; source not a regular file'; return; fi
  if ! [ -r "$src" ]; then GRANT_LINE='Host grant: no host-directed files; source unreadable'; return; fi
  wtr=$(realpath -- "$2")
  paths=$(awk "$SPAN_AWK" "$src")
  if [ -z "$paths" ]; then GRANT_LINE='Host grant: no host-directed files; source names no path'; return; fi
  while IFS= read -r p; do
    case $p in '~/'*) e=$HOME${p#'~'} ;; *) e=$p ;; esac
    case $seen in *$'\n'"$e"$'\n'*) continue ;; esac
    seen=$seen$e$'\n'
    why= r=
    if ! [ -e "$e" ]; then
      why=missing
    else
      r=$(realpath -- "$e")
      if [ -d "$r" ]; then why=directory
      elif ! [ -f "$r" ]; then why='not a regular file'
      elif ! [ -r "$r" ]; then why=unreadable
      elif [ "$r" = "$wtr" ] || [ "${r#"$wtr"/}" != "$r" ]; then why='inside the worktree'
      elif ! safe_path "$e" || ! safe_path "$r"; then why='unsafe path'
      fi
    fi
    if [ -n "$why" ]; then skipped=${skipped:+$skipped, }"$p ($why)"; continue; fi
    GRANT_READS+=("Read(/$e)")
    if [ "$r" = "$e" ]; then
      granted=${granted:+$granted, }$e
    else
      GRANT_READS+=("Read(/$r)")
      granted=${granted:+$granted, }"$e -> $r"
    fi
  done <<EOF
$paths
EOF
  if [ -n "$granted" ]; then GRANT_LINE="Host grant: $granted${skipped:+; skipped $skipped}"
  else GRANT_LINE="Host grant: no host-directed files; skipped $skipped"; fi
}

# ---- check: validate a run script without running it ----

v() { printf 'launch.sh: check: %s: %s\n' "$CK" "$*" >&2; VIOL=$((VIOL + 1)); }
pos_bad() { PB_F+=("$1"); PB_W+=("$2"); }

# list_items FLAG START END: accept or reject the words W[START..END-1] of a
# Claude list-taking flag for KIND.
list_items() {
  local f=$1 s=$2 e=$3 j k item phase=base
  local -a exp=()
  if [ "$s" -eq "$e" ]; then v "missing value for $f"; return; fi
  case $f in
    --add-dir | --mcp-config | --tools)
      for ((j = s; j < e; j++)); do
        item=${W[j]}
        if [ "$j" -gt "$s" ]; then pos_bad "$f" "$item"; continue; fi
        case $f in
          --mcp-config) [ "$item" = "$MCP" ] || pos_bad "$f" "$item" ;;
          --tools) [ "$KIND" = claude-read ] && [ "$item" = Read,Bash ] || pos_bad "$f" "$item" ;;
        esac
      done
      return ;;
    --disallowedTools)
      if [ "$KIND" = claude-read ]; then exp=("${CLAUDE_READ_DENY[@]}"); else exp=("${CLAUDE_WRITE_DENY[@]}"); fi ;;
    --allowedTools)
      if [ "$KIND" = claude-read ]; then exp=("${CLAUDE_READ_ALLOW[@]}"); else exp=("${CLAUDE_WRITE_ALLOW[@]}"); fi ;;
  esac
  for ((j = s; j < e; j++)); do
    item=${W[j]} k=$((j - s))
    if [ "$k" -lt "${#exp[@]}" ]; then
      [ "$item" = "${exp[k]}" ] || pos_bad "$f" "$item"
    elif [ "$f" = --disallowedTools ]; then
      pos_bad "$f" "$item"
    elif [ "$phase" != read ] && [[ $item =~ $ALLOW_RE ]]; then
      phase=bash
    elif [ "$KIND" != claude-read ] && [[ $item =~ $READ_RE ]] && safe_path "${BASH_REMATCH[1]}"; then
      phase=read
    else
      pos_bad "$f" "$item"
    fi
  done
  for ((k = e - s; k < ${#exp[@]}; k++)); do v "missing recipe entry in $f: ${exp[k]}"; done
}

walk_claude() {
  local i=1 n=${#W[@]} w f s val want
  [ "${W[0]}" = claude ] || v "first word is not claude: ${W[0]}"
  CTX[0]=cmd
  while [ "$i" -lt "$n" ]; do
    w=${W[i]}
    case $w in -p | --verbose | --disable-slash-commands | --strict-mcp-config | --permission-mode | --output-format | --model | --effort | --permission-prompts | --allowedTools | --disallowedTools | --mcp-config | --tools)
      case $SEEN in *" $w "*) v "duplicate flag: $w" ;; esac
      SEEN="$SEEN$w " ;;
    esac
    case $w in
      -p | --verbose | --disable-slash-commands | --strict-mcp-config)
        CTX[i]=flag
        [ "$w" != -p ] || SAW_P=1
        [ "$w" != --verbose ] || [ "$KIND" = claude-write-probe ] || v "flag not in the $KIND recipe: $w"
        i=$((i + 1)) ;;
      --permission-mode | --output-format | --model | --effort | --permission-prompts)
        CTX[i]=flag
        val=${W[i + 1]-}
        case $val in '' | -*) v "missing value for $w"; i=$((i + 1)); continue ;; esac
        CTX[i + 1]=$w
        want=
        case $w in
          --permission-mode) want=acceptEdits; [ "$KIND" != claude-read ] || want=plan ;;
          --output-format) want=json; [ "$KIND" != claude-write-probe ] || want=stream-json ;;
          --permission-prompts) want=none ;;
        esac
        [ -z "$want" ] || [ "$val" = "$want" ] || v "$w must be $want for $KIND: $val"
        i=$((i + 2)) ;;
      --add-dir | --allowedTools | --disallowedTools | --mcp-config | --tools)
        CTX[i]=flag f=$w
        i=$((i + 1)) s=$i
        while [ "$i" -lt "$n" ]; do
          case $CLAUDE_FLAGS in *" ${W[i]} "*) break ;; esac
          CTX[i]=$f
          i=$((i + 1))
        done
        list_items "$f" "$s" "$i" ;;
      *)
        CTX[i]=unknown
        v "unknown argument: $w"
        i=$((i + 1)) ;;
    esac
  done
  for f in --permission-mode --output-format --disable-slash-commands --strict-mcp-config --mcp-config --permission-prompts --allowedTools --disallowedTools; do
    case $SEEN in *" $f "*) ;; *) v "missing flag: $f" ;; esac
  done
  [ "$KIND" != claude-write-probe ] || case $SEEN in *" --verbose "*) ;; *) v "missing flag: --verbose" ;; esac
  [ "$KIND" != claude-read ] || case $SEEN in *" --tools "*) ;; *) v "missing flag: --tools" ;; esac
}

walk_codex() {
  local i=1 n=${#W[@]} w val policy= rk= excl= cdir= olm= tdir= rdir rres rroot why
  [ "$KIND" = codex-write ] || rk=1
  if [ -n "$rk" ]; then
    # The run script does not name the worktree; check is given it.
    [ -n "$CWT" ] || die "check: --worktree is required for $KIND"
    # The read recipe runs under env, so TMPDIR is a checked argv word.
    [ "${W[0]}" = env ] || v "first word is not env: ${W[0]}"
    CTX[0]=cmd
    case ${W[1]-} in TMPDIR=/*) CTX[1]=env tdir=${W[1]#TMPDIR=} ;; *) v "missing TMPDIR=ABSOLUTE_PATH after env: ${W[1]-}" ;; esac
    [ "${W[2]-}" = codex ] || v "word after TMPDIR is not codex: ${W[2]-}"
    CTX[2]=cmd i=3
  else
    [ "${W[0]}" = codex ] || v "first word is not codex: ${W[0]}"
    CTX[0]=cmd
  fi
  if [ "${W[i]-}" = exec ]; then CTX[i]=cmd i=$((i + 1)); else v "missing subcommand: exec"; fi
  while [ "$i" -lt "$n" ]; do
    w=${W[i]}
    case $w in
      --json | --skip-git-repo-check)
        CTX[i]=flag
        case $SEEN in *" $w "*) v "duplicate flag: $w" ;; esac
        SEEN="$SEEN$w "
        [ "$w" = --json ] || [ -n "$rk" ] || v "flag not in the $KIND recipe: $w"
        i=$((i + 1)) ;;
      -C | -s | -c | --model | --add-dir | --output-last-message)
        CTX[i]=flag
        case $w in -c | --add-dir) ;; *) case $SEEN in *" $w "*) v "duplicate flag: $w" ;; esac ;; esac
        SEEN="$SEEN$w "
        val=${W[i + 1]-}
        case $val in '' | -*) v "missing value for $w"; i=$((i + 1)); continue ;; esac
        CTX[i + 1]=$w
        case $w in
          -s) [ "$val" = workspace-write ] || v "-s must be workspace-write for $KIND: $val" ;;
          -c)
            if [ "$val" = 'approval_policy="never"' ]; then policy=1
            elif [ -n "$rk" ] && [ "$val" = sandbox_workspace_write.exclude_slash_tmp=true ]; then excl=1
            elif ! [[ $val =~ $EFFORT_RE ]]; then v "-c value not allowed: $val"; fi ;;
          -C | --output-last-message)
            case $val in /*) ;; *) v "$w must be an absolute path: $val" ;; esac
            if [ "$w" = -C ]; then cdir=$val; else olm=$val; fi
            [ "$w" != -C ] || [ "$val" = "$CDT" ] || v "-C differs from the cd target: $val" ;;
          --add-dir) [ -z "$rk" ] || v "flag not in the $KIND recipe: $w" ;;
        esac
        i=$((i + 2)) ;;
      -)
        if [ "$i" -eq $((n - 1)) ]; then CTX[i]=stdin; else CTX[i]=unknown; v "unknown argument: $w"; fi
        i=$((i + 1)) ;;
      *)
        CTX[i]=unknown
        v "unknown argument: $w"
        i=$((i + 1)) ;;
    esac
  done
  for w in -C -s --json --output-last-message; do
    case $SEEN in *" $w "*) ;; *) v "missing flag: $w" ;; esac
  done
  [ -n "$policy" ] || v 'missing flag: -c approval_policy="never"'
  [ -n "$rk" ] || return 0
  case $SEEN in *" --skip-git-repo-check "*) ;; *) v "missing flag: --skip-git-repo-check" ;; esac
  [ -n "$excl" ] || v "missing flag: -c sandbox_workspace_write.exclude_slash_tmp=true"
  [ -n "$olm" ] || return 0
  rdir=$(dirname -- "$olm")
  [ ! -L "$olm" ] || v "--output-last-message is a symlink: $olm"
  if rres=$(realpath -m -- "$olm") && rroot=$(realpath -m -- "$rdir/work"); then
    case $rres/ in "${rroot%/}"/*) v "--output-last-message resolves into the writable root: $olm" ;; esac
  else
    v "--output-last-message does not resolve: $olm"
  fi
  [ -z "$cdir" ] || [ "$cdir" = "$rdir/work" ] || v "-C must be $rdir/work for $KIND: $cdir"
  [ -z "$cdir" ] || { [ -d "$cdir" ] && ! [ -L "$cdir" ] && [ -O "$cdir" ] && [ "$(mode_of "$cdir")" = drwx------ ]; } \
    || v "-C is not an owner-only directory: $cdir"
  [ -z "$tdir" ] || [ "$tdir" = "$rdir/work/tmp" ] || v "TMPDIR must be $rdir/work/tmp for $KIND: $tdir"
  [ -z "$tdir" ] || { [ -d "$tdir" ] && ! [ -L "$tdir" ] && [ -O "$tdir" ] && [ "$(mode_of "$tdir")" = drwx------ ]; } \
    || v "TMPDIR is not an owner-only directory: $tdir"
  why=$(root_bad "$rdir" "$CWT")
  [ -z "$why" ] || v "$why"
}

# check_file RUN_SCRIPT: report each violation; VIOL holds the count.
check_file() {
  local line ln=0 state=1 ok j n word lines
  CK=$1 VIOL=0 KIND= CDT= STDIN= SAW_P= SEEN=' '
  W=() CTX=() PB_F=() PB_W=()
  # Grammar: the eight-part form, every line newline-terminated, nothing else.
  if [ -s "$CK" ] && [ -n "$(tail -c 1 "$CK")" ]; then
    lines=$(wc -l <"$CK")
    v "not a launch-builder run script (line $((lines + 1)))"
    return
  fi
  while IFS= read -r line; do
    ln=$((ln + 1)) ok=
    case $line in
      *$'\r'*) ;;
      *)
        case $state in
          1) [ "$line" = '#!/usr/bin/env bash' ] && state=2 ok=1 ;;
          2) if [[ $line =~ $HEAD_RE ]]; then KIND=${BASH_REMATCH[1]} state=3 ok=1; fi ;;
          3) [ "$line" = 'set -eu' ] && state=4 ok=1 ;;
          4) [ "$line" = 'argv=(' ] && state=5 ok=1 ;;
          5 | 6)
            if [ "$state" = 6 ] && [ "$line" = ')' ]; then
              state=7 ok=1
            else
              case $line in
                "'"*"'")
                  word=${line:1:${#line}-2}
                  case $word in *"'"*) ;; *) W+=("$word") && state=6 ok=1 ;; esac ;;
              esac
            fi ;;
          7) if [[ $line =~ $CD_RE ]]; then CDT=${BASH_REMATCH[1]} state=8 ok=1; fi ;;
          8)
            case $line in
              "$EXEC0") state=9 ok=1 ;;
              "$EXEC0 < '"*"'")
                word=${line#"$EXEC0 < '"} word=${word%"'"}
                case $word in *"'"*) ;; *) STDIN=$word state=9 ok=1 ;; esac ;;
            esac ;;
        esac ;;
    esac
    [ -n "$ok" ] || { v "not a launch-builder run script (line $ln)"; return; }
  done <"$CK"
  [ "$state" = 9 ] || { v "not a launch-builder run script (line $((ln + 1)))"; return; }
  n=${#W[@]}
  case $KIND in claude-*) FAM=claude; walk_claude ;; *) FAM=codex; walk_codex ;; esac
  for ((j = 0; j < n; j++)); do case ${W[j]} in 'Read('*) [ "${CTX[j]-}" = --allowedTools ] || v "Read( entry outside --allowedTools: ${W[j]}" ;; esac; done # bite:read-outside
  for ((j = 0; j < n; j++)); do [ "${CTX[j]-}" != --add-dir ] || is_abs_dir "${W[j]}" || v "--add-dir is not an existing directory: ${W[j]}"; done # bite:add-dir
  for ((j = 0; j < ${#PB_W[@]}; j++)); do v "positional argument after list-taking flag ${PB_F[j]}: ${PB_W[j]}"; done # bite:positional
  case $STDIN in /*) [ -f "$STDIN" ] || v "prompt not attached on stdin: not a regular file: $STDIN" ;; *) v "prompt not attached on stdin${STDIN:+: not an absolute path: $STDIN}" ;; esac # bite:stdin
  [ "$FAM" != codex ] || [ "${W[n - 1]}" = - ] || v "prompt not attached on stdin: the argv does not end in -" # bite:stdin
  [ "$FAM" != claude ] || [ "$SAW_P" = 1 ] || v "prompt not attached on stdin: no -p" # bite:stdin
}

# ---- subcommands ----

render() { # KIND START_DIR LAUNCH_FILE WORD...
  local k=$1 w=$2 l=$3
  shift 3
  printf '#!/usr/bin/env bash\n# Capstan launch (%s). Written by scripts/launch.sh; verify with scripts/launch.sh check.\nset -eu\nargv=(\n' "$k"
  printf "'%s'\n" "$@"
  printf ")\ncd -- '%s'\n%s < '%s'\n" "$w" "$EXEC0" "$l"
}

cmd_write() {
  local kind= wt= lf= out= model= effort= hs= result= a val dir tmp d cdir rdir rres rroot tdir= why
  local -a adds=() allows=() A=()
  while [ $# -gt 0 ]; do
    a=$1
    case $a in
      --kind | --worktree | --launch-file | --out | --model | --effort | --add-dir | --allow | --host-source | --result) ;;
      *) die "write: unknown argument: $a" ;;
    esac
    [ $# -ge 2 ] || die "write: $a needs a value"
    val=$2
    shift 2
    need_plain "$a" "$val"
    case $a in
      --add-dir) need_abs "$a" "$val"; adds+=("$val"); continue ;;
      --allow) allows+=("$val"); continue ;;
    esac
    case " $SEEN_W " in *" $a "*) die "write: $a given twice" ;; esac
    SEEN_W="$SEEN_W $a"
    case $a in
      --kind) kind=$val ;;
      --worktree) need_abs "$a" "$val"; wt=$val ;;
      --launch-file) need_abs "$a" "$val"; lf=$val ;;
      --out) need_abs "$a" "$val"; out=$val ;;
      --model) model=$val ;;
      --effort) effort=$val ;;
      --host-source) need_abs "$a" "$val"; hs=$val ;;
      --result) need_abs "$a" "$val"; result=$val ;;
    esac
  done
  [ -n "$kind" ] || die "write: --kind is required"
  case $KINDS in *" $kind "*) ;; *) die "write: unknown --kind: $kind" ;; esac
  [ -n "$wt" ] || die "write: --worktree is required"
  [ -n "$lf" ] || die "write: --launch-file is required"
  [ -n "$out" ] || die "write: --out is required"
  [ -d "$wt" ] || die "--worktree is not a directory: $wt"
  [ -f "$lf" ] || die "--launch-file is not a regular file: $lf"
  dir=$(dirname -- "$out")
  [ -d "$dir" ] || die "--out directory does not exist: $dir"
  if [ -L "$out" ] || { [ -e "$out" ] && ! [ -f "$out" ]; }; then die "--out is not a regular file path: $out"; fi
  case $model in -*) die "--model cannot start with -: $model" ;; esac
  case $effort in -* | *'"'*) die "--effort cannot start with - or hold a double quote: $effort" ;; esac
  for a in ${allows[@]+"${allows[@]}"}; do
    [[ $a =~ $ALLOW_RE ]] || die "--allow must have the form Bash(...): $a"
  done
  case $kind in
    claude-write*) [ -n "$hs" ] || die "--host-source is required for $kind" ;;
    *) [ -z "$hs" ] || die "--host-source is only for claude-write kinds, not $kind" ;;
  esac
  case $kind in
    codex-*)
      [ -n "$result" ] || die "--result is required for $kind"
      [ "${#allows[@]}" -eq 0 ] || die "--allow is not accepted for $kind" ;;
    *) [ -z "$result" ] || die "--result is only for codex kinds, not $kind" ;;
  esac
  cdir=$wt
  case $kind in
    codex-read*)
      # workspace-write makes every --add-dir writable. work/ beneath the result directory is
      # the one writable root; the header names the owner of the result rule.
      [ "${#adds[@]}" -eq 0 ] || die "--add-dir is not accepted for $kind"
      rdir=$(dirname -- "$result")
      [ -d "$rdir" ] || die "--result directory does not exist: $rdir"
      why=$(root_bad "$rdir" "$wt")
      [ -z "$why" ] || die "--result is refused for $kind: $why"
      if [ -L "$result" ]; then die "--result is a symlink: $result"; fi
      rres=$(realpath -m -- "$result") && rroot=$(realpath -m -- "$rdir/work") || die "--result does not resolve: $result"
      case $rres/ in "${rroot%/}"/*) die "--result resolves into the writable root: $result" ;; esac
      cdir=$rdir/work tdir=$rdir/work/tmp
      for d in "$cdir" "$tdir"; do
        if [ -L "$d" ] || { [ -e "$d" ] && ! [ -d "$d" ]; }; then die "not a directory: $d"; fi
        [ -d "$d" ] || (umask 077 && mkdir -- "$d") || die "cannot create $d"
        [ -O "$d" ] && [ "$(mode_of "$d")" = drwx------ ] || die "not an owner-only directory: $d"
      done ;;
  esac

  GRANT_READS=()
  case $kind in claude-write*) grant "$hs" "$wt" ;; esac

  case $kind in
    claude-*)
      A=(claude -p --permission-mode)
      if [ "$kind" = claude-read ]; then A+=(plan); else A+=(acceptEdits); fi
      if [ "$kind" = claude-write-probe ]; then A+=(--output-format stream-json --verbose); else A+=(--output-format json); fi
      [ -z "$model" ] || A+=(--model "$model")
      [ -z "$effort" ] || A+=(--effort "$effort")
      A+=(--disable-slash-commands --strict-mcp-config --mcp-config "$MCP")
      for d in ${adds[@]+"${adds[@]}"}; do A+=(--add-dir "$d"); done
      A+=(--permission-prompts none)
      if [ "$kind" = claude-read ]; then
        A+=(--tools Read,Bash --allowedTools "${CLAUDE_READ_ALLOW[@]}" ${allows[@]+"${allows[@]}"})
        A+=(--disallowedTools "${CLAUDE_READ_DENY[@]}")
      else
        A+=(--allowedTools "${CLAUDE_WRITE_ALLOW[@]}" ${allows[@]+"${allows[@]}"} ${GRANT_READS[@]+"${GRANT_READS[@]}"})
        A+=(--disallowedTools "${CLAUDE_WRITE_DENY[@]}")
      fi ;;
    codex-*)
      A=(codex exec -C "$cdir" -s workspace-write)
      [ "$kind" = codex-write ] || A=(env "TMPDIR=$tdir" "${A[@]}" --skip-git-repo-check -c sandbox_workspace_write.exclude_slash_tmp=true)
      A+=(-c 'approval_policy="never"')
      [ -z "$model" ] || A+=(--model "$model")
      [ -z "$effort" ] || A+=(-c "model_reasoning_effort=\"$effort\"")
      for d in ${adds[@]+"${adds[@]}"}; do A+=(--add-dir "$d"); done
      A+=(--json --output-last-message "$result" -) ;;
  esac

  tmp=$(umask 077 && mktemp "$dir/.launch.XXXXXX") || die "cannot create a temp file in $dir"
  if ! render "$kind" "$cdir" "$lf" "${A[@]}" >"$tmp" || ! chmod 700 "$tmp"; then
    rm -f -- "$tmp"
    die "cannot write $tmp"
  fi
  CWT=$wt
  check_file "$tmp"
  if [ "$VIOL" -ne 0 ]; then
    rm -f -- "$tmp"
    printf 'launch.sh: write: no run script written: %s\n' "$out" >&2
    exit 1
  fi
  if [ -L "$out" ] || { [ -e "$out" ] && ! [ -f "$out" ]; }; then
    rm -f -- "$tmp"
    die "--out is not a regular file path: $out"
  fi
  mv -f -- "$tmp" "$out"
  if ! [ -f "$out" ] || [ -L "$out" ] || [ -e "$tmp" ] || [ "$(mode_of "$out")" != -rwx------ ]; then
    rm -f -- "$tmp" "$out/${tmp##*/}"
    printf 'launch.sh: write: publish failed: %s\n' "$out" >&2
    exit 1
  fi
  case $kind in claude-write*) printf '%s\n' "$GRANT_LINE" ;; esac
  exit 0
}

cmd_check() {
  local rs=
  while [ $# -gt 0 ]; do
    case $1 in
      --worktree)
        [ $# -ge 2 ] || die "check: --worktree needs a value"
        [ -z "$CWT" ] || die "check: --worktree given twice"
        need_abs --worktree "$2"
        [ -d "$2" ] || die "--worktree is not a directory: $2"
        CWT=$2
        shift 2 ;;
      *)
        [ -z "$rs" ] || die "usage: launch.sh check RUN_SCRIPT [--worktree DIR]"
        rs=$1
        shift ;;
    esac
  done
  [ -n "$rs" ] || die "usage: launch.sh check RUN_SCRIPT [--worktree DIR]"
  need_abs RUN_SCRIPT "$rs"
  [ -f "$rs" ] && [ -r "$rs" ] || die "check: cannot read run script: $rs"
  check_file "$rs"
  [ "$VIOL" -eq 0 ] || exit 1
  exit 0
}

cmd_grant() {
  local src= wt=
  while [ $# -gt 0 ]; do
    [ $# -ge 2 ] || die "grant: $1 needs a value"
    case $1 in
      --source) need_abs --source "$2"; src=$2 ;;
      --worktree) need_abs --worktree "$2"; wt=$2 ;;
      *) die "grant: unknown argument: $1" ;;
    esac
    shift 2
  done
  [ -n "$src" ] && [ -n "$wt" ] || die "usage: launch.sh grant --source FILE --worktree DIR"
  [ -d "$wt" ] || die "--worktree is not a directory: $wt"
  grant "$src" "$wt"
  printf '%s\n' "$GRANT_LINE"
  exit 0
}

SEEN_W= CWT=
case ${1-} in
  write) shift; cmd_write "$@" ;;
  check) shift; cmd_check "$@" ;;
  grant) shift; cmd_grant "$@" ;;
  *) die "usage: launch.sh write|check|grant ... (see the header of scripts/launch.sh)" ;;
esac
