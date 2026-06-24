#!/usr/bin/env bash
# Render a terminal-style PNG screenshot from a command + its captured output,
# using headless Chrome (2x DPI). Used to produce the proof-of-work screenshots.
#
#   capture.sh <output_name> "<displayed command>" <path-to-output-text>
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHOTS="$REPO/screenshots"
CHROME="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
mkdir -p "$SHOTS"

name="$1"; cmd="$2"; outfile="$3"
output="$(cat "$outfile")"

lines=$(printf '%s\n' "$output" | wc -l)
height=$(( lines * 21 + 130 )); [ "$height" -lt 200 ] && height=200

cmd_esc=$(printf '%s' "$cmd" | sed 's/</\&lt;/g; s/>/\&gt;/g')
inner=$(printf '%s' "$output" | python3 -c "import sys,html; print(html.escape(sys.stdin.read()).replace(chr(10),'<br>'))")

html="/mnt/c/Windows/Temp/cap_$$.html"
cat > "$html" << HTMLEOF
<!DOCTYPE html><html><head><meta charset="utf-8"><style>
* { margin:0; padding:0; box-sizing:border-box; }
html,body { background:#1e1e2e; display:inline-block; width:960px; }
.b { padding:14px 18px 18px 18px; color:#cdd6f4;
     font-family:'Cascadia Code','Consolas','Courier New',monospace;
     font-size:13px; line-height:1.5; white-space:pre; }
.p { margin-bottom:6px; } .u{color:#a6e3a1;} .h{color:#89b4fa;} .c{color:#f9e2af;}
</style></head><body><div class="b">
<div class="p"><span class="u">naman</span>@<span class="h">ansible-control</span>:~\$ <span class="c">${cmd_esc}</span></div>
${inner}
</div></body></html>
HTMLEOF

"$CHROME" --headless=new --disable-gpu \
  --screenshot="C:\\Windows\\Temp\\${name}.png" \
  --window-size="960,${height}" --force-device-scale-factor=2 \
  --hide-scrollbars "file:///C:/Windows/Temp/cap_$$.html" 2>/dev/null

cp "/mnt/c/Windows/Temp/${name}.png" "$SHOTS/${name}.png"
rm -f "$html" "/mnt/c/Windows/Temp/${name}.png"
echo "Saved: $SHOTS/${name}.png"
