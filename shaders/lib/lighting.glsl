#ifndef LIB_LIGHTING
#define LIB_LIGHTING

#include "/settings.glsl"
#include "/lib/common.glsl"
#include "/lib/noise.glsl"
#include "/lib/palette.glsl"
#include "/lib/shadows.glsl"

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform vec3 shadowLightPosition;

vec3 worldSunDir() {
    return normalize(toMat3(gbufferModelViewInverse) * normalize(sunPosition));
}

float sunHeight() {
    return worldSunDir().y;
}

// Direction of the current dominant light (sun by day, moon by night)
vec3 worldLightDir() {
    return normalize(toMat3(gbufferModelViewInverse) * normalize(shadowLightPosition));
}

// Full surface shading: direct sun/moon + sky ambient + block light
vec3 shadeSurface(vec3 albedo, vec3 normalWorld, vec2 lm, vec3 viewPos) {
    float block = lm.x;
    float sky = lm.y;
#if defined(DIM_NETHER)
    // Nether: no sun or shadows; deep warm ambient driven by block light
    vec3 ambient = vec3(0.30, 0.16, 0.12) * (0.35 + 0.65 * block)
                 + vec3(0.16, 0.08, 0.10);
    vec3 torch = torchColor() * (block * block) * 1.4;
    return albedo * (ambient + torch);
#elif defined(DIM_END)
    // End: cool violet ambient, no directional light
    vec3 ambient = vec3(0.34, 0.28, 0.46) * (0.40 + 0.60 * sky);
    vec3 torch = torchColor() * (block * block) * 1.2;
    return albedo * (ambient + torch);
#else
    float h = sunHeight();
    vec3 lightDir = worldLightDir();

    float ndl = max(dot(normalWorld, lightDir), 0.0);
    vec3 worldPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
    float shadow = shadowSample(worldPos, normalWorld, gl_FragCoord.xy);

    // Fade shadows out as the light grazes/below the horizon
    shadow *= smoothstep(-0.06, 0.06, lightDir.y);
    // Moon shadows are much fainter than sun shadows
    shadow = mix(shadow, min(shadow * 0.5 + 0.5, 1.0), nightAmt(h));

    vec3 direct = sunLightColor(h) * ndl * shadow * smoothstep(0.55, 0.95, sky);
    vec3 ambient = skyAmbient(h) * mix(0.12, 1.0, sky * sky);
    vec3 torch = torchColor() * (block * block) * 1.6;
    return albedo * (direct + ambient + torch);
#endif
}

// Cheap shading for particles and other unlit-by-shadow surfaces
vec3 shadeSimple(vec3 albedo, vec2 lm) {
#if defined(DIM_NETHER)
    return albedo * (vec3(0.35, 0.20, 0.16) * (0.30 + 0.70 * lm.x)
           + torchColor() * (lm.x * lm.x) * 1.3);
#elif defined(DIM_END)
    return albedo * (vec3(0.34, 0.28, 0.46) * (0.40 + 0.60 * lm.y)
           + torchColor() * (lm.x * lm.x) * 1.2);
#else
    float h = sunHeight();
    vec3 amb = skyAmbient(h) * mix(0.15, 1.0, lm.y * lm.y);
    vec3 torch = torchColor() * (lm.x * lm.x) * 1.5;
    vec3 sun = sunLightColor(h) * 0.15 * lm.y;
    return albedo * (amb + torch + sun);
#endif
}

#endif
