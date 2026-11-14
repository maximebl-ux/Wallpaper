#version 120

uniform sampler2D gtexture;

varying vec2 texcoord;

void main() {
    vec4 tex = texture2D(gtexture, texcoord) * gl_Color;
    if (tex.a < 0.01) discard;

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(tex.rgb * 1.15, tex.a * 0.8);
}
