// Colored, untextured geometry (lines, leashes, block outline).
#include "/lib/settings.glsl"

out vec4 glcolor;
out vec2 lmcoord;

void main() {
    gl_Position = ftransform();
    glcolor = gl_Color;
    lmcoord = vec2(0.9);
}
