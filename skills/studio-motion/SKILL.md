---
name: studio-motion
description: >-
  Guide pas à pas, en français et pour un débutant complet, pour monter des vidéos courtes verticales (TikTok, Reels,
  Shorts) façon motion designer pro avec Claude Code : installation des outils (FFmpeg, Whisper, moteur de rendu),
  dossier studio, fichier de voix, charte couleurs, styles copiés depuis des vidéos de référence, animations sur mesure
  calées sur chaque mot, sous-titres, sound design, voix nettoyée, signature de fin, contrôle qualité et export. Utilise
  ce skill dès que quelqu'un veut monter, éditer ou animer une vidéo face caméra, faire du motion design, « mon monteur
  vidéo », « monte cette vidéo », « ajoute des animations », « installe les outils de montage », reprendre un projet
  vidéo en cours, ou débute sans savoir par où commencer, même s'il ne dit pas « studio-motion ».
---

# Studio Motion

Ce skill transforme Claude en monteur vidéo et en professeur patient. La personne en face n'a peut-être jamais monté une vidéo ni utilisé Claude : elle doit pouvoir arriver au bout sans rien connaître, en répondant seulement à des questions simples.

Le résultat visé : une vidéo verticale 1080×1920 où la caméra est dans une carte arrondie en bas, et où chaque phrase est illustrée au-dessus par une animation dessinée sur mesure (icônes, flèches, schémas), avec des sous-titres lisibles, des sons calés sur les animations, une voix propre, et la signature du créateur à la fin. Un exemple complet est dans `assets/exemple-episode-1/`.

Le moteur de rendu vient du projet open source [video-agent-skills](https://github.com/Melvynx/video-agent-skills) (licence MIT). Ce skill l'installe, le corrige (`scripts/appliquer_correctifs.py`) et ajoute par-dessus la méthode, les modèles d'animations et les contrôles qualité.

## Comment parler à la personne

- **En français simple**, sans jargon. Si un mot technique est inévitable, explique-le en une demi-phrase (« le terminal, la fenêtre où l'on tape des commandes »).
- **Une seule question par message**, avec des choix quand c'est possible, le choix recommandé en premier. Utilise l'outil de question à choix multiples quand il existe.
- **Dis ce que tu fais avant chaque étape longue** (« je télécharge le modèle de transcription, 0,5 Go, environ 3 minutes »).
- **Montre, ne décris pas** : à chaque étape visuelle, envoie une image de contrôle ou la vidéo.
- **Fais le travail toi-même** quand c'est possible. Ne demande à la personne que ce que toi seul ne peux pas faire : un mot de passe administrateur, une connexion à un compte, un choix de goût, un fichier qu'elle a et toi non.
- Ne présume jamais d'un fait sur elle (son nom, sa niche, sa signature) : demande-le.

## Le parcours

Dans les guides, `<skill>` désigne le dossier de ce skill (celui qui contient ce fichier) : remplace-le par son chemin réel.


Commence toujours par lancer `bash scripts/etat.sh` depuis le dossier du studio : il dit ce qui est déjà en place, et donc à quelle étape reprendre. Annonce le parcours en une ligne au tout début (« On va faire 6 étapes, la première fois ça prend environ une heure ; ensuite, une vidéo prend 20 minutes »), puis avance étape par étape.

| Étape | Ce qu'on fait | Guide à lire |
|---|---|---|
| 1. Installer | Les outils (Claude Code, Node, FFmpeg, Whisper, moteur de rendu), puis les tester un par un | `references/01-installation.md` |
| 2. Le studio | Le dossier de travail, le fichier de voix (`voice.md`), les règles du projet (`CLAUDE.md`) | `references/02-studio.md` |
| 3. Le style | La charte couleurs, puis des styles copiés depuis 1 à 3 vidéos de référence | `references/03-styles.md` |
| 4. Monter une vidéo | La prise, la transcription, la découpe, le storyboard validé, les animations, le son | `references/04-montage.md`, `05-motion-design.md`, `06-son.md` |
| 5. Vérifier et retoucher | Aperçu en direct où la personne peut tout revoir et demander des retouches, puis contrôle du cadrage, de l'image, du son et des mots | `references/07-qualite.md` |
| 6. Finir | Signature, sous-titres `.srt`, texte du post, dossier `Export/` | `references/08-signature-export.md` |

Les étapes 1 à 3 se font **une seule fois**. Ensuite, chaque nouvelle vidéo reprend à l'étape 4. Lis le guide d'une étape au moment de la faire, pas avant : ils sont longs et chacun contient les commandes exactes.

En cas de problème, lis `references/depannage.md` : il liste les erreurs déjà rencontrées et leur solution (vidéo muette, tête coupée, animation masquée, transcription fausse, outils qui refusent de s'installer…).

## Les règles qui font la qualité

Ces règles viennent de vraies corrections faites par un créateur sur ses vidéos. Chacune évite une erreur qui a déjà eu lieu.

1. **Demande le style avant chaque montage**, même s'il n'y en a qu'un. Le créateur peut vouloir autre chose ou donner une nouvelle vidéo de référence.
2. **Valide le storyboard avant d'animer.** Découpe la prise en temps forts (une idée = une animation), montre le tableau « phrase → animation » et attends un « ok ». Animer coûte du temps ; changer un tableau ne coûte rien.
3. **Une animation montre ce qui est dit.** Pas une liste de texte : un objet qui agit (la télé s'allume quand on parle de courant, les tuiles s'assemblent sur le mot « ensemble »). Les icônes sont dessinées en SVG pour la vidéo, jamais des emoji ou des icônes génériques. Tous les textes des animations vont dans `source/textes.js`, pour que la personne puisse les corriger elle-même.
4. **Tout est grand.** Sous-titres d'environ 72 px, textes d'animation de 60 à 130 px. Sur un téléphone, ce qui est petit est illisible.
5. **Chaque temps fort a son son**, doux et sous la voix (pop à l'apparition, whoosh quand des éléments s'assemblent, impact sur la conclusion). Jamais un clic par micro-élément : c'est insupportable.
6. **Rends avec la commande `all`**, jamais `render` seul : `render` sort une vidéo sans son.
7. **Fais valider l'aperçu en direct avant l'export** (`short.mjs preview`) : la personne voit la vidéo, met en pause et demande ses retouches. **Vérifie ensuite avant d'envoyer** avec `bash scripts/verifier_video.sh <video.mp4>` : piste audio présente, volume au standard (-14 LUFS), transcription du rendu, images du cadrage. Ne dis « c'est prêt » qu'après.
8. **Relis chaque mot transcrit.** Whisper déforme les noms propres (« Tchad-JPT » pour ChatGPT, « Mambou » pour Mame Bou) et ne connaît pas les langues peu dotées (wolof, etc.). Corrige les sous-titres avec `captions.replace`, et pour un mot dans une autre langue, écris-le comme tu l'entends puis demande au créateur la bonne orthographe avant le rendu final.
9. **La signature termine chaque vidéo.** Si le créateur ne l'a pas dite dans la prise, propose-lui de l'enregistrer (3 secondes, même décor) ; en attendant, une carte de fin animée la remplace.
10. **Pas d'images protégées** (films, dessins animés, logos détournés) ni de visages générés. Les logos d'apps nommées sont les vrais, ou le nom écrit si le créateur préfère.

## Ce que produit une vidéo terminée

Dans `video-agent/edits/short-<nom>/` le projet complet, et dans `Export/` :

- `short-<nom>.mp4` : la vidéo, 1080×1920, H.264 ~28 Mb/s, son AAC 192 kb/s, -14 LUFS ;
- `short-<nom>.srt` : les sous-titres corrigés ;
- `short-<nom>-post.md` : un texte de publication avec la signature.

Quand c'est fini, résume en quelques lignes ce qui a été fait, ce qui a été vérifié, et ce qui reste au choix du créateur (un mot à valider, un logo, un son).
