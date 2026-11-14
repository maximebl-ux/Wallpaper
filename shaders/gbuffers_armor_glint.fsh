#version 120

uniform sampler2D gtexture;

varying vec2 texcoord;

void main() {
    vec4 tex = texture2D(gtexture, texcoord) * gl_Color;
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = tex;
}
