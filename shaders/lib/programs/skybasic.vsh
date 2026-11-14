// Sky dome and void plane. The fragment shader fully replaces the
// vanilla gradient with the procedural sky.
#include "/lib/settings.glsl"
#include "/lib/common.glsl"

void main() {
    gl_Position = ftransform();
}
