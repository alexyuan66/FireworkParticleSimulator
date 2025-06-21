#version 410 core

layout(location=0) in vec2 aCorner;
layout(location=1) in vec4 aInfo;
layout(location=2) in vec4 aColor;
out vec2 vUV;
out vec4 vColor;

uniform mat4 uView;
uniform mat4 uProjection;

void main() {
    vec3 center = aInfo.xyz;
    float size  = aInfo.w;
    vColor      = aColor;

    vec3 right = vec3(uView[0][0], uView[1][0], uView[2][0]);
    vec3 up    = vec3(uView[0][1], uView[1][1], uView[2][1]);

    vec3 pos = center + (aCorner.x * right + aCorner.y * up) * size;
    gl_Position = uProjection * uView * vec4(pos, 1.0);

    vUV = aCorner + 0.5;
}