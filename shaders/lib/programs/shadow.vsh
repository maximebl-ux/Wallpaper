#include "/lib/settings.glsl"
#include "/lib/common.glsl"

out vec2 texcoord;
out vec4 glcolor;

void main() {
    gl_Position = ftransform();
    // Distort early so near geometry keeps most of the shadow resolution
    gl_Position.xy = distortShadow(gl_Position.xy);
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;
}
