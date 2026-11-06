# Étape 1 : installer les outils

Une seule fois par ordinateur. Durée : 15 à 45 minutes selon la machine et la connexion. Dis-le à la personne avant de commencer.

## Ce qu'on installe et pourquoi (à expliquer en une ligne chacun)

| Outil | À quoi il sert, en mots simples |
|---|---|
| Claude Code (app de bureau ou terminal) | C'est moi : je lance les commandes et je monte la vidéo |
| Node.js 20+ | Fait tourner le moteur de rendu |
| Git | Télécharge les outils depuis GitHub |
| FFmpeg | Coupe, convertit, mélange le son, encode la vidéo finale |
| whisper.cpp + modèle `large-v3-turbo` | Écoute la voix et écrit chaque mot avec son minutage, sur l'ordinateur, sans rien envoyer en ligne |
| video-agent-skills | Le moteur de rendu (sous-titres, cartes, musique, rendu image par image dans Chrome) |
| Google Chrome | Le moteur dessine chaque image dans Chrome (installé automatiquement s'il manque) |
| yt-dlp + deno (facultatif) | Récupère des vidéos de référence ou des sous-titres depuis YouTube |
| Treg (facultatif) | Publie sur YouTube, Instagram, TikTok et lit les statistiques |

## 1. Faire l'état des lieux

```bash
bash <skill>/scripts/verifier_outils.sh
```

Il affiche une ligne par outil (✓ version, ou ✗ manquant) et l'architecture de la machine. Montre ce résultat en une phrase : « Tu as déjà Node et Git, il manque FFmpeg et Whisper. »

## 2. Installer ce qui manque

### Sur Mac

**Le cas simple** : Homebrew fonctionne. Vérifie avec `brew config` que `HOMEBREW_PREFIX` vaut `/opt/homebrew` sur une puce Apple (M1, M2, M3…), ou `/usr/local` sur un Mac Intel.

```bash
brew install node ffmpeg whisper-cpp yt-dlp
npm i -g deno
```

**Le cas qui coince** (déjà rencontré) : sur une puce Apple, Homebrew est installé dans `/usr/local` et tourne en mode Intel (Rosetta), ou il refuse avec « Your Command Line Tools (CLT) does not support macOS ». Réparer Homebrew demande le mot de passe administrateur de la personne. Plutôt que de l'arrêter, compile FFmpeg et Whisper en natif depuis leurs sources officielles avec le script fourni :

```bash
bash <skill>/scripts/installer_mac_natif.sh
```

Il installe CMake et uv dans un environnement Python isolé (`~/Tools/venv`), compile whisper.cpp avec l'accélération GPU Metal, compile x264, LAME puis FFmpeg (avec `libx264`, `libmp3lame`, VideoToolbox et AudioToolbox, dont le moteur a besoin), puis crée les raccourcis dans `/usr/local/bin`. Compte 10 à 20 minutes. Lance-le en arrière-plan et donne des nouvelles.

Pourquoi en natif : un Whisper compilé pour Intel tourne sous Rosetta sans le GPU et transcrit plusieurs fois plus lentement.

### Sur Windows

```powershell
winget install OpenJS.NodeJS.LTS Git.Git Gyan.FFmpeg yt-dlp.yt-dlp DenoLand.Deno
```

Puis fermer et rouvrir Claude Code. Le moteur télécharge lui-même whisper.cpp pour Windows à sa première préparation.

### Sur Linux

```bash
sudo apt install nodejs npm git ffmpeg
```

Whisper : compiler whisper.cpp (`cmake -B build && cmake --build build -j`) et mettre `build/bin/whisper-cli` dans le PATH.

## 3. Installer le moteur de rendu dans le dossier du studio

Le dossier du studio est celui où vivront toutes les vidéos (étape 2). Crée-le s'il n'existe pas, puis :

```bash
cd "<dossier du studio>"
npx -y skills add Melvynx/video-agent-skills -a claude-code -y
python3 <skill>/scripts/appliquer_correctifs.py .claude/skills/short-editing
node .claude/skills/short-editing/engine/setup.mjs
```

- La première commande copie 13 skills vidéo dans `.claude/skills/`.
- La deuxième ajoute les améliorations de Studio Motion au moteur (mot clé en italique serif dans les sous-titres, minuscules possibles dans les gros mots, nettoyage de la voix réglable, chargement de la police). On peut la relancer sans risque : elle ne modifie rien deux fois. **À relancer après chaque `npx skills update`**, qui écrase ces améliorations.
- La troisième prépare le moteur : paquets (15 Mo), modèle de transcription (0,5 Go), 8 musiques de fond générées, icônes. 3 à 6 minutes. Dis ce qui se télécharge avant de lancer.

## 4. Treg (facultatif, pour publier)

Seulement si la personne veut publier depuis Claude. Lis le script avant de le lancer, puis :

```bash
curl -fsSL https://treg.to/install.sh -o /tmp/treg-install.sh   # le lire
TREG_TELEMETRY=0 sh /tmp/treg-install.sh
treg login        # c'est la personne qui se connecte, dans son navigateur
```

Treg demande Python 3.12 ou 3.13 et `uv` (le script d'installation native l'installe). Ne te connecte jamais à sa place.

## 5. Tester chaque outil (obligatoire)

Un outil installé n'est pas un outil qui marche. Lance :

```bash
bash <skill>/scripts/tester_outils.sh
```

Le script :
1. fabrique une voix de test en français (`say` sur Mac) ;
2. encode une vidéo verticale 1080×1920 en x264 et en VideoToolbox, avec du son AAC et MP3 (test FFmpeg) ;
3. transcrit la voix avec Whisper et affiche le texte (test Whisper) ;
4. vérifie que le moteur est prêt (`setup.mjs --check`).

Montre le résultat : « La transcription de test est parfaite : “Bonjour, je suis ton monteur vidéo…” ». Tant qu'un test échoue, on ne passe pas à l'étape 2.
