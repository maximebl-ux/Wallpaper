// Particles and other textured, unlit-ish geometry.
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out vec3 worldNormal;
out vec3 worldPosRel;
out float materialId;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor  = gl_Color;
    worldNormal = mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal);

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    worldPosRel = (gbufferModelViewInverse * viewPos).xyz;
    gl_Position = gl_ProjectionMatrix * viewPos;
    materialId = 0.0;
}
