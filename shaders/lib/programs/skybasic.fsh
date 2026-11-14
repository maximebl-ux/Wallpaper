#include "/lib/settings.glsl"
#include "/lib/common.glsl"

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform vec3 cameraPosition;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform float rainStrength;

/* DRAWBUFFERS:01 */
void main() {
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    vec4 clip = vec4(uv, 1.0, 1.0) * 2.0 - 1.0;
    vec3 viewDir = normalize((gbufferProjectionInverse * clip).xyz);
    vec3 worldDir = normalize(mat3(gbufferModelViewInverse) * viewDir);

    vec3 sunDirW = normalize(mat3(gbufferModelViewInverse) * normalize(sunPosition));
    float dayF, duskF, nightF;
    timeFactors(sunDirW.y, dayF, duskF, nightF);

#ifdef DIM_NETHER
    vec3 sky = dimensionSky(worldDir);
#elif defined(DIM_END)
    vec3 sky = dimensionSky(worldDir);
#else
    vec3 sky = renderSky(worldDir, sunDirW, cameraPosition, dayF, duskF, nightF, rainStrength, frameTimeCounter);
#endif

    gl_FragData[0] = vec4(sky, 1.0);
    gl_FragData[1] = vec4(0.5, 0.5, 1.0, 1.0);
}
