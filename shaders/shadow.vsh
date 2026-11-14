#version 120

#include "/settings.glsl"

const int shadowMapResolution = SHADOW_RES;
const float shadowDistance = 160.0;
// Tilts the sun path for longer, more cinematic shadows
const float sunPathRotation = -25.0;

varying vec2 texcoord;

float distortFactor(vec3 p) {
    return length(p.xy) * 0.85 + 0.15;
}

void main() {
    gl_Position = ftransform();
    // Must match the sampling-side distortion in lib/shadows.glsl
    gl_Position.xy /= distortFactor(gl_Position.xyz);
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
