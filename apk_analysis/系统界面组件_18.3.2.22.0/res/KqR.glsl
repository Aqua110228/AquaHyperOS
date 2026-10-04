#version 300 es

uniform mat4 uMatrix;

layout (location = 0) in vec3 aPosition;
layout (location = 1) in vec2 aUv;

out vec4 vUv;
out vec2 vCenter;

struct Particle {
    float state;
    float startTime;
    float duration;
    float lifeTime;
    float scaleFactor;
    float alpha;
    float rotateFactor;
    float preWarmFactor;
    vec4 param1;
    vec4 param2;
    mat4 matrix;
};

layout(binding = 0, std430) buffer Particles {
    Particle particles[];
};

layout(std140) uniform EmitterParam {
    float lifeMin;
    float lifeMax;
    int emitterType;//0:持续发射,1:一次发射
    int loop;//是否循环
    float frequency;//发射频率，个数/秒
    float startSizeMin;
    float startSizeMax;
    vec3 scale;
    int amount;//粒子数目
    int reset;
    float preWarmScale;
};

layout(std140) uniform TimeParam {
    float time;
    float deltaTime;
};

float pfv(float v, float min, float max) {
    return (v - min) / (max - min);
}

float cpfv(float v, float min, float max) {
    return clamp(pfv(v, min, max), 0.0, 1.0);
}

#define STATE_RUN 2.0

void main() {
    vUv.xy = vec2(aUv.x, 1. - aUv.y);
    vUv.z = particles[gl_InstanceID].scaleFactor;
    vUv.w = particles[gl_InstanceID].alpha;
    float strength = 1.0 - particles[gl_InstanceID].matrix[3].y;
    strength *= clamp(1.0 - abs(particles[gl_InstanceID].matrix[3].x), 0.3,1.0);
    float scaleCoef = 0.25;
    strength = mix(0.3, 1.0, strength) * ((particles[gl_InstanceID].matrix[1].y / (0.1*scaleCoef) - (0.1*scaleCoef)) /
    (0.15*scaleCoef)) * cpfv(strength, 0.25, 0.5) * cpfv(particles[gl_InstanceID].startTime, 0.0, 1.0);
    vUv.w *= strength;
    gl_Position =  particles[gl_InstanceID].matrix * vec4(aPosition, 1.0);
    vCenter.x = particles[gl_InstanceID].matrix[3].x;
    vCenter.y = particles[gl_InstanceID].matrix[3].y;
    if (particles[gl_InstanceID].state != STATE_RUN) {
        gl_Position.z += 3.*gl_Position.w;//z的范围移出ndc
    }
}
