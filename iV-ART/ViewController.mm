//
//  ViewController.m
//  iV-ART
//
//  Created by Heitor Augusto Schmitt on 20/09/12.
//  Copyright (c) 2012 Heitor Augusto Schmitt. All rights reserved.
//

#import  "ViewController.h"
#include "vart/meshobject.h"
#include "vart/scene.h"
#include "vart/point4d.h"
#include "vart/triangle.h"
#include "vart/uniaxialjoint.h"
#import "GlobalVar.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

using namespace VART;

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface ViewController () {
    GLuint _program;
        
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    GLKMatrix2 _color;
    GLKMatrix4 projectionMatrix;
    GLKMatrix4 modelViewMatrix;
    GLKMatrix4 baseModelViewMatrix;
    
    float _rotation;
    float _lastRotation1;
    float _lastRotation2;
    float _lastRotation3;
    float _cameraRotation;
    float model[16];
    float aspect;
    int   selectDof;

    GLuint _vertexArray;
    GLuint _vertexBuffer;

    VART::MeshObject base;
    VART::Material mat;
    VART::Dof* dofPtr1;
    VART::Dof* dofPtr2;
    VART::Dof* dofPtr3;
    VART::Dof* dofPtr4;
    VART::Dof* dofPtr5;
    VART::Dof* dofPtr6;
    VART::Dof* dofPtr7;
    VART::Dof* dofPtr8;
    VART::Dof* dofPtr9;
    VART::Dof* dofPtr10;
    VART::Dof* dofPtr11;
    VART::Dof* dofPtr12;
    VART::Dof* dofPtr13;
    VART::Dof* dofPtr14;
    VART::Dof* dofPtr15;
    VART::Dof* dofPtr16;
    VART::Dof* dofPtr17;
    VART::Dof* dofPtr18;
    VART::Dof* dofPtr19;
    VART::Dof* dofPtr20;
    VART::Dof* dofPtr21;
    VART::Dof* dofPtr22;
    VART::Dof* dofPtr23;
    VART::Dof* dofPtr24;
    VART::Dof* dofPtr25;
    VART::Dof* dofPtr26;
    VART::Dof* dofPtr27;
    VART::Dof* dofPtr28;
    VART::Dof* dofPtr29;
    VART::Dof* dofPtr30;
    VART::MeshObject arm1;
    VART::MeshObject arm2;
    VART::MeshObject arm3;
    VART::MeshObject arm4;
    VART::MeshObject arm5;
    VART::MeshObject arm6;
    VART::MeshObject arm7;
    VART::MeshObject arm8;
    VART::MeshObject arm9;
    VART::MeshObject arm10;
    VART::MeshObject arm11;
    VART::MeshObject arm12;
    VART::MeshObject arm13;
    VART::MeshObject arm14;
    VART::MeshObject arm15;
    VART::MeshObject arm16;
    VART::MeshObject arm17;
    VART::MeshObject arm18;
    VART::MeshObject arm19;
    VART::MeshObject arm20;
    VART::MeshObject arm21;
    VART::MeshObject arm22;
    VART::MeshObject arm23;
    VART::MeshObject arm24;
    VART::MeshObject arm25;
    VART::MeshObject arm26;
    VART::MeshObject arm27;
    VART::MeshObject arm28;
    VART::MeshObject arm29;
    VART::MeshObject arm30;
    VART::UniaxialJoint baseJoint;
    VART::UniaxialJoint joint12;
    VART::UniaxialJoint joint23;
    VART::UniaxialJoint joint34;
    VART::UniaxialJoint joint45;
    VART::UniaxialJoint joint56;
    VART::UniaxialJoint joint67;
    VART::UniaxialJoint joint78;
    VART::UniaxialJoint joint89;
    VART::UniaxialJoint joint910;
    VART::UniaxialJoint joint1011;
    VART::UniaxialJoint joint1112;
    VART::UniaxialJoint joint1213;
    VART::UniaxialJoint joint1314;
    VART::UniaxialJoint joint1415;
    VART::UniaxialJoint joint1516;
    VART::UniaxialJoint joint1617;
    VART::UniaxialJoint joint1718;
    VART::UniaxialJoint joint1819;
    VART::UniaxialJoint joint1920;
    VART::UniaxialJoint joint2021;
    VART::UniaxialJoint joint2122;
    VART::UniaxialJoint joint2223;
    VART::UniaxialJoint joint2324;
    VART::UniaxialJoint joint2425;
    VART::UniaxialJoint joint2526;
    VART::UniaxialJoint joint2627;
    VART::UniaxialJoint joint2728;
    VART::UniaxialJoint joint2829;
    VART::UniaxialJoint joint2930;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;
- (void)setupScene;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[UITouch alloc] init];
    CGPoint currentTouch;

    for (int nTouch = 0;  nTouch < [allTouches count];  nTouch++)
    {
        touch = [[allTouches allObjects] objectAtIndex:nTouch];
        currentTouch = [touch locationInView:[touch view]];
    }

    if (currentTouch.y > self.view.bounds.size.height/2) {
        if (currentTouch.x < self.view.bounds.size.width/2) {
            if (selectDof == 1) {
                _lastRotation1 = _lastRotation1 + 0.05f;
                if (_lastRotation1 > 1.0f) {
                    _lastRotation1 = 1.0f;
                }
            } else if (selectDof == 2) {
                _lastRotation2 = _lastRotation2 + 0.05f;
                if (_lastRotation2 > 1.0f) {
                    _lastRotation2 = 1.0f;
                }
            } else if (selectDof == 3) {
                _lastRotation3 = _lastRotation3 + 0.05f;
                if (_lastRotation3 > 1.0f) {
                    _lastRotation3 = 1.0f;
                }
            }
        } else {
            if (selectDof == 1) {
                _lastRotation1 = _lastRotation1 - 0.05f;
                if (_lastRotation1 < 0.0f) {
                    _lastRotation1 = 0.0f;
                }
            } else if (selectDof == 2) {
                _lastRotation2 = _lastRotation2 - 0.05f;
                if (_lastRotation2 < 0.0f) {
                    _lastRotation2 = 0.0f;
                }
            } else if (selectDof == 3) {
                _lastRotation3 = _lastRotation3 - 0.05f;
                if (_lastRotation3 < 0.0f) {
                    _lastRotation3 = 0.0f;
                }
            }
        }
    } else {
        if (selectDof == 2) {
            selectDof = 1;
        } else if (selectDof == 1) {
            selectDof = 3;
        } else if (selectDof == 3) {
            selectDof = 2;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    [self setupGL];
    [self setupScene];
    [self setupColor];
    [self setPreferredFramesPerSecond:60];
    _lastRotation1  = 0.4f;
    _lastRotation2  = 0.4f;
    _lastRotation3  = 0.4f;
    _cameraRotation = 45.0f;
    selectDof       = 2;
}

- (void)viewDidUnload
{    
    [super viewDidUnload];

    [self tearDownGL];

    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];

    [self loadShaders];

    self.effect = [[GLKBaseEffect alloc] init];

    glEnable(GL_DEPTH_TEST);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);

    self.effect = nil;

    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

-(void) setupScene {
    dofPtr1 = baseJoint.AddDof(Point4D::Y(),Point4D::ORIGIN(), -3.141592654, 3.141592654);
    base.AddChild(baseJoint);
    
    base.MakeBox(-1,1,-0.1,0.1,-1,1);
    mat = VART::Material::DARK_PLASTIC_GRAY();
    base.SetMaterial(mat);

    //    base -> arm1
    arm1.MakeBox(-0.1,0.1, 0,0.5, -0.1,0.1);
    arm1.SetMaterial(VART::Material::PLASTIC_GREEN());
    baseJoint.AddChild(arm1);

    dofPtr2 = joint12.AddDof(Point4D::Z(), Point4D(0,0.5,0), -1.570796327, 1.570796327);
    arm1.AddChild(joint12);

    //    joint12 -> arm2
    arm2.MakeBox(-0.1,0.1, 0.5,1, -0.1,0.1);
    arm2.SetMaterial(VART::Material::PLASTIC_GREEN());
    joint12.AddChild(arm2);

    dofPtr3 = joint23.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    arm2.AddChild(joint23);

    //    joint23 -> arm3
    arm3.MakeBox(-0.1,0.1, 1,1.5, -0.1,0.1);
    arm3.SetMaterial(VART::Material::PLASTIC_GREEN());
    joint23.AddChild(arm3);
    
    //TESTES DE PERFORMANCE
    /*
    dofPtr4 = joint34.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    arm3.AddChild(joint34);
    
    arm4.MakeBox(-0.1,0.1, 1.5,2.0, -0.1,0.1);
    arm4.SetMaterial(VART::Material::PLASTIC_GREEN());
    joint34.AddChild(arm4);
    
    arm5.MakeBox(-0.1,0.1, 2,2.5, -0.1,0.1);
    arm6.MakeBox(-0.1,0.1, 2.5,3, -0.1,0.1);
    arm7.MakeBox(-0.1,0.1, 3,3.5, -0.1,0.1);
    arm8.MakeBox(-0.1,0.1, 3.5,4, -0.1,0.1);
    arm9.MakeBox(-0.1,0.1, 4,4.5, -0.1,0.1);
    arm10.MakeBox(-0.1,0.1, 4.5,5, -0.1,0.1);
    arm11.MakeBox(-0.1,0.1, 5,5.5, -0.1,0.1);
    arm12.MakeBox(-0.1,0.1, 5.5,6, -0.1,0.1);
    arm13.MakeBox(-0.1,0.1, 6,6.5, -0.1,0.1);
    arm14.MakeBox(-0.1,0.1, 6.5,7, -0.1,0.1);
    arm15.MakeBox(-0.1,0.1, 7,7.5, -0.1,0.1);
    arm16.MakeBox(-0.1,0.1, 7.5,8, -0.1,0.1);
    arm17.MakeBox(-0.1,0.1, 8,8.5, -0.1,0.1);
    arm18.MakeBox(-0.1,0.1, 8.5,9, -0.1,0.1);
    arm19.MakeBox(-0.1,0.1, 9,9.5, -0.1,0.1);
    arm20.MakeBox(-0.1,0.1, 9.5,10, -0.1,0.1);
    arm21.MakeBox(-0.1,0.1, 10,10.5, -0.1,0.1);
    arm22.MakeBox(-0.1,0.1, 10.5,11, -0.1,0.1);
    arm23.MakeBox(-0.1,0.1, 11,11.5, -0.1,0.1);
    arm24.MakeBox(-0.1,0.1, 11.5,12, -0.1,0.1);
    arm25.MakeBox(-0.1,0.1, 12,12.5, -0.1,0.1);
    arm26.MakeBox(-0.1,0.1, 12.5,13, -0.1,0.1);
    arm27.MakeBox(-0.1,0.1, 13,13.5, -0.1,0.1);
    arm28.MakeBox(-0.1,0.1, 13.5,14, -0.1,0.1);
    arm29.MakeBox(-0.1,0.1, 14,14.5, -0.1,0.1);
    arm30.MakeBox(-0.1,0.1, 14.5,15, -0.1,0.1);
    
    
    arm5.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm6.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm7.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm8.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm9.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm10.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm11.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm12.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm13.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm14.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm15.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm16.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm17.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm18.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm19.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm20.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm21.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm22.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm23.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm24.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm25.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm26.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm27.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm28.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm29.SetMaterial(VART::Material::PLASTIC_GREEN());
    arm30.SetMaterial(VART::Material::PLASTIC_GREEN());
    
    dofPtr5 = joint45.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr6 = joint56.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr7 = joint67.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr8 = joint78.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr9 = joint89.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr10 = joint910.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr11 = joint1011.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr12 = joint1112.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr13 = joint1213.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr14 = joint1314.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr15 = joint1415.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr16 = joint1516.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr17 = joint1617.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr18 = joint1718.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr19 = joint1819.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr20 = joint1920.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr21 = joint2021.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr22 = joint2122.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr23 = joint2223.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr24 = joint2324.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr25 = joint2425.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr26 = joint2526.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr27 = joint2627.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr28 = joint2728.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr29 = joint2829.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    dofPtr30 = joint2930.AddDof(Point4D::Z(), Point4D(0,1,0), -1.570796327, 1.570796327);
    
    arm4.AddChild(joint45);
    arm5.AddChild(joint56);
    arm6.AddChild(joint67);
    arm7.AddChild(joint78);
    arm8.AddChild(joint89);
    arm9.AddChild(joint910);
    arm10.AddChild(joint1011);
    arm11.AddChild(joint1112);
    arm12.AddChild(joint1213);
    arm13.AddChild(joint1314);
    arm14.AddChild(joint1415);
    arm15.AddChild(joint1516);
    arm16.AddChild(joint1617);
    arm17.AddChild(joint1718);
    arm18.AddChild(joint1819);
    arm19.AddChild(joint1920);
    arm20.AddChild(joint2021);
    arm21.AddChild(joint2122);
    arm22.AddChild(joint2223);
    arm23.AddChild(joint2324);
    arm24.AddChild(joint2425);
    arm25.AddChild(joint2526);
    arm26.AddChild(joint2627);
    arm27.AddChild(joint2728);
    arm28.AddChild(joint2829);
    arm29.AddChild(joint2930);
    
    joint45.AddChild(arm5);
    joint56.AddChild(arm6);
    joint67.AddChild(arm7);
    joint78.AddChild(arm8);
    joint89.AddChild(arm9);
    joint910.AddChild(arm10);
    joint1011.AddChild(arm11);
    joint1112.AddChild(arm12);
    joint1213.AddChild(arm13);
    joint1314.AddChild(arm14);
    joint1415.AddChild(arm15);
    joint1516.AddChild(arm16);
    joint1617.AddChild(arm17);
    joint1718.AddChild(arm18);
    joint1819.AddChild(arm19);
    joint1920.AddChild(arm20);
    joint2021.AddChild(arm21);
    joint2122.AddChild(arm22);
    joint2223.AddChild(arm23);
    joint2324.AddChild(arm24);
    joint2425.AddChild(arm25);
    joint2526.AddChild(arm26);
    joint2627.AddChild(arm27);
    joint2728.AddChild(arm28);
    joint2829.AddChild(arm29);
    joint2930.AddChild(arm30);
     */
}

-(void) setupColor {
    _color.m00 = mat.GetDiffuseColor().GetR()/255.0f;
    _color.m01 = mat.GetDiffuseColor().GetG()/255.0f;
    _color.m10 = mat.GetDiffuseColor().GetB()/255.0f;
    _color.m11 = mat.GetDiffuseColor().GetA()/255.0f;

    glUniformMatrix2fv(uniforms[UNIFORM_COLOR_MATRIX], 1, 0, _color.m);
}

-(void) setupMatrix {
    aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);

    projectionMatrix = GLKMatrix4Multiply(projectionMatrix, GLKMatrix4MakeTranslation(-0.5f, -1.0f, -2.0f));

    self.effect.transform.projectionMatrix = projectionMatrix;

    modelViewMatrix = GLKMatrix4MakeTranslation(0.5f, 0.0f, 1.5f);

    self.effect.transform.modelviewMatrix = modelViewMatrix;

    baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);

    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_cameraRotation), 0.0f, 1.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);

    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

    model[0]  = _modelViewProjectionMatrix.m00;
    model[1]  = _modelViewProjectionMatrix.m01;
    model[2]  = _modelViewProjectionMatrix.m02;
    model[3]  = _modelViewProjectionMatrix.m03;
    model[4]  = _modelViewProjectionMatrix.m10;
    model[5]  = _modelViewProjectionMatrix.m11;
    model[6]  = _modelViewProjectionMatrix.m12;
    model[7]  = _modelViewProjectionMatrix.m13;
    model[8]  = _modelViewProjectionMatrix.m20;
    model[9]  = _modelViewProjectionMatrix.m21;
    model[10] = _modelViewProjectionMatrix.m22;
    model[11] = _modelViewProjectionMatrix.m23;
    model[12] = _modelViewProjectionMatrix.m30;
    model[13] = _modelViewProjectionMatrix.m31;
    model[14] = _modelViewProjectionMatrix.m32;
    model[15] = _modelViewProjectionMatrix.m33;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

    [self setupMatrix];

    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // Render the object again with ES2
    glUseProgram(_program);

    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniformMatrix2fv(uniforms[UNIFORM_COLOR_MATRIX], 1, 0, _color.m);

    dofPtr1->MoveTo(_lastRotation2);
    dofPtr2->MoveTo(_lastRotation1);
    dofPtr3->MoveTo(_lastRotation3);

    base.DrawOGL(model);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    // Create shader program.
    _program = glCreateProgram();

    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }

    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);

    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);

    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }

    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    
    uniforms[UNIFORM_COLOR_MATRIX] = glGetUniformLocation(_program, "colorMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }

    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }

    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }

    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }

    return YES;
}

@end