# Étape 2 : le studio

Une seule fois. Durée : 15 minutes, surtout des questions.

## 1. Le dossier

Dans le dossier du studio (celui où le moteur est installé), crée :

```text
<studio>/
├── CLAUDE.md          les règles du projet, relues par Claude à chaque session (modèle : assets/CLAUDE.md.modele)
├── A-Roll/            où la personne dépose ses prises brutes
├── Références/        les vidéos dont elle aime le style
├── Export/            les vidéos finies, prêtes à publier
├── .gitignore         (si le dossier est dans un dépôt git)
└── video-agent/       le dossier de travail du moteur
    ├── voice.md       qui elle est, comment elle parle
    ├── style.json     {"default": "default"}
    ├── styles/        un dossier par style
    ├── takes/         les prises préparées
    ├── edits/         un dossier par vidéo montée
    ├── .env           ses clés API, jamais partagées (droits 600)
    └── .tmp/          brouillons, vidés après usage
```

```bash
mkdir -p A-Roll Références Export video-agent/{styles/default/assets/logos,takes,edits,.tmp,scripts,images}
printf '{"default": "default"}\n' > video-agent/style.json
touch video-agent/.env && chmod 600 video-agent/.env
cp <skill>/assets/CLAUDE.md.modele CLAUDE.md
```

Si le dossier est dans un dépôt git (`git rev-parse --show-toplevel` répond), ajoute ce `.gitignore` : les vidéos sont lourdes, et `.env` contient des clés.

```gitignore
video-agent/takes/
video-agent/edits/**/*.mp4
video-agent/edits/**/*.mov
video-agent/edits/**/assets/
video-agent/edits/**/frames/
video-agent/edits/**/stills/
.claude/skills/short-editing/engine/node_modules/
video-agent/.tmp/
video-agent/.env
A-Roll/
Export/*.mp4
```

Explique en une phrase : « Tu déposes tes prises dans A-Roll, tu récupères tes vidéos finies dans Export. Le reste, c'est moi. »

## 2. Le fichier de voix (`video-agent/voice.md`)

Tous les scripts et tous les choix de montage partent de ce fichier. Remplis-le avec les vrais mots de la personne. Une ligne qu'on ne sait pas remplir reste `{{à compléter}}` : une ligne vide vaut mieux qu'une ligne inventée.

Demande d'abord : **« On le construit à partir de tes vidéos existantes, ou par une petite interview ? »**
- Si elle débute, propose l'interview.
- Si elle a des vidéos, prends 2 ou 3 fichiers (vidéos, notes vocales WhatsApp `.opus`, `.m4a`…) déposés dans `video-agent/.tmp/` et transcris-les sur l'ordinateur :

```bash
ffmpeg -v error -y -i "<fichier>" -ar 16000 -ac 1 /tmp/v.wav
whisper-cli -m ~/.cache/whisper-cpp/ggml-large-v3-turbo-q5_0.bin -l fr -f /tmp/v.wav -nt -np
```

Mesure le débit (mots ÷ minutes de parole, la plupart des gens sont entre 150 et 190 mots/minute) et relève comment elle ouvre ses vidéos.

**L'interview, une question par message :**
1. À qui parles-tu ? Une seule personne type : son métier, son niveau, ce qui la bloque, avec ses propres mots. Il peut y avoir deux publics ; chaque vidéo n'en vise qu'un.
2. Qu'est-ce que ce public croit à tort ? (Chaque idée reçue devient un hook tout prêt.)
3. Quelles preuves peux-tu montrer : projets, chiffres, élèves, clients ? Et **lesquelles as-tu le droit de citer** ? (Noter aussi la règle : une preuve n'apparaît que si la personne la demande pour cette vidéo.)
4. Comment parles-tu face caméra : énergie, expressions, autres langues mêlées au français ?
5. Comment termines-tu tes vidéos ? (Sa **signature** exacte, mot pour mot, avec l'orthographe validée.)
6. Qu'est-ce qui est interdit : sujets, noms, promesses, marques à ne pas citer avant une date ?
7. Que demandes-tu au spectateur : s'abonner, commenter un mot pour recevoir une ressource, rejoindre une offre ? (Souvent : ça dépend de la vidéo.)

Modèle complet : `assets/voice.md.modele`. Après l'avoir écrit, relis-le en 5 lignes et demande ce qui sonne faux.

Les transcriptions peuvent déformer les mots d'autres langues que le français (wolof, créole, arabe dialectal…) et les noms propres : ne les recopie pas tels quels, demande l'orthographe.

## 3. Les règles du projet (`CLAUDE.md`)

Copie le modèle `assets/CLAUDE.md.modele` et complète-le avec ce que tu viens d'apprendre (signature, langues, interdits). Ce fichier est relu automatiquement à chaque nouvelle session : c'est ainsi que Claude se souvient des règles d'une vidéo à l'autre. Chaque fois que la personne corrige quelque chose (« ma tête est coupée », « pas d'orange »), ajoute la règle dans ce fichier pour que l'erreur ne revienne pas.
