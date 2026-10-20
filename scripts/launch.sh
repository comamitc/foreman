#!/usr/bin/env bash
# Capstan launch builder. The coordinator runs it; workers never do. It writes
# and checks the run script for one Claude or Codex worker launch. It does not
# launch or supervise. references/harnesses/shared.md ("A run script that
# `scripts/launch.sh write` writes takes `--capture DIR`") owns the capture.
# The recipes in references/harnesses/claude.md, codex.md, and shared.md
# ("Launch probe") are the specification: where this file differs, this file
# is wrong.
#
#   launch.sh write --kind K --worktree DIR --launch-file FILE --out RUN_SCRIPT
#       --capture DIR --events FILE --delivery OWNER/REPO#N --station S --attempt A
#       [--model M] [--effort E] [--add-dir DIR]... [--allow ENTRY]...
#       [--host-source FILE] [--result FILE] [--redact-env NAME]...
#     K: claude-write, claude-read, claude-write-probe, codex-write, codex-read,
#     codex-read-probe. Prints the Host grant: line for claude-write*.
#     Every kind requires --capture, --events, --delivery, --station and
#     --attempt; its run script ends in the capture block. The capture DIR is
#     absolute and owner-only, and is not inside --worktree or work/; no capture
#     file in it is the launch file, the run script, or the result. FILE is an
#     absolute path ending in /events.jsonl; references/telemetry.md
#     ("appends each worker `tool-call` line when that call completes") owns
#     what the run script appends to it. NAME is an environment variable name.
#     codex-read and codex-read-probe build the read recipe that
#     references/harnesses/codex.md ("The read recipe, for kinds") owns, and
#     refuse --add-dir and a --result that is a symlink or resolves into
#     work/. references/harnesses/codex.md ("owns the Codex read-station result
#     rule") governs the result file. They refuse
#     a --result directory that is, holds, or sits inside --worktree, or that is
#     $HOME or above it, compared by canonical path, or that is not owned by
#     the user or is writable by group or others.
#   launch.sh check RUN_SCRIPT [--worktree DIR]
#     --worktree is required for codex-read and codex-read-probe: their run
#     script does not name the worktree, and check applies the --result rule above.
#   launch.sh grant --source FILE --worktree DIR
#   launch.sh pack PACK --worktree DIR
#     The pack check; references/pack.md ("Pack check:") owns the rule.
#   launch.sh cite --worktree DIR [--plan PLAN] [--rev SHA]
#     The citation check; references/pack.md ("Citation check:") owns the rule.
#     Without --plan it reads each tracked Markdown file of DIR; with --plan it
#     reads PLAN against DIR's files. --rev reads those files at SHA, not the
#     working tree. DIR is a git work tree.
#
# Exit: 0 ok; 1 check violation (for write, no script was written; for pack, a cited rule file is not named,
# or a named file's anchor is missing or outside its range; for cite, a citation's anchor is missing or
# not in its target, or a linked file is not in the tree); 2 usage or input error. Every path input must be absolute.
set -u

MCP='{"mcpServers":{}}'
CLAUDE_WRITE_ALLOW=('Bash(git add *)' 'Bash(git commit *)' 'Bash(git status *)' 'Bash(git diff *)'
  'Bash(git log *)' 'Bash(git rev-parse *)' 'Bash(git show *)' 'Bash(git restore -- *)')
CLAUDE_WRITE_DENY=('Bash(git checkout *)' 'Bash(git reset --hard *)' 'Bash(git push *)' 'Bash(gh *)'
  'Bash(time *)' 'Bash(nice *)' 'Bash(timeout *)' 'Bash(nohup *)')
CLAUDE_READ_ALLOW=('Bash(git status *)' 'Bash(git rev-parse *)' 'Bash(git diff *)')
CLAUDE_READ_DENY=('Bash(grep -r*)' 'Bash(grep -R*)' 'Bash(grep --recursive*)'
  'Bash(grep --dereference-recursive*)' 'Bash(rg *)' 'Bash(find *)'
  'Bash(time *)' 'Bash(nice *)' 'Bash(timeout *)' 'Bash(nohup *)')
WRAP_RE='^Bash\((time|nice|timeout|nohup) '
CLAUDE_FLAGS=' -p --verbose --disable-slash-commands --strict-mcp-config --permission-mode --output-format --model --effort --permission-prompts --add-dir --allowedTools --disallowedTools --mcp-config --tools '
KINDS=' claude-write claude-read claude-write-probe codex-write codex-read codex-read-probe '
ALLOW_RE='^Bash\(.+\)$'
READ_RE='^Read\(/(/.*)\)$'
SAFE_RE='^/[A-Za-z0-9._+@-]+(/[A-Za-z0-9._+@-]+)*$'
EFFORT_RE='^model_reasoning_effort="[^"]*"$'
PATHPOL_RE='^shell_environment_policy\.set\.PATH="([^"\\]*)"$'
HEAD_RE='^# Capstan launch \((claude-write|claude-read|claude-write-probe|codex-write|codex-read|codex-read-probe)\)\. Written by scripts/launch\.sh; verify with scripts/launch\.sh check\.$'
CD_RE="^cd -- '(/[^']*)'\$"
EXEC0='exec "${argv[@]}"'
NAME_RE='^[A-Za-z_][A-Za-z0-9_]*$'
NAMES_RE='^([A-Za-z_][A-Za-z0-9_]*( [A-Za-z_][A-Za-z0-9_]*)*)?$'
LF_RE="^lf='(/[^']*)'\$"
CAP_RE="^cap='(/[^']*)'\$"
RENV_RE="^redact_env='([^']*)'\$"
DELIV_RE="^[^/' ]+/[^#' ]+#[0-9]+\$"
EV_LINES=(events delivery station attempt)
CAP_NAMES='stdout stderr exit capture-error stream telemetry-error'

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
# a capture, by canonical path; prints nothing when it can. RESULT is empty for
# a Claude kind. A DIR that does not exist yet passes the checks that need it.
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

# ---- capture: the block that ends every kind's run script ----

# The redaction program of the capture. It implements the credential
# redaction of references/security.md item 6 on every stream and, with host set,
# the host-grant redaction of references/harnesses/claude.md ("Before any output
# of a run under a host grant is written") on both Claude streams. It reads the
# credential values from ENVIRON, never argv: each value whose variable name
# matches the pattern below, or is listed in names. A line that parses as one
# JSON object is rewritten token by token, so its structure is kept; any other
# line is redacted as text, or is [removed] with host set. Each line is flushed
# as it is written, so later stages see it when it arrives. The run script holds
# this text, and TC_AWK, inside single quotes, so they contain none.
# RED_FUNCS is the function section RED_AWK and TC_AWK share.
RED_FUNCS='
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
function rep(s, x, y,   o, i) {
  o = ""
  while ((i = index(s, x)) > 0) { o = o substr(s, 1, i - 1) y; s = substr(s, i + length(x)) }
  return o s
}
# cred(s): text that is not a JSON string, with each credential raw and JSON-escaped.
function cred(s,   j) {
  for (j = 1; j <= NC; j++) s = rep(rep(s, CE[j], "[redacted]"), CR[j], "[redacted]")
  return s
}
function hex(x,   i, c, v) {
  v = 0
  for (i = 1; i <= 4; i++) {
    if (!(c = index("0123456789abcdef", tolower(substr(x, i, 1))))) return -1
    v = v * 16 + c - 1
  }
  return v
}
# jcred(b): b is the body of a JSON string. Each credential is matched against
# the decoded value, one character or escape per unit (JU, with JD one character
# per unit), and its units are replaced whole, so no escape is split and the
# string stays valid JSON. A string with no match keeps its original text.
function jcred(b,   d, j, n, i, c, h, k, m, l, p, o) {
  if (!index(b, "\\")) {
    for (j = 1; j <= NC; j++) b = rep(b, CR[j], "\001")
    return rep(b, "\001", "[redacted]")
  }
  if (!index(b, "\\u")) {
    d = b
    gsub(/\\\\/, "\001", d); gsub(/\\"/, "\"", d); gsub(/\\\//, "/", d); gsub(/\\n/, "\n", d)
    gsub(/\\t/, "\t", d); gsub(/\\r/, "\r", d); gsub(/\\b/, "\b", d); gsub(/\\f/, "\f", d)
    d = rep(d, "\001", "\\")
    for (j = 1; j <= NC && !index(d, CR[j]); j++) ;
    if (j > NC) return b
  }
  n = 0; JD = ""
  for (i = 1; i <= length(b); ) {
    c = substr(b, i, 1)
    if (c != "\\") { JU[++n] = c; JD = JD c; i++; continue }
    c = substr(b, i + 1, 1)
    if (c == "u") { JU[++n] = substr(b, i, 6); h = hex(substr(b, i + 2, 4)); JD = JD ((h > 0 && h < 128) ? CHR[h] : "\001"); i += 6 }
    else { JU[++n] = substr(b, i, 2); JD = JD ((c in UNESC) ? UNESC[c] : c); i += 2 }
  }
  for (j = 1; j <= NC; j++) {
    if (!index(JD, CR[j])) continue
    k = 0; m = 0; o = ""; l = length(CR[j])
    while ((p = index(JD, CR[j])) > 0) {
      for (i = 1; i < p; i++) JV[++k] = JU[++m]
      JV[++k] = "[redacted]"; m += l
      o = o substr(JD, 1, p - 1) "\002"; JD = substr(JD, p + l)
    }
    while (m < n) JV[++k] = JU[++m]
    JD = o JD; n = k
    for (i = 1; i <= n; i++) JU[i] = JV[i]
  }
  o = ""
  for (i = 1; i <= n; i++) o = o JU[i]
  return o
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
# for each object its parent (OPAR), its key there (OKEY) and members
# (MEM[object, key] = value token).
function pval(par, key,   s, ok) {
  s = P
  if (TK[P] == "{") { OKEY[P] = key; ok = pobj(par) }
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
# argof(i): 1 when value token i lies in the arguments of a tool: a member of a
# tool_use object other than its type, id and name, or anything under an
# ARGK key. ATOOL is then the name of that tool.
function argof(i,   k, o) {
  k = VKEY[i]
  for (o = VPAR[i]; o; o = OPAR[o]) {
    if ((k in ARGK) || (mget(o, "type") == "\"tool_use\"" && !(k in TUMETA))) {
      ATOOL = mget(o, "name")
      if (ATOOL == "") ATOOL = mget(o, "tool_name")
      return 1
    }
    k = OKEY[o]
  }
  return 0
}
function keep(i,   k) {
  k = VKEY[i]
  if (argof(i)) return TK[i] == "s" && (k == "file_path" || (k == "command" && ATOOL == "\"Bash\""))
  if (k in KEEP) return 1
  return k == "result" && TT[i] == "\"CAPSTAN_PROBE_OK\""
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
    if (((TK[i] == "s" && !(i in ISKEY)) || (TK[i] == "b" && argof(i))) && !keep(i)) { TT[i] = "\"[removed]\""; TK[i] = "s" }
}
function emit(   i, o, t) {
  o = ""
  for (i = 1; i <= NT; i++) {
    o = o TW[i]
    if (i in REPL) { o = o REPL[i]; i = VEND[i]; continue }
    t = TT[i]
    if (TK[i] == "s") t = "\"" jcred(substr(t, 2, length(t) - 2)) "\""
    else if (TK[i] == "b" && (t in BARECR)) t = "\"[redacted]\""
    o = o t
  }
  return o TAIL
}
'
RED_AWK=$RED_FUNCS'BEGIN {
  SCALAR = "^(true|false|null|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][-+]?[0-9]+)?)$"
  BARE = "-+.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  HFC ="\"[host file content removed]\""
  split("type subtype id name tool_name tool_use_id role model session_id uuid stop_reason file_path", a, " ")
  for (i in a) KEEP[a[i]] = 1
  split("input tool_input wire_tool_inputs", a, " ")
  for (i in a) ARGK[a[i]] = 1
  split("type id name", a, " ")
  for (i in a) TUMETA[a[i]] = 1
  for (i = 1; i < 32; i++) ORD[sprintf("%c", i)] = i
  for (i = 1; i < 128; i++) CHR[i] = sprintf("%c", i)
  UNESC["n"] = "\n"; UNESC["t"] = "\t"; UNESC["r"] = "\r"; UNESC["b"] = "\b"; UNESC["f"] = "\f"
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
  split("", OPAR); split("", OKEY); split("", VPAR); split("", VKEY); split("", VEND); split("", ISKEY); split("", MEM); split("", REPL)
  P = 1
  if (!lex($0) || TK[1] != "{" || !pobj(0) || P != NT + 1) { print (host ? "[removed]" : cred($0)); fflush(); next }
  if (host) hostpass()
  print emit(); fflush()
}
'

# The tool-call program of the capture. It reads the arrival-stamped redacted
# stream, ISO<TAB>EPOCH<TAB>LINE per record, and prints one worker tool-call
# event of references/telemetry.md for each completed call, when its end record
# arrives: a Claude tool_use and the tool_result with the same id, or a Codex
# item.started and the item.completed with the same item id. A completion with
# no start is dropped; a start that never completes prints nothing. duration_s
# is exact integer-microsecond arithmetic; a missing clock is "unknown".
TC_AWK=$RED_FUNCS'BEGIN {
  SCALAR = "^(true|false|null|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][-+]?[0-9]+)?)$"
  BARE = "-+.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  for (i = 1; i < 32; i++) ORD[sprintf("%c", i)] = i
  HEAD = "\"kind\":\"tool-call\",\"delivery\":" q(delivery) ",\"station\":" q(station) ",\"attempt\":" q(attempt) ",\"source\":\"worker\""
}
function q(s) { return "\"" esc(s) "\"" }
function us(f) { return substr(f "000000", 1, 6) + 0 }
function dur(se, ee,   a, b, d) {
  if (se !~ /^[0-9]+[.][0-9]+$/ || ee !~ /^[0-9]+[.][0-9]+$/) return q("unknown")
  split(se, a, "."); split(ee, b, ".")
  d = (b[1] - a[1]) * 1000000 + (us(b[2]) - us(a[2]))
  if (d < 0) return q("unknown")
  return sprintf("%d.%06d", int(d / 1000000), d % 1000000)
}
function out(tool, id, si, se, tail) {
  if (tool == "") tool = q("unknown")
  print "{\"time\":" q(ISO) "," HEAD ",\"tool\":" tool ",\"id\":" id ",\"start\":" q(si) ",\"end\":" q(ISO) ",\"duration_s\":" dur(se, EP) "," tail "}"
  fflush()
}
{
  i = index($0, "\t"); if (!i) next
  ISO = substr($0, 1, i - 1); r = substr($0, i + 1)
  i = index(r, "\t"); if (!i) next
  EP = substr(r, 1, i - 1); r = substr(r, i + 1)
  split("", OPAR); split("", OKEY); split("", VPAR); split("", VKEY); split("", VEND); split("", ISKEY); split("", MEM)
  P = 1
  if (!lex(r) || TK[1] != "{" || !pobj(0) || P != NT + 1) next
  t = mget(1, "type")
  if (t == "\"item.started\"" || t == "\"item.completed\"") {
    if (!((1, "item") in MEM) || TK[o = MEM[1, "item"]] != "{" || (id = mget(o, "id")) == "") next
    if (t == "\"item.started\"") { XI[id] = ISO; XE[id] = EP; XT[id] = mget(o, "type"); next }
    if (!(id in XI)) next
    x = mget(o, "exit_code"); if (x !~ /^-?[0-9]+$/) x = q("unknown")
    out(XT[id], id, XI[id], XE[id], "\"exit\":" x)
    delete XI[id]; delete XE[id]; delete XT[id]
    next
  }
  for (i = 1; i <= NT; i++) {
    if (TK[i] != "{") continue
    t = mget(i, "type")
    if (t == "\"tool_use\"" && (id = mget(i, "id")) != "") { UI[id] = ISO; UE[id] = EP; UN[id] = mget(i, "name"); continue }
    if (t != "\"tool_result\"") continue
    id = mget(i, "tool_use_id")
    if (!(id in UI)) continue
    x = mget(i, "is_error"); if (x != "true" && x != "false") x = q("unknown")
    out(UN[id], id, UI[id], UE[id], "\"error\":" x)
    delete UI[id]; delete UE[id]; delete UN[id]
  }
}
'

# capture_block KIND HOST: prints the block that follows the lf=, cap=,
# redact_env=, events=, delivery=, station= and attempt= lines of a run script.
# HOST is 1 for a run under a host grant: claude-write-probe, and claude-write
# when its argv carries a Read( entry. The harness stdout goes through the
# redactor, then the stamping loop, which writes stdout and stream, then the
# tool-call program, which appends to events. references/harnesses/shared.md
# ("is a required-capture failure") owns the capture and telemetry failure
# classes; a tool-call pipe failure counts there as a tool-call stage failure.
capture_block() {
  local red=$RED_AWK
  [ "$2" != 1 ] || red="BEGIN { host = 1 }$RED_AWK"
  cat <<'EOF'
umask 077
set +e
rm -f -- "$cap/stdout" "$cap/stderr" "$cap/exit" "$cap/capture-error" || exit 70
rm -f -- "$cap/stream" "$cap/telemetry-error" 2>/dev/null
EOF
  printf "red='%s'\n" "$red"
  printf "tc='%s'\n" "$TC_AWK"
  cat <<'EOF'
{ { rc=0; "${argv[@]}" <"$lf" 2>&1 1>&3 3>&- || rc=$?; printf '%s\n' "$rc" >"$cap/exit" || exit 71; } | awk -v names="$redact_env" "$red" >"$cap/stderr"; s=("${PIPESTATUS[@]}"); [ "${s[0]}" = 0 ] && [ "${s[1]}" = 0 ] || exit 72; } 3>&1 | awk -v names="$redact_env" "$red" | {
  trap '' PIPE; export TZ=UTC0 LC_ALL=C; t=0 o=0
  exec 4>"$cap/stream" || { exec 4>/dev/null; t=1; }
  exec 5>"$cap/stdout" || exit 1
  while :; do
    if IFS= read -r l; then n=$'\n'; elif [ -n "$l" ]; then n=; else break; fi
    e=${EPOCHREALTIME-}
    if [ -n "$e" ]; then printf -v iso '%(%Y-%m-%dT%H:%M:%S)T' "${e%.*}"; iso=$iso.${e#*.}Z; else iso=unknown e=unknown; fi
    printf '%s%s' "$l" "$n" >&5 || exit 1
    [ "$t" = 1 ] || printf '%s\t%s\t%s\n' "$iso" "$e" "$l" >&4 || t=1
    [ "$o" = 1 ] || printf '%s\t%s\t%s\n' "$iso" "$e" "$l" || o=1
    [ -n "$n" ] || break
  done
  [ "$t$o" = 00 ] || printf 'telemetry failed: stream=%s tool-call-pipe=%s\n' "$t" "$o" >"$cap/telemetry-error" || :
} | awk -v delivery="$delivery" -v station="$station" -v attempt="$attempt" "$tc" >>"$events"
p=("${PIPESTATUS[@]}")
if [ "${p[0]}" = 0 ] && [ "${p[1]}" = 0 ] && [ "${p[2]}" = 0 ] && read -r rc <"$cap/exit"; then
  [ "${p[3]}" = 0 ] || printf 'telemetry failed: tool-call-stage=%s\n' "${p[3]}" >>"$cap/telemetry-error" || :
  exit "$rc"
fi
printf 'capture failed: harness-side=%s stdout-redactor=%s stdout-writer=%s\n' "${p[0]}" "${p[1]}" "${p[2]}" >"$cap/capture-error"
exit 70
EOF
}

# host_of KIND WORD...: prints 1 when a KIND run with this argv is under a host grant, else 0.
host_of() {
  local k=$1 w
  shift
  case $k in
    claude-write-probe) echo 1; return ;;
    claude-write) for w in "$@"; do case $w in 'Read('*) echo 1; return ;; esac; done ;;
  esac
  echo 0
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
    elif [[ $item =~ $WRAP_RE ]]; then
      v "$f entry starts with a denied wrapper: $item"
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
        i=$((i + 1)) ;;
      --permission-mode | --output-format | --model | --effort | --permission-prompts)
        CTX[i]=flag
        val=${W[i + 1]-}
        case $val in '' | -*) v "missing value for $w"; i=$((i + 1)); continue ;; esac
        CTX[i + 1]=$w
        want=
        case $w in
          --permission-mode) want=acceptEdits; [ "$KIND" != claude-read ] || want=manual ;;
          --output-format) want=stream-json ;;
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
  for f in --permission-mode --output-format --verbose --disable-slash-commands --strict-mcp-config --mcp-config --permission-prompts --allowedTools --disallowedTools; do
    case $SEEN in *" $f "*) ;; *) v "missing flag: $f" ;; esac
  done
  [ "$KIND" != claude-read ] || case $SEEN in *" --tools "*) ;; *) v "missing flag: --tools" ;; esac
}

walk_codex() {
  local i=1 n=${#W[@]} w val policy= rk= excl= cdir= olm= tdir= tpre= ppath= pseen= rdir rres rroot why
  [ "$KIND" = codex-write ] || rk=1
  if [ -n "$rk" ]; then
    # The run script does not name the worktree; check is given it.
    [ -n "$CWT" ] || die "check: --worktree is required for $KIND"
    # The read recipe runs under env, so TMPDIR is a checked argv word.
    [ "${W[0]}" = env ] || v "first word is not env: ${W[0]}"
    CTX[0]=cmd
    case ${W[1]-} in TMPDIR=/*) CTX[1]=env tdir=${W[1]#TMPDIR=} ;; *) v "missing TMPDIR=ABSOLUTE_PATH after env: ${W[1]-}" ;; esac
    case ${W[2]-} in
      TMPPREFIX=/*) CTX[2]=env tpre=${W[2]#TMPPREFIX=} i=3 ;;
      *) v "missing TMPPREFIX=RESULT_DIR/work/tmp/zsh after TMPDIR: ${W[2]-}"; i=2 ;;
    esac
    [ "${W[i]-}" = codex ] || v "word after the env words is not codex: ${W[i]-}"
    CTX[i]=cmd i=$((i + 1))
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
            elif [ -n "$rk" ] && [[ $val =~ $PATHPOL_RE ]]; then pseen=1 ppath=${BASH_REMATCH[1]}
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
  [ -n "$pseen" ] || v 'missing flag: -c shell_environment_policy.set.PATH="RESULT_DIR/bin:PATH"'
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
  [ -z "$tpre" ] || [ "$tpre" = "$rdir/work/tmp/zsh" ] || v "TMPPREFIX must be $rdir/work/tmp/zsh for $KIND: $tpre"
  [ -z "$pseen" ] || case $ppath in "$rdir/bin:"*) ;; *) v "shell_environment_policy.set.PATH must start with $rdir/bin: for $KIND: $ppath" ;; esac
  [ -z "$pseen" ] || { [ -d "$rdir/bin" ] && ! [ -L "$rdir/bin" ] && [ -O "$rdir/bin" ] && [ "$(mode_of "$rdir/bin")" = drwx------ ]; } \
    || v "$rdir/bin is not an owner-only directory"
  why=$(root_bad "$rdir" "$CWT")
  [ -z "$why" ] || v "$why"
}

# capture_lines FIRST TEXT: TEXT, which starts at line FIRST of the run script,
# must equal capture_block KIND HOST; reports the first line that differs.
capture_lines() {
  local e r=$2 k=$1
  e=$(capture_block "$KIND" "$(host_of "$KIND" ${W[@]+"${W[@]}"})"; printf x)
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
  local line ln=0 state=1 ok j n word lines blk= rest= re
  CK=$1 VIOL=0 KIND= CDT= STDIN= SAW_P= SEEN=' ' CAP= RENV= OLM=
  W=() CTX=() PB_F=() PB_W=() EVV=()
  # Grammar: the eight-part form, every line newline-terminated, nothing else.
  # Every kind ends with its lf=, cap=, redact_env=, events=, delivery=,
  # station= and attempt= lines and capture_block KIND HOST.
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
            case $line in "$EXEC0"*) v "exec line in a $KIND run script, which captures its run (line $ln)"; return ;; esac
            if [[ $line =~ $LF_RE ]]; then STDIN=${BASH_REMATCH[1]} state=20 ok=1; fi ;;
          20) if [[ $line =~ $CAP_RE ]]; then CAP=${BASH_REMATCH[1]} state=21 ok=1; fi ;;
          21) if [[ $line =~ $RENV_RE ]]; then RENV=${BASH_REMATCH[1]} state=23 ok=1; fi ;;
          23 | 24 | 25 | 26)
            word=${EV_LINES[state - 23]} re="^${EV_LINES[state - 23]}='([^']*)'\$"
            [[ $line =~ $re ]] || { v "missing $word= line in a $KIND run script (line $ln)"; return; }
            EVV+=("${BASH_REMATCH[1]}") state=$((state + 1)) ok=1
            [ "$state" != 27 ] || state=22 blk=$((ln + 1)) ;;
          22) rest=$rest$line$'\n' ok=1 ;;
        esac ;;
    esac
    [ -n "$ok" ] || { v "not a launch-builder run script (line $ln)"; return; }
  done <"$CK"
  case $state in
    22) capture_lines "$blk" "$rest" || return ;;
    *) v "not a launch-builder run script (line $((ln + 1)))"; return ;;
  esac
  n=${#W[@]}
  case $KIND in claude-*) FAM=claude; walk_claude ;; *) FAM=codex; walk_codex ;; esac
  # The capture directory, the credential names, and the tool-call event lines.
  if [[ $RENV =~ $NAMES_RE ]]; then :; else v "redact_env is not a list of environment variable names: $RENV"; fi
  if [ "$FAM" = claude ]; then word=$(cap_bad "$CAP" "$CDT" '' "$STDIN" "$CK")
  else word=$(cap_bad "$CAP" "$CWT" "$OLM" "$STDIN" "$CK"); fi
  [ -z "$word" ] || v "cap $word"
  [ -d "$CAP" ] || v "cap is not an owner-only directory: $CAP"
  case ${EVV[0]} in /*/events.jsonl) ;; *) v "events is not an absolute path ending in /events.jsonl: ${EVV[0]}" ;; esac
  [[ ${EVV[1]} =~ $DELIV_RE ]] || v "delivery is not OWNER/REPO#N: ${EVV[1]}"
  [ -n "${EVV[2]}" ] || v "station is empty"
  [ -n "${EVV[3]}" ] || v "attempt is empty"
  for ((j = 0; j < n; j++)); do case ${W[j]} in 'Read('*) [ "${CTX[j]-}" = --allowedTools ] || v "Read( entry outside --allowedTools: ${W[j]}" ;; esac; done # bite:read-outside
  for ((j = 0; j < n; j++)); do [ "${CTX[j]-}" != --add-dir ] || is_abs_dir "${W[j]}" || v "--add-dir is not an existing directory: ${W[j]}"; done # bite:add-dir
  for ((j = 0; j < ${#PB_W[@]}; j++)); do v "positional argument after list-taking flag ${PB_F[j]}: ${PB_W[j]}"; done # bite:positional
  case $STDIN in /*) [ -f "$STDIN" ] || v "prompt not attached on stdin: not a regular file: $STDIN" ;; *) v "prompt not attached on stdin${STDIN:+: not an absolute path: $STDIN}" ;; esac # bite:stdin
  [ "$FAM" != codex ] || [ "${W[n - 1]}" = - ] || v "prompt not attached on stdin: the argv does not end in -" # bite:stdin
  [ "$FAM" != claude ] || [ "$SAW_P" = 1 ] || v "prompt not attached on stdin: no -p" # bite:stdin
}

# ---- subcommands ----

render() { # KIND START_DIR LAUNCH_FILE WORD...; also reads CAP, RENV, EVENTS, DELIVERY, STATION and ATTEMPT
  local k=$1 w=$2 l=$3
  shift 3
  printf '#!/usr/bin/env bash\n# Capstan launch (%s). Written by scripts/launch.sh; verify with scripts/launch.sh check.\nset -eu\nargv=(\n' "$k"
  printf "'%s'\n" "$@"
  printf ")\ncd -- '%s'\nlf='%s'\ncap='%s'\nredact_env='%s'\n" "$w" "$l" "$CAP" "$RENV"
  printf "events='%s'\ndelivery='%s'\nstation='%s'\nattempt='%s'\n" "$EVENTS" "$DELIVERY" "$STATION" "$ATTEMPT"
  capture_block "$k" "$(host_of "$k" "$@")"
}

cmd_write() {
  local kind= wt= lf= out= model= effort= hs= result= cap= events= delivery= station= attempt= a val dir tmp d cdir rdir rres rroot tdir= bdir py why
  local -a adds=() allows=() renvs=() A=()
  while [ $# -gt 0 ]; do
    a=$1
    case $a in
      --kind | --worktree | --launch-file | --out | --model | --effort | --add-dir | --allow | --host-source | --result \
        | --capture | --redact-env | --events | --delivery | --station | --attempt) ;;
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
      --events)
        need_abs "$a" "$val"
        case $val in */events.jsonl) ;; *) die "--events must be an absolute path ending in /events.jsonl: $val" ;; esac
        events=$val ;;
      --delivery) [[ $val =~ $DELIV_RE ]] || die "--delivery must have the form OWNER/REPO#N: $val"; delivery=$val ;;
      --station) station=$val ;;
      --attempt) attempt=$val ;;
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
    ! [[ $a =~ $WRAP_RE ]] || die "--allow starts with a denied wrapper: $a"
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
  [ -n "$cap" ] || die "--capture is required for $kind"
  for a in events delivery station attempt; do
    [ -n "${!a}" ] || die "--$a is required for $kind"
  done
  # The capture directory is checked before anything is created and again once it exists.
  why=$(cap_bad "$cap" "$wt" "$result" "$lf" "$out")
  [ -z "$why" ] || die "--capture $why"
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
      case $PATH in *[\'\"\\]* | *[[:cntrl:]]*) die "PATH holds a single quote, double quote, backslash or control character: cannot build $kind" ;; esac
      cdir=$rdir/work tdir=$rdir/work/tmp bdir=$rdir/bin
      for d in "$cdir" "$tdir" "$bdir"; do
        if [ -L "$d" ] || { [ -e "$d" ] && ! [ -d "$d" ]; }; then die "not a directory: $d"; fi
        [ -d "$d" ] || (umask 077 && mkdir -- "$d") || die "cannot create $d"
        [ -O "$d" ] && [ "$(mode_of "$d")" = drwx------ ] || die "not an owner-only directory: $d"
      done
      [ ! -e "$bdir/python" ] || [ -L "$bdir/python" ] || die "not a symlink: $bdir/python"
      py=$(command -v python3) || py=
      case $py in /*) ln -sfn -- "$py" "$bdir/python" || die "cannot link $bdir/python" ;; *) rm -f -- "$bdir/python" ;; esac ;;
  esac
  [ -e "$cap" ] || [ -L "$cap" ] || (umask 077 && mkdir -- "$cap") || die "cannot create $cap"
  why=$(cap_bad "$cap" "$wt" "$result" "$lf" "$out")
  [ -z "$why" ] || die "--capture $why"
  CAP=$cap RENV=${renvs[*]+"${renvs[*]}"} EVENTS=$events DELIVERY=$delivery STATION=$station ATTEMPT=$attempt

  GRANT_READS=()
  case $kind in claude-write*) grant "$hs" "$wt" ;; esac

  case $kind in
    claude-*)
      A=(claude -p --permission-mode)
      if [ "$kind" = claude-read ]; then A+=(manual); else A+=(acceptEdits); fi
      A+=(--output-format stream-json --verbose)
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
      [ "$kind" = codex-write ] || A=(env "TMPDIR=$tdir" "TMPPREFIX=$tdir/zsh" "${A[@]}" --skip-git-repo-check -c sandbox_workspace_write.exclude_slash_tmp=true \
        -c "shell_environment_policy.set.PATH=\"$bdir:$PATH\"")
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

# ---- pack: the pack check; references/pack.md ("Pack check:") owns the rule ----

PK_LEAD_RE='^[[:space:]]*(([-*+]|[0-9]+[.)]|>)[[:space:]]*)*`([^`[:space:]]+)`'
PK_INLINE_RE='(^|[[:space:](`])([A-Za-z0-9_.~/+-]*[A-Za-z][A-Za-z0-9_.~/+-]*):([0-9]+(-[0-9]+)?)([^:A-Za-z0-9]|$)'
PK_HINT_RE='^(.+):[0-9]+(-[0-9]+)?$'
PK_BLANK_RE='^[[:space:]]*$'
PK_COMPACT_RE='^(Criterion|Rule|Check|Named file):'
PK_RULE_RE='^Rule:[[:space:]]*`?([^`[:space:]]+)'
PK_NAMED_RE='^Named file:[[:space:]]*`([^`[:space:]]+)`'
PK_CITES=() PK_NAMED=() PK_BAD=0

# pk_file CITATION WORKTREE: the cited file without a :LINE or :LINE-RANGE hint,
# a leading ./, or a leading WORKTREE/.
pk_file() {
  local p=$1
  [[ $p =~ $PK_HINT_RE ]] && p=${BASH_REMATCH[1]}
  p=${p#./}
  case $p in "$2"/*) p=${p#"$2"/} ;; esac
  printf '%s\n' "$p"
}

# pk_path TOKEN: TOKEN is a path: it holds a / or a ., or ends in a :LINE or :LINE-RANGE hint.
pk_path() { [[ $1 == */* || $1 == *.* || $1 =~ $PK_HINT_RE ]]; }

# pk_cite LINE: add what one ## Rules that apply line cites to PK_CITES: the backticked
# path that opens it, after any list or blockquote markers, or else each path:line hint on it
# whose path holds a letter and whose hint is followed by no :, letter, or digit.
pk_cite() {
  local rest=$1 t
  if [[ $rest =~ $PK_LEAD_RE ]]; then
    t=${BASH_REMATCH[3]}
    pk_path "$t" && { PK_CITES+=("$t"); return; }
  fi
  while [[ $rest =~ $PK_INLINE_RE ]]; do
    PK_CITES+=("${BASH_REMATCH[2]}:${BASH_REMATCH[3]}")
    rest=${rest#*"${BASH_REMATCH[0]}"}
  done
}

# pk_entry ENTRY REST WT: the Named files ENTRY carries ("anchor") at the start of REST; when ENTRY's
# path is a file in WT, the anchor occurs inside its line range, or in the file when it has none.
pk_entry() {
  local c=$1 f a s= e=
  if [[ $2 =~ ^[[:space:]]*\(\"(.*)$ ]] && [[ ${BASH_REMATCH[1]} == *'")'* ]]; then
    a=${BASH_REMATCH[1]%%'")'*}
  else
    printf 'launch.sh: pack: %s: no quoted anchor; fix: write `%s ("anchor") — reason` with a heading or verbatim phrase inside the range\n' "$c" "$c" >&2
    PK_BAD=$((PK_BAD + 1)); return
  fi
  if [[ $a =~ ^[[:space:]]*$ ]]; then
    printf 'launch.sh: pack: %s ("%s"): the anchor holds no text; fix: quote a heading or verbatim phrase inside the range, as ("anchor")\n' "$c" "$a" >&2
    PK_BAD=$((PK_BAD + 1)); return
  fi
  f=$(pk_file "$c" "$3")
  [[ $f != /* && -f $3/$f ]] || return 0
  [[ $c =~ :([0-9]+)(-([0-9]+))?$ ]] && { s=${BASH_REMATCH[1]}; e=${BASH_REMATCH[3]:-$s}; }
  CT_WT=$3 CT_REV=
  ct_has "$f" "$a" "$s" "$e" && return 0
  if [ -n "$s" ]; then
    printf 'launch.sh: pack: %s ("%s"): the anchor is not inside lines %s-%s of %s; fix: widen the range to the lines that hold it, or quote a heading or verbatim phrase inside it\n' "$c" "$a" "$s" "$e" "$f" >&2
  else
    printf 'launch.sh: pack: %s ("%s"): the anchor does not occur in %s; fix: quote a heading or verbatim phrase that %s holds\n' "$c" "$a" "$f" "$f" >&2
  fi
  PK_BAD=$((PK_BAD + 1))
}

cmd_pack() {
  local pk= wt= line c f n i b e where entry r=-1 nf=-1 bad=0
  local -a L=() seen=()
  while [ $# -gt 0 ]; do
    case $1 in
      --worktree)
        [ $# -ge 2 ] || die "pack: --worktree needs a value"
        need_abs --worktree "$2"
        [ -d "$2" ] || die "--worktree is not a directory: $2"
        wt=${2%/}
        shift 2 ;;
      *)
        [ -z "$pk" ] || die "usage: launch.sh pack PACK --worktree DIR"
        pk=$1
        shift ;;
    esac
  done
  [ -n "$pk" ] && [ -n "$wt" ] || die "usage: launch.sh pack PACK --worktree DIR"
  need_abs PACK "$pk"
  [ -f "$pk" ] && [ -r "$pk" ] || die "pack: cannot read pack: $pk"
  while IFS= read -r line || [ -n "$line" ]; do L+=("$line"); done <"$pk"
  e=$((${#L[@]} - 1))
  while [ "$e" -ge 0 ] && [[ ${L[e]} =~ $PK_BLANK_RE ]]; do e=$((e - 1)); done
  if [ "$e" -ge 0 ] && [[ ${L[e]} =~ $PK_COMPACT_RE ]]; then
    # Compact: only the closing run of Criterion:, Rule:, Check:, Named file:, and blank lines.
    b=$e
    while [ "$b" -gt 0 ] && [[ ${L[b-1]} =~ $PK_COMPACT_RE || ${L[b-1]} =~ $PK_BLANK_RE ]]; do b=$((b - 1)); done
    for ((i = b; i <= e; i++)); do
      if [[ ${L[i]} =~ $PK_RULE_RE ]]; then
        PK_CITES+=("${BASH_REMATCH[1]}")
      elif [[ ${L[i]} =~ $PK_NAMED_RE ]]; then
        c=${BASH_REMATCH[1]}
        PK_NAMED+=("$(pk_file "$c" "$wt")")
        pk_entry "$c" "${L[i]#*"\`$c\`"}" "$wt"
      fi
    done
    where='on a Rule: line, but no Named file: line names it; add a Named file: line'
  else
    # Full: the last ## Rules that apply and ## Named files headings. The candidate and the
    # open findings come before them, so nothing they carry, fenced or not, is read here.
    for i in "${!L[@]}"; do
      case ${L[i]} in
        '## Rules that apply'*) r=$i ;;
        '## Named files'*) nf=$i ;;
      esac
    done
    if [ "$r" -ge 0 ]; then
      # The quotes end at the first ## Checks or ## Named files line after the Rules heading.
      for ((i = r + 1; i < ${#L[@]}; i++)); do
        case ${L[i]} in '## Checks'* | '## Named files'*) break ;; esac
        pk_cite "${L[i]}"
      done
    fi
    if [ "$nf" -gt "$r" ]; then
      for ((i = nf + 1; i < ${#L[@]}; i++)); do
        case ${L[i]} in '## '*) break ;; esac
        [[ ${L[i]} =~ $PK_LEAD_RE ]] || continue
        c=${BASH_REMATCH[3]}
        pk_path "$c" || continue
        PK_NAMED+=("$(pk_file "$c" "$wt")")
        pk_entry "$c" "${L[i]#*"\`$c\`"}" "$wt"
      done
    fi
    where='under ## Rules that apply, but no ## Named files entry names it; add a ## Named files entry'
  fi
  for c in "${PK_CITES[@]}"; do
    f=$(pk_file "$c" "$wt")
    for n in "${PK_NAMED[@]}" "${seen[@]}"; do [ "$n" = "$f" ] && continue 2; done
    seen+=("$f")
    entry="\`$f:START-END (\"anchor\") — reason\`"
    printf 'launch.sh: pack: %s is cited at %s %s %s whose range holds the quoted line\n' "$f" "$c" "$where" "$entry" >&2
    bad=$((bad + 1))
  done
  [ "$bad" -eq 0 ] && [ "$PK_BAD" -eq 0 ] || exit 1
  exit 0
}

# ---- cite: the citation check; references/pack.md ("Citation check:") owns the rule ----

CT_REPO_RE='\]\(([^) ]+)\)([^][()]{0,60})\("'
CT_STOP_RE='[.!?][[:space:]]'
CT_LINK_RE='\[[^]]*\]\(([^) ]+)\)'
CT_TICK_RE='`([^`[:space:]]+)`'
CT_HINT_ANCHOR_RE='^([^][()|"`]{0,60})\(?"'
CT_LINK_ANCHOR_RE='^([^][()|"`]{0,60})\("'
CT_STEP_RE='^[[:space:]]*(\((steps?|items?)[[:space:]]+[0-9][^)]*\))'
CT_FENCE_RE='^ {0,3}(```+|~~~+)'
CT_WT= CT_REV= CT_BAD=0 CT_EAT=0 CT_PLEN=0 CT_FILES=$'\n'
CT_CP=() CT_CT=()

# ct_norm TEXT: TEXT with each run of whitespace collapsed to one space, in REPLY.
ct_norm() {
  local s=${1//[$'\t\r\n']/ }
  while [[ $s == *'  '* ]]; do s=${s//  / }; done
  REPLY=$s
}

# ct_list: the tree's files, at --rev or in the index, one per line in CT_FILES.
ct_list() {
  local out
  if [ -n "$CT_REV" ]; then
    out=$(git -C "$CT_WT" -c core.quotepath=off ls-tree -r --name-only "$CT_REV") || die "cite: cannot list $CT_REV in $CT_WT"
  else
    out=$(git -C "$CT_WT" -c core.quotepath=off ls-files) || die "cite: --worktree is not a git work tree: $CT_WT"
  fi
  CT_FILES=$'\n'$out$'\n'
}
ct_in() { [[ $CT_FILES == *$'\n'"$1"$'\n'* ]]; }

# ct_text PATH [START END]: PATH's collapsed text, or that of its lines START-END, in REPLY.
ct_text() {
  local p=$1 s=${2-} e=${3-} raw i line out=
  if [ -z "$s" ]; then
    for i in "${!CT_CP[@]}"; do [ "${CT_CP[i]}" = "$p" ] && { REPLY=${CT_CT[i]}; return; }; done
  fi
  if [ -n "$CT_REV" ]; then raw=$(git -C "$CT_WT" show "$CT_REV:$p") || die "cite: cannot read $p at $CT_REV"
  else raw=$(<"$CT_WT/$p") || die "cannot read $CT_WT/$p"; fi
  if [ -n "$s" ]; then
    i=0
    while IFS= read -r line; do i=$((i + 1)); [ "$i" -ge "$s" ] && [ "$i" -le "$e" ] && out+="$line "; done <<<"$raw"
    raw=$out
  fi
  ct_norm "$raw"
  [ -n "$s" ] || { CT_CP+=("$p"); CT_CT+=("$REPLY"); }
}

# ct_has PATH ANCHOR [START END]: ANCHOR, collapsed, is part of PATH's text or of its lines START-END.
ct_has() { local a; ct_norm "$2"; a=$REPLY; ct_text "$1" "${3-}" "${4-}"; [[ $REPLY == *"$a"* ]]; }

# ct_fail WHERE CITATION PROBLEM TARGET: one error line that names the fix.
ct_fail() {
  printf 'launch.sh: cite: %s: %s: %s; fix: quote a heading or verbatim phrase that %s holds, as ("anchor")\n' "$1" "$2" "$3" "$4" >&2
  CT_BAD=$((CT_BAD + 1))
}

# ct_check WHERE CITATION PATH INNER: each anchor of INNER, one quote's text or several
# joined by '" and "' or '", "', holds text other than whitespace and occurs in PATH.
ct_check() {
  local in=$4 a why
  in=${in//\" and \"/$'\x1f'}; in=${in//\", \"/$'\x1f'}$'\x1f'
  while [ -n "$in" ]; do
    a=${in%%$'\x1f'*}; in=${in#*$'\x1f'}
    if [[ $a =~ ^[[:space:]]*$ ]]; then
      why="the anchor \"$a\" holds no text"
    else
      ct_has "$3" "$a" && continue
      why="the anchor \"$a\" does not occur in $3"
      case $a in *…* | *...*) why+="; an ellipsis is not verbatim text" ;; esac
    fi
    ct_fail "$1" "$2" "$why" "$3"
  done
}

# ct_canon DIR PATH: DIR/PATH without empty, . and .. segments, in REPLY; .. at the root is dropped.
ct_canon() {
  local seg out= p=$1/$2 IFS=/
  set -f; set -- $p; set +f
  for seg; do
    case $seg in
      '' | .) ;;
      ..) case $out in */*) out=${out%/*} ;; *) out= ;; esac ;;
      *) out=${out:+$out/}$seg ;;
    esac
  done
  REPLY=$out
}

# ct_repo: each owner link and quoted anchor pair in the tree's Markdown files. A pair is one
# sentence: a gap holding . ! or ? and then whitespace is two. The parenthesis closes at the
# first "), so an anchor may hold ( and ).
ct_repo() {
  local f d s link gap in tgt
  while IFS= read -r f; do
    case $f in *.md) ;; *) continue ;; esac
    ct_text "$f"; s=$REPLY
    d=${f%/*}; [ "$d" = "$f" ] && d=
    while [[ $s =~ $CT_REPO_RE ]]; do
      link=${BASH_REMATCH[1]} gap=${BASH_REMATCH[2]}
      s=${s#*"${BASH_REMATCH[0]}"}
      [[ $gap =~ $CT_STOP_RE ]] && continue
      [[ $s == *'")'* ]] || continue
      in=${s%%'")'*}
      s=${s#*'")'}
      case $link in http* | '#'*) continue ;; esac
      ct_canon "$d" "${link%%#*}"; tgt=$REPLY
      if ! ct_in "$tgt"; then
        printf 'launch.sh: cite: %s: link %s ("%s"): the target %s is not in the tree; fix: link a file the tree holds, and quote a heading or verbatim phrase that it holds, as ("anchor")\n' "$f" "$link" "$in" "$tgt" >&2
        CT_BAD=$((CT_BAD + 1)); continue
      fi
      ct_check "$f" "link $link (\"$in\")" "$tgt" "$in"
    done
  done <<<"$CT_FILES"
}

# ct_paren TEXT: TEXT opens, after any spaces, with ("…"); REPLY holds each quote's text joined by
# '" and "', with any directly following and ("…") or , ("…"); CT_PLEN is the length of TEXT they span.
ct_paren() {
  local t=$1 q= a k=0
  while [[ $t =~ ^[[:space:]]*\(\"(.*)$ ]] && [[ ${BASH_REMATCH[1]} == *'")'* ]]; do
    a=${BASH_REMATCH[1]%%'")'*}
    if [ "$k" -gt 0 ]; then q+="\" and \"$a"; else q=$a; fi
    k=$((k + 1)) t=${BASH_REMATCH[1]#*'")'}
    [[ $t =~ ^(,|[[:space:]]+and)([[:space:]]*\(\".*)$ ]] || break
    t=${BASH_REMATCH[2]}
  done
  [ "$k" -gt 0 ] || return 1
  REPLY=$q CT_PLEN=$((${#1} - ${#t}))
}

# ct_resolve WHERE PATH ANCHORED: the tree file PATH names, in REPLY. A PATH that is no file in the
# tree names nothing unless ANCHORED is 1 and PATH holds no /: then it names the one file with that name.
ct_resolve() {
  local f hit= k=0
  ct_in "$2" && { REPLY=$2; return 0; }
  [ "$3" = 1 ] && [[ $2 != */* ]] || return 1
  while IFS= read -r f; do [ "${f##*/}" = "$2" ] && { hit=$f; k=$((k + 1)); }; done <<<"$CT_FILES"
  [ "$k" -eq 1 ] && { REPLY=$hit; return 0; }
  if [ "$k" -gt 1 ]; then
    printf 'launch.sh: cite: %s: %s: %s files in the tree have this name; fix: cite it by its path from the repository root\n' "$1" "$2" "$k" >&2
    CT_BAD=$((CT_BAD + 1))
  fi
  return 1
}

# ct_hinted WHERE TOKEN AFTER: a path:line or path:line-range TOKEN, and the text AFTER it.
# CT_EAT is the length of AFTER that its anchor spans, so the scan reads on after the anchor.
ct_hinted() {
  local p q= t g k=
  p=$(pk_file "$2" "$CT_WT")
  if [[ $3 =~ $CT_HINT_ANCHOR_RE ]]; then
    g=${#BASH_REMATCH[1]}; t=${3:g}
    if [[ $t == '('* ]]; then ct_paren "$t" && { q=$REPLY k=1 CT_EAT=$((g + CT_PLEN)); }
    else t=${t#\"}; [[ $t == *\"* ]] && { q=${t%%\"*} k=1; CT_EAT=$((g + ${#q} + 2)); }; fi
  fi
  if [ -n "$k" ]; then
    ct_resolve "$1" "$p" 1 || return 0
    ct_check "$1" "$2 (\"$q\")" "$REPLY" "$q"
  else
    ct_resolve "$1" "$p" 0 || return 0
    ct_fail "$1" "$2" "no quoted anchor" "$REPLY"
  fi
}

# ct_tick WHERE TOKEN AFTER: a backticked TOKEN. With no line hint it cites only when ("…"),
# (step N), or (item N) directly follows it; CT_EAT is the length of AFTER that follower spans.
ct_tick() {
  local p q s
  if [[ $2 =~ $PK_HINT_RE ]]; then ct_hinted "$@"; return; fi
  pk_path "$2" || return 0
  p=$(pk_file "$2" "$CT_WT")
  if ct_paren "$3"; then
    q=$REPLY CT_EAT=$CT_PLEN
    ct_resolve "$1" "$p" 1 || return 0
    ct_check "$1" "$2 (\"$q\")" "$REPLY" "$q"
  elif [[ $3 =~ $CT_STEP_RE ]]; then
    s=${BASH_REMATCH[1]} CT_EAT=${#BASH_REMATCH[0]}
    ct_resolve "$1" "$p" 1 || return 0
    ct_fail "$1" "$2 $s" "a step or item number is not an anchor" "$REPLY"
  fi
}

# ct_link WHERE LINK TARGET AFTER: a Markdown LINK to TARGET, and the text AFTER it; CT_EAT is the
# length of AFTER that its anchor spans, read even for a link the check skips.
ct_link() {
  local t=${3%%#*} q= g k=
  if [[ $4 =~ $CT_LINK_ANCHOR_RE ]]; then
    g=${#BASH_REMATCH[1]}
    ct_paren "${4:g}" && { q=$REPLY k=1 CT_EAT=$((g + CT_PLEN)); }
  fi
  case $t in '' | *://* | mailto:*) return 0 ;; esac
  while :; do case $t in ./*) t=${t#./} ;; ../*) t=${t#../} ;; *) break ;; esac; done
  ct_canon "" "$t"; t=$REPLY
  ct_in "$t" || return 0
  if [ -n "$k" ]; then ct_check "$1" "$2 (\"$q\")" "$t" "$q"
  else ct_fail "$1" "$2" "no quoted anchor" "$t"; fi
}

# ct_line WHERE LINE: each citation on one plan line outside fences, left to right; after each
# citation the scan reads on after its anchor, so an anchor's text is never read as a citation.
ct_line() {
  local w=$1 rest=$2 k re m o bo kind tok tgt
  while :; do
    bo=-1
    for k in link tick inline; do
      case $k in link) re=$CT_LINK_RE ;; tick) re=$CT_TICK_RE ;; *) re=$PK_INLINE_RE ;; esac
      [[ $rest =~ $re ]] || continue
      m=${BASH_REMATCH[0]}; o=${rest%%"$m"*}; o=${#o}
      if [ "$bo" -lt 0 ] || [ "$o" -lt "$bo" ]; then
        bo=$o kind=$k tok=$m
        case $k in inline) tgt=${BASH_REMATCH[2]}:${BASH_REMATCH[3]} ;; *) tgt=${BASH_REMATCH[1]} ;; esac
      fi
    done
    [ "$bo" -ge 0 ] || return 0
    rest=${rest:bo+${#tok}} CT_EAT=0
    case $kind in
      link) ct_link "$w" "$tok" "$tgt" "$rest" ;;
      tick) ct_tick "$w" "$tgt" "$rest" ;;
      *) ct_hinted "$w" "$tgt" "$rest" ;;
    esac
    rest=${rest:CT_EAT}
  done
}

# ct_plan PLAN: each line of PLAN outside fenced blocks; a fence closes on the same character, at least as long.
ct_plan() {
  local n=0 line f= t
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n + 1))
    if [[ $line =~ $CT_FENCE_RE ]]; then
      t=${BASH_REMATCH[1]}
      if [ -z "$f" ]; then f=$t
      elif [ "${t:0:1}" = "${f:0:1}" ] && [ "${#t}" -ge "${#f}" ]; then f=; fi
      continue
    fi
    [ -n "$f" ] || ct_line "$1:$n" "$line"
  done <"$1"
}

cmd_cite() {
  local plan=
  while [ $# -gt 0 ]; do
    case $1 in
      --worktree)
        [ $# -ge 2 ] || die "cite: --worktree needs a value"
        need_abs --worktree "$2"
        [ -d "$2" ] || die "--worktree is not a directory: $2"
        CT_WT=${2%/}; shift 2 ;;
      --plan)
        [ $# -ge 2 ] || die "cite: --plan needs a value"
        need_abs --plan "$2"; plan=$2; shift 2 ;;
      --rev)
        [ $# -ge 2 ] || die "cite: --rev needs a value"
        CT_REV=$2; shift 2 ;;
      *) die "usage: launch.sh cite --worktree DIR [--plan PLAN] [--rev SHA]" ;;
    esac
  done
  [ -n "$CT_WT" ] || die "usage: launch.sh cite --worktree DIR [--plan PLAN] [--rev SHA]"
  [ -z "$plan" ] || { [ -f "$plan" ] && [ -r "$plan" ]; } || die "cite: cannot read plan: $plan"
  [ -z "$CT_REV" ] || git -C "$CT_WT" rev-parse -q --verify "$CT_REV^{commit}" >/dev/null || die "cite: --rev is not a commit in $CT_WT: $CT_REV"
  ct_list
  if [ -n "$plan" ]; then ct_plan "$plan"; else ct_repo; fi
  [ "$CT_BAD" -eq 0 ] || exit 1
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
  pack) shift; cmd_pack "$@" ;;
  cite) shift; cmd_cite "$@" ;;
  *) die "usage: launch.sh write|check|grant|pack|cite ... (see the header of scripts/launch.sh)" ;;
esac
