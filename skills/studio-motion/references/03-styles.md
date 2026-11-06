# Étape 3 : la charte et les styles

Une seule fois, puis à chaque nouvelle référence. Durée : 20 à 40 minutes.

Un style = un fichier `video-agent/styles/<nom>/style.json` (ce que le moteur lit) + `STYLE.md` (ce qui a été mesuré, et les règles que le moteur ne sait pas tenir seul).

## 1. La charte couleurs

Demande : **« Tu as des couleurs de marque ? Un code (#04529A) ou une couleur en mots. »**
- Garde-la courte : une couleur d'accent forte (pas un pastel) + blanc + noir suffit. C'est ce qui rend une vidéo élégante.
- L'accent marque les mots clés, les flèches, les pastilles, les coches. Le texte courant reste noir.
- Pas de charte : propose un bleu profond (#04529A) ou un noir et blanc, et montre.

## 2. Les vidéos de référence

Demande 1 à 3 vidéos dont elle aime le style, dans `Références/` (fichiers) ou en liens. Puis, pour chacune, suis le skill `steal` installé avec le moteur (`.claude/skills/steal/SKILL.md`). En résumé :

```bash
W=video-agent/.tmp/steal-<nom>; mkdir -p $W
ffmpeg -v error -y -i "<ref>" -vf "fps=2,scale=270:480,tile=8x3:padding=4:color=black" $W/sheet-%02d.jpg
ffmpeg -hide_banner -i "<ref>" -vf "scdet=threshold=12" -an -f null - 2>&1 | grep -o "scd.time: [0-9.]*" | cut -d' ' -f2 > $W/cuts.txt
ffmpeg -v error -y -i "<ref>" -lavfi "showspectrumpic=s=3000x500:legend=0:scale=log:stop=11000" $W/spectrum.png
```

Regarde **toutes** les planches et le spectrogramme : mise en page (caméra en carte ? plein écran ? sans visage ?), sous-titres (police, taille, mot clé), animations, rythme des coupes, sons. Ensuite, écris le style avec les clés de `.claude/skills/short-editing/references/style-schema.md`.

Ce qu'on a appris en copiant :
- **Ne copie pas les clics d'interface** sur chaque élément, même si l'original en a : c'est insupportable sur toute une vidéo.
- **Ne copie pas les images protégées** de la référence (films, dessins animés) : on les remplace par les vraies photos du créateur ou des dessins faits pour la vidéo.
- Dis honnêtement ce qui sera proche et ce qui ne le sera pas (un effet 3D d'After Effects ne se reproduit pas à 100 %).

## 3. Le style « Explicatif » (le plus abouti)

C'est le style de l'exemple `assets/exemple-episode-1/`. Point de départ : `assets/style-explicatif.json`. Remplace `{{ACCENT}}` par la couleur de la charte et complète `creator`.

Ce qui le définit :
- **Mise en page** : `layout.card` = la caméra dans une carte arrondie en bas (`{x: 66, y: 915, w: 948, h: 800, r: 44, zoom: 1.0, bias: 0.40}`), la scène au-dessus (y 40 à 770), les sous-titres entre les deux (~y 800).
  - `zoom: 1.0` et `bias: 0.40` laissent de l'air au-dessus de la tête. Avec les valeurs par défaut du moteur (zoom 1.08, bias 0.27), le haut du crâne était coupé.
- **Fond** : `paper.bg: "clean"` (blanc avec un léger halo), pas de grain.
- **Sous-titres** : `dim` (les mots arrivent en flou, gris puis noir quand ils sont dits), 72 px, 3 mots max, le mot clé en italique serif de la couleur d'accent (`emphFont: "Instrument Serif"`, ajouté par les correctifs).
- **Animations** : composants HTML dessinés sur mesure (étape 4), un par temps fort.
- **Son** : musique douce très basse (-31 LUFS), un son par temps fort d'animation.

## 4. Écrire le style

```bash
mkdir -p video-agent/styles/<nom>/{stills,assets/sfx,assets/logos}
cp <skill>/assets/style-explicatif.json video-agent/styles/<nom>/style.json   # puis l'éditer
node -e 'JSON.parse(require("fs").readFileSync("video-agent/styles/<nom>/style.json","utf8")); console.log("ok")'
```

Ajoute dans `notes` les règles en français que le moteur ne sait pas tenir seul : elles sont relues à chaque montage.

Teste chaque style sur une vraie prise de la personne (étapes 4 à 5 en version courte) et envoie-lui la vidéo. Fais-la choisir, puis améliore celui qu'elle garde jusqu'à ce qu'elle dise « parfait ». Chaque remarque devient une note du style ou une règle de `CLAUDE.md`.

## 5. Avant chaque montage

Demande toujours : **« Quel style j'utilise ? »** avec les styles existants en choix (le dernier utilisé en premier). La personne peut aussi donner une nouvelle référence pour cette seule vidéo.
