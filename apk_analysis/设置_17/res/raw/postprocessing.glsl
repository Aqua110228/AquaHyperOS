// postprocessing.glsl — 后处理 Pass
// 采样 mesh gradient 离屏结果，叠加：
//   1. rippleMask 圆形展开遮罩
//   2. mainLogo 玻璃质感 logo（多层混合 + UDF inset shadow）
//   3. innerGlow 白色内发光 + noise
//
// 注意：Android 坐标系 Y=0 在屏幕顶部（Y-down），与 Vue/WebGL (Y-up) 相反。
// fragCoord: (0,0) = 左上角, (w,h) = 右下角
// uv = fragCoord / uResolution: (0,0) = 左上, (1,1) = 右下

uniform shader uMeshGradient;       // Pass 1 的 mesh gradient 结果

uniform float2 uResolution;
uniform float  uTime;               // noise 动画时间
uniform float  uRippleMaskProgress;
uniform float  uRippleMaskOpacity;
uniform float2 uRippleMaskCenter;

// ====================== 工具函数 ======================

half luminance(half3 color) {
    return dot(color, half3(0.2126, 0.7152, 0.0722));
}

// ====================== rippleMask ======================

half calculateRippleMask(float2 xy, float2 center, half progress, half opacity) {
    float2 rippleScale = float2(1.0, 0.95);
    half dist = half(length((xy - center) * rippleScale));
    half width = half(length(uResolution) * 0.225);
    float maxRadius = 0.0;
    maxRadius = max(maxRadius, length((float2(0.0, 0.0) - center) * rippleScale));
    maxRadius = max(maxRadius, length((float2(uResolution.x, 0.0) - center) * rippleScale));
    maxRadius = max(maxRadius, length((float2(0.0, uResolution.y) - center) * rippleScale));
    maxRadius = max(maxRadius, length((uResolution - center) * rippleScale));
    half u = mix(-width * 0.5, half(maxRadius), progress);
    half b = 1.0 - smoothstep(0.0, 1.0, (dist - u) / width);
    return b * opacity;
}

// ====================== Noise ======================

float hash2D(float2 p) {
    float3 p3 = fract(float3(p.xyx) * 0.13);
    p3 += dot(p3, p3.yzx + 3.333);
    return fract((p3.x + p3.y) * p3.z);
}

float valueNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash2D(i);
    float b = hash2D(i + float2(1.0, 0.0));
    float c = hash2D(i + float2(0.0, 1.0));
    float d = hash2D(i + float2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbmNoise(float2 p) {
    float v = 0.5 * valueNoise(p);
    p *= 2.01;
    v += 0.25 * valueNoise(p);
    return v * 1.333;
}

// ====================== innerGlow ======================

half boxSdf(half2 p, half2 b, half r) {
    half2 d = abs(p) - b + r;
    return min(max(d.x, d.y), 0.0) + length(max(d, half2(0.0))) - r;
}

half drawInnerGlow(half d, half strength) {
    return clamp(exp(d * strength) * step(d, 0.0), 0.0, 1.0);
}

// ====================== Main ======================

half4 main(float2 fragCoord) {
    float2 uv = fragCoord / uResolution;
    // flippedY: 模拟 WebGL Y-up 坐标，用于 Y 相关的视觉效果
    float flippedY = 1.0 - uv.y;

    // 采样 mesh gradient（标准屏幕坐标）
    half4 color = half4(uMeshGradient.eval(fragCoord));
    color.rgb *= color.a;

    // rippleMask（基于距离，不受 Y 方向影响）
    half rippleMask = calculateRippleMask(fragCoord, uRippleMaskCenter,
        half(uRippleMaskProgress), half(uRippleMaskOpacity));

    // 从不透明黑色过渡到渐变色（保证背景为实心黑色，非透明）
    color = mix(half4(0.0, 0.0, 0.0, 1.0), color, rippleMask);

    // innerGlow
    half2 center = half2(uResolution * 0.5);
    // r=0 让 SDF 退化为普通矩形：圆角屏的物理圆角自然裁剪，直角屏边缘对齐不留缺口。
    // r=20 时四角(超出 20px 圆角的直角区)落在 SDF 外侧被 innerGlow 强制 mix 成白色，
    // 在圆角屏上白角露在系统物理圆角弧内侧 → 四角白色缺角(ISS-202606-00018837A)。
    // 对齐 MiuiProvisionAosp 8984210 的 r=20→0 修复。
    half sdf = boxSdf(half2(fragCoord) - center, center, 0.0) / 100.0;

    // Noise flicker
    float2 noiseUV = float2(uv.x, flippedY); // 用 flipped Y 让 noise 方向与 Vue 一致
    float2 noiseCoord = noiseUV * 0.9 + float2(uTime * 0.3, uTime * 0.21);
    half noiseMod = half(smoothstep(0.0, 1.0, fbmNoise(noiseCoord)));

    half innerGlow = drawInnerGlow(sdf, 3.0) * noiseMod;
    innerGlow = mix(innerGlow, 1.0, smoothstep(0.02, 0.0, -sdf));
    // flippedY: 底部(flippedY≈0)变淡为白色，顶部(flippedY≈1)保持正常 glow
    innerGlow = mix(1.0, innerGlow, smoothstep(0.0, 0.8, flippedY));
    innerGlow = mix(0.0, innerGlow, smoothstep(0.2, 0.75, luminance(color.rgb)));
    color = mix(color, half4(1.0, 1.0, 1.0, 1.0), innerGlow * smoothstep(0.6, 1.0, rippleMask));

    return color;
}
