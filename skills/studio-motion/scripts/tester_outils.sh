#!/usr/bin/env bash
# Teste chaque outil pour de vrai : encodage FFmpeg, transcription Whisper, moteur prêt. À lancer depuis le dossier du studio.
set -u; T=$(mktemp -d); trap 'rm -rf "$T"' EXIT; fail=0
MSG="Bonjour, je suis ton monteur vidéo. Aujourd'hui on teste l'intelligence artificielle."
if command -v say >/dev/null; then say -v Thomas -o "$T/v.aiff" "$MSG" 2>/dev/null || say -o "$T/v.aiff" "$MSG"; IN="$T/v.aiff"
else ffmpeg -v error -f lavfi -i "sine=frequency=440:duration=3" "$T/v.wav"; IN="$T/v.wav"; fi
ffmpeg -v error -y -i "$IN" -ar 16000 -ac 1 -c:a pcm_s16le "$T/v16.wav" || fail=1
if ffmpeg -v error -y -f lavfi -i testsrc2=size=1080x1920:rate=30:duration=3 -i "$T/v16.wav" -shortest -c:v libx264 -pix_fmt yuv420p -c:a aac "$T/a.mp4"; then
  echo "✓ FFmpeg : vidéo verticale 1080x1920 x264 + AAC"; else echo "✗ FFmpeg : encodage x264 impossible"; fail=1; fi
ffmpeg -v error -y -i "$T/a.mp4" -c:v h264_videotoolbox -b:v 6M -c:a libmp3lame "$T/b.mov" 2>/dev/null && echo "✓ FFmpeg : accélération matérielle + MP3" || echo "• FFmpeg : pas de VideoToolbox/MP3 (normal hors Mac)"
M=~/.cache/whisper-cpp/ggml-large-v3-turbo-q5_0.bin
if command -v whisper-cli >/dev/null && [ -f "$M" ]; then
  echo "✓ Whisper a entendu : $(whisper-cli -m "$M" -l fr -f "$T/v16.wav" -nt -np 2>/dev/null | tr -s ' \n' ' ')"
else echo "✗ Whisper ou son modèle manquant (le modèle arrive avec setup.mjs)"; fail=1; fi
SE=.claude/skills/short-editing/engine/setup.mjs
[ -f $SE ] && { node $SE --check | tail -3; } || { echo "✗ moteur absent dans ce dossier"; fail=1; }
exit $fail
