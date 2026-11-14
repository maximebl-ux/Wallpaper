#version 120

#include "/settings.glsl"

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

varying vec2 texcoord;

// Soft-knee bright pass
vec3 brightAt(vec2 uv) {
    vec3 c = texture2D(colortex0, uv).rgb;
    float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
    return c * smoothstep(0.70, 1.50, lum);
}

void main() {
    vec2 px = vec2(1.0 / viewWidth, 0.0) * 2.0;
    vec3 sum = brightAt(texcoord) * 0.2270270;
    sum += (brightAt(texcoord + px * 1.3846154) + brightAt(texcoord - px * 1.3846154)) * 0.3162162;
    sum += (brightAt(texcoord + px * 3.2307692) + brightAt(texcoord - px * 3.2307692)) * 0.0702703;

    /* DRAWBUFFERS:2 */
    gl_FragData[0] = vec4(sum, 1.0);
}
