
precision highp float;

varying vec2 o_TexCoord;

uniform float uTime;
uniform float uTimeOffset;
uniform float uBlur;

uniform vec3 u_LtColor;
uniform vec3 u_LmColor;
uniform vec3 u_LbColor;

uniform vec3 u_RtColor;
uniform vec3 u_RmColor;
uniform vec3 u_RbColor;



vec3 sat(vec3 rgb,float par){
    vec3 W = vec3(0.2125,0.7154,0.0721);
    vec3 intensity = vec3(dot(rgb,W));
    return mix(intensity,rgb,par);
}
vec3 ContrastSaturationBrightness(vec3 color, float brt, float sat, float con){
    const float AvgLumR = 0.5;
    const float AvgLumG = 0.5;
    const float AvgLumB = 0.5;

    const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);

    vec3 AvgLumin  = vec3(AvgLumR, AvgLumG, AvgLumB);
    vec3 brtColor  = color * brt;
    vec3 intensity = vec3(dot(brtColor, LumCoeff));
    vec3 satColor  = mix(intensity, brtColor, sat);
    vec3 conColor  = mix(AvgLumin, satColor, con);

    return conColor;
}
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,
    0.366025403784439,
    -0.577350269189626,
    0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289(i);
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}
vec3 getCol(vec2 st){
    vec3 tCol = mix(u_LmColor,u_RtColor,st.x);
    vec3 mCol = mix(u_LmColor,u_RmColor,st.x);
    vec3 bCol = mix(u_LbColor,u_RbColor,st.x);
    if(st.y < 0.5) return mix(bCol,mCol,st.y/0.5);
    else return mix(mCol,tCol,(st.y-0.5)/0.5);
}
void main() {
    vec2 uv = o_TexCoord;
    vec2 st = uv;
    //st.y = 1.-st.y;

    st.x -= 0.5;
    st.x *= 0.8;
    st.x += 0.5;

    float t = uTime / 20.;

    float s;
    int type = 1;
    s = snoise(vec2(st.x+t,st.y*1.3+uTimeOffset+t));

    float ef = 0.8 + s;

    st *= vec2(ef);
    vec3 col = getCol(st);

    col = ContrastSaturationBrightness(
    col,
    1.,
    1.2,
    1.
    );
    col = mix(col,vec3(0.),0.3);

    gl_FragColor = vec4(col,1.);
}