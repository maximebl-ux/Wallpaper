#version 330 compatibility

#include "/settings.glsl"
#include "/lib/noise.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

layout(location = 0) out vec4 fragColor;

void main() {
    vec3 c = texture(colortex0, texcoord).rgb;

#if BLOOM == 1
    c += texture(colortex3, texcoord).rgb * BLOOM_STRENGTH;
#endif

    c *= EXPOSURE;

    // ACES filmic approximation (Narkowicz) keeps highlights controlled
    c = clamp((c * (2.51 * c + 0.03)) / (c * (2.43 * c + 0.59) + 0.14), 0.0, 1.0);

    // Gentle color grade
    float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
    c = mix(vec3(lum), c, SATURATION);
    c = clamp((c - 0.5) * CONTRAST + 0.5, 0.0, 1.0);

#if VIGNETTE == 1
    vec2 q = texcoord - 0.5;
    c *= 1.0 - dot(q, q) * 0.55;
#endif

    // Fine dithering removes gradient banding
    c += (hash12(gl_FragCoord.xy) - 0.5) / 255.0;

    fragColor = vec4(c, 1.0);
}
