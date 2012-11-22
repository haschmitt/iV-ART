//
//  GlobalVar.h
//  iV-ART
//
//  Created by Heitor Augusto Schmitt on 11/1/12.
//  Copyright (c) 2012 Heitor Augusto Schmitt. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_COLOR_MATRIX,
    NUM_UNIFORMS
};
extern GLint uniforms[NUM_UNIFORMS];

@interface GlobalVar : NSObject

@end