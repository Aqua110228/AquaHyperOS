// logo.glsl — 全屏分辨率 logo 渲染 shader
// 采样低分辨率 mesh gradient 背景来计算玻璃质感 logo
// 输出 pre-multiplied alpha，用于叠加到全屏 canvas 上
// 移植自 miuix demo CL 8027505 (animation_test/OOBE_Intro_OS4)

uniform shader uBackground;         // 低分辨率 mesh gradient 结果
uniform shader uMainLogo;           // logo 纹理（alpha mask）
uniform shader uMainLogoUdf;        // logo UDF 距离场

uniform float2 uResolution;         // 全屏分辨率
uniform float2 uBgResolution;       // 低分辨率背景尺寸
uniform float2 uMainLogoResolution; // logo 纹理原始分辨率
uniform float  uLogoWidthRatio;     // logo 宽占屏宽比例（= 固定 dp × density / 屏宽 px，scale=1 基准）
uniform float  uLogoCenterRatio;    // logo 中心距顶部占屏高比例（设计稿 ~0.41）
uniform float  uMainLogoOpacity;
uniform float  uMainLogoScale;
uniform float  uMainLogoY;          // Y 偏移（像素，参考 1200×2608 坐标系）
uniform float  uMainLogoInsetElevation;
uniform float  uRippleMaskProgress;
uniform float  uRippleMaskOpacity;
uniform float2 uRippleMaskCenter;   // 全屏坐标系

// mY（logo Y 偏移）的参考坐标系高度
const float REF_HEIGHT = 2608.0;

// ====================== 工具函数 ======================

half luminance(half3 color) {
    return dot(color, half3(0.2126, 0.7152, 0.0722));
}

// ====================== rippleMask（用于计算背景色） ======================

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

// ====================== Logo 混合 ======================

half overlayChannel(half base, half blend) {
    return base < 0.5
        ? 2.0 * base * blend
        : 1.0 - 2.0 * (1.0 - base) * (1.0 - blend);
}

half4 computeLogoColor(half3 backdrop) {
    half3 c0 = half3(64.0 / 255.0);
    half a0 = 0.52;
    half lum0 = luminance(c0);
    half3 lumBlended = clamp(backdrop + (lum0 - luminance(backdrop)), 0.0, 1.0);
    half3 rgb0 = mix(backdrop, lumBlended, a0);

    half3 c1 = half3(204.0 / 255.0);
    half a1 = 0.30;
    half3 blended1 = half3(
        overlayChannel(rgb0.r, c1.r),
        overlayChannel(rgb0.g, c1.g),
        overlayChannel(rgb0.b, c1.b)
    );
    half3 rgb1 = mix(rgb0, blended1, a1);

    half3 c2 = half3(77.0 / 255.0);
    half a2 = 0.75;
    half3 rgb2 = min(rgb1 + c2 * a2, half3(1.0));

    half a3 = 0.20;
    half3 rgb3 = min(rgb2 + half3(a3), half3(1.0));

    half alpha = a0;
    alpha = alpha + a1 * (1.0 - alpha);
    alpha = min(alpha + a2, 1.0);
    alpha = min(alpha + a3, 1.0);

    return half4(rgb3, alpha);
}

half4 blendScreen(half4 src, half4 dst) {
    return half4(
        1.0 - (1.0 - src.rgb) * (1.0 - dst.rgb),
        src.a + dst.a * (1.0 - src.a)
    );
}

// ====================== Main ======================

half4 main(float2 fragCoord) {
    float2 uv = fragCoord / uResolution;

    // Logo 定位：宽度按设计稿固定 dp（占屏比 uLogoWidthRatio 由 View 层算好传入，不随屏幕变形），
    // 高度按贴图原始宽高比反算（锁定物理宽高比，不被屏幕宽高比污染——ISS-202606-00018485A）。
    //   logoSize.y = logoSize.x * (屏宽/屏高) * (贴图高/贴图宽)
    float texAspect = uMainLogoResolution.x / uMainLogoResolution.y;
    float2 baseLogoSize = float2(uLogoWidthRatio, 0.0);
    baseLogoSize.y = baseLogoSize.x * (uResolution.x / uResolution.y) / texAspect;
    float2 logoSize = baseLogoSize * uMainLogoScale;
    // 垂直：中心固定在屏高 uLogoCenterRatio（设计稿 ~0.41），不再用"顶部 ratio + 半高"。
    float2 logoCenter = float2(0.5, uLogoCenterRatio);
    logoCenter.y += uMainLogoY / REF_HEIGHT;

    float2 logoStart = logoCenter - logoSize * 0.5;
    float2 st = (uv - logoStart) / logoSize;

    // 超出 logo 区域：完全透明
    if (st.x < 0.0 || st.x > 1.0 || st.y < 0.0 || st.y > 1.0) {
        return half4(0.0);
    }

    // 采样背景色（低分辨率 mesh gradient + rippleMask）
    float2 bgCoord = uv * uBgResolution;
    half4 bgColor = half4(uBackground.eval(bgCoord));
    bgColor.rgb *= bgColor.a;
    half rippleMask = calculateRippleMask(fragCoord, uRippleMaskCenter,
        half(uRippleMaskProgress), half(uRippleMaskOpacity));
    bgColor = mix(half4(0.0, 0.0, 0.0, 1.0), bgColor, rippleMask);
    half3 backdrop = bgColor.rgb;

    // 采样 logo 纹理
    float2 texCoord = st * uMainLogoResolution;
    half4 tex = half4(uMainLogo.eval(texCoord));
    half4 logoTint = computeLogoColor(backdrop);
    half a = tex.a * half(uMainLogoOpacity) * logoTint.a;
    half4 result = half4(logoTint.rgb * a, a);

    // --- Inset box-shadows (UDF-based) ---
    half udf = half4(uMainLogoUdf.eval(texCoord)).r;

    half udfR = half4(uMainLogoUdf.eval(texCoord + float2(1.0, 0.0))).r;
    half udfL = half4(uMainLogoUdf.eval(texCoord - float2(1.0, 0.0))).r;
    half udfD = half4(uMainLogoUdf.eval(texCoord + float2(0.0, 1.0))).r;
    half udfU = half4(uMainLogoUdf.eval(texCoord - float2(0.0, 1.0))).r;
    half2 grad = half2(udfR - udfL, udfD - udfU);
    half2 edgeNormal = length(grad) > 0.0001 ? normalize(grad) : half2(0.0);

    half insetWidth = mix(0.5, 0.02, half(uMainLogoInsetElevation));

    // Inset shadow 1: light from top-left
    {
        half2 lightDir = normalize(half2(0.3, 0.6));
        half facing = clamp(-dot(edgeNormal, lightDir), 0.0, 1.0);
        half falloff = smoothstep(insetWidth, 0.0, udf);
        half insetAlpha = facing * falloff * tex.a;
        half4 insetColor = half4(half3(insetAlpha), insetAlpha) * half(uMainLogoOpacity);
        result = blendScreen(insetColor, result);
    }

    // Inset shadow 2: light from bottom-right
    {
        half2 lightDir = normalize(half2(-0.488, -0.488));
        half facing = clamp(-dot(edgeNormal, lightDir), 0.0, 1.0);
        half falloff = smoothstep(insetWidth, 0.0, udf);
        half insetAlpha = facing * falloff * tex.a;
        half4 insetColor = half4(half3(insetAlpha), insetAlpha) * half(uMainLogoOpacity);
        result = blendScreen(insetColor, result);
    }

    return result;
}
