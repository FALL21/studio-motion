#!/usr/bin/env python3
"""Applique les améliorations Studio Motion au moteur short-editing (video-agent-skills, licence MIT).

Usage : python3 appliquer_correctifs.py <chemin vers .claude/skills/short-editing>

Sans risque à relancer : un correctif déjà présent est ignoré. À relancer après chaque `npx skills update`,
qui réécrit le moteur. Les correctifs :
  1. captions.emphFont / emphScale / emphColor / emphWeight : dans les sous-titres `dim`, le mot clé en italique
     (par ex. Instrument Serif) au lieu d'une pastille sombre.
  2. Préchargement d'Instrument Serif italique (sinon les premières images tombent sur une police par défaut).
  3. captions.bigCase: false : les gros mots des sous-titres `stack` gardent leurs minuscules.
  4. spec.voiceFx : une chaîne ffmpeg complète pour nettoyer la voix (débruitage, égaliseur, de-esser...).
  5. captions.replace corrige aussi un mot que Whisper a collé à un autre dans le même bloc (« Mais Tchad-JPT »).
"""
import sys, pathlib

PATCHES = {
    'engine/lib/runtime.js': [
        ('emphFont (sous-titres dim)',
         "    const vis = c.words.slice(0, cur + 1).map((w, i) => ({ w, ww: wordW(w), gi: i }));",
         "    // captions.emphFont (local addition): emphasised words drawn in that family, italic, at captions.emphScale x size, no pill\n"
         "    const EF = cap.emphFont ? K.famCss(cap.emphFont) : null, ES = CS * (cap.emphScale || 1.12);\n"
         "    const efont = () => `italic ${cap.emphWeight || 400} ${ES}px ${EF}`;\n"
         "    const emW = w => { ctx.save(); ctx.font = efont(); ctx.letterSpacing = '0px'; const m = ctx.measureText(w.text).width; ctx.restore(); return m; };\n"
         "    const vis = c.words.slice(0, cur + 1).map((w, i) => ({ w, ww: EF && w.emph ? emW(w) : wordW(w), gi: i }));"),
        ('emphFont (dessin)',
         "        if (emph) { const h = CS * 1.24;",
         "        if (emph && EF) { ctx.font = efont(); ctx.letterSpacing = '0px'; ctx.fillStyle = cap.emphColor || cap.hi || '#FFFFFF'; ctx.fillText(w.text, wx, b); ctx.restore(); continue; }\n"
         "        if (emph) { const h = CS * 1.24;"),
        ('préchargement Instrument Serif',
         "  await document.fonts.load('900 40px Archivo');   // board",
         "  await document.fonts.load('italic 400 40px \"Instrument Serif\"');   // local addition: captions.emphFont / board serif titles\n"
         "  await document.fonts.load('900 40px Archivo');   // board"),
        ('bigCase (mesure)',
         "const text = bare(w.text).toUpperCase(), wd",
         "const text = scap.bigCase === false ? bare(w.text) : bare(w.text).toUpperCase(), wd"),
        ('bigCase (dessin)',
         "const text = bare(w.text).toUpperCase(); fBig(SBIG);",
         "const text = scap.bigCase === false ? bare(w.text) : bare(w.text).toUpperCase(); fBig(SBIG);"),
    ],
    'engine/lib/timeline.js': [
        ('replace dans les mots collés',
         "  const rep = (cfg.replace || []).map(([k, v]) => [k.toLowerCase().split(/\\s+/), v]);",
         "  const rep = (cfg.replace || []).map(([k, v]) => [k.toLowerCase().split(/\\s+/), v]);\n"
         "  // local addition (Studio Motion): a replace key also fixes words that Whisper glued into one token (\"Mais Tchad-JPT\")\n"
         "  const esc = x => x.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&');\n"
         "  const subRep = s => (cfg.replace || []).reduce((acc, [k, v]) => acc.replace(new RegExp('(^|\\\\s)' + esc(k) + '(?=$|[\\\\s.,!?;:…])', 'gi'), (m, a) => a + v), s);"),
        ('replace dans les mots collés (application)',
         "    } else merged.push({ text: words[i].text, start: words[i].start, end: words[i].end });",
         "    } else merged.push({ text: subRep(words[i].text), start: words[i].start, end: words[i].end });"),
    ],
    'engine/audio.mjs': [
        ('voiceFx',
         "    const pcm = execFileSync(FFMPEG, ['-v', 'error', '-i', P('assets/voice.wav'), '-af',\n"
         "      'highpass=f=80,lowpass=f=15000,acompressor=threshold=0.125:ratio=3:attack=5:release=90:makeup=2',",
         "    // raw.voiceFx (local addition): a full ffmpeg chain for the voice (denoise, EQ, de-esser...) instead of the default\n"
         "    const pcm = execFileSync(FFMPEG, ['-v', 'error', '-i', P('assets/voice.wav'), '-af',\n"
         "      raw.voiceFx || 'highpass=f=80,lowpass=f=15000,acompressor=threshold=0.125:ratio=3:attack=5:release=90:makeup=2',"),
    ],
}


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    root = pathlib.Path(sys.argv[1])
    if not (root / 'engine' / 'short.mjs').exists():
        sys.exit(f"✗ {root} n'est pas le dossier du skill short-editing (engine/short.mjs introuvable)")
    problems = 0
    for rel, patches in PATCHES.items():
        f = root / rel
        src = f.read_text(encoding='utf-8')
        changed = False
        for name, old, new in patches:
            if new in src:
                print(f"✓ {name} : déjà appliqué")
            elif old in src:
                src = src.replace(old, new, 1)
                changed = True
                print(f"✓ {name} : appliqué")
            else:
                problems += 1
                print(f"✗ {name} : point d'ancrage introuvable dans {rel} (le moteur a changé : à adapter à la main)")
        if changed:
            f.write_text(src, encoding='utf-8')
    if problems:
        sys.exit(f"{problems} correctif(s) non appliqué(s).")
    print("Moteur prêt pour Studio Motion.")


if __name__ == '__main__':
    main()
