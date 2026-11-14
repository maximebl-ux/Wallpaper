#include "/lib/settings.glsl"

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 glcolor;

/* DRAWBUFFERS:01 */
void main() {
    vec4 color = texture(gtexture, texcoord) * glcolor;
    if (color.a < 0.01) discard;
    gl_FragData[0] = vec4(color.rgb, 1.0);
    gl_FragData[1] = vec4(0.5, 0.5, 1.0, 1.0);
}
