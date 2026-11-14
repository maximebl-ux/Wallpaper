// Bloom combine + tonemap + grade. Writes straight to the screen.
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex3;

in vec2 uv;

void main() {
    vec3 color = texture(colortex0, uv).rgb;

#ifdef BLOOM
    color += texture(colortex3, uv).rgb * BLOOM_STRENGTH;
#endif

    color = tonemapACES(color);

    float l = luma(color);
    color = mix(vec3(l), color, SATURATION);
    color = clamp((color - 0.5) * CONTRAST + 0.5, 0.0, 1.0);

#ifdef DITHERING
    color += (hash12(gl_FragCoord.xy) - 0.5) / 255.0;
#endif

    gl_FragData[0] = vec4(color, 1.0);
}
