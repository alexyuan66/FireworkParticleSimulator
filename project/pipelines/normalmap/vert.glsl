#version 410 core

layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexCoords;
layout(location=2) in vec3 aNormal;
layout(location=3) in vec3 aTangent;
layout(location=4) in vec3 aBiTangent;

out vec2 vTexCoords;
out mat3 TBN;
out vec3 fragPos;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

void main()
{
	vTexCoords = aTexCoords;

	vec3 T = normalize(vec3(uModel * vec4(aTangent,   0.0)));
   	vec3 B = normalize(vec3(uModel * vec4(aBiTangent, 0.0)));
   	vec3 N = normalize(vec3(uModel * vec4(aNormal,    0.0)));
   	TBN = mat3(T, B, N);

	fragPos = vec3(uModel * vec4(aPosition, 1.0f));

	vec4 finalPosition = uProjection * uView * uModel * vec4(aPosition,1.0f);

	// Note: Something subtle, but we need to use the finalPosition.w to do the perspective divide
	gl_Position = vec4(finalPosition.x, finalPosition.y, finalPosition.z, finalPosition.w);
}


