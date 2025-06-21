#version 410 core

in vs{
	vec3 normal;
} fs_in;

out vec4 fragColor;

uniform vec3 lightCubeColor;

void main()
{
	fragColor = vec4(lightCubeColor * 1.5, 1.0);
}
