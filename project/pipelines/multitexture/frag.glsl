#version 410 core

in vec2 vTexCoords;
in vec4 vWorldCoords;

out vec4 fragColor;

uniform sampler2D sampler1; // sand
uniform sampler2D sampler2; // dirt
uniform sampler2D sampler3; // grass

vec3 GetColor(){
		vec3 color = vec3(1.0,1.0,1.0);
		float height = vWorldCoords.y;

		// Create height thresholds
		float h0 = -12.0;  // Low height (sand)
		float h1 = -6.0; // Mid height (dirt)
		float h2 = 1.0; // Higher height (grass)

		// Sample textures
		vec3 tex0 = texture(sampler1, vTexCoords).rgb; // Low-altitude texture (sand)
		vec3 tex1 = texture(sampler2, vTexCoords).rgb; // Mid-altitude texture (dirt)
		vec3 tex2 = texture(sampler3, vTexCoords).rgb; // High-altitude texture (grass)

		// Choose colors to mix
		if (height < h0)
		{
			color = tex0;
		}
		else if (height < h1)
		{
			float t = smoothstep(h0, h1, height);
        	color = mix(tex0, tex1, t);
		}
		else if (height < h2)
		{
			float t = smoothstep(h1, h2, height);
        	color = mix(tex1, tex2, t);
		}
		else
		{
			color = tex2;
		}
		
		return color;
}

void main(){

		fragColor = vec4(GetColor(), 1.0);
}
