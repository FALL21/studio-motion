#!/usr/bin/env bash
# Mac à puce Apple quand Homebrew ne marche pas (Rosetta, outils Xcode trop anciens) : compile FFmpeg et whisper.cpp
# en natif arm64 depuis leurs sources officielles, sans mot de passe administrateur. 10 à 20 minutes.
# Tout va dans ~/Tools ; les commandes sont liées dans /usr/local/bin (ou ~/.local/bin si /usr/local/bin n'est pas inscriptible).
set -euo pipefail
[ "$(uname -s)" = Darwin ] || { echo "Ce script est pour macOS."; exit 1; }
xcrun --find clang >/dev/null || { echo "Il faut les outils de développement : xcode-select --install"; exit 1; }
T=~/Tools; mkdir -p $T/src; BIN=/usr/local/bin; [ -w $BIN ] || { BIN=~/.local/bin; mkdir -p $BIN; }
AR="arch -arm64"; [ "$(uname -m)" = arm64 ] || AR=""
echo "1/5 CMake et uv (environnement Python isolé)"
[ -x $T/venv/bin/cmake ] || { python3 -m venv $T/venv && $T/venv/bin/pip -q install cmake uv; }
ln -sf $T/venv/bin/uv $BIN/uv
echo "2/5 whisper.cpp (avec le GPU Metal)"
[ -d $T/whisper.cpp ] || git clone -q --depth 1 https://github.com/ggml-org/whisper.cpp.git $T/whisper.cpp
( cd $T/whisper.cpp && $AR /bin/zsh -c "$T/venv/bin/cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=$(uname -m) -DGGML_METAL=ON -DGGML_METAL_EMBED_LIBRARY=ON -DBUILD_SHARED_LIBS=OFF -DWHISPER_BUILD_TESTS=OFF >/dev/null && $T/venv/bin/cmake --build build -j 8 --config Release >/dev/null" )
ln -sf $T/whisper.cpp/build/bin/whisper-cli $BIN/whisper-cli
echo "3/5 sources de LAME (MP3), x264 et FFmpeg"
cd $T/src
[ -d x264 ] || git clone -q --depth 1 https://code.videolan.org/videolan/x264.git
[ -d FFmpeg ] || git clone -q --depth 1 https://github.com/FFmpeg/FFmpeg.git
if [ ! -d lame-3.100 ]; then
  curl -fsSL -o lame-3.100.tar.gz https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
  echo "ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e  lame-3.100.tar.gz" | shasum -a 256 -c - && tar xzf lame-3.100.tar.gz
fi
echo "4/5 compilation (le plus long)"
P=$T/ffmpeg-deps; A=$(uname -m)
$AR /bin/zsh -c "
set -e; export PKG_CONFIG_PATH=$P/lib/pkgconfig CFLAGS='-arch $A' LDFLAGS='-arch $A'
cd $T/src/lame-3.100 && sed -i '' '/lame_init_old/d' include/libmp3lame.sym && ./configure --prefix=$P --enable-static --disable-shared --disable-frontend >/dev/null && make -j8 >/dev/null && make install >/dev/null
cd $T/src/x264 && ./configure --prefix=$P --enable-static --disable-cli --enable-pic >/dev/null && make -j8 >/dev/null 2>&1 && make install >/dev/null
unset CFLAGS LDFLAGS
cd $T/src/FFmpeg && ./configure --prefix=$T/ffmpeg --cc=clang --enable-gpl --enable-libx264 --enable-libmp3lame --enable-videotoolbox --enable-audiotoolbox --disable-doc --disable-debug --extra-cflags=-I$P/include --extra-ldflags=-L$P/lib --pkg-config-flags=--static >/dev/null && make -j8 >/dev/null 2>&1 && make install >/dev/null"
ln -sf $T/ffmpeg/bin/ffmpeg $BIN/ffmpeg; ln -sf $T/ffmpeg/bin/ffprobe $BIN/ffprobe
echo "5/5 vérification"
ffmpeg -hide_banner -encoders | grep -E " libx264 | libmp3lame | h264_videotoolbox " || true
file $T/ffmpeg/bin/ffmpeg $T/whisper.cpp/build/bin/whisper-cli
[ "$BIN" = ~/.local/bin ] && echo "Ajoute ~/.local/bin au PATH : echo 'export PATH=\$HOME/.local/bin:\$PATH' >> ~/.zshrc"
echo "✓ FFmpeg et Whisper installés en natif."
