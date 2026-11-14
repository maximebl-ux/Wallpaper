// Translucent terrain: water, glass, ice. Water gets vertex waves.
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

attribute vec4 mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

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
    vec3 worldPos = (gbufferModelViewInverse * viewPos).xyz + cameraPosition;

    materialId = 0.0;
    if (mc_Entity.x == 10001.0 && worldNormal.y > 0.5) {
        materialId = 0.75;
        float t = frameTimeCounter * WATER_WAVE_SPEED;
        float w = sin(worldPos.x * 0.9 + t * 1.6) * cos(worldPos.z * 0.8 + t * 1.2)
                + 0.5 * sin((worldPos.x + worldPos.z) * 0.5 + t * 2.0);
        worldPos.y += w * 0.03 * WATER_WAVE_SIZE;
    }

    worldPosRel = worldPos - cameraPosition;
    viewPos = gbufferModelView * vec4(worldPosRel, 1.0);
    gl_Position = gl_ProjectionMatrix * viewPos;
}
