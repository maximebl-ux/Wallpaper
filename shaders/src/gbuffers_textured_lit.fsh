#include "/lib/lighting.glsl"

varying vec2 texcoord;
varying vec2 lmcoord;

void main() {
    vec4 tex = texture2D(texture, texcoord) * gl_Color;
    if (tex.a < 0.1) discard;

    vec3 col = shadeSimple(tex.rgb, lmcoord);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(col, tex.a);
}
