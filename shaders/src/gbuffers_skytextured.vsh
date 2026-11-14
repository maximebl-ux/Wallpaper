varying vec2 texcoord;
varying vec3 rayDir;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    rayDir = (gl_ModelViewMatrix * gl_Vertex).xyz;
}
