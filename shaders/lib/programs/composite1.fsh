// Bright pass + horizontal blur into the quarter-res bloom buffer.
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform float viewWidth;

in vec2 uv;

vec3 brightPass(vec2 u) {
    vec3 c = texture(colortex0, u).rgb;
    float l = luma(c);
    // Soft threshold so highlights roll into bloom instead of clipping
    return c * clamp((l - BLOOM_THRESHOLD) / 0.35, 0.0, 1.0);
}

/* DRAWBUFFERS:3 */
void main() {
    float texel = 1.5 / (viewWidth * 0.25);
    vec3 blur = brightPass(uv) * 0.4;
    blur += brightPass(uv + vec2(texel * 1.0, 0.0)) * 0.15;
    blur += brightPass(uv - vec2(texel * 1.0, 0.0)) * 0.15;
    blur += brightPass(uv + vec2(texel * 2.4, 0.0)) * 0.075;
    blur += brightPass(uv - vec2(texel * 2.4, 0.0)) * 0.075;

    gl_FragData[0] = vec4(blur, 1.0);
}
