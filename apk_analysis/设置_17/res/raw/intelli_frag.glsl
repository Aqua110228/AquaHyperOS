// HeadDrop ripple lights effect - SkSL Runtime Shader
// Ported from os4-onboarding intelliFrag.glsl
// 优化：展开 8 光源循环、内部计算使用 mediump、减少冗余计算
// 注意：uniform 保持 float 类型以兼容 Java 侧 setFloatUniform

uniform float2 uResolution;
uniform float uPower;
uniform float uLightness;
uniform float3 uBgColor;

// 8 lights: position (vec2) + color (vec3)
uniform float2 uLight0;  uniform float3 uLightColor0;
uniform float2 uLight1;  uniform float3 uLightColor1;
uniform float2 uLight2;  uniform float3 uLightColor2;
uniform float2 uLight3;  uniform float3 uLightColor3;
uniform float2 uLight4;  uniform float3 uLightColor4;
uniform float2 uLight5;  uniform float3 uLightColor5;
uniform float2 uLight6;  uniform float3 uLightColor6;
uniform float2 uLight7;  uniform float3 uLightColor7;

// 单个光源贡献计算
// dist / 0.5 等价于 dist * 2.0，减少一次除法
// smoothstep(1,0,x) 等价于 smoothstep(0,1,1-x)，但反转参数可省去 1.0-x
half3 applyLight(half2 pos, half2 lightPos, half3 lightColor, half3 current) {
    half dist = length(lightPos - pos);
    half s = smoothstep(1.0, 0.0, dist * 2.0);
    return mix(current, lightColor, s);
}

half4 main(float2 fragCoord) {
    // UV 计算保持 highp，避免大坐标精度丢失
    float2 vUv = fragCoord / uResolution;
    half2 uv = half2(vUv.x - 0.5, 0.5 - vUv.y); // 合并 y 翻转和偏移

    half mixValue = mix(0.75, 0.775, half(uLightness));

    half3 col = half3(uBgColor);

    // 展开 8 光源循环，避免数组分配+循环的开销
    col = applyLight(uv, half2(uLight0), half3(uLightColor0), col);
    col = applyLight(uv, half2(uLight1), half3(uLightColor1), col);
    col = applyLight(uv, half2(uLight2), half3(uLightColor2), col);
    col = applyLight(uv, half2(uLight3), half3(uLightColor3), col);
    col = applyLight(uv, half2(uLight4), half3(uLightColor4), col);
    col = applyLight(uv, half2(uLight5), half3(uLightColor5), col);
    col = applyLight(uv, half2(uLight6), half3(uLightColor6), col);
    col = applyLight(uv, half2(uLight7), half3(uLightColor7), col);

    // 亮度限制
    col = min(half3(1.0), col);

    // 后处理：亮度/饱和度调整
    half brightness = 1.0 + half(uPower) * 0.2;
    half luminance = dot(col, half3(0.2126, 0.7153, 0.0722));
    half3 mixColor = mix(half3(luminance), col, half3(brightness)) * mixValue;

    return half4(mixColor, 1.0);
}
