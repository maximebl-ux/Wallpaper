// Writes albedo, encoded normal + material id, and lightmap for deferred lighting.
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

uniform sampler2D gtexture;
uniform mat4 gbufferModelView;
uniform float alphaTestRef;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
in vec3 worldNormal;
in vec3 worldPosRel;
in float materialId;

/* DRAWBUFFERS:012 */
void main() {
    vec4 color = texture(gtexture, texcoord);
    if (color.a < alphaTestRef) discard;

    vec3 viewNormal = normalize(mat3(gbufferModelView) * worldNormal);

    gl_FragData[0] = vec4(color.rgb * glcolor.rgb, 1.0);
    gl_FragData[1] = vec4(encodeNormal(viewNormal), 1.0);
    gl_FragData[2] = vec4(lmcoord, materialId, 1.0);
}
