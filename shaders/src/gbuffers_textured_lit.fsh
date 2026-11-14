#include "/lib/lighting.glsl"

in vec2 texcoord;
in vec2 lmcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 tex = texture(gtexture, texcoord) * gl_Color;
    if (tex.a < 0.1) discard;

    vec3 col = shadeSimple(tex.rgb, lmcoord);

    fragColor = vec4(col, tex.a);
}
