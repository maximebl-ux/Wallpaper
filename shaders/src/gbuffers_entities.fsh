#include "/lib/lighting.glsl"

uniform vec4 entityColor;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 viewNormal;
varying vec3 viewPos;

void main() {
    vec4 tex = texture2D(texture, texcoord) * gl_Color;
    if (tex.a < 0.1) discard;

    // Hurt/flash overlay from vanilla
    tex.rgb = mix(tex.rgb, entityColor.rgb, entityColor.a);

    vec3 normalWorld = normalize(toMat3(gbufferModelViewInverse) * viewNormal);
    vec3 col = shadeSurface(tex.rgb, normalWorld, lmcoord, viewPos);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(col, tex.a);
}
