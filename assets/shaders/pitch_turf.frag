#version 460 core
#include <flutter/runtime_effect.glsl>

// Gramado de estadio.
//
// A verdade fisica que este shader existe para reproduzir: **a listra do campo
// nao e uma cor diferente.** O rolo do cortador deita a grama para um lado em
// cada passada; a faixa que se deita afastando-se de quem olha devolve luz e
// parece clara, a que se deita na direcao contraria engole luz e parece escura.
// O efeito e anisotropico -- depende da direcao da luz -- e por isso o
// contraste **inverte de sinal** ao cruzar o eixo do refletor. Pintar duas
// cores alternadas, que era o que o CustomPainter fazia, da aspecto de adesivo.

// `highp`, nao `mediump`: em GLES movel mediump e float de 16 bits, e o
// `43758.5453123` do hash simplesmente nao cabe la. Com mediump o grao vira
// faixa e as laminas viram xadrez -- justamente nos Android baratos que este
// app mais roda.
precision highp float;

uniform vec2 uSize;

// Rampa da turfa, vinda de PitchTheme. O seed do usuario nunca chega aqui: o
// campo e superficie fotografica, nao tematica.
uniform vec3 uTurfNear;
uniform vec3 uTurfMid;
uniform vec3 uTurfFar;

// Refletor: posicao normalizada e forca.
uniform vec2 uLight;
uniform float uLightIntensity;
uniform vec3 uLightColor;

uniform float uStripeCount;
uniform float uStripeStrength;

// Desgaste das areas mais pisadas.
uniform float uWear;

uniform vec3 uVignetteColor;
uniform float uVignetteStrength;
uniform float uGrain;

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Ruido de valor com interpolacao suave. Barato o bastante para rodar por
// pixel em duas frequencias diferentes.
float valueNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Mancha radial suave, usada para o desgaste.
float softPatch(vec2 uv, vec2 centre, vec2 radius) {
  float d = length((uv - centre) / radius);
  return 1.0 - smoothstep(0.0, 1.0, d);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;

  // 1 -- Base: a turfa escurece para longe, como campo sob refletor alto.
  float radial = clamp(length((uv - vec2(0.5, 0.45)) * vec2(1.0, 1.15)) / 0.75, 0.0, 1.0);
  vec3 color = mix(uTurfNear, uTurfMid, smoothstep(0.0, 0.55, radial));
  color = mix(color, uTurfFar, smoothstep(0.55, 1.0, radial));

  // 2 -- Listras com borda suave. A grama dobra em gradiente, nao em degrau,
  // entao a transicao entre faixas e um smoothstep, nao um corte.
  float band = uv.y * uStripeCount;
  float index = floor(band);
  float within = fract(band);
  float edge = smoothstep(0.0, 0.14, within) * (1.0 - smoothstep(0.86, 1.0, within));
  float direction = mod(index, 2.0) * 2.0 - 1.0;

  // 3 -- O termo anisotropico. `bend` e para onde a lamina esta deitada;
  // quanto mais alinhada com a direcao da luz, mais escura ela le. Como
  // `toLight.y` troca de sinal ao passar pelo refletor, o contraste das
  // listras se inverte na metade do campo -- que e exatamente o que se ve numa
  // transmissao.
  vec2 toLight = normalize(uLight - uv + vec2(0.0001));
  float bend = direction;
  float aniso = bend * toLight.y;
  color *= 1.0 + aniso * uStripeStrength * edge;

  // 4 -- Laminas. Ruido esticado na vertical: a grama tem fibra, e e a fibra
  // que mata o aspecto de plastico de um gradiente chapado.
  float blades = valueNoise(vec2(uv.x * 420.0, uv.y * 90.0));
  float clumps = valueNoise(vec2(uv.x * 38.0, uv.y * 26.0));
  color *= 1.0 + (blades - 0.5) * 0.05 + (clumps - 0.5) * 0.06;

  // 5 -- Desgaste. Onde mais se pisa a grama rala e o solo aparece: as duas
  // pequenas areas, o circulo central e as marcas de penalti.
  float wear = 0.0;
  wear += softPatch(uv, vec2(0.5, 0.045), vec2(0.20, 0.055));
  wear += softPatch(uv, vec2(0.5, 0.955), vec2(0.20, 0.055));
  wear += softPatch(uv, vec2(0.5, 0.5), vec2(0.13, 0.075)) * 0.7;
  wear += softPatch(uv, vec2(0.5, 0.135), vec2(0.045, 0.022)) * 0.6;
  wear += softPatch(uv, vec2(0.5, 0.865), vec2(0.045, 0.022)) * 0.6;
  wear = clamp(wear, 0.0, 1.0) * uWear;
  // Pisado clareia e perde saturacao, nunca vira marrom: campo bem cuidado
  // gasta, nao morre.
  float luma = dot(color, vec3(0.299, 0.587, 0.114));
  color = mix(color, mix(color, vec3(luma), 0.55) * 1.12, wear);

  // 6 -- Ganho do refletor.
  float lit = 1.0 - smoothstep(0.0, 1.0, length((uv - uLight) * vec2(1.0, 0.9)) / 0.95);
  color += uLightColor * lit * uLightIntensity;

  // 7 -- Vinheta: o estadio escurece nas bordas do enquadramento.
  float vig = smoothstep(0.45, 1.0, length((uv - vec2(0.5)) * vec2(1.05, 1.0)) / 0.9);
  color = mix(color, uVignetteColor, vig * uVignetteStrength);

  // 8 -- Grao. Evita banding em tela de 8 bits, que e onde um gradiente amplo
  // de verde se denuncia.
  float grain = hash(uv * uSize) - 0.5;
  color += grain * uGrain;

  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
