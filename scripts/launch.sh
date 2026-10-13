#!/usr/bin/env bash
# Capstan launch builder. The coordinator runs it; workers never do. It writes
# and checks the run script for one Claude or Codex worker launch. It does not
# launch or supervise. references/harnesses/shared.md ("## Launch probe") owns
# the probe capture. The recipes in references/harnesses/claude.md,
# codex.md, and shared.md ("Launch probe") are the specification: where this
# file differs, this file is wrong.
#
#   launch.sh write --kind K --worktree DIR --launch-file FILE --out RUN_SCRIPT
#       [--model M] [--effort E] [--add-dir DIR]... [--allow ENTRY]...
#       [--host-source FILE] [--result FILE] [--capture DIR] [--redact-env NAME]...
#     K: claude-write, claude-read, claude-write-probe, codex-write, codex-read,
#     codex-read-probe. Prints the Host grant: line for claude-write*.
#     --capture and --redact-env are for the probe kinds only, and a probe kind
#     requires --capture. Its DIR is absolute and owner-only, and is not inside
#     --worktree or work/; no capture file in it is the launch file, the run
#     script, or the result. NAME is an environment variable name.
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
NAME_RE='^[A-Za-z_][A-Za-z0-9_]*$'
NAMES_RE='^([A-Za-z_][A-Za-z0-9_]*( [A-Za-z_][A-Za-z0-9_]*)*)?$'
LF_RE="^lf='(/[^']*)'\$"
CAP_RE="^cap='(/[^']*)'\$"
RENV_RE="^redact_env='([^']*)'\$"
CAP_NAMES='stdout stderr exit capture-error'

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

# cap_bad DIR WORKTREE RESULT LAUNCH_FILE RUN_SCRIPT: prints why DIR cannot hold
# a probe capture, by canonical path; prints nothing when it can. RESULT is empty
# for a Claude probe. A DIR that does not exist yet passes the checks that need it.
cap_bad() {
  local rc rw n c
  rc=$(realpath -m -- "$1") && rw=$(realpath -m -- "$2") || { printf 'does not resolve: %s' "$1"; return 0; }
  case $rc/ in "${rw%/}"/*) printf 'is inside the worktree: %s' "$1"; return 0 ;; esac
  if [ -n "$3" ]; then
    rw=$(realpath -m -- "$(dirname -- "$3")/work")
    case $rc/ in "${rw%/}"/*) printf 'resolves into the writable root: %s' "$1"; return 0 ;; esac
  fi
  for n in $CAP_NAMES; do
    c=$(realpath -m -- "$1/$n")
    [ "$c" != "$(realpath -m -- "$4")" ] || { printf '%s is the launch file' "$1/$n"; return 0; }
    [ "$c" != "$(realpath -m -- "$5")" ] || { printf '%s is the run script' "$1/$n"; return 0; }
    [ -z "$3" ] || [ "$c" != "$(realpath -m -- "$3")" ] || { printf '%s is the result' "$1/$n"; return 0; }
  done
  [ -e "$1" ] || [ -L "$1" ] || return 0
  { [ -d "$1" ] && ! [ -L "$1" ] && [ -O "$1" ] && [ "$(mode_of "$1")" = drwx------ ]; } \
    || { printf 'is not an owner-only directory: %s' "$1"; return 0; }
  n=$(root_bad "$1" "$2")
  [ -z "$n" ] || printf 'is refused: %s' "$n"
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

# ---- probe capture: the block that ends a probe kind's run script ----

# The redaction program of the probe capture. It implements the credential
# redaction of references/security.md item 6 on every stream and, with host set,
# the host-grant redaction of references/harnesses/claude.md ("Before any output
# of a run under a host grant is written") on both Claude streams. It reads the
# credential values from ENVIRON, never argv: each value whose variable name
# matches the pattern below, or is listed in names. A line that parses as one
# JSON object is rewritten token by token, so its structure is kept; any other
# line is redacted as text, or is [removed] with host set. The run script holds
# this text inside single quotes, so it contains none.
RED_AWK='
function esc(s,   o, i, c) {
  o = ""
  for (i = 1; i <= length(s); i++) {
    c = substr(s, i, 1)
    if (c == "\\") o = o "\\\\"
    else if (c == "\"") o = o "\\\""
    else if (c == "\n") o = o "\\n"
    else if (c == "\t") o = o "\\t"
    else if (c == "\r") o = o "\\r"
    else if (c == "\b") o = o "\\b"
    else if (c == "\f") o = o "\\f"
    else if (c in ORD) o = o sprintf("\\u%04x", ORD[c])
    else o = o c
  }
  return o
}
function rep(s, x,   o, i) {
  o = ""
  while ((i = index(s, x)) > 0) { o = o substr(s, 1, i - 1) "[redacted]"; s = substr(s, i + length(x)) }
  return o s
}
# Inside a JSON string a raw value holding a backslash can only match across an escape.
function cred(s, json,   j) {
  for (j = 1; j <= NC; j++) {
    s = rep(s, CE[j])
    if (!json || !index(CR[j], "\\")) s = rep(s, CR[j])
  }
  return s
}
function swap(s, x, y,   a, n, i, o) {
  n = split(s, a, x); o = a[1]
  for (i = 2; i <= n; i++) o = o y a[i]
  return o
}
# lex(s): splits s into tokens TT (text), TK (kind: a bracket, colon or comma;
# s a string; b a scalar) and TW (the blanks before each); returns 0 if s cannot be JSON.
function lex(s,   q, k, o, n, i, j, c, w) {
  split("", TT); split("", TK); split("", TW); NT = 0; TAIL = ""
  if (index(s, "\001") || index(s, "\002")) return 0
  gsub(/\\\\/, "\001", s)
  gsub(/\\"/, "\002", s)
  q = split(s, PART, "\"")
  if (q % 2 == 0) return 0
  w = ""
  for (k = 1; k <= q; k++) {
    o = PART[k]
    if (k % 2 == 0) {
      TW[++NT] = w; w = ""; TK[NT] = "s"
      TT[NT] = "\"" swap(swap(o, "\001", "\\\\"), "\002", "\\\"") "\""
      continue
    }
    n = length(o)
    for (i = 1; i <= n; ) {
      c = substr(o, i, 1)
      if (c == " " || c == "\t" || c == "\r") { w = w c; i++; continue }
      TW[++NT] = w; w = ""
      if (index("{}[]:,", c)) { TK[NT] = c; TT[NT] = c; i++; continue }
      for (j = i; j <= n && index(BARE, substr(o, j, 1)); j++) ;
      if (j == i) return 0
      TK[NT] = "b"; TT[NT] = substr(o, i, j - i); i = j
      if (TT[NT] !~ SCALAR) return 0
    }
  }
  TAIL = w
  return NT > 0
}
# The parser records, for each value token, its enclosing object (VPAR) and key
# (VKEY; an array element takes its array key) and where the value ends (VEND);
# for each object its parent (OPAR) and members (MEM[object, key] = value token).
function pval(par, key,   s, ok) {
  s = P
  if (TK[P] == "{") ok = pobj(par)
  else if (TK[P] == "[") ok = parr(par, key)
  else if (TK[P] == "s" || TK[P] == "b") { VPAR[P] = par; VKEY[P] = key; P++; ok = 1 }
  else ok = 0
  VEND[s] = P - 1
  return ok
}
function pobj(par,   o, k) {
  o = P; OPAR[o] = par; P++
  if (TK[P] == "}") { P++; return 1 }
  while (1) {
    if (TK[P] != "s") return 0
    k = substr(TT[P], 2, length(TT[P]) - 2); ISKEY[P] = 1; P++
    if (TK[P] != ":") return 0
    MEM[o, k] = ++P
    if (!pval(o, k)) return 0
    if (TK[P] == ",") { P++; continue }
    if (TK[P] == "}") { P++; return 1 }
    return 0
  }
}
function parr(par, key) {
  P++
  if (TK[P] == "]") { P++; return 1 }
  while (1) {
    if (!pval(par, key)) return 0
    if (TK[P] == ",") { P++; continue }
    if (TK[P] == "]") { P++; return 1 }
    return 0
  }
}
function mget(o, k) { return ((o, k) in MEM) ? TT[MEM[o, k]] : "" }
function keep(i,   k, o) {
  k = VKEY[i]
  if (k in KEEP) return 1
  if (k == "result") return TT[i] == "\"CAPSTAN_PROBE_OK\""
  if (k != "command") return 0
  for (o = VPAR[i]; o; o = OPAR[o]) {
    if ((o, "name") in MEM) return mget(o, "name") == "\"Bash\""
    if ((o, "tool_name") in MEM) return mget(o, "tool_name") == "\"Bash\""
  }
  return 0
}
function hostpass(   i, ok) {
  for (i = 1; i <= NT; i++)
    if (TK[i] == "{" && mget(i, "type") == "\"tool_use\"" && mget(i, "id") != "") NAMEOF[mget(i, "id")] = mget(i, "name")
  ok = 0
  for (i = 1; i <= NT; i++)
    if (TK[i] == "{" && mget(i, "type") == "\"tool_result\"" && NAMEOF[mget(i, "tool_use_id")] == "\"Read\"" && mget(i, "is_error") != "true") {
      ok = 1
      if ((i, "content") in MEM) REPL[MEM[i, "content"]] = HFC
    }
  if (ok && ((1, "tool_use_result") in MEM)) REPL[MEM[1, "tool_use_result"]] = HFC
  for (i = 1; i <= NT; i++)
    if (TK[i] == "s" && !(i in ISKEY) && !keep(i)) TT[i] = "\"[removed]\""
}
function emit(   i, o, t) {
  o = ""
  for (i = 1; i <= NT; i++) {
    o = o TW[i]
    if (i in REPL) { o = o REPL[i]; i = VEND[i]; continue }
    t = TT[i]
    if (TK[i] == "s") t = "\"" cred(substr(t, 2, length(t) - 2), 1) "\""
    else if (TK[i] == "b" && (t in BARECR)) t = "\"[redacted]\""
    o = o t
  }
  return o TAIL
}
BEGIN {
  SCALAR = "^(true|false|null|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][-+]?[0-9]+)?)$"
  BARE = "-+.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  HFC = "\"[host file content removed]\""
  split("type subtype id name tool_name tool_use_id role model session_id uuid stop_reason file_path", a, " ")
  for (i in a) KEEP[a[i]] = 1
  for (i = 1; i < 32; i++) ORD[sprintf("%c", i)] = i
  split(names, a, " ")
  for (i in a) WANT[a[i]] = 1
  NC = 0
  for (k in ENVIRON) {
    v = ENVIRON[k]
    if (v == "" || !(toupper(k) ~ /TOKEN|API_KEY|SECRET|PASSWORD/ || (k in WANT))) continue
    for (j = ++NC; j > 1 && length(CR[j - 1]) < length(v); j--) { CR[j] = CR[j - 1]; CE[j] = CE[j - 1] }
    CR[j] = v; CE[j] = esc(v); BARECR[v] = 1
  }
}
{
  split("", OPAR); split("", VPAR); split("", VKEY); split("", VEND); split("", ISKEY); split("", MEM); split("", REPL)
  P = 1
  if (!lex($0) || TK[1] != "{" || !pobj(0) || P != NT + 1) { print (host ? "[removed]" : cred($0, 0)); next }
  if (host) hostpass()
  print emit()
}
'

# probe_block KIND: prints the block that follows the lf=, cap= and redact_env=
# lines of a probe kind's run script. It is the same for every input of KIND.
probe_block() {
  local red=$RED_AWK
  [ "$1" != claude-write-probe ] || red="BEGIN { host = 1 }$RED_AWK"
  cat <<'EOF'
umask 077
set +e
rm -f -- "$cap/stdout" "$cap/stderr" "$cap/exit" "$cap/capture-error" || exit 70
EOF
  printf "red='%s'\n" "$red"
  cat <<'EOF'
{ { rc=0; "${argv[@]}" <"$lf" 2>&1 1>&3 3>&- || rc=$?; printf '%s\n' "$rc" >"$cap/exit" || exit 71; } | awk -v names="$redact_env" "$red" >"$cap/stderr"; s=("${PIPESTATUS[@]}"); [ "${s[0]}" = 0 ] && [ "${s[1]}" = 0 ] || exit 72; } 3>&1 | awk -v names="$redact_env" "$red" >"$cap/stdout"
p=("${PIPESTATUS[@]}")
if [ "${p[0]}" = 0 ] && [ "${p[1]}" = 0 ] && read -r rc <"$cap/exit"; then exit "$rc"; fi
printf 'capture failed: harness-side=%s stdout-redactor=%s\n' "${p[0]}" "${p[1]}" >"$cap/capture-error"
exit 70
EOF
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
  OLM=$olm
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

# probe_lines FIRST TEXT: TEXT, which starts at line FIRST of the run script,
# must equal probe_block KIND; reports the first line that differs.
probe_lines() {
  local e r=$2 k=$1
  e=$(probe_block "$KIND"; printf x)
  e=${e%x}
  [ "$r" != "$e" ] || return 0
  while [ -n "$r" ] && [ -n "$e" ] && [ "${r%%$'\n'*}" = "${e%%$'\n'*}" ]; do r=${r#*$'\n'} e=${e#*$'\n'} k=$((k + 1)); done
  case $r in
    "$EXEC0"*) v "exec line in a $KIND run script, which captures its run (line $k)" ;;
    *) v "capture block differs from the $KIND block (line $k)" ;;
  esac
  return 1
}

# check_file RUN_SCRIPT: report each violation; VIOL holds the count.
check_file() {
  local line ln=0 state=1 ok j n word lines blk= rest=
  CK=$1 VIOL=0 KIND= CDT= STDIN= SAW_P= SEEN=' ' CAP= RENV= OLM=
  W=() CTX=() PB_F=() PB_W=()
  # Grammar: the eight-part form, every line newline-terminated, nothing else. A
  # probe kind ends with its lf=, cap= and redact_env= lines and probe_block KIND.
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
            case $KIND:$line in
              *-probe:"$EXEC0"*) v "exec line in a $KIND run script, which captures its run (line $ln)"; return ;;
              *-probe:*) if [[ $line =~ $LF_RE ]]; then STDIN=${BASH_REMATCH[1]} state=20 ok=1; fi ;;
              *:"$EXEC0") state=9 ok=1 ;;
              *:"$EXEC0 < '"*"'")
                word=${line#"$EXEC0 < '"} word=${word%"'"}
                case $word in *"'"*) ;; *) STDIN=$word state=9 ok=1 ;; esac ;;
            esac ;;
          9) v "text after the exec line of a $KIND run script (line $ln)"; return ;;
          20) if [[ $line =~ $CAP_RE ]]; then CAP=${BASH_REMATCH[1]} state=21 ok=1; fi ;;
          21) if [[ $line =~ $RENV_RE ]]; then RENV=${BASH_REMATCH[1]} blk=$((ln + 1)) state=22 ok=1; fi ;;
          22) rest=$rest$line$'\n' ok=1 ;;
        esac ;;
    esac
    [ -n "$ok" ] || { v "not a launch-builder run script (line $ln)"; return; }
  done <"$CK"
  case $state in
    9) ;;
    22) probe_lines "$blk" "$rest" || return ;;
    *) v "not a launch-builder run script (line $((ln + 1)))"; return ;;
  esac
  n=${#W[@]}
  case $KIND in claude-*) FAM=claude; walk_claude ;; *) FAM=codex; walk_codex ;; esac
  if [ "$state" = 22 ]; then # the probe capture directory and the credential names
    if [[ $RENV =~ $NAMES_RE ]]; then :; else v "redact_env is not a list of environment variable names: $RENV"; fi
    if [ "$FAM" = claude ]; then word=$(cap_bad "$CAP" "$CDT" '' "$STDIN" "$CK")
    else word=$(cap_bad "$CAP" "$CWT" "$OLM" "$STDIN" "$CK"); fi
    [ -z "$word" ] || v "cap $word"
    [ -d "$CAP" ] || v "cap is not an owner-only directory: $CAP"
  fi
  for ((j = 0; j < n; j++)); do case ${W[j]} in 'Read('*) [ "${CTX[j]-}" = --allowedTools ] || v "Read( entry outside --allowedTools: ${W[j]}" ;; esac; done # bite:read-outside
  for ((j = 0; j < n; j++)); do [ "${CTX[j]-}" != --add-dir ] || is_abs_dir "${W[j]}" || v "--add-dir is not an existing directory: ${W[j]}"; done # bite:add-dir
  for ((j = 0; j < ${#PB_W[@]}; j++)); do v "positional argument after list-taking flag ${PB_F[j]}: ${PB_W[j]}"; done # bite:positional
  case $STDIN in /*) [ -f "$STDIN" ] || v "prompt not attached on stdin: not a regular file: $STDIN" ;; *) v "prompt not attached on stdin${STDIN:+: not an absolute path: $STDIN}" ;; esac # bite:stdin
  [ "$FAM" != codex ] || [ "${W[n - 1]}" = - ] || v "prompt not attached on stdin: the argv does not end in -" # bite:stdin
  [ "$FAM" != claude ] || [ "$SAW_P" = 1 ] || v "prompt not attached on stdin: no -p" # bite:stdin
}

# ---- subcommands ----

render() { # KIND START_DIR LAUNCH_FILE WORD...; a probe kind also reads CAP and RENV
  local k=$1 w=$2 l=$3
  shift 3
  printf '#!/usr/bin/env bash\n# Capstan launch (%s). Written by scripts/launch.sh; verify with scripts/launch.sh check.\nset -eu\nargv=(\n' "$k"
  printf "'%s'\n" "$@"
  case $k in
    *-probe)
      printf ")\ncd -- '%s'\nlf='%s'\ncap='%s'\nredact_env='%s'\n" "$w" "$l" "$CAP" "$RENV"
      probe_block "$k" ;;
    *) printf ")\ncd -- '%s'\n%s < '%s'\n" "$w" "$EXEC0" "$l" ;;
  esac
}

cmd_write() {
  local kind= wt= lf= out= model= effort= hs= result= cap= a val dir tmp d cdir rdir rres rroot tdir= why
  local -a adds=() allows=() renvs=() A=()
  while [ $# -gt 0 ]; do
    a=$1
    case $a in
      --kind | --worktree | --launch-file | --out | --model | --effort | --add-dir | --allow | --host-source | --result \
        | --capture | --redact-env) ;;
      *) die "write: unknown argument: $a" ;;
    esac
    [ $# -ge 2 ] || die "write: $a needs a value"
    val=$2
    shift 2
    need_plain "$a" "$val"
    case $a in
      --add-dir) need_abs "$a" "$val"; adds+=("$val"); continue ;;
      --allow) allows+=("$val"); continue ;;
      --redact-env)
        [[ $val =~ $NAME_RE ]] || die "--redact-env must be an environment variable name: $val"
        renvs+=("$val"); continue ;;
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
      --capture) need_abs "$a" "$val"; cap=$val ;;
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
  case $kind in
    *-probe) [ -n "$cap" ] || die "--capture is required for $kind" ;;
    *)
      [ -z "$cap" ] || die "--capture is only for probe kinds, not $kind"
      [ "${#renvs[@]}" -eq 0 ] || die "--redact-env is only for probe kinds, not $kind" ;;
  esac
  # The capture directory is checked before anything is created and again once it exists.
  if [ -n "$cap" ]; then
    why=$(cap_bad "$cap" "$wt" "$result" "$lf" "$out")
    [ -z "$why" ] || die "--capture $why"
  fi
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
  if [ -n "$cap" ]; then
    [ -e "$cap" ] || [ -L "$cap" ] || (umask 077 && mkdir -- "$cap") || die "cannot create $cap"
    why=$(cap_bad "$cap" "$wt" "$result" "$lf" "$out")
    [ -z "$why" ] || die "--capture $why"
  fi
  CAP=$cap RENV=${renvs[*]+"${renvs[*]}"}

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
