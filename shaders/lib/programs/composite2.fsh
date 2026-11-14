// Vertical blur of the bloom buffer.
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

uniform sampler2D colortex3;
uniform float viewHeight;

in vec2 uv;

/* DRAWBUFFERS:3 */
void main() {
    float texel = 1.5 / (viewHeight * 0.25);
    vec3 blur = texture(colortex3, uv).rgb * 0.4;
    blur += texture(colortex3, uv + vec2(0.0, texel * 1.0)).rgb * 0.15;
    blur += texture(colortex3, uv - vec2(0.0, texel * 1.0)).rgb * 0.15;
    blur += texture(colortex3, uv + vec2(0.0, texel * 2.4)).rgb * 0.075;
    blur += texture(colortex3, uv - vec2(0.0, texel * 2.4)).rgb * 0.075;

    gl_FragData[0] = vec4(blur, 1.0);
}
