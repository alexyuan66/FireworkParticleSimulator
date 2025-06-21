#version 410 core

in  vec4 vClipPos;
in  vec2 vUV;

out vec4 FragColor;

uniform sampler2D reflectionTex;
uniform sampler2D refractionTex;
uniform sampler2D dudvMap;
uniform float uTime;

void main() {
    // Reconstruct NDC
    vec2 ndc    = vClipPos.xy / vClipPos.w;
    vec2 baseUV = ndc * 0.5 + 0.5;
    vec2 reflUV = vec2(baseUV.x, 1.0 - baseUV.y);
    vec2 refrUV = baseUV;

    // Sample DuDv map and apply distortion
    vec2 dudv = texture(dudvMap, vUV + vec2(uTime*0.05, uTime*0.03)).rg;
    dudv = dudv * 2.0 - 1.0;            // now in [-1..1]
    float distortionStrength = 0.03;   // tweak as needed
    reflUV += dudv * distortionStrength;
    refrUV += dudv * distortionStrength;
    vec3 n = vec3(-1.0, -1.0, -1.0);
    reflUV += n.xy * 0.005;
    refrUV += n.xy * 0.005;

    // Get offscreen buffers
    vec3 reflection = texture(reflectionTex, reflUV).rgb;
    vec3 refraction = texture(refractionTex,  refrUV).rgb;

    // Fresnel blend
    float baseRefl = 0.99;
    float F = clamp(baseRefl +
        pow(1.0 - dot(normalize(n), vec3(0,0,1)), 3.0)*(1.0-baseRefl),
        0.0, 1.0
    );

    // Combine everything together
    vec3 color = mix(refraction, reflection, F) * vec3(0.8,0.9,1.0);
    FragColor  = vec4(color, 1.0);
}