# Le motion design : les animations sur mesure

C'est ce qui fait qu'on « sent qu'un pro du design a monté la vidéo ». Chaque temps fort du storyboard devient une petite page HTML qui dessine une animation, que le moteur filme image par image en vidéo transparente, puis pose au-dessus de la caméra.

## Le contrat d'une animation

- Un fichier `source/<nom>.html`, 1080 px de large, fond transparent.
- **Tout est une fonction du temps** : la page expose `window.setT(t)` qui dessine l'état exact à l'instant `t` (secondes depuis le début de l'animation). Pas d'animation CSS, pas de minuteur : sinon la capture image par image saute.
- Avec la mise en page « carte » : dessine seulement dans la zone **y 40 à 770** (au-dessus des sous-titres et de la caméra). Ce qui dépasse est caché par la carte caméra, sauf pour un overlay `layer: 'over'` (carte de fin plein écran).
- `t = 0` correspond au `from` de l'overlay. Les temps à l'intérieur sont des **temps short** : prends dans `files/words.md` le temps short du mot déclencheur et soustrais le temps short du début de l'overlay.

## La boîte à outils (`assets/composants/lib.js`)

Copie-la dans `source/` du projet. Elle fournit :

- **Couleurs** : `B` (accent), `K` (noir), `W` (blanc), `BL` (accent très clair). Change l'accent en mettant `window.CHARTE = {accent: '#04529A'}` avant de charger `lib.js`.
- **Mouvements** : `S(x)` ressort amorti (arrivée douce), `OS(x, w, z)` ressort avec léger rebond (pop), `E(x)` décélération, `EIO(x)` accélération puis décélération, `lerp`.
- **Texte** : `txt(x, y, texte, taille, graisse, couleur)`, `riseText(t0, t, x, y, texte, ...)` = mot qui monte en sortant d'un flou.
- **Éléments dessinés** : `tv`, `bolt` (éclair), `socket` (prise), `cable` (câble qui se trace avec du courant qui circule), `chatWin` (fenêtre de discussion qui tape puis répond), `iaCore` (cœur IA en réseau), `check` (coche qui se dessine), `chip` (pastille), `ring` (onde), `shadowEl` (ombre au sol).
- `page(t => '...svg...')` : crée la page et branche `window.setT`.

Squelette :

```html
<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;background:transparent}body{width:1080px;height:1920px;overflow:hidden}</style></head><body>
<script>window.CHARTE = { accent: '#04529A' };</script>
<script src="lib.js"></script><script>
// Phrase : « ... » ; mots déclencheurs (temps local) : mot1 .38, mot2 1.73
page(t => {
  let h = '';
  const p = OS(t - .3, 11, .45);                 // l'objet arrive avec un rebond juste avant le mot
  if (p > 0) h += tv(430, 420, 1.15 * p, 0, t);
  h += riseText(.45, t, 430, 140, 'Télévision', 64, 800, K);
  return h;
});
</script></body></html>
```

## Les textes : tous dans un seul fichier (`source/textes.js`)

Pour que la personne puisse corriger elle-même un texte d'animation sans toucher au code, **aucun texte n'est écrit en dur dans les animations** : ils sont tous dans `source/textes.js`, une section par animation, avec en commentaire la phrase qu'elle illustre. Modèle : `assets/composants/textes.js.modele` (celui de l'exemple).

```js
window.TEXTES = {
  // a : « Pour que cette télévision fonctionne, il lui faut du courant électrique »
  a: { objet: "Télévision", energie: "Courant" },
};
```

Dans chaque animation, charge le fichier avant `lib.js` et lis sa section, avec le texte d'origine en secours :

```html
<script src="textes.js"></script><script src="lib.js"></script><script>
const X = (window.TEXTES || {}).a || {};   // textes modifiables dans textes.js
page(t => riseText(.45, t, 430, 140, X.objet ?? 'Télévision', 64, 800, K));
```

Après une modification de `textes.js` (ou d'une animation), une seule commande refilme ce qui a changé et prépare le projet :

```bash
bash <skill>/scripts/refaire_animations.sh video-agent/edits/short-<nom>
```

Puis touche **R** dans l'aperçu. Compte environ 45 secondes quand `textes.js` change (il est partagé : toutes les animations sont refilmées).

## Les modèles prêts à adapter (`assets/composants/`)

| Fichier | Ce qu'il montre | Pour quelle phrase |
|---|---|---|
| `question-reseau.html` | Un réseau de neurones qui se construit, une question en deux lignes, un « ? » qui rebondit avec une onde | Une question, un hook « c'est quoi X ? » |
| `objet-alimente.html` | Un objet qui s'allume quand un câble l'alimente | Une cause et un effet, « il faut X pour que Y marche » |
| `egal-ou-pas.html` | Deux éléments face à face, « = ? » barré en « ≠ » avec « NON » | « X n'est pas Y », une idée reçue démontée |
| `produit-technologie.html` | Un produit relié à une technologie, le courant passe, le produit répond | « X utilise Y » |
| `partie-du-tout.html` | Un élément qui rétrécit et devient une case parmi d'autres, encadrées par un titre | « X n'est qu'une partie de Y » |
| `assemblage.html` | Des tuiles éparpillées qui s'emboîtent en nid d'abeille autour d'un cœur, puis s'allument | « un ensemble de… », une définition |
| `imitation.html` | Un robot et un humain, un flux de données, le robot copie le geste, « ≈ » et coches | « imiter », « comme un humain » |
| `presentation.html` | Une carte nom + titre + pastilles | « Moi c'est … » |
| `signature-scene.html` | La signature mot par mot au-dessus de la caméra, « Abonne-toi », bouton tapé | Signature dite face caméra |
| `signature-plein-ecran.html` | Même chose en plein écran (couvre la caméra), `layer: 'over'` | Signature non dite (carte de fin) |

En haut de chaque modèle, un commentaire donne les textes et les temps à modifier. Remplace-les par ceux du storyboard.

## Les règles de design (ce qui fait « pro »)

1. **L'objet agit au moment du mot.** L'animation commence 0,1 à 0,3 s avant le mot déclencheur, pour que l'œil soit déjà là quand l'oreille entend.
2. **Des ressorts, jamais du linéaire.** Les objets arrivent avec `OS` (petit rebond), le texte avec `riseText` (monte en sortant d'un flou), les traits se dessinent (`stroke-dashoffset`).
3. **Une couleur d'accent, du noir, du blanc.** L'accent seulement sur ce qui compte (le mot clé, la flèche, la coche).
4. **Grand.** Titres 84 à 130 px, étiquettes 40 à 56 px, rien sous 30 px.
5. **De l'air.** Rien ne touche les bords (marge ≥ 60 px), rien ne se chevauche. Vérifie sur les planches.
6. **Ça vit même quand c'est posé** : une impulsion qui circule, un halo qui respire, une onde. Une image figée plus de 2 s paraît morte.
7. **Une animation = une idée.** Si on doit lire, c'est trop.

## Filmer et vérifier

```bash
node $E capture <projet> source/<anim>.html --dur <durée> --alpha --out assets/<anim>.mov
```

Lis `stills/<anim>-sheet.jpg` (8 images de l'animation) : chevauchements, textes coupés, espaces manquants (un `<b>` en `inline-block` mange l'espace avant lui), éléments qui sortent de la zone. Corrige et refilme. Après une refilme, relance `prepare` pour que le moteur la prenne en compte.

Dans une boucle shell sous zsh, `set -- $variable` ne découpe pas la chaîne : lance plutôt une commande `capture` par ligne.
