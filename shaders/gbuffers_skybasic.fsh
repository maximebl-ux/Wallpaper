#version 330 compatibility

#include "/lib/common.glsl"
#include "/lib/noise.glsl"
#include "/lib/palette.glsl"
#include "/lib/sky.glsl"
#include "/settings.glsl"

uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform float frameTimeCounter;

in vec3 rayDir;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec3 rayWorld = normalize(toMat3(gbufferModelViewInverse) * rayDir);
    vec3 sunDir = normalize(toMat3(gbufferModelViewInverse) * normalize(sunPosition));
    float h = sunDir.y;

    vec3 col = renderSky(rayWorld, sunDir, h);

    // Stars fade in with night and only above the horizon
    if (rayWorld.y > 0.0) {
        col += vec3(0.90, 0.95, 1.10) * starField(rayWorld, frameTimeCounter)
             * nightAmt(h) * STAR_BRIGHTNESS;
    }

    fragColor = vec4(col, 1.0);
}
