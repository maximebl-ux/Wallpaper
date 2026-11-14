in vec4 mc_Entity;

out vec2 texcoord;
out vec2 lmcoord;
out vec3 viewNormal;
out vec3 viewPos;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = clamp(gl_MultiTexCoord1.xy / 240.0, 0.0, 1.0);
    viewNormal = normalize(gl_NormalMatrix * gl_Normal);
    viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
}
