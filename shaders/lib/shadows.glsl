#ifndef LIB_SHADOWS
#define LIB_SHADOWS

#include "/settings.glsl"
#include "/lib/common.glsl"
#include "/lib/noise.glsl"

uniform sampler2D shadowtex0;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

// Standard shadow-map distortion: more precision near the player
float distortFactor(vec3 clipPos) {
    return length(clipPos.xy) * 0.85 + 0.15;
}

// Returns lit amount 0..1. worldPos is camera-relative world space.
float shadowSample(vec3 worldPos, vec3 worldNormal, vec2 screenPos) {
#if SHADOW_QUALITY == 0
    return 1.0;
#else
    // Normal-offset bias removes acne on block faces
    vec3 offsetPos = worldPos + worldNormal * 0.08;
    vec4 shadowClip = shadowProjection * (shadowModelView * vec4(offsetPos, 1.0));
    shadowClip.xy /= distortFactor(shadowClip.xyz);
    vec3 proj = shadowClip.xyz * 0.5 + 0.5;
    if (proj.x < 0.0 || proj.x > 1.0 || proj.y < 0.0 || proj.y > 1.0 || proj.z > 1.0) return 1.0;

    float bias = 0.0012;
    // Rotate the poisson disk per pixel: breaks up banding/flicker
    float rot = hash12(screenPos) * 6.2831853;
    float cr = cos(rot);
    float sr = sin(rot);
    float radius = (SHADOW_QUALITY == 2) ? 1.5 : 1.0;
    vec2 ts = vec2(1.0) / float(SHADOW_RES) * radius;
    vec2 o0 = vec2( cr,  sr) * ts;
    vec2 o1 = vec2(-sr,  cr) * ts;
    vec2 o2 = vec2( cr, -sr) * ts;
    vec2 o3 = vec2(-sr, -cr) * ts;

    float s = 0.0;
    s += step(proj.z - bias, texture(shadowtex0, proj.xy + o0).r);
    s += step(proj.z - bias, texture(shadowtex0, proj.xy + o1).r);
    s += step(proj.z - bias, texture(shadowtex0, proj.xy + o2).r);
    s += step(proj.z - bias, texture(shadowtex0, proj.xy + o3).r);
    return s * 0.25;
#endif
}

#endif
