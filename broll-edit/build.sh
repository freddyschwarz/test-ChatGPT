#!/usr/bin/env bash
# Usage: ./build.sh <input.mp4> <brolls-dir> <output.mp4>
# B-Rolls (Pexels, hochkant) in <brolls-dir>: pool money sign furn calc sign2 keys (.mp4)
# Sie decken Bild 0..790px ab; Untertitel (unten) + Originalton bleiben erhalten.
set -euo pipefail
IN=$1; DIR=$2; OUT=$3
# name:start:end[:offset] (Sekunden auf der Haupt-Timeline, laut Transkript; offset = Einstieg im B-Roll-Clip)
SHOTS=(pool:16.0:20.4 money:12.4:14.0:2 sign:27.9:30.0 furn:31.4:34.2 calc:57.0:59.5 sign2:65.6:67.4 keys:74.3:75.96)
inputs=(-i "$IN"); fc=""; prev="[0:v]"; i=1
for s in "${SHOTS[@]}"; do IFS=: read -r n a b o <<<"$s"; o=${o:-0}
  d=$(awk "BEGIN{print $b-$a}")
  inputs+=(-ss "$o" -t "$d" -i "$DIR/$n.mp4")
  fc+="[$i:v]scale=576:790:force_original_aspect_ratio=increase,crop=576:790,setsar=1,fps=30,setpts=PTS-STARTPTS+$a/TB[b$i];"
  fc+="$prev[b$i]overlay=0:0:enable='between(t,$a,$b)':eof_action=pass[v$i];"
  prev="[v$i]"; i=$((i+1))
done
ffmpeg -y "${inputs[@]}" -filter_complex "${fc%;}" -map "$prev" -map 0:a -c:v libx264 -crf 18 -preset medium -c:a copy "$OUT"
