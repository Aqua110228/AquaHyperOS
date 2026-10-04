#version 300 es
precision highp float;

/*******************************************************/
/*  2024-08-14                                         */
/*  Author:                                            */
/*    - luoruiyao1@xiaomi.com                          */
/*    - liyulian@xiaomi.com                            */
/*                                                     */
/*  Inspirations:                                      */
/*    - https://www.shadertoy.com/view/XssXWH          */
/*    - https://ronvalstar.nl/experiment-fire          */
/*                                                     */
/*  Notice:                                            */
/*    - All blending happens in pre-multiplied space   */
/*******************************************************/


out vec4 fragColor;
in vec2 vUv;

uniform vec2 uResolution; //px
uniform sampler2D uNoiseBwTex;

uniform vec2 uBeam1PointF;
uniform float uBeam1LineY;
uniform float uBeam1E;
uniform float uBeam1HighBand;
uniform vec3 uBeam1RGB;
uniform float uBeam1Alpha;
uniform float uBeam1ScaleX;
uniform float uBeam1Shift;
uniform float uBeam1Dispersion;

uniform vec2 uBeam2PointF;
uniform float uBeam2LineY;
uniform float uBeam2E;
uniform float uBeam2HighBand;
uniform vec3 uBeam2RGB;
uniform float uBeam2Alpha;
uniform float uBeam2ScaleX;
uniform float uBeam2Shift;
uniform float uBeam2Dispersion;

uniform vec2 uBeam3PointF;
uniform float uBeam3LineY;
uniform float uBeam3E;
uniform float uBeam3HighBand;
uniform vec3 uBeam3RGB;
uniform float uBeam3Alpha;
uniform float uBeam3ScaleX;
uniform float uBeam3Shift;
uniform float uBeam3Dispersion;

uniform vec2 uBeam4PointF;
uniform float uBeam4LineY;
uniform float uBeam4E;
uniform float uBeam4HighBand;
uniform vec3 uBeam4RGB;
uniform float uBeam4Alpha;
uniform float uBeam4ScaleX;
uniform float uBeam4Shift;
uniform float uBeam4Dispersion;

uniform vec2 uBeam5PointF;
uniform float uBeam5LineY;
uniform float uBeam5E;
uniform float uBeam5HighBand;
uniform vec3 uBeam5RGB;
uniform float uBeam5Alpha;
uniform float uBeam5ScaleX;
uniform float uBeam5Shift;
uniform float uBeam5Dispersion;

uniform vec2 uBeam6PointF;
uniform float uBeam6LineY;
uniform float uBeam6E;
uniform float uBeam6HighBand;
uniform vec3 uBeam6RGB;
uniform float uBeam6Alpha;
uniform float uBeam6ScaleX;
uniform float uBeam6Shift;
uniform float uBeam6Dispersion;

uniform float uTime;
uniform float uParticleCount;
uniform float uParticleSize;
uniform vec4 uParticleColor;
uniform float uMaskOn;
uniform float uLite;
uniform float uCanvasScale;

struct Beam {
    vec2 point_f;
    float line_y;
    float e;
    float highband;
    vec3 color;
    float alpha;
    float scale_x;
    float shift;
    float dispersion;
};

vec4 blendAdd(vec4 base, vec4 blend) {
    return vec4((base.rgb + blend.rgb) * blend.a + base.rgb * (1.0 - blend.a), base.a + blend.a);
}

vec4 blendAlpha(vec4 base, vec4 blend) {
    return vec4(base.rgb * (1.0 - blend.a) + blend.rgb * blend.a, blend.a + base.a * (1.0 - blend.a));
}

vec4 blendScreen(vec4 base, vec4 blend) {
    return vec4(1.0 - (1.0 - base.rgb) * (1.0 - blend.rgb), base.a + blend.a);
}

float luminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

float satan(vec2 p, float w) {
    float a = 0.0;
    if (abs(p.x) < 1e-10) {
        a = 1.5707963268; // Approximately PI/2
    } else {
        a = atan(abs(p.y / p.x));
    }
    float sy = 2.0 * smoothstep(-w, w, p.y) - 1.0;
    return abs(a + 3.1415926536 * min(0.0, sign(p.x))) * sy;
}

vec3 mod289_vec3(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289_vec4(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
    return mod289_vec4((x * 34.0 + 1.0) * x);
}

vec4 taylorInvSqrt(vec4 r) {
    return 1.7928429 - 0.85373473 * r;
}

float snoise(vec3 v) {
    const vec2 C = vec2(1. / 6., 1. / 3.);
    const vec4 D = vec4(0., 0.5, 1., 2.);
    vec3 i = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1. - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;
    i = mod289_vec3(i);
    vec4 p = permute(permute(permute(i.z + vec4(0., i1.z, i2.z, 1.)) + i.y + vec4(0., i1.y, i2.y, 1.)) + i.x + vec4(0., i1.x, i2.x, 1.));
    float n_ = 0.14285715;
    vec3 ns = n_ * D.wyz - D.xzx;
    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);
    vec4 x = x_ * ns.x + ns.yyyy;
    vec4 y = y_ * ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);
    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);
    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));
    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);
    vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;
    vec4 m = max(vec4(0.6) - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), vec4(0.0));
    m = m * m;
    return 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

float prng(vec2 seed) {
    vec2 seed_var = seed;
    seed_var = fract(seed_var * vec2(5.3983, 5.4427));
    seed_var += dot(seed_var.yx, seed_var.xy + vec2(21.5351, 14.3137));
    return fract(seed_var.x * seed_var.y * 95.4337);
}

float noiseStack(vec3 pos, int octaves, float falloff) {
    vec3 pos_var = pos;
    float noise = snoise(pos_var);
    float off = 1.0;
    if (octaves > 1) {
        pos_var = pos_var * 2.0;
        off = off * falloff;
        noise = (1.0 - off) * noise + off * snoise(pos_var);
    }
    if (octaves > 2) {
        pos_var = pos_var * 2.0;
        off = off * falloff;
        noise = (1.0 - off) * noise + off * snoise(pos_var);
    }
    if (octaves > 3) {
        pos_var = pos_var * 2.0;
        off = off * falloff;
        noise = (1.0 - off) * noise + off * snoise(pos_var);
    }
    return (1.0 + noise) / 2.0;
}

vec2 noiseStackUV(vec3 pos, int octaves, float falloff, float diff) {
    float displaceA = noiseStack(pos, octaves, falloff);
    float displaceB = noiseStack(pos + vec3(3984.293, 423.21, 5235.19), octaves, falloff);
    return vec2(displaceA, displaceB);
}

float pfv(float a, float b, float t) {
    return mix(a, b, t);
}

float cpfv(float a, float b, float t) {
    return pfv(a, b, clamp(t, 0.0, 1.0));
}

// -------------------- Helpers -------------------- //
vec4 interpolate_color_bright(float t) {
    // Define the color stops
    const int numStops = 5;
    vec4 color_stops[numStops] = vec4[numStops](
    vec4(0.612, 0.612, 0.612, 0.00), // 9c9c9c 0.63
    vec4(0.612, 0.612, 0.612, 0.30), // 9c9c9c 0.63
    vec4(0.000, 0.000, 0.000, 0.76), // 000000
    vec4(0.039, 0.039, 0.039, 0.99), // 0a0a0a
    vec4(0.000, 0.000, 0.000, 1.00)  // 000000
    );

    float stops[numStops] = float[numStops](
    0.00,
    0.38,
    0.80,
    0.89,
    1.00
    );

    // Find the two stops to interpolate between
    int i = numStops - 2;
    for (; i > -1; i--) {
        if (t > stops[i]) {
            break;
        }
    }

    float t0 = stops[i];
    float t1 = stops[i + 1];
    vec4 color0 = color_stops[i];
    vec4 color1 = color_stops[i + 1];

    // Linear interpolation
    float factor = (t - t0) / (t1 - t0);

    return vec4(
    mix(color0.rgb, color1.rgb, factor),
    mix(color0.a, color1.a, factor)
    );
}

vec4 interpolate_color_dark(float t) {
    // Define the color stops
    const int numStops = 5;
    vec4 color_stops[numStops] = vec4[numStops](
    vec4(0.561, 0.561, 0.561, 0.10), // 8f8f8f
    vec4(0.271, 0.271, 0.271, 0.28), // 454545
    vec4(0.000, 0.000, 0.000, 0.76), // 000000
    vec4(0.039, 0.039, 0.039, 0.99), // 0a0a0a
    vec4(0.000, 0.000, 0.000, 1.00)  // 000000
    );

    float stops[numStops] = float[numStops](
    0.00,
    0.45,
    0.79,
    0.89,
    1.00
    );

    // Find the two stops to interpolate between
    int i = numStops - 2;
    for (; i > -1; i--) {
        if (t > stops[i]) {
            break;
        }
    }

    float t0 = stops[i];
    float t1 = stops[i + 1];
    vec4 color0 = color_stops[i];
    vec4 color1 = color_stops[i + 1];

    // Linear interpolation
    float factor = (t - t0) / (t1 - t0);

    return vec4(
    mix(color0.rgb, color1.rgb, factor),
    mix(color0.a, color1.a, factor)
    );
}

vec4 beam(vec2 uv, Beam beam, vec2 scale) {
    vec2 resolution = vec2(1080.0, 2400.0) * scale;
    vec2 coord = uv * resolution;

    vec2 point_f = vec2(beam.point_f.x, beam.point_f.y) / vec2(392.0, 871.0) * resolution;
    float line_y = beam.line_y / 871.0 * resolution.y;
    float e = beam.e;
    float highband = beam.highband;
    float scale_x = beam.scale_x;
    vec2 transformed_coord = coord;
    transformed_coord.x -= resolution.x / 2.0;
    transformed_coord.x *= scale_x;
    transformed_coord.x += resolution.x / 2.0;

    float pf = length(point_f + vec2(0.0, line_y) - transformed_coord);
    float pp = transformed_coord.y - line_y;
    float a = max(1.0 - (pf / pp) / e, 0.0) * step(line_y, transformed_coord.y);

    if (a < highband) {
        a = a / highband;
    } else {
        a = pow(1.0 - (a - highband) / (1.0 - highband), 3.0);
    }

    a = smoothstep(0.0, 1.0, a);

    a *= exp(-pf / 1080.0 * 2.0);

    // dispersion
    float x = mod(a + beam.shift, 1.0) * 3.0;
    vec3 band = vec3(0.5);
    if (x < 1.0) {
        band.r += 1.0 - x;
        band.g += x;
    } else if (x < 2.0) {
        x -= 1.0;
        band.g += 1.0 - x;
        band.b += x;
    } else {
        x -= 2.0;
        band.b += 1.0 - x;
        band.r += x;
    }

    band = mix(vec3(1.0), band, beam.dispersion);

    return vec4(band * beam.color * a * beam.alpha, a * beam.alpha);

    // return a * beam.alpha;
}

vec4 main_beam(vec2 uv, Beam beam, vec2 scale) {
    vec2 resolution = vec2(1080.0, 2400.0) * scale;
    vec2 coord = uv * resolution;

    vec2 point_f = vec2(beam.point_f.x, beam.point_f.y) / vec2(392.0, 871.0) * resolution;
    float line_y = beam.line_y / 871.0 * resolution.y;
    float e = beam.e;
    float highband = beam.highband;
    float scale_x = beam.scale_x;
    vec2 transformed_coord = coord;
    transformed_coord.x -= resolution.x / 2.0;
    transformed_coord.x *= scale_x;
    transformed_coord.x += resolution.x / 2.0;

    float pf = length(point_f + vec2(0.0, line_y) - transformed_coord);
    float pp = transformed_coord.y - line_y;
    float a = max(1.0 - (pf / pp) / e, 0.0) * step(line_y, transformed_coord.y);

    if (a < highband) {
        a = a / highband;
    } else {
        a = pow(1.0 - (a - highband) / (1.0 - highband), 3.0);
    }

    // dispersion
    float x = mod(a + beam.shift, 1.0) * 3.0;
    vec3 band = vec3(0.5);
    if (x < 1.0) {
        band.r += 1.0 - x;
        band.g += x;
    } else if (x < 2.0) {
        x -= 1.0;
        band.g += 1.0 - x;
        band.b += x;
    } else {
        x -= 2.0;
        band.b += 1.0 - x;
        band.r += x;
    }

    band = mix(vec3(1.0), band, beam.dispersion);

    // Using tanh() instead of smoothstep()
    a = tanh(a);

    a *= exp(-pf / 1080.0 * 2.0);

    return vec4(band * beam.color * beam.alpha, a * beam.alpha);
}

// -------------------- Draw-ers -------------------- //
vec4 draw_flashlight_shadow(vec2 uv, vec2 scale) {
    float level = min((uBeam1Alpha + uBeam2Alpha + uBeam3Alpha + uBeam4Alpha + uBeam5Alpha + uBeam6Alpha) / 6.0, 1.0);

    vec2 texcoord = uv * uResolution;

    vec2 nst = uv;
    nst.x *= uResolution.x / uResolution.y;
    nst *= 20.0;
    float n = texture(uNoiseBwTex, nst).r;
    // c.rgb = mix(c.rgb, c.rgb + vec3(10. / 255.), n);

    vec2 stl = texcoord - vec2(0.74, 0.5) * uResolution;
    stl /= vec2(0.3046875, 1.0) * scale;
    float left = 1.0 - (satan(stl, 1.0 / uResolution.y) / 3.1415926536 * 0.5 + 0.5);
    left = mix(left, left+0.02, n);

    vec2 str = texcoord - vec2(0.26, 0.5) * uResolution;
    str.x = 1.0 - str.x;
    str /= vec2(0.3046875, 1.0) * scale;
    float right = 1.0 - (satan(str, 1.0 / uResolution.y) / 3.1415926536 * 0.5 + 0.5);
    right = mix(right, right+0.02, n);

    float t = mix(right, left, step(0.5, uv.x));

    float a_bright = 0.42;
    vec4 c_bright = interpolate_color_bright(t);
    c_bright.a *= a_bright;
    vec4 r_bright = c_bright;
    // vec4 r_bright = blendAlpha(vec4(c_bright.rgb * c_bright.a, c_bright.a), vec4(0.0, 0.0, 0.0, 0.2));

    float a_dark = 0.32;
    vec4 c_dark = interpolate_color_dark(t);
    c_dark.a *= a_dark;
    vec4 r_dark = blendAlpha(vec4(c_dark.rgb * c_dark.a, c_dark.a), vec4(0.0, 0.0, 0.0, 0.13));
    r_dark.rgb *= a_dark;

    return mix(r_dark, r_bright, level);
    // return vec4(r.rgb * r.a, r.a);
}

float calc_mask(vec2 uv, vec2 scale) {
    vec2 texcoord = uv * uResolution;

    vec2 stl = texcoord - vec2(0.74, 0.5) * uResolution;
    // stl /= vec2(0.3046875, 1.0) * scale;
    float left = (atan(stl.y, stl.x) / 3.1415926536 * 0.5 + 0.5);

    vec2 str = texcoord - vec2(0.26, 0.5) * uResolution;
    str.x = 1.0 - str.x;
    // str /= vec2(0.3046875, 1.0) * scale;
    float right = (atan(str.y, str.x) / 3.1415926536 * 0.5 + 0.5);

    float t = mix(right, left, step(0.5, uv.x));

    t = smoothstep(0.0, 1.0,(t - 0.5) / 0.1);

    return sqrt(t);
}

vec4 draw_metal_ring(vec2 uv, float height, float width, float alpha, float beta) {
    vec2 st = uv;
    st -= 0.5;
    st *= vec2(2.04, 400.0);
    st += 0.5;

    st.y += 0.5;

    float a = step(0.01, st.x) * step(0.01, st.y) * step(st.x, 0.99) * step(st.y, 0.99);
    a *= smoothstep(0.5, 0.49, abs(st.x - 0.5));

    float fallout = sin(3.1415926536 * st.x);
    fallout = fallout * fallout * alpha + beta;
    fallout *= a;

    return vec4(1.0, 1.0, 1.0, fallout);
}

vec4 draw_beams_lite(vec2 uv, int beam_count, vec2 scale, float mask) {
    vec4 col = vec4(0.0);

    if (uv.y < 0.5) { return col; }

    Beam beam1 = Beam( uBeam1PointF, uBeam1LineY, uBeam1E, uBeam1HighBand, uBeam1RGB, uBeam1Alpha, uBeam1ScaleX, uBeam1Shift, uBeam1Dispersion );
    Beam beam2 = Beam( uBeam2PointF, uBeam2LineY, uBeam2E, uBeam2HighBand, uBeam2RGB, uBeam2Alpha, uBeam2ScaleX, uBeam2Shift, uBeam2Dispersion );
    Beam beam3 = Beam( uBeam3PointF, uBeam3LineY, uBeam3E, uBeam3HighBand, uBeam3RGB, uBeam3Alpha, uBeam3ScaleX, uBeam3Shift, uBeam3Dispersion );
    Beam beam4 = Beam( uBeam4PointF, uBeam4LineY, uBeam4E, uBeam4HighBand, uBeam4RGB, uBeam4Alpha, uBeam4ScaleX, uBeam4Shift, uBeam4Dispersion );
    Beam beam5 = Beam( uBeam5PointF, uBeam5LineY, uBeam5E, uBeam5HighBand, uBeam5RGB, uBeam5Alpha, uBeam5ScaleX, uBeam5Shift, uBeam5Dispersion );

    col = blendAdd(col, beam(uv, beam1, scale) * mask);
    // col = blendAdd(col, beam(beam2, scale) * mask);
    // col = blendAdd(col, beam(beam3, scale) * mask);
    // col = blendAdd(col, beam(beam4, scale) * mask);
    // col = blendAdd(col, beam(beam5, scale) * mask);

    return col;
}

vec4 draw_beams(vec2 uv, int beam_count, vec2 scale, float mask) {
    vec4 col = vec4(0.0);

    if (uv.y < 0.5) { return col; }

    Beam beam1 = Beam( uBeam1PointF, uBeam1LineY, uBeam1E, uBeam1HighBand, uBeam1RGB, uBeam1Alpha, uBeam1ScaleX, uBeam1Shift, uBeam1Dispersion );
    Beam beam2 = Beam( uBeam2PointF, uBeam2LineY, uBeam2E, uBeam2HighBand, uBeam2RGB, uBeam2Alpha, uBeam2ScaleX, uBeam2Shift, uBeam2Dispersion );
    Beam beam3 = Beam( uBeam3PointF, uBeam3LineY, uBeam3E, uBeam3HighBand, uBeam3RGB, uBeam3Alpha, uBeam3ScaleX, uBeam3Shift, uBeam3Dispersion );
    Beam beam4 = Beam( uBeam4PointF, uBeam4LineY, uBeam4E, uBeam4HighBand, uBeam4RGB, uBeam4Alpha, uBeam4ScaleX, uBeam4Shift, uBeam4Dispersion );
    Beam beam5 = Beam( uBeam5PointF, uBeam5LineY, uBeam5E, uBeam5HighBand, uBeam5RGB, uBeam5Alpha, uBeam5ScaleX, uBeam5Shift, uBeam5Dispersion );

    col = blendAdd(col, beam(uv, beam1, scale) * mask);
    // col = blendAdd(col, beam(beam2, scale) * mask);
    col = blendAdd(col, beam(uv, beam3, scale) * mask);
    // col = blendAdd(col, beam(beam4, scale) * mask);
    col = blendAdd(col, beam(uv, beam5, scale) * mask);

    return col;
}

vec4 draw_main_beam(vec2 uv, vec2 scale, float mask) {
    Beam beam = Beam( uBeam6PointF, uBeam6LineY, uBeam6E, uBeam6HighBand, uBeam6RGB, uBeam6Alpha, uBeam6ScaleX, uBeam6Shift, uBeam6Dispersion );
    // float a = main_beam(uv, beam) * step(0.5, uv.y);
    // return main_beam(uv, beam, scale) * step(0.5, uv.y);
    return main_beam(uv, beam, scale) * mask;
    // return vec4(beam.color, a);
}

vec4 draw_particles(vec2 uv) {
    vec2 st = uv;
    st = st - 0.5;
    st.x *= uResolution.x / uResolution.y;
    st = st + 0.5;
    st -= vec2(0.0, 0.5);

    float time = uTime * 0.1;

    vec2 drag = vec2(0.0);
    vec2 offset = vec2(0.0);

    float xpart = st.x;
    float clip = 210.0 / 1550.0;
    float ypartClip = st.y / clip;
    float ypartClipped = min(ypartClip, 1.);
    float ypartClippedn = 1. - ypartClipped;
    float xfuel = 1. - abs(2. * xpart - 1.);
    float timeSpeed = 0.5;
    float realTime = timeSpeed * time;
    vec3 flow = vec3(4.1 * (0.5 - xpart) * pow(ypartClippedn, 4.), -2. * xfuel * pow(ypartClippedn, 64.), 0.);
    float sparkGridSize = 50.0 / 1550.0;
    vec2 sparkCoord = st - vec2(2. * offset.x, 190. * realTime) / vec2(2400.0, 1550.0);
    sparkCoord = sparkCoord - (30. * noiseStackUV(0.01 * vec3(sparkCoord + 30.0 * time, 30. * time), 1, 0.4, 0.1)) / vec2(2400.0, 1550.0);
    sparkCoord = sparkCoord + (100. * flow.xy) / vec2(2400.0, 1550.0);

    vec2 sparkGridIndex = vec2(floor(sparkCoord / sparkGridSize));
    float sparkRandom = prng(sparkGridIndex);
    float sparkLife = min(10. * (1. - min((sparkGridIndex.y + 190. * realTime / (sparkGridSize * 1550.0)) / (24. - 20. * sparkRandom), 1.)), 1.);
    vec3 sparks = vec3(0.);
    if (sparkLife > 0.) {
        float sparkSize = xfuel * xfuel * sparkRandom * 0.08 * uParticleCount;
        sparkSize = sparkSize * 0.08 * uParticleSize;
        float sparkRadians = 999. * sparkRandom * 2. * 3.1415927 + 2. * time;
        vec2 sparkCircular = vec2(sin(sparkRadians), cos(sparkRadians));
        vec2 sparkOffset = (0.5 - sparkSize) * sparkGridSize * sparkCircular;
        vec2 sparkLocalCoord = sparkCoord + sparkOffset;
        vec2 sparkModulus = vec2(mod(sparkLocalCoord.x, sparkGridSize), mod(sparkLocalCoord.y, sparkGridSize)) - 0.5 * vec2(sparkGridSize);
        float sparkLength = length(sparkModulus);
        float sparksGray = max(0., 1. - sparkLength / (sparkSize * sparkGridSize));
        sparks = sparkLife * sparksGray * uParticleColor.rgb;
    }

    sparks = max(sparks, vec3(0.0));
    float fade = cpfv(0.0, 0.7, 1.0 - st.y);
    vec4 col = vec4(sparks, luminance(sparks) * fade);
    return vec4(col.rgb * col.a, col.a);
}

void main() {
    vec2 uv = vUv;
    vec2 scale = vec2(1.0);
    if (uResolution.y / uResolution.x > 2400.0 / 1080.0) {
        scale.y *= uResolution.y / uResolution.x / (2400.0 / 1080.0);
    } else {
        scale.x *= uResolution.x / uResolution.y / (1080.0 / 2400.0);
    }

    uv -= 0.5;
    uv *= scale;
    uv /= uCanvasScale;
    uv += 0.5;

    vec4 col = vec4(0.0);

    // 1. Draw the flashlight shadow
    col = draw_flashlight_shadow(uv, scale);

    float mask = calc_mask(uv, scale);

    mask = mix(step(0.5, uv.y), mask, uMaskOn);

    vec2 st = vUv;
    st -= 0.5;
    st /= uCanvasScale;
    st += 0.5;

    // 2. Draw the beam
    if (uLite == 1.0) {
        col = blendAdd(col, draw_beams_lite(st, 5, scale, mask));
    } else {
        col = blendAdd(col, draw_beams(st, 5, scale, mask));
    }

    // 3. Draw the main beam
    col = blendAlpha(col, draw_main_beam(st, scale, mask));

    vec2 nst = uv;
    nst.x *= uResolution.x / uResolution.y;
    nst *= 30.0;
    float n = texture(uNoiseBwTex, nst).r;
    col.rgb = mix(clamp(col.rgb-0.01, vec3(0.0), vec3(1.0)), col.rgb + 0.01, n);

    // 4. Draw the particles
    // col = blendAdd(col, draw_particles(uv));

    // 5. Draw the metal ring
    vec4 ring = draw_metal_ring(uv, 0.1, 0.1, 0.72, 0.3);
    ring.a *= mix(0.3, 1.0, cpfv(0.0, 1.0, pfv(0.0, 0.5, uBeam6Alpha)));
    col = blendAlpha(col, ring);

    fragColor = vec4(col.rgb, col.a);
}