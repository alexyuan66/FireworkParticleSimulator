#version 410 core

layout(location=0) in vec3 aPos;
layout(location=1) in vec2 aUV;

out vec4 vClipPos;
out vec2 vUV;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;
uniform float uTime;

void main() {
    vUV = aUV + vec2(uTime * 0.03, uTime * 0.02);

    // compute world and clip positions
    vec4 world = uModel * vec4(aPos, 1.0);
    vClipPos   = uProjection * uView * world;
    gl_Position = vClipPos;
}