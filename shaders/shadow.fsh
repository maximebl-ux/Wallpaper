#version 330 compatibility

uniform sampler2D gtexture;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 c = texture(gtexture, texcoord);
    if (c.a < 0.1) discard;

    fragColor = c;
}
