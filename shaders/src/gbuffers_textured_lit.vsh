out vec2 texcoord;
out vec2 lmcoord;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = clamp(gl_MultiTexCoord1.xy / 240.0, 0.0, 1.0);
}
