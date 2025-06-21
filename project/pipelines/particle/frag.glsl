#version 410 core

in vec2 vUV;
in vec4 vColor;
out vec4 FragColor;

uniform sampler2D uTex;

void main() {
    float mask = texture(uTex, vUV).r;
    float rim = 1.0 - mask;
    const float bias = 0.05;  
    float t = clamp((rim - bias)/(1.0 - bias), 0.0, 1.0);
    vec3 finalRGB = mix(vec3(1.0), vColor.rgb, t);
    float finalA = vColor.a * mask;
    FragColor = vec4(finalRGB, finalA);
}