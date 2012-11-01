//
//  Shader.vsh
//  OpenGL Default
//
//  Created by Heitor Augusto Schmitt on 10/17/12.
//  Copyright (c) 2012 Heitor Augusto Schmitt. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
//uniform vec4 colorVector;
uniform mat2 colorMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);

    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));

    colorVarying = vec4(colorMatrix[0][0], colorMatrix[0][1], colorMatrix[1][0], colorMatrix[1][1]);

    gl_Position = modelViewProjectionMatrix * position;
}