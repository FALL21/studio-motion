#!/usr/bin/env bash
# À lancer depuis le dossier du studio : dit ce qui est en place et à quelle étape reprendre.
step=""; note() { printf '%s %s\n' "$1" "$2"; }
first() { [ -z "$step" ] && step="$1"; }
command -v ffmpeg >/dev/null && command -v whisper-cli >/dev/null && command -v node >/dev/null && note ✓ "outils (node, ffmpeg, whisper)" || { note ✗ "outils incomplets"; first "1. Installer (references/01-installation.md)"; }
SE=.claude/skills/short-editing
if [ -f $SE/engine/short.mjs ]; then
  note ✓ "moteur de rendu installé"
  grep -q "captions.emphFont (local addition)" $SE/engine/lib/runtime.js && note ✓ "correctifs Studio Motion" || { note ✗ "correctifs Studio Motion absents"; first "1. Installer : python3 <skill>/scripts/appliquer_correctifs.py $SE"; }
  node $SE/engine/setup.mjs --check >/dev/null 2>&1 && note ✓ "moteur prêt (modèle, musiques)" || { note ✗ "moteur pas préparé"; first "1. Installer : node $SE/engine/setup.mjs"; }
else note ✗ "moteur de rendu absent"; first "1. Installer (references/01-installation.md, point 3)"; fi
[ -f CLAUDE.md ] && note ✓ "CLAUDE.md" || { note ✗ "CLAUDE.md absent"; first "2. Le studio (references/02-studio.md)"; }
[ -f video-agent/voice.md ] && note ✓ "voice.md" || { note ✗ "voice.md absent"; first "2. Le studio (references/02-studio.md)"; }
n=$(ls -d video-agent/styles/*/ 2>/dev/null | grep -v '/default/$' | wc -l | tr -d ' ')
[ "$n" -gt 0 ] && note ✓ "styles : $(ls video-agent/styles | grep -v '^default$' | tr '\n' ' ')" || { note ✗ "aucun style créé"; first "3. Le style (references/03-styles.md)"; }
e=$(ls -d video-agent/edits/short-*/ 2>/dev/null | wc -l | tr -d ' '); note • "vidéos en cours ou montées : $e"
a=$(ls A-Roll 2>/dev/null | grep -v '^\.' | wc -l | tr -d ' '); note • "prises dans A-Roll : $a"
first "4. Monter une vidéo (references/04-montage.md)"
echo "=> Reprendre à l'étape : $step"
