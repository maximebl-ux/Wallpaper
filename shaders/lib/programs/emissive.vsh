// Fullbright emissive geometry (beacon beams, spider eyes).
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out vec3 worldNormal;
out vec3 worldPosRel;
out float materialId;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = vec2(1.0);
    glcolor  = gl_Color;
    worldNormal = vec3(0.0, 1.0, 0.0);

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    worldPosRel = vec3(0.0);
    gl_Position = gl_ProjectionMatrix * viewPos;
    materialId = 1.0;
}
