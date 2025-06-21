#version 410 core

in vs{
	vec3 normal;
//	vec2 texCoord;
} fs_in;

out vec4 fragColor;

void main()
{
	fragColor = vec4(fs_in.normal.x, fs_in.normal.y, fs_in.normal.z, 1.0f);
}
