#!/usr/bin/env bash
# Affiche une ligne par outil : ✓ version, ou ✗ manquant (avec la commande d'installation conseillée).
ok() { printf '✓ %-12s %s\n' "$1" "$2"; }
ko() { printf '✗ %-12s manquant  ->  %s\n' "$1" "$2"; }
OS=$(uname -s); ARCH=$(uname -m)
echo "Système : $OS $ARCH"
v() { command -v "$1" >/dev/null 2>&1; }
v node   && ok node "$(node -v)"                               || ko node   "brew install node | winget install OpenJS.NodeJS.LTS"
v git    && ok git "$(git --version | awk '{print $3}')"       || ko git    "xcode-select --install | winget install Git.Git"
v ffmpeg && ok ffmpeg "$(ffmpeg -version | head -1 | awk '{print $3}')" || ko ffmpeg "brew install ffmpeg | scripts/installer_mac_natif.sh | winget install Gyan.FFmpeg"
if v ffmpeg; then
  for enc in libx264 libmp3lame; do ffmpeg -hide_banner -encoders 2>/dev/null | grep -q " $enc " && ok "  $enc" "présent" || ko "  $enc" "FFmpeg sans $enc : recompiler (installer_mac_natif.sh)"; done
  file -L "$(command -v ffmpeg)" 2>/dev/null | grep -q arm64 && ok "  natif" "arm64" || { [ "$ARCH" = arm64 ] && printf '! %-12s %s\n' "  natif" "FFmpeg n'est pas en arm64 (Rosetta) : ça marche, mais plus lentement"; }
fi
v whisper-cli && ok whisper-cli "$(command -v whisper-cli)"    || ko whisper-cli "brew install whisper-cpp | scripts/installer_mac_natif.sh"
M=~/.cache/whisper-cpp/ggml-large-v3-turbo-q5_0.bin
[ -f "$M" ] && ok modèle "large-v3-turbo ($(du -h "$M" | cut -f1))" || ko modèle "téléchargé par: node .claude/skills/short-editing/engine/setup.mjs"
v yt-dlp && ok yt-dlp "$(yt-dlp --version)"                    || ko yt-dlp "(facultatif) brew install yt-dlp | uv tool install 'yt-dlp[default]'"
v deno   && ok deno "$(deno --version | head -1 | awk '{print $2}')" || ko deno "(facultatif) npm i -g deno"
v treg   && ok treg "$(treg --version 2>/dev/null | awk '{print $2}')" || ko treg "(facultatif, pour publier) voir references/01-installation.md"
[ -d "/Applications/Google Chrome.app" ] || v google-chrome || v chromium && ok chrome "présent" || ko chrome "installé automatiquement par setup.mjs"
