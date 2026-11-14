#version 330 compatibility

uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS: 3 */
layout(location = 0) out vec4 fragColor;

void main() {
    // Vertical half of the separable gaussian blur
    vec2 px = vec2(0.0, 1.0 / viewHeight) * 2.0;
    vec3 sum = texture(colortex2, texcoord).rgb * 0.2270270;
    sum += (texture(colortex2, texcoord + px * 1.3846154).rgb
          + texture(colortex2, texcoord - px * 1.3846154).rgb) * 0.3162162;
    sum += (texture(colortex2, texcoord + px * 3.2307692).rgb
          + texture(colortex2, texcoord - px * 3.2307692).rgb) * 0.0702703;

    fragColor = vec4(sum, 1.0);
}
