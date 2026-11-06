# Studio Motion

**Ton monteur vidéo IA, en français, étape par étape.** Un skill pour [Claude Code](https://claude.com/claude-code) qui te guide de zéro jusqu'à une vidéo courte verticale (TikTok, Reels, Shorts) montée comme par un motion designer pro, même si tu n'as jamais fait de montage ni utilisé Claude.

Tu filmes, tu déposes ta prise, tu réponds à quelques questions simples. Claude s'occupe du reste :

- **transcrit** ta voix mot à mot, sur ton ordinateur (rien n'est envoyé en ligne) ;
- **coupe** les silences et les passages à enlever ;
- **dessine une animation sur mesure pour chaque phrase**, calée sur tes mots (une télé qui s'allume quand tu parles de courant, des tuiles qui s'assemblent sur le mot « ensemble »…) ;
- ajoute des **sous-titres** lisibles, une **musique** discrète et un **son sur chaque animation** ;
- **nettoie ta voix** (souffle, résonance, « s » sifflants) ;
- termine par **ta signature** ;
- **vérifie tout** (son, volume, cadrage, mots mal transcrits) avant de te livrer la vidéo, ses sous-titres `.srt` et un texte de publication.

## Le résultat

Exemple complet, avec ses 7 animations : [`skills/studio-motion/assets/exemple-episode-1/`](skills/studio-motion/assets/exemple-episode-1/), « ChatGPT n'est pas l'IA », épisode 1, de Mame Bou Fall.

- Format : vertical 1080×1920, 30 images/s, H.264 ~28 Mb/s.
- Son : -14 LUFS (le standard des réseaux).
- Mise en page : ta caméra dans une carte arrondie en bas, l'animation au-dessus, les sous-titres entre les deux.

## Ce qu'il te faut

- Un ordinateur : **Mac** (conseillé, puce Apple idéale), Windows ou Linux.
- **Claude Code** : l'app Claude pour ordinateur (onglet Code) ou le terminal. Un abonnement Claude est nécessaire.
- Environ **2 Go** d'espace libre, et **une heure** la première fois (installation et réglages). Ensuite, compte **20 à 40 minutes par vidéo**.

Tout le reste (FFmpeg, Whisper, le moteur de rendu…), Claude l'installe pour toi à la première étape.

## Installer le skill

**Option 1 : en une commande** (dans un terminal) :

```bash
npx skills add FALL21/studio-motion -a claude-code -g
```

**Option 2 : demande-le à Claude.** Colle simplement ce message dans Claude Code :

> Installe le skill https://github.com/FALL21/studio-motion

**Option 3 : à la main.**

```bash
git clone https://github.com/FALL21/studio-motion.git
mkdir -p ~/.claude/skills
cp -r studio-motion/skills/studio-motion ~/.claude/skills/
```

## Commencer

1. Crée un dossier vide pour ton studio (par exemple `Mes vidéos`) et ouvre-le dans Claude Code.
2. Écris : **« Aide-moi à monter ma première vidéo »**, ou tape `/studio-motion`.
3. Laisse-toi guider : Claude te pose une question à la fois.

## Les 6 étapes

| | Étape | Une seule fois ? |
|---|---|---|
| 1 | **Installer** les outils et les tester un par un | oui |
| 2 | **Le studio** : tes dossiers, ta façon de parler (`voice.md`), tes règles (`CLAUDE.md`) | oui |
| 3 | **Le style** : ta couleur, et des styles copiés depuis des vidéos que tu aimes | oui, puis à volonté |
| 4 | **Monter** : prise, découpe, storyboard validé, animations, son | à chaque vidéo |
| 5 | **Vérifier** : son, volume, cadrage, chaque mot des sous-titres | à chaque vidéo |
| 6 | **Finir** : signature, sous-titres `.srt`, texte du post, export | à chaque vidéo |

## Dans le dépôt

```text
skills/studio-motion/
├── SKILL.md                 le parcours et les règles de qualité
├── references/              un guide détaillé par étape, et le dépannage
├── scripts/                 vérifier les outils, installer (Mac), corriger le moteur, contrôler une vidéo, faire le .srt
└── assets/
    ├── composants/          10 modèles d'animations prêts à adapter + la boîte à outils lib.js
    ├── exemple-episode-1/   une vraie vidéo montée de bout en bout
    └── *.modele             modèles de CLAUDE.md, voice.md et du style Explicatif
```

## Merci

Studio Motion s'appuie sur le moteur de rendu open source [video-agent-skills](https://github.com/Melvynx/video-agent-skills) de Melvyn (licence MIT), qu'il installe puis améliore localement. La transcription utilise [whisper.cpp](https://github.com/ggml-org/whisper.cpp), et l'encodage [FFmpeg](https://ffmpeg.org).

## Licence

MIT : tu peux l'utiliser, le modifier et le partager librement. Voir [LICENSE](LICENSE).

---

Créé par **Mame Bou Fall**, ingénieur IA & Big Data à Dakar. *Xam, Jëf, Jariñu.*
