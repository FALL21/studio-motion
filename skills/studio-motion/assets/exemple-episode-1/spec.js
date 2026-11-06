// Short: "<one-line promise>". All times are SOURCE seconds (read them from files/words.md).
// Parameters: references/scene-library.md. Delete what you don't use.
// Pace (speed, tighten), caption look, music bpm and mix come from source/style.json (the creator style snapshot
// written by `init`). Set a key here only to override it for this one short.
window.SPEC = {
  title: 'ChatGPT n\'est pas l\'IA (épisode 1)',
  media: {
    a: { src: 'assets/a-tele.mov', width: 1080, alpha: true },
    b: { src: 'assets/b-pas-pareil.mov', width: 1080, alpha: true },
    c: { src: 'assets/c-chatgpt-ia.mov', width: 1080, alpha: true },
    d: { src: 'assets/d-ensemble.mov', width: 1080, alpha: true },
    e: { src: 'assets/e-question.mov', width: 1080, alpha: true },
    f: { src: 'assets/f-presentation.mov', width: 1080, alpha: true },
    g: { src: 'assets/g-signature.mov', width: 1080, alpha: true },
  },
  cam: { crop: [0, 0, 2160, 3840], eyes: [1017, 1654] , q: 1 },   // face detected on this take
  // voix : débruitage doux, moins de résonance de pièce, présence, de-esser, compression
  voiceFx: 'highpass=f=75,afftdn=nr=16:nf=-50:tn=1,equalizer=f=250:t=q:w=1:g=-2.5,equalizer=f=3200:t=q:w=1.2:g=2.5,equalizer=f=9000:t=q:w=1:g=1.5,deesser=i=0.4,acompressor=threshold=0.1:ratio=3:attack=5:release=80:makeup=2,alimiter=limit=0.95',
  cut: [],   // prise = épisode 1 (0-26 s) + signature enregistrée à part (26-29 s)                                                // [[a, b]] retakes / dead air to drop

  // seam: 960 half, 1240 paper-heavy, 0 full camera. Change it every few seconds.
  
  zoom: { keys: [[0, 1]] },

  actors: [
    // { id: 'demo', media: 'demo', offset: 0, from: 0.5, to: 6, pre: .45,
    //   keys: [[0.5, [60, 250, 960]]], labelKeys: [[0.5, 'Label']], dot: 'blue' },
  ],

  scenes: [
    { type: 'overlay', media: 'a', from: 0, to: 3.9 },
    { type: 'overlay', media: 'b', from: 3.9, to: 7.66 },
    { type: 'overlay', media: 'c', from: 7.66, to: 13.6 },
    { type: 'overlay', media: 'd', from: 13.6, to: 17.7 },
    { type: 'overlay', media: 'e', from: 17.7, to: 22.3 },
    { type: 'overlay', media: 'f', from: 22.3, to: 26.0 },
    { type: 'overlay', media: 'g', from: 26.0, to: 29.0 },
  ],

  music: { breaks: [] },
  // sons calés sur les animations (temps source)
  sfx: { swish: 0, accents: 0,
    extra: [[0.55, 'pop', -9], [2.95, 'thud', -6], [5.34, 'pop', -8], [9.58, 'pop', -8], [8.8, 'tap', -10], [12.3, 'bell', -13], [16.45, 'pop', -9], [21.55, 'pop', -9], [23.8, 'pop', -10], [25.3, 'pop', -10], [26.46, 'pop', -9], [27.04, 'pop', -9], [27.8, 'pop', -7], [28.7, 'tap', -7], [28.8, 'bell', -13]],
    files: [
      { at: 2.1, src: 'assets/sfx/zhhh.mp3', gain: -18, peak: true },
      { at: 2.45, src: 'assets/sfx/pop-back.mp3', gain: -13, peak: true },
      { at: 5.7, src: 'assets/sfx/pop-back.mp3', gain: -13, peak: true },
      { at: 7.27, src: 'assets/sfx/impact-boom.mp3', gain: -13, peak: true },
      { at: 9.95, src: 'assets/sfx/zhhh.mp3', gain: -18, peak: true },
      { at: 10.5, src: 'assets/sfx/pop-back.mp3', gain: -14, peak: true },
      { at: 14.1, src: 'assets/sfx/zhhh.mp3', gain: -16, peak: true },
      { at: 16.0, src: 'assets/sfx/zhhh.mp3', gain: -19, peak: true },
      { at: 20.3, src: 'assets/sfx/pop-back.mp3', gain: -12, peak: true },
      { at: 22.4, src: 'assets/sfx/zhhh.mp3', gain: -18, peak: true },
    ] },   // [[a, b]] drums drop (a punchline, a full-camera beat); a library bed instead: src + offset, see references/music.md
  captions: {
    replace: [['Tchad-JPT', 'ChatGPT'], ['Et bien', 'Eh bien'], ['Mambou', 'Mame Bou'], ['l\'inseigneur', 'ingénieur'], ['l\'enseigneur', 'ingénieur'], ['je vous le sais.', 'Xam, Jëf, Jariñu.']],
    emph: [],
    hide: [[17.7, 99]],   // ranges where a scene already shows the words (title, typing, CTA -> [ctaFrom, 99])
  },
};
