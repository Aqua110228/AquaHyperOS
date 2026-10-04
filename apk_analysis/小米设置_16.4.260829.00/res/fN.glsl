/*
 * Copyright (C) 2020, Xiaomi Inc. All rights reserved.
 */

attribute vec2 aPosition;
attribute vec2 aTexCoord;
varying vec2 o_TexCoord;

void main() {
    o_TexCoord = aTexCoord;
    o_TexCoord.y = 1. - o_TexCoord.y;
    gl_Position = vec4(aPosition,1.0,1.0);
}
