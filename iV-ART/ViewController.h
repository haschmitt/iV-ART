//
//  ViewController.h
//  iV-ART
//
//  Created by Heitor Augusto Schmitt on 20/09/12.
//  Copyright (c) 2012 Heitor Augusto Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#include "vart/Scene.h"

@interface ViewController : GLKViewController {
    VART::Scene scene;
}

@end
