#version 330 compatibility

uniform sampler2D gtexture;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 tex = texture(gtexture, texcoord) * gl_Color;
    // Fullbright emissive; bloom picks it up naturally
    fragColor = vec4(tex.rgb * 2.2, tex.a);
}
