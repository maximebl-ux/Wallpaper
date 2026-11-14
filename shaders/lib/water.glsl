#ifndef LIB_WATER
#define LIB_WATER

#include "/settings.glsl"
#include "/lib/common.glsl"
#include "/lib/noise.glsl"
#include "/lib/palette.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform int isEyeInWater;

vec3 worldSunDirW() {
    return normalize(toMat3(gbufferModelViewInverse) * normalize(sunPosition));
}

vec3 worldLightDirW() {
    return normalize(toMat3(gbufferModelViewInverse) * normalize(shadowLightPosition));
}

vec3 toView(vec2 uv, float depth) {
    vec4 clip = vec4(uv, depth, 1.0) * 2.0 - 1.0;
    vec4 v = gbufferProjectionInverse * clip;
    return v.xyz / v.w;
}

vec2 toScreen(vec3 vp) {
    vec4 clip = gbufferProjection * vec4(vp, 1.0);
    return (clip.xyz / clip.w).xy * 0.5 + 0.5;
}

// Sum of two drifting noise octaves = gentle animated ripple height
float waveH(vec2 p, float t) {
    return vnoise(p * 0.85 + vec2(t * 0.50, t * 0.25)) * 0.65
         + vnoise(p * 2.10 - vec2(t * 0.35, t * 0.60)) * 0.35;
}

// Animated world-space water normal from a finite-difference gradient
vec3 waterNormal(vec2 worldXZ) {
    float t = frameTimeCounter * 0.5;
    float e = 0.12;
    float h0 = waveH(worldXZ, t);
    float hx = waveH(worldXZ + vec2(e, 0.0), t);
    float hy = waveH(worldXZ + vec2(0.0, e), t);
    vec2 g = vec2(hx - h0, hy - h0) / e;
    float amp = 0.05 * RIPPLE_HEIGHT;
    return normalize(vec3(-g.x * amp, 1.0, -g.y * amp));
}

// March the reflected ray through the opaque depth buffer.
// hitUv receives the hit screen position; returns hit color (unmodified if miss).
vec3 ssrReflection(vec3 viewPos, vec3 viewNormal, inout vec2 hitUv, out float hitW) {
    hitW = 0.0;
    vec3 rayDir = normalize(reflect(normalize(viewPos), viewNormal));
    vec3 color = vec3(0.0);
#if SSR_STEPS > 0
    vec3 p = viewPos + rayDir * 0.35;
    float ls = 0.35;
    for (int i = 0; i < SSR_STEPS; i++) {
        vec2 uv = toScreen(p);
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) break;
        float d1 = texture(depthtex1, uv).r;
        if (d1 < 1.0) {
            vec3 scene = toView(uv, d1);
            if (p.z < scene.z) {
                // Refine with a short binary search for a crisper hit
                vec3 lo = p - rayDir * ls;
                vec3 hi = p;
#if SSR_REFINE == 1
                for (int j = 0; j < 4; j++) {
                    vec3 mid = (lo + hi) * 0.5;
                    vec2 muv = toScreen(mid);
                    float md = texture(depthtex1, muv).r;
                    if (mid.z < toView(muv, md).z) hi = mid; else lo = mid;
                }
                p = (lo + hi) * 0.5;
                uv = toScreen(p);
#endif
                color = texture(colortex0, uv).rgb;
                hitUv = uv;
                // Fade hits near screen borders so reflections do not snap
                float b = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
                hitW = clamp(b * 12.0, 0.0, 1.0);
                break;
            }
        }
        ls *= 1.35;   // growing step length: fine detail near, reach far
        p += rayDir * ls;
    }
#endif
    return color;
}

#endif
