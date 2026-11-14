#include "/lib/lighting.glsl"

uniform vec4 entityColor;

in vec2 texcoord;
in vec2 lmcoord;
in vec3 viewNormal;
in vec3 viewPos;

uniform float alphaTestRef = 0.1;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 tex = texture(gtexture, texcoord) * gl_Color;
    if (tex.a < alphaTestRef) discard;

    // Hurt/flash overlay from vanilla
    tex.rgb = mix(tex.rgb, entityColor.rgb, entityColor.a);

    vec3 normalWorld = normalize(toMat3(gbufferModelViewInverse) * viewNormal);
    vec3 col = shadeSurface(tex.rgb, normalWorld, lmcoord, viewPos);

    fragColor = vec4(col, tex.a);
}
