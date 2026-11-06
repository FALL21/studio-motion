# Étape 6 : signature, sous-titres et export

## 1. La signature

Chaque vidéo se termine par la signature du créateur (notée dans `voice.md`). Trois cas :

**a. Il la dit dans la prise.** Garde-la (ne la mets pas dans `cut`) et anime-la mot par mot au-dessus de la caméra avec `assets/composants/signature-scene.html`.

**b. Il l'a enregistrée à part** (même décor, même cadrage, 3 secondes). Assemble les deux prises en une seule, en 4K, avant `init` :

```bash
bash <skill>/scripts/assembler_prises.sh "A-Roll/<prise>" <fin_en_secondes> "A-Roll/<signature>" video-agent/takes/<nom>-complet.mov
```

`<fin_en_secondes>` = où couper la prise principale (juste après le dernier mot gardé). Puis même animation qu'au cas a, en recalant les temps des mots sur `files/words.md`. Whisper transcrit mal les mots d'autres langues : remplace-les par la bonne orthographe (`captions.replace: [['je vous le sais.', 'Xam, Jëf, Jariñu.']]`).

**c. Il ne l'a pas dite.** Propose-lui de l'enregistrer (conseils ci-dessous). En attendant, ajoute une carte de fin plein écran :

```js
outro: 3.2,
// ...
{ type: 'overlay', media: 'g', from: 'o+0', to: 'o+3.2', layer: 'over' },   // layer 'over' : couvre aussi la caméra
```

avec `assets/composants/signature-plein-ecran.html`. Sans `layer: 'over'`, la carte caméra masque la moitié de la carte de fin.

Conseils à donner pour enregistrer la signature : même endroit, même tenue, même cadrage ; dire la phrase avec la même énergie que la vidéo ; 1 seconde de silence avant et après ; la dire 2 ou 3 fois ; téléphone à 20 cm, pièce qui ne résonne pas ; déposer le fichier dans `A-Roll/`.

## 2. Les sous-titres `.srt`

```bash
python3 <skill>/scripts/faire_srt.py video-agent/edits/short-<nom> --replace "Tchad-JPT=ChatGPT" "Mambou=Mame Bou" --coupure-avant 21.9
```

Il lit `files/words.md`, applique les corrections, regroupe par 4 mots et écrit `output/short-<nom>.srt`. `--coupure-avant <temps short>` force une nouvelle ligne (pour mettre la signature seule sur sa ligne). Relis le fichier.

## 3. Le texte du post

Écris `output/short-<nom>-post.md` dans la voix de la personne (`voice.md`) : 2 à 4 phrases qui reprennent le message, la signature, 5 ou 6 hashtags. Pas de promesse qu'elle ne ferait pas, pas de marque interdite.

## 4. L'export

```bash
cp video-agent/edits/short-<nom>/output/short-<nom>*.mp4 Export/short-<nom>.mp4
cp video-agent/edits/short-<nom>/output/short-<nom>.srt Export/
cp video-agent/edits/short-<nom>/output/short-<nom>-post.md Export/
```

## 5. Publier (facultatif)

Avec Treg configuré, le skill `publish` installé avec le moteur publie sur YouTube, Instagram et TikTok, **toujours après un « oui » explicite de la personne** pour chaque publication.
