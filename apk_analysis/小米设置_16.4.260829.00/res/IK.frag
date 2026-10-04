uniform vec2 uResolution;
uniform float uTime;// nouse
uniform shader uTex;// nouse

uniform float uTrackProgress;
uniform vec2 uTrackSize;
uniform vec2 uTrackPosition;
uniform vec2 uTrackCanvasSize;
uniform vec2 uHeadSize;
uniform float uHeadGlowAlpha;
uniform int uIsRtl;


vec4 addBlend(vec4 src, vec4 dst) {
    vec3 color = src.rgb + dst.rgb;
    float alpha = src.a + (1.0 - src.a) + dst.a;
    return vec4(color, alpha);
}

vec4 alphaBlend(vec4 src, vec4 dst) {
    vec3 color = src.rgb + (1.0 - src.a) * dst.rgb;
    float alpha = src.a + dst.a * (1.0 - src.a);
    return vec4(color, alpha);
}


float rbx( in vec2 p, in vec2 b, in vec4 r ) {
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}

float capsule(in vec2 uv, in vec2 pos, in vec2 size) {
    vec2 p = uv - vec2(0.5);
    p.x *= uResolution.x / uResolution.y;

    vec2 b = size / uResolution.y / 2.0;
    //    p.y -= 0.5 - pos.y / uResolution.y;
    p.y += (uResolution.y / 2.0 - pos.y - size.y / 2.0) / uResolution.y;
    p.x -= pos.x / uResolution.y + b.x - uResolution.x / uResolution.y / 2.0;

    vec4 r = vec4(min(size.x, size.y) / uResolution.y / 2.0);
    float d = rbx(p, b, r);
    // return smoothstep(0.001, -0.001, d);
    return d;
}

vec4 draw_track(in vec2 uv) {
    float d = capsule(uv, vec2(uTrackPosition.x, uResolution.y - uTrackPosition.y - uTrackSize.y / 2.0), uTrackSize);
    float a = smoothstep(0.001, -0.001, d);
    return vec4(0.2 * a);
}

vec4 draw_track_progress(in vec2 uv, in float progress) {
    //    vec2 csize = uTrackCanvasSize;
    //    vec2 hsize = uHeadSize ;
    vec2 hsize = vec2(75.0, 38.0) * 2.7551020408; ;
    float thight = 6.0 * 2.7551020408;
    float xoffset = 52.0 * 2.7551020408;

    vec2 st = uv;
    // map st to tracksize
    st.x = (st.x - uTrackPosition.x / uResolution.x) / (uTrackSize.x / uResolution.x);
    st.y = (st.y - (uResolution.y - uTrackPosition.y - uTrackSize.y / 2.0) / uResolution.y) * (uResolution.y / uTrackSize.y);

    // float startFade = clamp(st.x / (uTrackSize.y / uTrackSize.x * (hsize.x / hsize.y)), 0.0, 1.0);
    float startFade = smoothstep(0.0, uTrackSize.y / uTrackSize.x * (hsize.x / hsize.y) * 1.5, st.x);

    st.x -= mix(uTrackSize.y / 2.0, uTrackSize.x - uTrackSize.y / 2.0, progress) / uTrackSize.x;


    // scale the head size to the track size
    st.y -= 0.5;
    st.x /= (uTrackSize.y / thight) * (hsize.x / uTrackSize.x);
    st.y /= (uTrackSize.y / thight) * (hsize.y / uTrackSize.y);
    st.y += 0.5;

    // move the head to the start of the track
    st.x -= -xoffset / hsize.x;

    vec4 head = uTex.eval(st*uHeadSize);// * 0.5;
    head *= startFade * uHeadGlowAlpha;
    return head;
}

vec4 main(vec2 fragCoord){
    vec2 vUv = fragCoord / uResolution;
    if (uIsRtl == 1) {
        vUv.x = 1.0 - vUv.x;
    }
    vec4 color = vec4(0.0);

    // 1. the track
//    vec4 track = draw_track(vUv);
//    //    return track;
//    color = alphaBlend(track, color);

//     2. the progress
    vec4 progress = draw_track_progress(vUv, uTrackProgress);
    color = alphaBlend(progress, color);
    return color;
}