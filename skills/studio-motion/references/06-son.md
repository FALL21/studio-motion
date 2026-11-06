# Le son

Un son pro, c'est trois couches : une voix propre et devant, une musique très discrète, et un son court sur chaque temps fort d'animation.

## 1. La voix (`voiceFx` dans `spec.js`)

Ajout de Studio Motion au moteur (appliqué par `appliquer_correctifs.py`). Mets dans `spec.js` :

```js
voiceFx: 'highpass=f=75,afftdn=nr=16:nf=-50:tn=1,equalizer=f=250:t=q:w=1:g=-2.5,equalizer=f=3200:t=q:w=1.2:g=2.5,equalizer=f=9000:t=q:w=1:g=1.5,deesser=i=0.4,acompressor=threshold=0.1:ratio=3:attack=5:release=80:makeup=2,alimiter=limit=0.95',
```

Dans l'ordre : coupe les basses inutiles (75 Hz), débruite doucement (souffle de la pièce), retire 2,5 dB de « boîte » vers 250 Hz, ajoute de la présence (3,2 kHz) et un peu d'air (9 kHz), adoucit les « s » sifflants, compresse, et limite les pics. Le moteur règle ensuite la voix à -16 LUFS et le mix final à -14 LUFS (le standard des réseaux).

Si la voix sonne métallique ou « sous l'eau », baisse `nr=16` vers `nr=10`. Si on entend encore un souffle, monte vers `nr=20`.

## 2. La musique

Le moteur génère 8 musiques de fond libres de droits. Dans le style : `mix.music: -31` (très bas, sous la voix, qui baisse encore quand on parle). Pour une ambiance plus présente : -26.

## 3. Un son par temps fort

Deux familles, les temps sont **en temps source** comme le reste du `spec.js` :

```js
sfx: { swish: 0, accents: 0,
  extra: [[0.55, 'pop', -9], [2.95, 'thud', -6], [12.3, 'bell', -13]],         // sons du moteur : [temps, nom, gain]
  files: [                                                                      // fichiers de la bibliothèque
    { at: 2.1, src: 'assets/sfx/zhhh.mp3', gain: -18, peak: true },
    { at: 7.27, src: 'assets/sfx/impact-boom.mp3', gain: -13, peak: true },
  ] },
```

Copie d'abord les fichiers : `mkdir -p <projet>/assets/sfx && cp .claude/skills/short-editing/assets/sfx/{zhhh,pop-back,impact-boom}.mp3 <projet>/assets/sfx/`.

| Moment de l'animation | Son | Gain conseillé |
|---|---|---|
| Un objet apparaît | `pop` (moteur) | -8 à -10 |
| Des éléments s'assemblent, un trait ou un câble se dessine, une carte glisse | `zhhh.mp3` | -15 à -19 |
| Des éléments s'allument, un élément clé arrive | `pop-back.mp3` | -12 à -14 |
| La conclusion, le « non », la révélation | `impact-boom.mp3` | -12 à -14 |
| Une chose qui se pose, un « ? » | `thud` (moteur) | -4 à -6 |
| Une coche, une réussite, « abonné » | `bell` (moteur) | -12 à -14 |
| Un bouton tapé | `tap` (moteur) | -6 à -9 |

Le gain est en dB sous la voix : plus le nombre est petit (plus négatif), plus c'est discret. `peak: true` met le moment le plus fort du fichier exactement sur le temps donné.

Pour trouver le temps source d'un événement d'animation : temps local dans l'animation + temps short du début de l'overlay, puis cherche dans `files/words.md` le temps source correspondant.

À éviter (déjà refusé par des créateurs) : un clic à chaque petit élément, une montée (riser) avant un moment, des sons plus forts que la voix.
