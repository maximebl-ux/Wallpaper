#include "/lib/lighting.glsl"

in vec2 texcoord;
in vec3 rayDir;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 tex = texture(gtexture, texcoord) * gl_Color;

    vec3 rayWorld = normalize(toMat3(gbufferModelViewInverse) * rayDir);
    vec3 sunDir = worldSunDir();
    float h = sunDir.y;

#if defined(DIM_END)
    // End sky texture: dim and shift toward violet
    vec3 col = tex.rgb * vec3(0.55, 0.45, 0.75);
#else
    // Sun and moon quads: pick tint by alignment with the sun direction
    float align = dot(rayWorld, sunDir);
    float sunW = smoothstep(0.995, 0.9999, align);
    vec3 sunTint = mix(vec3(1.15, 0.55, 0.30), vec3(1.10, 1.02, 0.90), dayAmt(h));
    vec3 moonTint = vec3(0.85, 0.90, 1.05);
    vec3 col = tex.rgb * mix(moonTint, sunTint, sunW) * 1.3;
#endif

    fragColor = vec4(col, tex.a);
}
