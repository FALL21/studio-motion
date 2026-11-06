#!/usr/bin/env bash
# Refilme les animations dont le fichier (ou textes.js / lib.js) a changé depuis le dernier tournage, puis prépare le projet.
# Usage (depuis le dossier du studio) : refaire_animations.sh video-agent/edits/short-<nom> [--toutes]
# Garde la durée de chaque animation déjà filmée. Ensuite : touche R dans l'aperçu, ou `short.mjs all` pour l'export.
set -uo pipefail
P="${1:?Usage : $0 <dossier du projet> [--toutes]}"; ALL="${2:-}"
E=.claude/skills/short-editing/engine/short.mjs
[ -f "$E" ] || { echo "✗ À lancer depuis le dossier du studio (moteur introuvable : $E)"; exit 1; }
n=0
for h in "$P"/source/*.html; do
  name=$(basename "$h" .html); mov="$P/assets/$name.mov"
  [ -f "$mov" ] || { echo "• $name : pas encore filmée (filme-la une première fois avec short.mjs capture --dur)"; continue; }
  if [ "$ALL" = "--toutes" ] || [ "$h" -nt "$mov" ] || { [ -f "$P/source/textes.js" ] && [ "$P/source/textes.js" -nt "$mov" ]; } || { [ -f "$P/source/lib.js" ] && [ "$P/source/lib.js" -nt "$mov" ]; }; then
    dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$mov")
    if node "$E" capture "$P" "source/$name.html" --dur "$dur" --alpha --out "assets/$name.mov" >/dev/null 2>&1; then echo "✓ $name refilmée (${dur%.*} s)"; n=$((n+1)); else echo "✗ $name : erreur (ouvre le fichier pour vérifier les guillemets et les virgules)"; fi
  fi
done
[ $n -gt 0 ] && node "$E" prepare "$P" >/dev/null 2>&1 && echo "✓ projet préparé : appuie sur R dans l'aperçu" || [ $n -gt 0 ] || echo "Rien n'a changé."
