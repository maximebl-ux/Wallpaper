#include "/lib/settings.glsl"
#include "/lib/common.glsl"

uniform sampler2D gtexture;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
in vec3 worldNormal;
in vec3 worldPosRel;
in float materialId;

/* DRAWBUFFERS:012 */
void main() {
    vec4 color = texture(gtexture, texcoord);
    if (color.a < 0.01) discard;

    gl_FragData[0] = vec4(color.rgb * glcolor.rgb, 1.0);
    gl_FragData[1] = vec4(0.5, 0.5, 1.0, 1.0);
    gl_FragData[2] = vec4(1.0, materialId, 1.0);
}
