#ifndef LIB_SKY
#define LIB_SKY

#include "/lib/common.glsl"
#include "/lib/noise.glsl"
#include "/lib/palette.glsl"
#include "/settings.glsl"

// Procedural sky gradient; ray and sunDir are world-space unit vectors
vec3 renderSky(vec3 ray, vec3 sunDir, float h) {
    float t = clamp(ray.y, 0.0, 1.0);
    vec3 col = mix(skyHorizon(h), skyMid(h), pow(t, 0.45));
    col = mix(col, skyZenith(h), pow(t, 1.5));

    // Warm glow around the sun; strongest at dawn/dusk
    float sd = max(dot(ray, sunDir), 0.0);
    vec3 glowCol = mix(vec3(1.00, 0.45, 0.20), vec3(1.00, 0.85, 0.55), clamp(h * 3.0, 0.0, 1.0));
    col += glowCol * pow(sd, 6.0) * (0.30 + 1.50 * duskAmt(h));

    // Subtle violet back-scatter opposite the low sun
    col += vec3(0.20, 0.10, 0.35) * pow(max(dot(ray, -sunDir), 0.0), 3.0) * duskAmt(h) * 0.35;

    // Below the horizon fade toward a darker ground haze
    col *= mix(1.0, 0.55, clamp(-ray.y * 3.0, 0.0, 1.0));
    return col;
}

// Sparse procedural stars; quantize the ray onto a sphere grid
float starField(vec3 ray, float time) {
    vec3 p = ray * 180.0;
    vec3 i = floor(p);
    float hsh = hash13(i);
    float star = step(0.9965, hsh);
    vec3 f = fract(p) - 0.5;
    star *= smoothstep(0.35, 0.05, length(f));
    star *= 0.75 + 0.25 * sin(time * 2.0 + hsh * 40.0);   // twinkle
    return star;
}

#endif
