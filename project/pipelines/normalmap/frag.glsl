#version 410 core

struct Light {
    vec3 mColor;
    vec3 mPosition;
    float mAmbientIntensity;
    float mSpecularIntensity;
    float mSpecularExponent;
};

in  vec2 vTexCoords;
in mat3 TBN;
in vec3 fragPos;

out vec4 fragColor;

uniform sampler2D albedomap; // colors from texture
uniform sampler2D normalmap; // The normal map
uniform Light light;
uniform vec3 viewPos;

void main()
{
	vec3 colors = texture(albedomap,vTexCoords).rgb;
	vec3 normals = texture(normalmap,vTexCoords).rgb;

	vec3 normal = normalize(TBN * (normals * 2.0 - 1.0));
	vec3 lightDir = normalize(light.mPosition - fragPos);
    vec3 viewDir = normalize(viewPos - fragPos);
	vec3 reflectDir = reflect(-lightDir, normal);

	// Ambient
	vec3 ambient = light.mAmbientIntensity * light.mColor * colors;

	// Get rid of small specular leakage
	vec3 surfaceNormal = normalize(TBN[2]);
	float facing = dot(surfaceNormal, lightDir);
	if (facing <= 0.0) {
		fragColor = vec4(ambient, 1.0);
		return;
	}

	// Diffuse
	float diff = max(dot(normal, lightDir), 0.0);
	vec3 diffuse = diff * light.mColor * colors;

	// Specular
	float spec = pow(max(dot(normal, reflectDir), 0.0), light.mSpecularExponent);
	vec3 specular = light.mSpecularIntensity * spec * light.mColor;

	vec3 finalColor = ambient + diffuse + specular;
	fragColor = vec4(finalColor, 1.0);
}
