// ============================================================
//  Neon Horizons - shared helpers, palettes and sky model
//  Palette reference: neon skyline at dawn/dusk - deep indigo
//  zenith, magenta/pink/coral band, golden horizon, violet
//  shadows, cyan/magenta accents.
// ============================================================
#ifndef COMMON_GLSL
#define COMMON_GLSL

// ------------------------------------------------ hashes / noise
float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float hash13(vec3 p3) {
    p3 = fract(p3 * 0.1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

float valueNoise2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = hash12(i);
    float b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0));
    float d = hash12(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm2(vec2 p, int octaves) {
    float v = 0.0;
    float amp = 0.5;
    float tot = 0.0;
    for (int i = 0; i < octaves; i++) {
        v += valueNoise2D(p) * amp;
        tot += amp;
        p = p * 2.03 + vec2(17.3, 9.1);
        amp *= 0.5;
    }
    return v / tot;
}

// Interleaved gradient noise for dithered sampling
float interleavedGradientNoise(vec2 p) {
    return fract(52.9829189 * fract(dot(p, vec2(0.06711056, 0.00583715))));
}

// ------------------------------------------------ octahedral normals
vec2 encodeNormal(vec3 n) {
    n = normalize(n);
    vec2 e = n.xy * (1.0 / (abs(n.x) + abs(n.y) + abs(n.z)));
    e = n.z >= 0.0 ? e : (1.0 - abs(e.yx)) * sign(e.xy);
    return e * 0.5 + 0.5;
}

vec3 decodeNormal(vec2 e) {
    e = e * 2.0 - 1.0;
    vec3 n = vec3(e.xy, 1.0 - abs(e.x) - abs(e.y));
    vec2 wrap = (1.0 - abs(n.yx)) * sign(n.xy);
    n.xy = n.z < 0.0 ? wrap : n.xy;
    return normalize(n);
}

// ------------------------------------------------ space helpers
float linearizeDepth(float depth, float near, float far) {
    return (2.0 * near * far) / (far + near - (depth * 2.0 - 1.0) * (far - near));
}

// Compresses shadow-map UVs so the area near the player keeps detail
vec2 distortShadow(vec2 pos) {
    float distb = length(pos);
    float factor = (1.0 - SHADOW_DISTORT_STRENGTH) + distb * SHADOW_DISTORT_STRENGTH;
    return pos / max(factor, 1e-4);
}

float luma(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

vec3 tonemapACES(vec3 x) {
    x *= EXPOSURE;
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

// ------------------------------------------------ time of day
// sunH = world-space sun direction y component
void timeFactors(float sunH, out float dayF, out float duskF, out float nightF) {
    dayF   = smoothstep(-0.05, 0.25, sunH);
    duskF  = exp(-pow(sunH * 5.0, 2.0));           // peaks exactly at sunrise/sunset
    nightF = 1.0 - smoothstep(-0.25, -0.02, sunH);
}

// ------------------------------------------------ lighting palettes
vec3 sunLightColor(float dayF, float duskF, float nightF, float rain) {
    vec3 day   = vec3(1.05, 1.00, 0.94);
    vec3 dusk  = vec3(1.30, 0.55, 0.26);   // golden/coral low sun
    vec3 night = vec3(0.20, 0.26, 0.45);   // cool moonlight
    vec3 c = mix(night, day, dayF);
    c = mix(c, dusk, duskF);
    return c * (1.0 - rain * 0.6);
}

vec3 ambientColor(float dayF, float duskF, float nightF, float rain) {
    vec3 day   = vec3(0.34, 0.44, 0.62);
    vec3 dusk  = vec3(0.30, 0.20, 0.47);   // violet-blue shadow fill
    vec3 night = vec3(0.055, 0.07, 0.145);
    vec3 c = mix(night, day, dayF);
    c = mix(c, dusk, duskF);
    return c * (1.0 - rain * 0.35);
}

vec3 blockLightColor() {
#ifdef BLOCKLIGHT_TINT
    return vec3(1.00, 0.60, 0.32);
#else
    return vec3(1.0);
#endif
}

// ------------------------------------------------ sky model
// Base gradient only (used for fog and reflections - cheap)
vec3 skyGradient(vec3 dir, vec3 sunDir, float dayF, float duskF, float nightF, float rain) {
    float y = clamp(dir.y, -1.0, 1.0);
    float horiz = exp(-max(y, 0.0) * 3.5);

    vec3 dayZen   = vec3(0.10, 0.28, 0.68);
    vec3 dayHor   = vec3(0.55, 0.74, 0.95);
    vec3 nightZen = vec3(0.008, 0.012, 0.038);
    vec3 nightHor = vec3(0.035, 0.045, 0.115);

    // Dusk horizon band rotates through violet -> pink -> gold toward the sun
    vec2 dxz = normalize(dir.xz + vec2(1e-4, 1e-4));
    vec2 sxz = normalize(sunDir.xz + vec2(1e-4, 1e-4));
    float toSun = dot(dxz, sxz) * 0.5 + 0.5;
    vec3 duskZen     = vec3(0.07, 0.045, 0.25);
    vec3 duskHorAway = vec3(0.34, 0.13, 0.60);  // violet
    vec3 duskHorMid  = vec3(0.96, 0.28, 0.55);  // magenta/pink
    vec3 duskHorSun  = vec3(1.00, 0.55, 0.18);  // gold/coral
    vec3 duskHor = mix(duskHorAway, duskHorMid, smoothstep(0.15, 0.55, toSun));
    duskHor = mix(duskHor, duskHorSun, smoothstep(0.55, 0.95, toSun));

    vec3 zen = mix(nightZen, dayZen, dayF);
    zen = mix(zen, duskZen, duskF);
    vec3 hor = mix(nightHor, dayHor, dayF);
    hor = mix(hor, duskHor, duskF);

    vec3 sky = mix(zen, hor, horiz);

    // Broad sun glow - strongest at dusk/dawn
    float sd = max(dot(dir, sunDir), 0.0);
    vec3 glowCol = mix(vec3(1.0, 0.95, 0.85), vec3(1.0, 0.45, 0.15), duskF);
    sky += glowCol * (pow(sd, 6.0) * 0.20 + pow(sd, 48.0) * 0.35) * (dayF * 0.7 + duskF * 1.5);

    // Moon glow
    float md = max(dot(dir, -sunDir), 0.0);
    sky += vec3(0.35, 0.45, 0.70) * pow(md, 32.0) * 0.10 * nightF;

    // Rain greys the sky out
    float gl = luma(sky);
    sky = mix(sky, vec3(gl) * vec3(0.75, 0.78, 0.85), rain * 0.75);
    return sky;
}

vec3 starField(vec3 dir, float nightF, float rain, float time) {
    if (nightF <= 0.001 || rain > 0.9) return vec3(0.0);
    vec3 p = dir * 180.0;
    vec3 id = floor(p);
    vec3 f = fract(p) - 0.5;
    float h = hash13(id);
    float star = step(0.982, h) * smoothstep(0.45, 0.0, length(f));
    float tw = 0.75 + 0.25 * sin(time * 2.0 + h * 40.0);
    vec3 col = mix(vec3(0.70, 0.80, 1.00), vec3(1.00, 0.85, 0.70), hash13(id + 7.0));
    return col * star * tw * nightF * (1.0 - rain) * STAR_BRIGHTNESS * 0.9;
}

vec4 cloudLayer(vec3 dir, vec3 sunDir, vec3 camPos, float dayF, float duskF, float nightF, float rain, float time) {
#if CLOUD_QUALITY == 0
    return vec4(0.0);
#else
    float cloudHeight = 260.0;
    float dist = (cloudHeight - camPos.y) / dir.y;
    if (dist < 0.0 || dist > 12000.0) return vec4(0.0);
    vec2 p = (camPos.xz + dir.xz * dist) * 0.0022;
    p += vec2(time * 0.008, time * 0.003);
#if CLOUD_QUALITY == 1
    float n = fbm2(p, 3);
#else
    float n = fbm2(p, 5);
#endif
    float edge = 0.35;
    float cov = smoothstep(1.0 - CLOUD_COVERAGE - edge, 1.0 - CLOUD_COVERAGE + edge, n);
    float fade = exp(-dist * 0.00028);
    float sunSide = dot(dir, sunDir) * 0.5 + 0.5;
    vec3 dayCloud   = mix(vec3(0.62, 0.68, 0.80), vec3(1.00, 0.98, 0.93), sunSide);
    vec3 duskCloud  = mix(vec3(0.38, 0.16, 0.52), vec3(1.00, 0.52, 0.32), sunSide);
    vec3 nightCloud = vec3(0.030, 0.038, 0.075);
    vec3 col = mix(nightCloud, dayCloud, dayF);
    col = mix(col, duskCloud, duskF);
    col = mix(col, vec3(0.30, 0.32, 0.38), rain * 0.8);
    float graze = smoothstep(0.0, 0.06, abs(dir.y));
    return vec4(col, cov * fade * graze * 0.85);
#endif
}

// Full sky: gradient + sun/moon discs + stars + procedural clouds
vec3 renderSky(vec3 dir, vec3 sunDir, vec3 camPos, float dayF, float duskF, float nightF, float rain, float time) {
    vec3 sky = skyGradient(dir, sunDir, dayF, duskF, nightF, rain);

    // Sun disc
    float sd = max(dot(dir, sunDir), 0.0);
    vec3 sunDiscCol = mix(vec3(1.0, 0.92, 0.72), vec3(1.0, 0.50, 0.18), duskF);
    sky += sunDiscCol * pow(sd, 1400.0) * 8.0 * (dayF + duskF);
    // Moon disc
    float md = max(dot(dir, -sunDir), 0.0);
    sky += vec3(0.80, 0.88, 1.0) * pow(md, 2500.0) * 2.0 * nightF;

    sky += starField(dir, nightF, rain, time);

    vec4 cl = cloudLayer(dir, sunDir, camPos, dayF, duskF, nightF, rain, time);
    sky = mix(sky, cl.rgb, cl.a);
    return sky;
}

// ------------------------------------------------ dimension skies
#ifdef DIM_NETHER
vec3 dimensionSky(vec3 dir) {
    float h = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);
    vec3 low = vec3(0.16, 0.055, 0.035);
    vec3 high = vec3(0.05, 0.018, 0.018);
    return mix(low, high, h);
}
#elif defined(DIM_END)
vec3 dimensionSky(vec3 dir) {
    float h = clamp(dir.y, 0.0, 1.0);
    vec3 low = vec3(0.030, 0.020, 0.055);
    vec3 high = vec3(0.008, 0.006, 0.020);
    vec3 sky = mix(low, high, h);
    // Slow violet nebula bands
    float band = sin(dir.x * 3.0 + dir.z * 2.0) * 0.5 + 0.5;
    sky += vec3(0.10, 0.04, 0.16) * pow(band, 3.0) * 0.6;
    sky += starField(dir, 1.0, 0.0, 0.0) * 0.8;
    return sky;
}
#endif

#endif // COMMON_GLSL
