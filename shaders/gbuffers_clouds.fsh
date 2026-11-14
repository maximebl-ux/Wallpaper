#version 330 compatibility

#include "/lib/common.glsl"
#include "/lib/palette.glsl"

uniform sampler2D gtexture;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 tex = texture(gtexture, texcoord) * gl_Color;
    if (tex.a < 0.01) discard;

    float h = normalize(toMat3(gbufferModelViewInverse) * normalize(sunPosition)).y;
    // Clouds catch the coral/pink band while the sun is low
    vec3 tint = mix(vec3(1.0), skyHorizon(h) * 1.4, duskAmt(h));
    tint = mix(vec3(0.55, 0.60, 0.80), tint, dayAmt(h) + duskAmt(h));

    fragColor = vec4(tex.rgb * tint, tex.a * 0.9);
}
