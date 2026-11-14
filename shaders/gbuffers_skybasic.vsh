#version 120

varying vec3 rayDir;

void main() {
    gl_Position = ftransform();
    rayDir = (gl_ModelViewMatrix * gl_Vertex).xyz;
}
