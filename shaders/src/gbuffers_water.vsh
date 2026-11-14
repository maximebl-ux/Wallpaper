attribute vec4 mc_Entity;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 viewNormal;
varying vec3 viewPos;
varying float matFlag;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    viewNormal = normalize(gl_NormalMatrix * gl_Normal);
    viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    // Water block ids are mapped in block.properties
    matFlag = (mc_Entity.x == 10008.0) ? 1.0 : 0.0;
}
