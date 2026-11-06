# Étape 5 : vérifier avant d'envoyer

Rien ne part chez la personne sans ces contrôles. Une vidéo muette, une tête coupée ou « Tchad-JPT » dans les sous-titres ont déjà été envoyés une fois : c'est exactement ce que cette étape évite.

## 1. Le contrôle automatique

```bash
bash <skill>/scripts/verifier_video.sh video-agent/edits/short-<nom>/output/short-<nom>.mp4
```

Il vérifie et affiche :
- **la piste audio existe** (sinon : la vidéo a été rendue avec `render` au lieu de `all`) ;
- format 1080×1920, H.264, débit vidéo (~28 Mb/s attendu), son AAC ;
- **volume** : -14 LUFS intégré, pic vrai sous -1 dBTP ;
- **la transcription du rendu final** : lis-la en entier. Elle doit contenir toute la phrase, du premier au dernier mot gardé, et rien de ce qu'on voulait couper ;
- trois images de la carte caméra (début, milieu, fin) dans `/tmp/studio-motion-cadrage.jpg`.

## 2. Les contrôles à l'œil

Ouvre l'image de cadrage et les planches (`stills/contact.jpg`) :

| Contrôle | Si ça ne va pas |
|---|---|
| La tête est entière, avec un peu d'air au-dessus | Dans `style.json` : `layout.card.zoom` vers 1.0 et `bias` vers 0.40 (plus haut = yeux plus bas dans la carte) |
| Le visage est net | `cam.q: 1` dans `spec.js`, puis `prepare` |
| Chaque mot des sous-titres est juste : **vérifie-les tous à l'image**, pas seulement dans la transcription. Extrais une planche : `ffmpeg -v error -i <vidéo> -vf "fps=4,crop=1080:170:0:715,scale=360:-1" /tmp/caps/c%03d.jpg` puis `ffmpeg -framerate 1 -i /tmp/caps/c%03d.jpg -vf tile=5x12 -frames:v 1 /tmp/caps.jpg` | `captions.replace`, en particulier les noms propres et les marques. Un mot peut être collé à un autre par Whisper (« Mais Tchad-JPT ») : le correctif 5 le gère |
| Les mots d'une autre langue ont l'orthographe validée par la personne | Lui demander, puis `captions.replace` |
| Rien ne se chevauche, rien n'est coupé | Corriger l'animation (`05-motion-design.md`), refilmer, `prepare` |
| Chaque animation arrive sur son mot | Décaler ses temps locaux d'après `files/words.md` |
| La signature est à la fin | `08-signature-export.md` |

Une transcription du rendu qui n'affiche pas un mot d'une autre langue (wolof…) ne prouve pas qu'il manque : mesure le son à cet endroit (`ffmpeg -ss <début> -t <durée> -i <vidéo> -af silencedetect=n=-30dB:d=0.15 -vn -f null -`). Des passages de parole entre les silences = la voix est là.

## 3. Envoyer

Envoie la vidéo à la personne (outil d'envoi de fichier si disponible), et dis en quelques lignes : ce qui a été fait, ce qui a été vérifié, et ce que tu as choisi toi-même et qu'elle peut changer.

## 4. Laisser la personne retoucher avant l'export

Avant l'export final, propose toujours l'**aperçu en direct** : la vidéo se joue dans le navigateur avec exactement le même rendu que l'export, sans attendre d'encodage.

```bash
node .claude/skills/short-editing/engine/short.mjs preview video-agent/edits/short-<nom> --port 41190 --scale 0.5
```

Dans l'app Claude (onglet Code), crée `.claude/launch.json` pour l'ouvrir dans le panneau navigateur :

```json
{ "version": "0.0.1", "configurations": [ { "name": "apercu-<nom>", "runtimeExecutable": "node",
  "runtimeArgs": [".claude/skills/short-editing/engine/short.mjs", "preview", "video-agent/edits/short-<nom>", "--port", "41190", "--scale", "0.5"],
  "port": 41190 } ] }
```

Explique-lui les commandes en une phrase : **Espace** lecture/pause, **← →** une seconde, **, .** une image, **M** coupe le son, **R** recharge après une modification. Le panneau de droite affiche le temps exact, le mot prononcé et l'élément du montage actif à cet instant.

Deux façons de retoucher :
- **En le disant** (le plus simple) : elle met en pause et dit ce qu'elle veut changer, en donnant le temps affiché (« à 12,3 s, le mot est faux », « l'animation arrive trop tôt », « ce son est trop fort »). Tu modifies `spec.js` ou l'animation, elle appuie sur **R** et revoit.
- **Elle-même**, dans deux fichiers texte du dossier `source/` :
  - `spec.js` pour les **sous-titres** et le montage : corriger un mot (`captions.replace`), couper un passage (`cut`), décaler une animation (`from` / `to` d'un `overlay`), baisser un son (`gain`, plus négatif = plus discret). Puis **R** dans l'aperçu : c'est immédiat.
  - `textes.js` pour les **textes des animations** (titres, étiquettes, cases, nom, signature) : elle change ce qui est entre guillemets, puis tu lances `bash <skill>/scripts/refaire_animations.sh <projet>` (ou elle le lance), environ 45 secondes, puis **R**. Les animations sont des vidéos filmées : sans cette commande, R ne montre pas le changement.

Explique-lui la différence en une phrase : « Les sous-titres se mettent à jour tout de suite ; les textes des animations demandent de refilmer l'animation, c'est la commande refaire. »

Ce n'est qu'une fois qu'elle a validé l'aperçu que tu lances `all`, la vérification, puis l'export.
