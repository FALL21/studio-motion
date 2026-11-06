// Shared motion helpers + drawn icons for the episode 1 components (charte: #04529A, white, black).
// Everything is a pure function of t. SVG strings, 1080 wide, stage zone y 40 - 770 (card layout).
const B = '#04529A', K = '#0A0A0A', W = '#FFFFFF', BL = '#E8F0F8';
const cl = (x, a = 0, b = 1) => Math.min(b, Math.max(a, x));
const S = (x, w = 14) => x <= 0 ? 0 : 1 - (1 + w * x) * Math.exp(-w * x);                      // smooth spring
const OS = (x, w = 10, z = .42) => { if (x <= 0) return 0; const wd = w * Math.sqrt(1 - z * z);  // overshoot spring
  return 1 - Math.exp(-z * w * x) * (Math.cos(wd * x) + z * w / wd * Math.sin(wd * x)); };
const E = x => { x = cl(x); return 1 - Math.pow(1 - x, 3); };
const EIO = x => { x = cl(x); return x < .5 ? 4 * x * x * x : 1 - Math.pow(-2 * x + 2, 3) / 2; };
const lerp = (a, b, k) => a + (b - a) * k;
const FONT = '-apple-system, "SF Pro Display", "Helvetica Neue", Inter, sans-serif';
const shadowEl = (cx, cy, w, a) => `<ellipse cx="${cx}" cy="${cy}" rx="${w}" ry="${w * .15}" fill="${B}" opacity="${a}"/>`;
const txt = (x, y, s, size, weight, fill, a = 1, anchor = 'middle', extra = '') =>
  `<text x="${x}" y="${y}" font-family='${FONT}' font-size="${size}" font-weight="${weight}" fill="${fill}" opacity="${a}" text-anchor="${anchor}" letter-spacing="${-size * .025}" ${extra}>${s}</text>`;
// a word that rises out of a blur: returns svg with a blur filter id per call
let _fid = 0;
function riseText(t0, t, x, y, s, size, weight, fill, anchor = 'middle') {
  const a = S(t - t0, 11); if (a <= 0) return '';
  const id = 'f' + (_fid++), bl = (1 - a) * 9;
  return `<filter id="${id}" x="-20%" y="-50%" width="140%" height="200%"><feGaussianBlur stdDeviation="${bl}"/></filter>` +
    txt(x, y + (1 - a) * 46, s, size, weight, fill, cl(a * 1.4), anchor, `filter="url(#${id})"`);
}
function chip(x, y, label, p, fill = B, color = W, size = 34) {
  if (p <= 0) return ''; const w = label.length * size * .58 + 56, h = size * 1.9;
  return `<g transform="translate(${x} ${y}) scale(${p})"><rect x="${-w / 2}" y="${-h / 2}" width="${w}" height="${h}" rx="${h / 2}" fill="${fill}"/>` +
    txt(0, size * .36, label, size, 800, color) + `</g>`;
}
// TV: 300 x 200 screen on a stand; on = 0..1 lights the screen
function tv(cx, cy, s, on, t) {
  let g = `<g transform="translate(${cx} ${cy}) scale(${s})">`;
  g += `<rect x="-40" y="118" width="80" height="16" rx="6" fill="${K}"/><rect x="-90" y="132" width="180" height="12" rx="6" fill="${K}"/>`;
  g += `<rect x="-160" y="-110" width="320" height="226" rx="26" fill="${K}"/>`;
  g += `<rect x="-142" y="-92" width="284" height="172" rx="14" fill="#1B1F24"/>`;
  if (on > 0) {
    g += `<rect x="-142" y="-92" width="284" height="172" rx="14" fill="${B}" opacity="${on}"/>`;
    // a light sweep + a play glyph on the lit screen
    const sx = -142 + ((t * 260) % 420) - 60;
    g += `<clipPath id="tvc"><rect x="-142" y="-92" width="284" height="172" rx="14"/></clipPath>`;
    g += `<g clip-path="url(#tvc)" opacity="${on * .35}"><rect x="${sx}" y="-100" width="60" height="200" fill="${W}" transform="skewX(-18)"/></g>`;
    g += `<g opacity="${on}" transform="scale(${.7 + .3 * on})"><circle r="40" fill="${W}" opacity=".18"/><path d="M-12 -20 L22 0 L-12 20Z" fill="${W}"/></g>`;
  }
  g += `<circle cx="132" cy="102" r="4" fill="${on > .5 ? B : '#555'}"/>`;
  return g + `</g>`;
}
// lightning bolt (current), 100 tall
function bolt(cx, cy, s, fill = B, glow = 0) {
  let g = `<g transform="translate(${cx} ${cy}) scale(${s})">`;
  if (glow > 0) g += `<circle r="${80 + 10 * glow}" fill="${B}" opacity="${.12 * glow}"/>`;
  g += `<path d="M12 -70 L-38 8 L-4 8 L-14 70 L38 -10 L4 -10 Z" fill="${fill}" stroke="${fill}" stroke-width="6" stroke-linejoin="round"/>`;
  return g + `</g>`;
}
// wall socket + plug
function socket(cx, cy, s) {
  return `<g transform="translate(${cx} ${cy}) scale(${s})"><rect x="-56" y="-56" width="112" height="112" rx="26" fill="${W}" stroke="${K}" stroke-width="7"/>` +
    `<circle r="30" fill="none" stroke="${K}" stroke-width="5"/><rect x="-14" y="-6" width="8" height="14" rx="3" fill="${K}"/><rect x="6" y="-6" width="8" height="14" rx="3" fill="${K}"/></g>`;
}
// a cable path drawn on (p 0..1) with current pulses (flow 0..1)
function cable(d, len, p, flow, t, w = 9) {
  let g = `<path d="${d}" fill="none" stroke="${K}" stroke-width="${w}" stroke-linecap="round" stroke-dasharray="${len}" stroke-dashoffset="${len * (1 - p)}"/>`;
  if (flow > 0) g += `<path d="${d}" fill="none" stroke="${B}" stroke-width="${w - 2}" stroke-linecap="round" stroke-dasharray="26 54" stroke-dashoffset="${-t * 260}" opacity="${flow}"/>`;
  return g;
}
// chat app window (generic, labelled ChatGPT by text, no logo)
function chatWin(cx, cy, s, typing, reply, t, title = 'ChatGPT') {
  let g = `<g transform="translate(${cx} ${cy}) scale(${s})">`;
  g += `<rect x="-170" y="-130" width="340" height="260" rx="30" fill="${W}" stroke="${K}" stroke-width="6"/>`;
  g += `<rect x="-170" y="-130" width="340" height="58" rx="30" fill="${K}"/><rect x="-170" y="-96" width="340" height="24" fill="${K}"/>`;
  g += txt(0, -91, title, 30, 800, W);
  g += `<rect x="10" y="-52" width="140" height="44" rx="22" fill="${BL}"/>`;
  g += `<rect x="-150" y="6" width="${180 * reply + 40}" height="44" rx="22" fill="${B}" opacity="${reply > 0 ? 1 : .0}"/>`;
  if (typing > 0 && reply <= 0) for (let i = 0; i < 3; i++) g += `<circle cx="${-122 + i * 22}" cy="28" r="7" fill="${B}" opacity="${typing * (.35 + .65 * Math.max(0, Math.sin(t * 9 - i)))}"/>`;
  if (reply > .6) g += `<rect x="-150" y="62" width="${200 * cl((reply - .6) / .4)}" height="16" rx="8" fill="${B}" opacity=".35"/>`;
  g += `<rect x="-150" y="96" width="300" height="20" rx="10" fill="${BL}"/>`;
  return g + `</g>`;
}
// neural core "IA": circle of nodes + links
function iaCore(cx, cy, s, p, t, label = 'IA') {
  let g = `<g transform="translate(${cx} ${cy}) scale(${s * p})">`;
  g += `<circle r="150" fill="${B}" opacity=".10"/><circle r="112" fill="${B}"/>`;
  const n = 8; for (let i = 0; i < n; i++) { const a = i / n * Math.PI * 2 + t * .4, x = Math.cos(a) * 150, y = Math.sin(a) * 150;
    g += `<line x1="0" y1="0" x2="${x}" y2="${y}" stroke="${B}" stroke-width="4" opacity=".35"/><circle cx="${x}" cy="${y}" r="13" fill="${W}" stroke="${B}" stroke-width="5"/>`; }
  g += txt(0, 30, label, 84, 800, W);
  return g + `</g>`;
}
function check(cx, cy, p, s = 1) {
  if (p <= 0) return ''; const L = 70;
  return `<g transform="translate(${cx} ${cy}) scale(${p * s})"><circle r="34" fill="${B}"/><path d="M-14 1 L-4 12 L16 -10" fill="none" stroke="${W}" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="${L}" stroke-dashoffset="${L * (1 - cl(p * 1.4 - .3))}"/></g>`;
}
function ring(cx, cy, r0, r1, t0, t, dur = .8, w = 7) {
  const k = cl((t - t0) / dur); if (k <= 0 || k >= 1) return '';
  return `<circle cx="${cx}" cy="${cy}" r="${r0 + (r1 - r0) * E(k)}" fill="none" stroke="${B}" stroke-width="${w * (1 - k)}" opacity="${1 - k}"/>`;
}
function page(draw) {
  document.body.innerHTML = '<svg id="sv" width="1080" height="900" viewBox="0 0 1080 900" style="position:absolute;left:0;top:0"></svg>';
  const sv = document.getElementById('sv');
  window.setT = t => { _fid = 0; sv.innerHTML = draw(t); };
  window.setT(0);
}
