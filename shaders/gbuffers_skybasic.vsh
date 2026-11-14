#version 330 compatibility

out vec3 rayDir;

void main() {
    gl_Position = ftransform();
    rayDir = (gl_ModelViewMatrix * gl_Vertex).xyz;
}
