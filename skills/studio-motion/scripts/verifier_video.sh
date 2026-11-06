#!/usr/bin/env bash
# Contrôle qualité d'une vidéo finie : piste audio, format, volume, transcription, images du cadrage.
# Usage : verifier_video.sh <video.mp4> [langue=fr]
set -u; V="$1"; L="${2:-fr}"; T=$(mktemp -d); trap 'rm -rf "$T"' EXIT; bad=0
[ -f "$V" ] || { echo "✗ fichier introuvable : $V"; exit 1; }
types=$(ffprobe -v error -show_entries stream=codec_type -of csv=p=0 "$V" | tr '\n' ' ')
echo "$types" | grep -q audio && echo "✓ piste audio présente" || { echo "✗ PAS DE SON : rendre avec 'short.mjs all', pas 'render'"; bad=1; }
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,bit_rate -of csv=p=0 "$V" | awk -F, '{printf "✓ image : %s %sx%s, %.0f Mb/s\n", $1, $2, $3, $4/1e6}'
if echo "$types" | grep -q audio; then
  ffmpeg -hide_banner -nostats -i "$V" -af ebur128=peak=true -f null - 2>&1 | awk '/Integrated loudness/{f=1} f&&/I:/{printf "✓ volume : %s %s (cible -14)\n",$2,$3} f&&/Peak:/{printf "✓ pic vrai : %s %s (doit rester sous -1)\n",$2,$3; exit}'
  M=~/.cache/whisper-cpp/ggml-large-v3-turbo-q5_0.bin
  if command -v whisper-cli >/dev/null && [ -f "$M" ]; then
    ffmpeg -v error -y -i "$V" -ar 16000 -ac 1 "$T/a.wav"
    echo "• transcription du rendu (à relire en entier) :"; whisper-cli -m "$M" -l "$L" -f "$T/a.wav" -nt -np 2>/dev/null | sed "s/^/    /"; echo
  fi
fi
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$V")
for k in 1 2 3; do t=$(awk -v d="$D" -v k=$k 'BEGIN{print d*(k*2-1)/6}'); ffmpeg -v error -y -ss "$t" -i "$V" -frames:v 1 -vf "crop=948:800:66:915,scale=316:-1" "$T/c$k.jpg" 2>/dev/null; done
ffmpeg -v error -y -i "$T/c1.jpg" -i "$T/c2.jpg" -i "$T/c3.jpg" -filter_complex hstack=3 /tmp/studio-motion-cadrage.jpg 2>/dev/null && echo "• cadrage (carte caméra au début, milieu, fin) : /tmp/studio-motion-cadrage.jpg"
exit $bad
