#include "/lib/settings.glsl"
#include "/lib/common.glsl"

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 glcolor;

/* DRAWBUFFERS:0 */
void main() {
    vec4 color = texture(gtexture, texcoord) * glcolor;
    if (color.a < 0.1) discard;
    // RGB tints light that passes through translucents; alpha marks casters
    gl_FragData[0] = vec4(color.rgb, color.a);
}
