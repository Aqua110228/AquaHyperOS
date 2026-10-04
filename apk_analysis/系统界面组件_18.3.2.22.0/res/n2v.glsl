#version 310 es

uniform mat4 uMatrix;

layout (location = 0) in vec3 aPosition;
layout (location = 1) in vec2 aUv;
//state,startTime,duration, lifeTime
layout (location = 2) in vec4 ssbo1;
//scaleFactor,alpha,rotateFactor, preWarmFactor
layout (location = 3) in vec4 ssbo2;
//param1
layout (location = 4) in vec4 ssbo3;
//param2
layout (location = 5) in vec4 ssbo4;
//matrix colume1
layout (location = 6) in vec4 ssbo5;
//matrix colume2
layout (location = 7) in vec4 ssbo6;
//matrix colume3
layout (location = 8) in vec4 ssbo7;
//matrix colume4
layout (location = 9) in vec4 ssbo8;

out vec4 vUv;
out vec2 vCenter;

layout(std140) uniform EmitterParam {
    float lifeMin;
    float lifeMax;
    int emitterType;//0:持续发射,1:一次发射
    int loop;//是否循环
    float frequency; //发射频率，个数/秒
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
    vUv.z = ssbo2.x;
    vUv.w = ssbo2.y;
    mat4 mat;
    mat[0] = ssbo5;
    mat[1] = ssbo6;
    mat[2] = ssbo7;
    mat[3] = ssbo8;
    float strength = 1.0 - mat[3].y;
    strength *= clamp(1.0 - abs(mat[3].x), 0.3,1.0);
    float scaleCoef = 0.25;
    strength = mix(0.3, 1.0, strength) * ((mat[1].y / (0.1*scaleCoef) - (0.1*scaleCoef)) /
    (0.15*scaleCoef)) * cpfv(strength, 0.25, 0.5) * cpfv(ssbo1.y, 0.0, 1.0);
    vUv.w *= strength;
    gl_Position =  mat * vec4(aPosition, 1.0);
    vCenter.x = mat[3].x;
    vCenter.y = mat[3].y;
    if(ssbo1.x != STATE_RUN) {
        gl_Position.z += 3.*gl_Position.w;//z的范围移出ndc
    }
}
