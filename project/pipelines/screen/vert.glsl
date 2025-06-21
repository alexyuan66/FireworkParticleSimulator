#version 410 core

layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexture;

out	vec2 vTexCoords;

void main()
{
	vTexCoords = aTexture;

	gl_Position = vec4(aPosition,1.0f);
}
