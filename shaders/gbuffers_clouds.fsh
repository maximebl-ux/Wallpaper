#version 120

#include "/lib/common.glsl"
#include "/lib/palette.glsl"

uniform sampler2D texture;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;

varying vec2 texcoord;

void main() {
    vec4 tex = texture2D(texture, texcoord) * gl_Color;
    if (tex.a < 0.01) discard;

    float h = normalize(toMat3(gbufferModelViewInverse) * normalize(sunPosition)).y;
    // Clouds catch the coral/pink band while the sun is low
    vec3 tint = mix(vec3(1.0), skyHorizon(h) * 1.4, duskAmt(h));
    tint = mix(vec3(0.55, 0.60, 0.80), tint, dayAmt(h) + duskAmt(h));

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(tex.rgb * tint, tex.a * 0.9);
}
