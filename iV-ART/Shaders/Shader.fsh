//
//  Shader.fsh
//  iV-ART
//
//  Created by Heitor Augusto Schmitt on 20/09/12.
//  Copyright (c) 2012 Heitor Augusto Schmitt. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
