#!/usr/bin/env python3
"""Écrit output/<projet>.srt à partir de files/words.md, avec les corrections de mots.

Usage : faire_srt.py <dossier du projet> [--replace "faux=juste" ...] [--coupure-avant <temps short> ...] [--mots 4]
Les remplacements s'appliquent mot par mot (ou à une suite de mots séparés par des espaces).
"""
import argparse, pathlib, re

ap = argparse.ArgumentParser()
ap.add_argument('projet'); ap.add_argument('--replace', nargs='*', default=[]); ap.add_argument('--coupure-avant', nargs='*', type=float, default=[])
ap.add_argument('--mots', type=int, default=4)
a = ap.parse_args()
P = pathlib.Path(a.projet)
md = (P / 'files/words.md').read_text(encoding='utf-8')
dur = float(re.search(r'Short duration: ([\d.]+)s', md).group(1))
words = [(float(r[2]), r[3].strip()) for r in (l.split('|') for l in md.splitlines() if re.match(r'\| \d', l)) if r[3].strip() not in ('?', '!')]
text = ' '.join(w for _, w in words)
for rep in a.replace:
    old, new = rep.split('=', 1)
    n_old, n_new = old.split(), new.split()
    out, i = [], 0
    while i < len(words):
        if [w for _, w in words[i:i + len(n_old)]] == n_old:
            t0 = words[i][0]
            out += [(t0, w) for w in n_new]; i += len(n_old)
        else:
            out.append(words[i]); i += 1
    words = out
# mots collés par Whisper dans un même bloc (« Mais Tchad-JPT ») : on corrige aussi à l'intérieur des blocs
for rep in a.replace:
    old, new = rep.split('=', 1)
    rx = re.compile(r'(^|\s)' + re.escape(old) + r'(?=$|[\s.,!?;:…])', re.I)
    words = [(t, rx.sub(lambda m: m.group(1) + new, w)) for t, w in words]
def ts(t):
    return f"{int(t // 3600):02}:{int(t % 3600 // 60):02}:{int(t % 60):02},{int(round((t % 1) * 1000)) % 1000:03}"
chunks, cur = [], []
for t, w in words:
    if cur and (len(cur) >= a.mots or any(cur[-1][0] < c <= t + 1e-6 for c in a.coupure_avant)):
        chunks.append(cur); cur = []
    cur.append((t, w))
if cur: chunks.append(cur)
lines = []
for n, ch in enumerate(chunks, 1):
    end = chunks[n][0][0] - .02 if n < len(chunks) else dur
    lines.append(f"{n}\n{ts(ch[0][0])} --> {ts(end)}\n{' '.join(w for _, w in ch)}\n")
out = P / 'output' / f"{P.name}.srt"
out.write_text('\n'.join(lines), encoding='utf-8')
print(f"✓ {out} ({len(chunks)} sous-titres)")
