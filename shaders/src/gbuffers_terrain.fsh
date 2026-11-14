#include "/lib/lighting.glsl"

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 viewNormal;
varying vec3 viewPos;

void main() {
    vec4 tex = texture2D(gtexture, texcoord) * gl_Color;

#if !defined(TERRAIN_SOLID)
    // Cutout / mixed: keep the alpha test for leaves, grass, glass panes
    if (tex.a < 0.1) discard;
#endif

    vec3 normalWorld = normalize(toMat3(gbufferModelViewInverse) * viewNormal);
    vec3 col = shadeSurface(tex.rgb, normalWorld, lmcoord, viewPos);

    /* DRAWBUFFERS:0 */
#if defined(TERRAIN_SOLID)
    // Solid terrain is always opaque; forcing alpha keeps it visible even if
    // the sampled alpha channel is unreliable on some loader versions
    gl_FragData[0] = vec4(col, 1.0);
#else
    gl_FragData[0] = vec4(col, tex.a);
#endif
}
