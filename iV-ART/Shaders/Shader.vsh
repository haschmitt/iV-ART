//
//  Shader.vsh
//  OpenGL Default
//
//  Created by Heitor Augusto Schmitt on 10/17/12.
//  Copyright (c) 2012 Heitor Augusto Schmitt. All rights reserved.
//

attribute vec4 position;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat2 colorMatrix;

void main()
{
    colorVarying = vec4(colorMatrix[0][0], colorMatrix[0][1], colorMatrix[1][0], colorMatrix[1][1]);

    gl_Position = modelViewProjectionMatrix * position;
}