#version 310 es
precision lowp float;
in vec4 vUv;
out vec4 oFragColor;

uniform sampler2D uTexColor;
uniform float alpha;
void main() {
    vec4 col = texture(uTexColor, vUv.xy);
    float a = clamp(0.5 - length(vUv.xy - 0.5), 0.0, 0.5) * 2.0;
    a = smoothstep(0.0, 1.0, a);
    col.a = a*vUv.w*alpha*0.9;
//    col.a = col.a*a*vUv.w*alpha;
//    col.a = col.a*vUv.w*alpha;
    oFragColor = vec4(col.xyz, col.a);
}