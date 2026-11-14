// Copies the opaque scene into colortex4 so translucent gbuffers
// programs can refract it. colortex0-3 cannot be read from gbuffers
// programs (they sample the atlas instead), so this hand-off pass is
// required for water refraction.
#include "/lib/settings.glsl"

uniform sampler2D colortex0;

in vec2 uv;

/* DRAWBUFFERS:4 */
void main() {
    gl_FragData[0] = vec4(texture(colortex0, uv).rgb, 1.0);
}
