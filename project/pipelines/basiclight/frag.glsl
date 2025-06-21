#version 410 core

in vs{
	vec3 normal;
//	vec2 texCoord;
} fs_in;

in vec3 FragPos;

out vec4 fragColor;

struct Light{
	vec3 color;
	vec3 position;
};

uniform Light uLight1;

void main()
{
	vec3 lighting = vec3(uLight1.color);
  float lightAngle = dot(uLight1.position-FragPos,fs_in.normal);

  lighting =  lightAngle * vec3(fs_in.normal.x*lighting.x, fs_in.normal.y*lighting.y, fs_in.normal.z*lighting.z);

	fragColor = vec4(lighting, 1.0f);
}
