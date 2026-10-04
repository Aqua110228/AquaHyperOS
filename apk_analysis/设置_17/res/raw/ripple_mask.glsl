// ripple_mask.glsl — 圆形遮罩 + innerGlow 白色渐变
// 与 Vue demo postprocessing.frag 对齐
// 优化：half 精度、减少 fbm 层数、预计算常量

uniform float2 uResolution;
uniform float uProgress;
uniform float uOpacity;
uniform float uTime;

// --- Noise ---
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

// 2 层 fbm（第 3 层权重仅 0.125，省掉后视觉差异极小）
float fbmNoise(float2 p) {
    float v = 0.5 * valueNoise(p);
    p *= 2.01;
    v += 0.25 * valueNoise(p);
    return v * 1.333; // 归一化：1 / 0.75
}

// --- SDF + innerGlow ---
half boxSdf(half2 p, half2 b, half r) {
    half2 d = abs(p) - b + r;
    return min(max(d.x, d.y), 0.0) + length(max(d, half2(0.0))) - r;
}

half drawInnerGlow(half d, half strength) {
    return clamp(exp(d * strength) * step(d, 0.0), 0.0, 1.0);
}

// --- rippleMask ---
half calculateRippleMask(float2 xy, float2 center, half progress, half opacity) {
    float2 delta = xy - center;
    delta.y *= 0.95;
    half dist = half(length(delta));
    half width = half(length(uResolution) * 0.225);
    half u = mix(-width * 0.5, half(length(uResolution * 0.5)), progress);
    half b = 1.0 - smoothstep(0.0, 1.0, (dist - u) / width);
    return b * opacity;
}

half4 main(float2 fragCoord) {
    // 预计算常量（避免每像素重复计算）
    half2 center = half2(uResolution * 0.5);
    half2 uv = half2(fragCoord / uResolution);
    uv.y = 1.0 - uv.y;

    // 1. rippleMask
    half rippleMask = calculateRippleMask(fragCoord, float2(center), half(uProgress), half(uOpacity));

    // 2. innerGlow
    half sdf = boxSdf(half2(fragCoord) - center, center, 20.0) / 100.0;

    // Noise flicker（float 精度，避免 half 精度不足导致 noise 失真）
    float2 noiseCoord = float2(uv) * 0.9 + float2(uTime * 0.3, uTime * 0.21);
    half noiseMod = half(smoothstep(0.0, 1.0, fbmNoise(noiseCoord)));

    half innerGlow = drawInnerGlow(sdf, 3.0) * noiseMod;
    innerGlow = mix(innerGlow, 1.0, smoothstep(0.02, 0.0, -sdf));
    innerGlow = mix(1.0, innerGlow, smoothstep(0.0, 0.8, uv.y));

    // 合成
    half blackAlpha = 1.0 - rippleMask;
    half whiteAlpha = innerGlow * smoothstep(0.6, 1.0, rippleMask);

    half3 col = half3(whiteAlpha);
    half a = blackAlpha + whiteAlpha * (1.0 - blackAlpha);
    col = a > 0.001 ? col / half3(a) : half3(0.0);

    return half4(col * a, a);
}
