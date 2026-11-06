#!/usr/bin/env bash
# Colle une signature enregistrée à part à la suite de la prise principale, en une seule prise 4K de haute qualité.
# Usage : assembler_prises.sh <prise principale> <fin en secondes> <signature> <sortie.mov>
set -euo pipefail
[ $# -eq 4 ] || { echo "Usage : $0 <prise> <fin_en_secondes> <signature> <sortie.mov>"; exit 1; }
P="$1"; FIN="$2"; SIG="$3"; OUT="$4"
VC=(-c:v libx264 -crf 12 -preset medium); ffmpeg -hide_banner -encoders 2>/dev/null | grep -q h264_videotoolbox && VC=(-c:v h264_videotoolbox -b:v 80M -profile:v high)
ffmpeg -v error -y -i "$P" -i "$SIG" -filter_complex \
 "[0:v]trim=0:$FIN,setpts=PTS-STARTPTS,format=yuv420p[v0];[0:a]atrim=0:$FIN,asetpts=PTS-STARTPTS[a0];[1:v]setpts=PTS-STARTPTS,format=yuv420p[v1];[1:a]asetpts=PTS-STARTPTS[a1];[v0][a0][v1][a1]concat=n=2:v=1:a=1[v][a]" \
 -map "[v]" -map "[a]" "${VC[@]}" -c:a pcm_s16le -ar 48000 "$OUT"
ffprobe -v error -show_entries format=duration:stream=width,height -of compact "$OUT"
echo "✓ Prise assemblée : $OUT (la signature commence à $FIN s)"
