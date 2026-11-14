#include "/lib/lighting.glsl"

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 viewNormal;
varying vec3 viewPos;
varying float matFlag;

void main() {
    vec4 tex = texture2D(gtexture, texcoord) * gl_Color;
    if (tex.a < 0.05) discard;

    /* DRAWBUFFERS:01 */
    if (matFlag > 0.5) {
        // Water: store an ambient-lit base tint; the composite pass adds
        // reflections, fresnel and specular so ripples stay coherent.
        vec3 base = tex.rgb * (skyAmbient(sunHeight()) * 0.9 + 0.08);
        gl_FragData[0] = vec4(base, tex.a);
        gl_FragData[1] = vec4(1.0, 0.0, 0.0, 1.0);
    } else {
        // Other translucents (glass, ice, ...) get normal surface shading
        vec3 normalWorld = normalize(toMat3(gbufferModelViewInverse) * viewNormal);
        vec3 col = shadeSurface(tex.rgb, normalWorld, lmcoord, viewPos);
        gl_FragData[0] = vec4(col, tex.a);
        gl_FragData[1] = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
