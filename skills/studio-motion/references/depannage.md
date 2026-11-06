# Dépannage : les problèmes déjà rencontrés

| Symptôme | Cause | Solution |
|---|---|---|
| La vidéo n'a pas de son | Rendu fait avec `short.mjs render` (image seule) | `short.mjs all <projet>`, puis `verifier_video.sh` |
| La tête est coupée en haut de la carte caméra | Réglages par défaut du moteur : zoom 1.08, yeux à 27 % du haut | `layout.card: {..., zoom: 1.0, bias: 0.40}` dans le style et dans `source/style.json` du projet |
| Une carte de fin est à moitié cachée par la caméra | Les overlays sont dessinés sous la carte caméra | `layer: 'over'` sur l'overlay |
| « Tchad-JPT », « Mambou », « l'inseigneur » dans les sous-titres | Whisper déforme les noms propres et les marques, et la transcription change d'une passe à l'autre | `captions.replace` après avoir relu **chaque** mot de `files/words.md` (à refaire après chaque nouvelle transcription) |
| Un mot reste faux alors qu'il est dans `captions.replace` (« Mais Tchad-JPT ») | Whisper a collé deux mots dans le même bloc ; le moteur d'origine ne corrige que les blocs entiers | Correctif 5 de `appliquer_correctifs.py` (corrige aussi à l'intérieur des blocs), et `faire_srt.py` fait de même. Vérifier en extrayant tous les sous-titres : voir `07-qualite.md` |
| Un mot wolof (ou autre) transcrit en charabia | Whisper ne connaît pas la langue | Écrire comme on l'entend, demander l'orthographe à la personne, `captions.replace` |
| `brew install` échoue : « Command Line Tools does not support macOS » | Outils Xcode trop anciens | `scripts/installer_mac_natif.sh` (pas de mot de passe), ou la personne met à jour les outils Xcode dans Réglages > Mise à jour |
| Homebrew installe des programmes Intel sur une puce Apple | Homebrew dans `/usr/local` sous Rosetta | Compiler en natif (`installer_mac_natif.sh`) : Whisper est bien plus rapide avec le GPU |
| `init` s'arrête avec une erreur Node sur un projet existant | `init` ne réécrit pas un dossier existant | Créer un nouveau projet et y recopier `source/*.html`, `lib.js`, `assets/*.mov`, `assets/sfx/` |
| Une boucle `for c in "a 3.0" ...; do set -- $c` échoue sous zsh | zsh ne découpe pas `$c` en mots | Une commande par ligne |
| Un espace disparaît dans un titre d'animation (« detechniques ») | `display: inline-block` sur le mot coloré | `margin-left` sur ce mot |
| Une animation modifiée n'apparaît pas dans la vidéo | Le cache du moteur | Relancer `prepare` après chaque `capture` |
| Les stills ne sortent qu'une image | Temps séparés par des virgules | Les séparer par des espaces : `stills <projet> 1.5 4 8` |
| `--out` refuse le chemin du rendu | Le chemin est relatif au projet | `--out output/<fichier>.mp4` |
| Les améliorations Studio Motion ont disparu | `npx skills update` a réécrit le moteur | Relancer `python3 <skill>/scripts/appliquer_correctifs.py .claude/skills/short-editing` |
