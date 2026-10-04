const vec2 RESOLUTION = vec2(1300.0, 1500.0);
const vec2 INIT_SIZE = vec2(511.0, 592.0);
const int MAX_STOPS = 5; // Maximum number of color stops supported
uniform shader uMainTx;
uniform shader uDigitBRMain;
uniform shader uDigitTLMain;
uniform shader uDigitBLMain;
uniform shader uDigitTRMain;
uniform shader uTexture;
uniform shader uFigure;
uniform float uHue;
uniform vec2 uDigitTLPosition;
uniform vec2 uDigitTRPosition;
uniform vec2 uDigitBLPosition;
uniform vec2 uDigitBRPosition;

vec3 rgb_to_hsv(vec3 rgb) {
  float cmax, cmin, h, s, v, cdelta;
  vec3 c;

  cmax = max(rgb[0], max(rgb[1], rgb[2]));
  cmin = min(rgb[0], min(rgb[1], rgb[2]));
  cdelta = cmax - cmin;

  v = cmax;

  if (cmax != 0.0) {
    s = cdelta / cmax;
  }
  else {
    s = 0.0;
    h = 0.0;
  }

  if (s == 0.0) {
    h = 0.0;
  }
  else {
    c = (vec3(cmax, cmax, cmax) - rgb) / cdelta;

    if (rgb[0] == cmax) {
      h = c[2] - c[1];
    }
    else if (rgb[1] == cmax) {
      h = 2.0 + c[0] - c[2];
    }
    else {
      h = 4.0 + c[1] - c[0];
    }

    h /= 6.0;

    if (h < 0.0) {
      h += 1.0;
    }
  }

  return vec3(h, s, v);
}

vec3 hsv_to_rgb(vec3 hsv) {
  float i, f, p, q, t, h, s, v;
  vec3 rgb;

  h = hsv[0];
  s = hsv[1];
  v = hsv[2];

  if (s == 0.0) {
    rgb = vec3(v, v, v);
  }
  else {
    if (h == 1.0) {
      h = 0.0;
    }

    h *= 6.0;
    i = floor(h);
    f = h - i;
    rgb = vec3(f, f, f);
    p = v * (1.0 - s);
    q = v * (1.0 - (s * f));
    t = v * (1.0 - (s * (1.0 - f)));

    if (i == 0.0) {
      rgb = vec3(v, t, p);
    }
    else if (i == 1.0) {
      rgb = vec3(q, v, p);
    }
    else if (i == 2.0) {
      rgb = vec3(p, v, t);
    }
    else if (i == 3.0) {
      rgb = vec3(p, q, v);
    }
    else if (i == 4.0) {
      rgb = vec3(t, p, v);
    }
    else {
      rgb = vec3(v, p, q);
    }
  }

  return rgb;
}

vec3 hue_sat(float hue, float sat, float value, float fac, vec3 col) {
  vec3 hsv = rgb_to_hsv(col.rgb);

  hsv[0] = fract(hsv[0] + hue + 0.5);
  hsv[1] = clamp(hsv[1] * sat, 0.0, 1.0);
  hsv[2] = hsv[2] * value;

  vec3 outcol = hsv_to_rgb(hsv);

  return mix(col, outcol, fac);
}

vec3 linearTosRGB(vec3 linearRGB) {
  vec3 cutoff = step(vec3(0.0031308), linearRGB);
  vec3 higher = 1.055 * pow(linearRGB, vec3(1.0/2.4)) - 0.055;
  vec3 lower = linearRGB * 12.92;

  return mix(lower, higher, cutoff);
}

// For handling alpha channel as well
vec4 linearTosRGB(vec4 linearRGB) {
  return vec4(linearTosRGB(linearRGB.rgb), linearRGB.a);
}

vec4 blendAlpha(vec4 src, vec4 dst) {
  return src + dst * (1.0 - src.a);
}

vec4 drawTex(vec4 main, vec2 st) {
//  vec2 tl = t - size / 2.0;
//  vec2 br = t + size / 2.0;
//
//  vec2 st = uv - t;
//
//  st = st * s / size;
//  // rotate
//  st = vec2(
//  st.x * cos(r) - st.y * sin(r),
//  st.x * sin(r) + st.y * cos(r)
//  );
//  // translate
//  st += 0.5;
//
//  vec4 main = mainTex.eval(st*RESOLUTION);

  if (main.a < 0.1) {
    return vec4(0.0);
  }

  if (st.x < 0.0 || st.x > 1.0 || st.y < 0.0 || st.y > 1.0) {
    return vec4(0.0);
  }

  // vec3 hsv = rgb_to_hsv(main.rgb);
  vec3 color = hue_sat(uHue, 1.5, 1.0, 1.0, main.rgb);

  // color.rgb = hsv_to_rgb(hsv);

  return vec4(color, main.a);
}

vec4 drawTLDigit(vec2 uv) {
  vec2 t = uDigitTLPosition / RESOLUTION;
  vec2 size = INIT_SIZE / RESOLUTION;
  float r = 0.0;
  float s = 1.0;
  ///////////////////////
  vec2 tl = t - size / 2.0;
  vec2 br = t + size / 2.0;

  vec2 st = uv - t;

  st = st * s / size;
  // rotate
  st = vec2(
  st.x * cos(r) - st.y * sin(r),
  st.x * sin(r) + st.y * cos(r)
  );
  // translate
  st += 0.5;

  vec4 main = uDigitTLMain.eval(st*RESOLUTION);
  return drawTex(main ,st);
}

vec4 drawTRDigit(vec2 uv) {
  vec2 t = uDigitTRPosition / RESOLUTION;
  vec2 size = INIT_SIZE / RESOLUTION;
  float r = 0.0;
  float s = 1.0;
  vec2 tl = t - size / 2.0;
  vec2 br = t + size / 2.0;

  vec2 st = uv - t;

  st = st * s / size;
  // rotate
  st = vec2(
  st.x * cos(r) - st.y * sin(r),
  st.x * sin(r) + st.y * cos(r)
  );
  // translate
  st += 0.5;

  vec4 main = uDigitTRMain.eval(st*RESOLUTION);
  return drawTex(main ,st);
}

vec4 drawBLDigit(vec2 uv) {
  vec2 t = uDigitBLPosition / RESOLUTION;
  vec2 size = INIT_SIZE / RESOLUTION;
  float r = 0.0;
  float s = 1.0;
  vec2 tl = t - size / 2.0;
  vec2 br = t + size / 2.0;

  vec2 st = uv - t;

  st = st * s / size;
  // rotate
  st = vec2(
  st.x * cos(r) - st.y * sin(r),
  st.x * sin(r) + st.y * cos(r)
  );
  // translate
  st += 0.5;

  vec4 main = uDigitBLMain.eval(st*RESOLUTION);
  return drawTex(main ,st);
}

vec4 drawBRDigit(vec2 uv) {
  vec2 t = uDigitBRPosition / RESOLUTION;
  vec2 size = INIT_SIZE / RESOLUTION;
  float r = radians(15.4);
  float s = 1.0;
  vec2 tl = t - size / 2.0;
  vec2 br = t + size / 2.0;

  vec2 st = uv - t;

  st = st * s / size;
  // rotate
  st = vec2(
  st.x * cos(r) - st.y * sin(r),
  st.x * sin(r) + st.y * cos(r)
  );
  // translate
  st += 0.5;

  vec4 main = uDigitBRMain.eval(st*RESOLUTION);
  return drawTex(main ,st);
}

vec4 main(vec2 xy) {
  vec4 fragColor;
  vec4 main = uMainTx.eval(xy);
  vec3 color = hue_sat(uHue, 1.5, 1.0, 1.0, main.xyz);
  fragColor = vec4(color, main.a);
  return fragColor;
}