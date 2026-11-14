#version 330 compatibility

uniform sampler2D gtexture;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 tex = texture(gtexture, texcoord) * gl_Color;
    if (tex.a < 0.01) discard;

    fragColor = vec4(tex.rgb * 1.15, tex.a * 0.8);
}
