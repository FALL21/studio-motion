# Étape 4 : monter une vidéo

À chaque vidéo. Durée : 20 à 40 minutes. `E` désigne le moteur : `E=.claude/skills/short-editing/engine/short.mjs` (depuis le dossier du studio).

## 1. La prise

La personne dépose sa prise dans `A-Roll/` et dit son nom de fichier, et ce qu'il faut garder ou enlever (« ignore la partie “mon objectif…” »).

```bash
ffprobe -v error -show_entries format=duration:stream=codec_name,width,height:stream_side_data=rotation -of compact "A-Roll/<prise>"
```

Une prise de téléphone en 4K tournée à la verticale apparaît souvent en 3840×2160 avec une rotation de -90 : c'est normal, le moteur la redresse.

Transcris-la tout de suite pour comprendre ce qu'elle dit :

```bash
ffmpeg -v error -y -i "A-Roll/<prise>" -ar 16000 -ac 1 /tmp/prise.wav
whisper-cli -m ~/.cache/whisper-cpp/ggml-large-v3-turbo-q5_0.bin -l fr -f /tmp/prise.wav -np
```

Puis **demande le style** (étape 3, point 5) en résumant ce que tu as entendu et ce que tu vas couper.

Si la signature a été enregistrée à part (même décor), assemble les deux en une seule prise avant de commencer : `bash <skill>/scripts/assembler_prises.sh "A-Roll/<prise>" <fin_en_secondes> "A-Roll/<signature>" video-agent/takes/<nom>-complet.mov`.

## 2. Créer le projet et transcrire mot à mot

```bash
cp "A-Roll/<prise>" video-agent/takes/<nom>.mov      # (ou la prise assemblée)
node $E init video-agent/edits/short-<nom> --source video-agent/takes/<nom>.mov --style <style>
node $E words video-agent/edits/short-<nom> fr
```

`<nom>` : court, en minuscules avec des tirets (`chatgpt-pas-ia-ep1`). `init` détecte le visage et fige le style dans `source/style.json`.

`init` refuse un dossier qui existe déjà : pour repartir de zéro, crée un nouveau projet (par ex. `short-<nom>-final`) et recopie-y `source/*.html`, `source/lib.js`, `assets/*.mov` et `assets/sfx/`.

## 3. Couper et corriger

Ouvre `source/spec.js` (tous les temps y sont en **secondes de la prise**, « temps source ») :

- `cut: [[a, b]]` : les parties à enlever (une reprise, « mon objectif… », la fin). Le moteur enlève tout seul les silences.
- `captions.replace: [['Tchad-JPT', 'ChatGPT'], ['Mambou', 'Mame Bou']]` : chaque mot mal transcrit. Lis **chaque mot** de la transcription : les noms propres, les marques et les mots d'autres langues sont presque toujours faux. Un mot incertain dans une autre langue : écris-le comme tu l'entends et demande l'orthographe à la personne avant le rendu final.
- `cam.q: 1` : extraction de la caméra quasi sans perte.

Puis :

```bash
node $E prepare video-agent/edits/short-<nom>
```

`files/words.md` donne pour chaque mot son temps source et son temps dans la vidéo finale (« temps short »). Garde ce tableau ouvert : il sert à caler les animations.

## 4. Le storyboard (à faire valider)

Découpe la vidéo en **temps forts** : une idée = une animation, 2 à 5 secondes chacun. Pour chacun, note la phrase, les mots déclencheurs et ce qu'on voit. Exemple réel :

| Phrase | Mots déclencheurs | Animation |
|---|---|---|
| « cette télévision fonctionne… du courant électrique » | télévision, courant, électrique | La télé apparaît, un câble se tire jusqu'à la prise, le courant circule, l'écran s'allume |
| « est-ce que la télé est le courant ? Bien sûr que non » | est, non | Télé et éclair face à face, « = ? » entre eux, barré en « ≠ » sur « non » |
| « ChatGPT utilise l'IA pour fonctionner » | ChatGPT, utilise, artificielle, fonctionner | Fenêtre de chat (le produit) reliée au cœur « IA » (la technologie), le courant passe, le chat répond |
| « Moi c'est … » | nom, métier | Carte de présentation qui s'écrit |
| « Xam, Jëf, Jariñu » | chaque mot | La signature mot par mot, puis « Abonne-toi » et un bouton tapé |

Montre ce tableau à la personne et attends son accord. Signale ce que tu as ajouté de toi-même (« les 12 domaines de l'IA, c'est moi qui les ai choisis »).

Repère où cacher les sous-titres (`captions.hide: [[a, b]]`, temps source) : là où l'animation écrit déjà les mêmes mots en grand.

## 5. Les animations

Suis `05-motion-design.md`. En résumé : un fichier HTML par temps fort dans `source/`, copié depuis `<skill>/assets/composants/`, puis filmé en vidéo transparente :

```bash
cp <skill>/assets/composants/lib.js video-agent/edits/short-<nom>/source/
node $E capture video-agent/edits/short-<nom> source/<anim>.html --dur <durée> --alpha --out assets/<anim>.mov
```

Puis branche-les dans `spec.js` :

```js
media: {
  a: { src: 'assets/a-tele.mov', width: 1080, alpha: true },
  // ...
},
scenes: [
  { type: 'overlay', media: 'a', from: 0, to: 3.9 },          // temps source
  // la carte de fin qui doit couvrir aussi la caméra : layer: 'over'
],
```

## 6. Le son

Suis `06-son.md` : `voiceFx` pour nettoyer la voix, `sfx.extra` et `sfx.files` pour un son par temps fort.

## 7. Aperçu, puis rendu complet

```bash
node $E stills video-agent/edits/short-<nom> 1.5 4 8 12 16     # temps short, séparés par des espaces
```

Regarde `stills/contact.jpg` toi-même : texte lisible, rien de coupé, rien qui se chevauche, tête entière dans la carte, mot juste au bon moment. Corrige, puis :

```bash
node $E all video-agent/edits/short-<nom>
```

`all` = image + son + assemblage final + contrôle technique. **Jamais `render` seul** (vidéo muette). Ensuite : étape 5 (`07-qualite.md`), puis étape 6 (`08-signature-export.md`).
