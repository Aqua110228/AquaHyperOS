// glow.glsl — Paint shader for Mesh gradient
// 对 inputShader（intelliLight）进行 Mitchell bicubic 采样。
// rippleMask 在 Java 侧单独叠加，不在此 shader 中计算。
// 优化：展开 4×4 循环、使用 mediump、减少分支

uniform shader inputShader;
uniform float2 uILResolution;

// Mitchell 滤波核 (B=1/3, C=1/3)
// 使用 half 精度，减少 GPU 寄存器压力
half mitchell(half x) {
    half ax = abs(x);
    half ax2 = ax * ax;
    half ax3 = ax2 * ax;
    // 用 step 替代 if-else 分支，避免 GPU warp divergence
    half inner = step(ax, 1.0) * ((7.0 * ax3 - 12.0 * ax2 + 5.333) / 6.0);
    half outer = step(1.0, ax) * step(ax, 2.0) *
                 ((-2.333 * ax3 + 12.0 * ax2 - 20.0 * ax + 10.667) / 6.0);
    return inner + outer;
}

half4 sampleMitchell(float2 uv) {
    float2 texSize = uILResolution;
    float2 coord = uv * texSize - 0.5;
    half2 f = half2(fract(coord));
    float2 base = floor(coord);
    float2 maxCoord = texSize - 1.0;

    // 预计算 4 个 Y 方向权重和 4 个 X 方向权重
    half wy0 = mitchell(-1.0 - f.y);
    half wy1 = mitchell(-f.y);
    half wy2 = mitchell(1.0 - f.y);
    half wy3 = mitchell(2.0 - f.y);

    half wx0 = mitchell(-1.0 - f.x);
    half wx1 = mitchell(-f.x);
    half wx2 = mitchell(1.0 - f.x);
    half wx3 = mitchell(2.0 - f.x);

    // 展开 4×4 采样循环，减少循环开销
    half4 result = half4(0.0);
    half totalWeight = 0.0;

    // 预计算 4 行的 Y 坐标（clamp 到纹理范围）
    float y0 = clamp(base.y - 1.0, 0.0, maxCoord.y) + 0.5;
    float y1 = clamp(base.y,       0.0, maxCoord.y) + 0.5;
    float y2 = clamp(base.y + 1.0, 0.0, maxCoord.y) + 0.5;
    float y3 = clamp(base.y + 2.0, 0.0, maxCoord.y) + 0.5;

    // 预计算 4 列的 X 坐标
    float x0 = clamp(base.x - 1.0, 0.0, maxCoord.x) + 0.5;
    float x1 = clamp(base.x,       0.0, maxCoord.x) + 0.5;
    float x2 = clamp(base.x + 1.0, 0.0, maxCoord.x) + 0.5;
    float x3 = clamp(base.x + 2.0, 0.0, maxCoord.x) + 0.5;

    // 第 0 行 (jj = -1)
    half w;
    w = wx0 * wy0; result += w * half4(inputShader.eval(float2(x0, y0))); totalWeight += w;
    w = wx1 * wy0; result += w * half4(inputShader.eval(float2(x1, y0))); totalWeight += w;
    w = wx2 * wy0; result += w * half4(inputShader.eval(float2(x2, y0))); totalWeight += w;
    w = wx3 * wy0; result += w * half4(inputShader.eval(float2(x3, y0))); totalWeight += w;

    // 第 1 行 (jj = 0)
    w = wx0 * wy1; result += w * half4(inputShader.eval(float2(x0, y1))); totalWeight += w;
    w = wx1 * wy1; result += w * half4(inputShader.eval(float2(x1, y1))); totalWeight += w;
    w = wx2 * wy1; result += w * half4(inputShader.eval(float2(x2, y1))); totalWeight += w;
    w = wx3 * wy1; result += w * half4(inputShader.eval(float2(x3, y1))); totalWeight += w;

    // 第 2 行 (jj = 1)
    w = wx0 * wy2; result += w * half4(inputShader.eval(float2(x0, y2))); totalWeight += w;
    w = wx1 * wy2; result += w * half4(inputShader.eval(float2(x1, y2))); totalWeight += w;
    w = wx2 * wy2; result += w * half4(inputShader.eval(float2(x2, y2))); totalWeight += w;
    w = wx3 * wy2; result += w * half4(inputShader.eval(float2(x3, y2))); totalWeight += w;

    // 第 3 行 (jj = 2)
    w = wx0 * wy3; result += w * half4(inputShader.eval(float2(x0, y3))); totalWeight += w;
    w = wx1 * wy3; result += w * half4(inputShader.eval(float2(x1, y3))); totalWeight += w;
    w = wx2 * wy3; result += w * half4(inputShader.eval(float2(x2, y3))); totalWeight += w;
    w = wx3 * wy3; result += w * half4(inputShader.eval(float2(x3, y3))); totalWeight += w;

    return result / totalWeight;
}

half gradientNoise(half2 uv) {
    return fract(52.9829 * fract(dot(uv, half2(0.06711, 0.00584))));
}

half4 main(float2 fragCoord) {
    float2 uv = fragCoord / uILResolution;
    half3 color = sampleMitchell(uv).rgb;
    // 添加轻微噪声避免色带
    color += (1.0 / 255.0) * gradientNoise(half2(fragCoord)) - (0.5 / 255.0);
    return half4(color, 1.0);
}
