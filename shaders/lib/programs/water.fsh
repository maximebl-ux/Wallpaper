// Translucents refract the opaque scene handed over by the deferred
// pass (colortex4). Water additionally stores a rippled normal so
// composite can add reflections and sun glint.
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

uniform sampler2D gtexture;
uniform sampler2D colortex4;
uniform mat4 gbufferModelView;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
in vec3 worldNormal;
in vec3 worldPosRel;
in float materialId;

float waterHeight(vec2 p, float t) {
    float h = sin(p.x * 1.1 + t * 1.5) * cos(p.y * 0.9 + t * 1.1) * 0.5;
    h += valueNoise2D(p * 0.9 + vec2(t * 0.35, -t * 0.25)) * 0.7;
    h += valueNoise2D(p * 2.1 - vec2(t * 0.5, t * 0.4)) * 0.3;
    return h;
}

/* DRAWBUFFERS:012 */
void main() {
    vec4 color = texture(gtexture, texcoord);
    if (color.a < 0.01) discard;

    vec2 screenUv = clamp(gl_FragCoord.xy / vec2(viewWidth, viewHeight), vec2(0.001), vec2(0.999));
    vec3 bg = texture(colortex4, screenUv).rgb;
    vec3 tint = color.rgb * glcolor.rgb;

    vec3 surface;
    float mat = 0.0;
    if (materialId > 0.5) {
        mat = 1.0;
        surface = mix(bg, bg * tint * 1.7, 0.55);
    } else {
        surface = mix(bg, tint, color.a * 0.9);
    }

    vec3 wn = normalize(worldNormal);
    if (materialId > 0.5) {
        // Ripple normal from an animated height field
        float t = frameTimeCounter * WATER_WAVE_SPEED;
        float e = 0.06;
        float h0 = waterHeight(worldPosRel.xz + cameraPosition.xz, t);
        float hx = waterHeight(worldPosRel.xz + cameraPosition.xz + vec2(e, 0.0), t);
        float hz = waterHeight(worldPosRel.xz + cameraPosition.xz + vec2(0.0, e), t);
        wn = normalize(vec3((h0 - hx) / e * WATER_WAVE_SIZE * 0.35, 1.0, (h0 - hz) / e * WATER_WAVE_SIZE * 0.35));
    }
    vec3 viewNormal = normalize(mat3(gbufferModelView) * wn);

    gl_FragData[0] = vec4(surface, 1.0);
    gl_FragData[1] = vec4(encodeNormal(viewNormal), 1.0);
    gl_FragData[2] = vec4(lmcoord, mat, 1.0);
}
