#version 410 core

layout(location = 0) in vec3 aPos;
out vec3 TexCoords;

uniform mat4 uView;
uniform mat4 uProjection;

void main() {
    mat4 rotView = mat4(mat3(uView));
    gl_Position = uProjection * rotView * vec4(aPos, 1.0);
    TexCoords = aPos;
}