// Solid + cutout terrain. Waving leaves and plants.
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform float rainStrength;

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

    float id = mc_Entity.x;
    materialId = 0.0;
    float wave = 0.0;
    if (id == 10002.0) {
        wave = 1.0;
        materialId = 0.25;
    } else if (id == 10003.0) {
        // Only the top vertices of short plants wave
        if (gl_MultiTexCoord0.t < mc_midTexCoord.t) wave = 0.6;
    }
    if (wave > 0.0) {
        vec2 wp = worldPos.xz + worldPos.y * 0.25;
        float sway = sin(frameTimeCounter * 1.4 + wp.x * 0.8 + wp.y * 0.6)
                   + sin(frameTimeCounter * 0.9 + wp.x * 0.35 - wp.y * 0.9) * 0.6;
        float amp = 0.022 * wave * (1.0 + rainStrength * 1.5);
        worldPos.xz += vec2(sway, sway * 0.8) * amp;
    }

    worldPosRel = worldPos - cameraPosition;
    viewPos = gbufferModelView * vec4(worldPosRel, 1.0);
    gl_Position = gl_ProjectionMatrix * viewPos;
}
