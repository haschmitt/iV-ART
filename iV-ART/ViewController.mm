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
    float _lastRotation;
    float model[16];
    float aspect;

    GLuint _vertexArray;
    GLuint _vertexBuffer;

    VART::MeshObject base;
    VART::Material mat;
    VART::Dof* dofPtr1;
    VART::Dof* dofPtr2;
    VART::Dof* dofPtr3;
    VART::MeshObject arm1;
    VART::MeshObject arm2;
    VART::MeshObject arm3;
    VART::UniaxialJoint baseJoint;
    VART::UniaxialJoint joint12;
    VART::UniaxialJoint joint23;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[UITouch alloc] init];
    CGPoint currentTouch;

    for (int nTouch = 0;  nTouch < [allTouches count];  nTouch++)
    {
        touch = [[allTouches allObjects] objectAtIndex:nTouch];
        currentTouch = [touch locationInView:[touch view]];
    }

    if (currentTouch.y > self.view.bounds.size.height/2) {
        if (currentTouch.x > self.view.bounds.size.width/2) {
            _lastRotation = _lastRotation + 0.1f;
            if (_lastRotation > 1.0f) {
                _lastRotation = 1.0f;
            }
        } else {
            _lastRotation = _lastRotation - 0.1f;
            if (_lastRotation < 0.0f) {
                _lastRotation = 0.0f;
            }
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
    _lastRotation = 0.0f;
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
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);

    projectionMatrix = GLKMatrix4Multiply(projectionMatrix, GLKMatrix4MakeTranslation(-0.5f, -1.0f, -2.0f));

    projectionMatrix = GLKMatrix4RotateX(projectionMatrix, GLKMathDegreesToRadians(15.0f));

    self.effect.transform.projectionMatrix = projectionMatrix;

    modelViewMatrix = GLKMatrix4MakeTranslation(0.5f, 0.0f, 1.5f);

    self.effect.transform.modelviewMatrix = modelViewMatrix;

    baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);

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

    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBindVertexArrayOES(_vertexArray);

    // Render the object again with ES2
    glUseProgram(_program);

    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);

    _color.m00 = mat.GetDiffuseColor().GetR()/255.0f;
    _color.m01 = mat.GetDiffuseColor().GetG()/255.0f;
    _color.m10 = mat.GetDiffuseColor().GetB()/255.0f;
    _color.m11 = mat.GetDiffuseColor().GetA()/255.0f;
    
    glUniformMatrix2fv(uniforms[UNIFORM_COLOR_MATRIX], 1, 0, _color.m);
    
    dofPtr1->MoveTo(0.4);
    dofPtr2->MoveTo(_lastRotation);
    dofPtr3->MoveTo(0.4);
    
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
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
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