#include "/lib/settings.glsl"

in vec4 glcolor;
in vec2 lmcoord;

/* DRAWBUFFERS:012 */
void main() {
    gl_FragData[0] = vec4(glcolor.rgb, 1.0);
    gl_FragData[1] = vec4(0.5, 0.5, 1.0, 1.0);
    gl_FragData[2] = vec4(lmcoord, 0.0, 1.0);
}
