#version 120

uniform sampler2D gtexture;

varying vec2 texcoord;

void main() {
    vec4 c = texture2D(gtexture, texcoord);
    if (c.a < 0.1) discard;

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = c;
}
