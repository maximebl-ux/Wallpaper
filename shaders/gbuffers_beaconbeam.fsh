#version 120

uniform sampler2D gtexture;

varying vec2 texcoord;

void main() {
    vec4 tex = texture2D(gtexture, texcoord) * gl_Color;
    // Fullbright emissive; bloom picks it up naturally
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(tex.rgb * 2.2, tex.a);
}
