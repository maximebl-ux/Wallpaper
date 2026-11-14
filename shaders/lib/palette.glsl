#ifndef LIB_PALETTE
#define LIB_PALETTE

// ============================================================
//  Time-of-day palette, referencing a Hong Kong neon skyline:
//  deep indigo zenith, magenta mid-sky, coral/gold horizon.
//  h = sun height in world space (-1 .. 1)
// ============================================================

float dayAmt(float h)   { return smoothstep(0.03, 0.28, h); }
float nightAmt(float h) { return smoothstep(0.03, 0.28, -h); }
float duskAmt(float h)  { return clamp(1.0 - dayAmt(h) - nightAmt(h), 0.0, 1.0); }

vec3 sunLightColor(float h) {
    vec3 day   = vec3(1.00, 0.97, 0.90) * 1.15;
    vec3 dusk  = vec3(1.10, 0.55, 0.35);            // golden coral low sun
    vec3 night = vec3(0.26, 0.32, 0.50) * 0.40;     // cool faint moonlight
    return day * dayAmt(h) + dusk * duskAmt(h) + night * nightAmt(h);
}

vec3 skyAmbient(float h) {
    vec3 day   = vec3(0.52, 0.63, 0.82);
    vec3 dusk  = vec3(0.34, 0.26, 0.50);            // violet-blue shadow fill
    vec3 night = vec3(0.10, 0.11, 0.20);
    return day * dayAmt(h) + dusk * duskAmt(h) + night * nightAmt(h);
}

vec3 skyZenith(float h) {
    vec3 day   = vec3(0.16, 0.36, 0.78);
    vec3 dusk  = vec3(0.09, 0.07, 0.27);            // deep indigo
    vec3 night = vec3(0.012, 0.016, 0.045);
    return day * dayAmt(h) + dusk * duskAmt(h) + night * nightAmt(h);
}

vec3 skyMid(float h) {
    vec3 day   = vec3(0.42, 0.62, 0.92);
    vec3 dusk  = vec3(0.72, 0.18, 0.48);            // magenta band
    vec3 night = vec3(0.030, 0.040, 0.100);
    return day * dayAmt(h) + dusk * duskAmt(h) + night * nightAmt(h);
}

vec3 skyHorizon(float h) {
    vec3 day   = vec3(0.72, 0.82, 0.94);
    vec3 dusk  = vec3(1.05, 0.52, 0.30);            // coral into bright gold
    vec3 night = vec3(0.055, 0.065, 0.140);
    return day * dayAmt(h) + dusk * duskAmt(h) + night * nightAmt(h);
}

// Warm tint applied to actual block-light data (not texture emissiveness)
vec3 torchColor() { return vec3(1.00, 0.56, 0.30); }

#endif
