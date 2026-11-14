#include "/lib/lighting.glsl"

in vec2 texcoord;
in vec2 lmcoord;
in vec3 viewNormal;
in vec3 viewPos;

uniform float alphaTestRef = 0.1;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 tex = texture(gtexture, texcoord) * gl_Color;

#if !defined(TERRAIN_SOLID)
    // Cutout / mixed: alpha test for leaves, grass, glass panes
    if (tex.a < alphaTestRef) discard;
#endif

    vec3 normalWorld = normalize(toMat3(gbufferModelViewInverse) * viewNormal);
    vec3 col = shadeSurface(tex.rgb, normalWorld, lmcoord, viewPos);

    // Opaque output must carry alpha 1.0, otherwise the write can be
    // blended away or dropped entirely by the driver
    fragColor = vec4(col, 1.0);
}
