#include "/lib/lighting.glsl"

in vec2 texcoord;
in vec2 lmcoord;
in vec3 viewNormal;
in vec3 viewPos;
in float matFlag;

uniform float alphaTestRef = 0.1;

/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 dataOut;

void main() {
    vec4 tex = texture(gtexture, texcoord) * gl_Color;
    if (tex.a < 0.05) discard;

    if (matFlag > 0.5) {
        // Water: store an ambient-lit base tint; the composite pass adds
        // reflections, fresnel and specular so ripples stay coherent.
        vec3 base = tex.rgb * (skyAmbient(sunHeight()) * 0.9 + 0.08);
        fragColor = vec4(base, tex.a);
        dataOut = vec4(1.0, 0.0, 0.0, 1.0);
    } else {
        // Other translucents (glass, ice, ...) get normal surface shading
        if (tex.a < alphaTestRef) discard;
        vec3 normalWorld = normalize(toMat3(gbufferModelViewInverse) * viewNormal);
        vec3 col = shadeSurface(tex.rgb, normalWorld, lmcoord, viewPos);
        fragColor = vec4(col, tex.a);
        dataOut = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
