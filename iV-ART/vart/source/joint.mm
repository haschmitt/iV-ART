/// \file joint.cpp
/// \brief Implementation file for V-ART class "Joint".
/// \version $Revision: 1.7 $

#include <algorithm>
#include <cassert>
#include "vart/joint.h"
#include "vart/dof.h"

#ifdef WIN32
#include <windows.h>
#endif
#ifdef VART_OGL
	#if defined(__APPLE__) || defined(MACOSX)
        #include <OpenGL/gl.h>
    #else
        #include <GL/gl.h>
    #endif
#else
    #ifdef VART_OGL_IOS
//        #include <OpenGLES/ES2/gl.h>
//        #include <OpenGLES/ES2/glext.h>
        #include <GLKit/GLKit.h>
        #import "GlobalVar.h"
    #endif
#endif

//enum
//{
//    UNIFORM_MODELVIEWPROJECTION_MATRIX,
//    UNIFORM_NORMAL_MATRIX,
//    UNIFORM_COLOR_MATRIX,
//    NUM_UNIFORMS
//};
//GLint uniforms2[NUM_UNIFORMS];

using namespace std;

VART::Joint::Joint()
{
}

VART::Joint::Joint(const Joint& j)
{
    this->operator=(j);
}

VART::SceneNode * VART::Joint::Copy()
{
    VART::Joint * copy;
    
    copy = new VART::Joint(*this);
    copy->CopyDofListFrom(*this);
    return copy;
}

void VART::Joint::CopyDofListFrom( VART::Joint& joint )
{
    std::list<Dof*>::iterator iter;
    VART::Dof* dof;

    dofList.clear();
    for( iter = joint.dofList.begin(); iter != joint.dofList.end(); iter++ )
    {
        dof = new VART::Dof(**iter);
        dof->SetOwnerJoint( this );
        AddDof( dof );
    }
}

VART::Joint::~Joint()
{
    // Deallocate all Dofs marked as autoDelete
    list<VART::Dof*>::iterator iter;
    for (iter = dofList.begin(); iter != dofList.end(); ++iter)
    {
        if ((*iter)->autoDelete)
            delete *iter;
    }
}

const VART::Joint& VART::Joint::operator=(const Joint& j)
{
    this->Transform::operator=(j);
    dofList = j.dofList;
    return *this;
}

VART::Dof* VART::Joint::AddDof(const Point4D& vec, const Point4D& pos, float min, float max)
{
    Dof* dofPtr = new Dof(vec, pos, min, max);
    dofPtr->SetOwnerJoint(this);
    dofList.push_back(dofPtr);
    return dofPtr;
}

void VART::Joint::AddDof(VART::Dof* dof)
{
    dofList.push_back(dof);
    dof->SetOwnerJoint(this);
}

void VART::Joint::MakeLim()
// In visual mode, the lim is not really used
{
// LIM = ...DOF3 * DOF2 * DOF1
    list<VART::Dof*>::reverse_iterator iter = dofList.rbegin();

    // Copy DOF1's matrix to this object
    (*iter)->GetLim(this);
    ++iter;
    while (iter != dofList.rend())
    {
        // this = dof * this
        (*iter)->ApplyTransformTo(this);
        ++iter;
    }
}

const VART::Dof& VART::Joint::GetDof(DofID dof) const
{
    assert(static_cast<int>(dofList.size()) > dof);
    list<VART::Dof*>::const_iterator iter = dofList.begin();
    int position = 0;
    while (position < dof)
    {
        ++position;
        ++iter;
    }
    return **iter;
}

void VART::Joint::GetDofs(std::list<Dof*>* dofListPtr)
// Warning: this method exposes the dofs of a joint. It has been created for IKChain's constructor.
// An IK chain is a sequence of DOFs that need to need in order to make an articulated object reach
// a certain state, therefore, DOFs must not be constant. I'm not sure if there is a better way to
// deal with encapsulation of the joint class in this case (perhaps making it a friend of IKChain?).
{
    list<Dof*>::iterator iter = dofList.begin();
    while (iter != dofList.end())
    {
        dofListPtr->push_back(*iter);
        ++iter;
    }
}

VART::Joint::DofID VART::Joint::GetDofID(const Dof* dofPtr) const
{
    list<Dof*>::const_iterator iter = dofList.begin();
    unsigned int dofIndex = 0;
    
    while ((iter != dofList.end()) && (*iter != dofPtr))
    {
        ++iter;
        ++dofIndex;
    }
    assert(iter != dofList.end());
    return static_cast<DofID>(dofIndex);
}

void VART::Joint::SetAtRest()
{
    list<VART::Dof*>::iterator iter;
    for(iter = dofList.begin(); iter != dofList.end(); ++iter)
        (*iter)->Rest();
}

bool VART::Joint::MoveDof(DofID dof, float variance)
{
    unsigned int dofNum = static_cast<unsigned int>(dof);

    if (dofNum < dofList.size())
    {
        list<VART::Dof*>::iterator iter = dofList.begin();
        while (dofNum > 0)
        {
            ++iter;
            --dofNum;
        }
        (*iter)->Move(variance);
        return true;
    }
    else
        return false;
}

bool VART::Joint::HasDof(DofID dof)
{
    return static_cast<unsigned int>(dof) < dofList.size();
}

#ifdef VISUAL_JOINTS
bool VART::Joint::DrawOGL(float *model) const {
    bool result = true;
    list<VART::SceneNode*>::const_iterator iter;
    list<VART::Dof*>::const_iterator dofIter;
    int i = 0;
    GLKMatrix4 _modelViewProjectionMatrix;

    GLKMatrix4 modelViewMatrix;
    modelViewMatrix.m00 = model[0];
    modelViewMatrix.m01 = model[1];
    modelViewMatrix.m02 = model[2];
    modelViewMatrix.m03 = model[3];
    modelViewMatrix.m10 = model[4];
    modelViewMatrix.m11 = model[5];
    modelViewMatrix.m12 = model[6];
    modelViewMatrix.m13 = model[7];
    modelViewMatrix.m20 = model[8];
    modelViewMatrix.m21 = model[9];
    modelViewMatrix.m22 = model[10];
    modelViewMatrix.m23 = model[11];
    modelViewMatrix.m30 = model[12];
    modelViewMatrix.m31 = model[13];
    modelViewMatrix.m32 = model[14];
    modelViewMatrix.m33 = model[15];

    for (dofIter = dofList.begin(); dofIter != dofList.end(); ++dofIter)
    {
        GLKMatrix4 matrix;
        matrix.m00 = static_cast<float>((*dofIter)->GetLim().GetData()[0]);
        matrix.m01 = static_cast<float>((*dofIter)->GetLim().GetData()[1]);
        matrix.m02 = static_cast<float>((*dofIter)->GetLim().GetData()[2]);
        matrix.m03 = static_cast<float>((*dofIter)->GetLim().GetData()[3]);
        matrix.m10 = static_cast<float>((*dofIter)->GetLim().GetData()[4]);
        matrix.m11 = static_cast<float>((*dofIter)->GetLim().GetData()[5]);
        matrix.m12 = static_cast<float>((*dofIter)->GetLim().GetData()[6]);
        matrix.m13 = static_cast<float>((*dofIter)->GetLim().GetData()[7]);
        matrix.m20 = static_cast<float>((*dofIter)->GetLim().GetData()[8]);
        matrix.m21 = static_cast<float>((*dofIter)->GetLim().GetData()[9]);
        matrix.m22 = static_cast<float>((*dofIter)->GetLim().GetData()[10]);
        matrix.m23 = static_cast<float>((*dofIter)->GetLim().GetData()[11]);
        matrix.m30 = static_cast<float>((*dofIter)->GetLim().GetData()[12]);
        matrix.m31 = static_cast<float>((*dofIter)->GetLim().GetData()[13]);
        matrix.m32 = static_cast<float>((*dofIter)->GetLim().GetData()[14]);
        matrix.m33 = static_cast<float>((*dofIter)->GetLim().GetData()[15]);

        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, matrix);
        _modelViewProjectionMatrix = modelViewMatrix;

        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);

        GetMaterial(i).DrawOGL();
        (*dofIter)->DrawInstanceOGL();
        ++i;
    }

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

//    VART::Material mat = GetMaterial(i);
//    
//    _color.m00 = mat.GetDiffuseColor().GetR()/255.0f;
//    _color.m01 = mat.GetDiffuseColor().GetG()/255.0f;
//    _color.m10 = mat.GetDiffuseColor().GetB()/255.0f;
//    _color.m11 = mat.GetDiffuseColor().GetA()/255.0f;
//    
//    glUniformMatrix2fv(uniforms[UNIFORM_COLOR_MATRIX], 1, 0, _color.m);

    for (iter = childList.begin(); iter != childList.end(); ++iter)
        result &= (*iter)->DrawOGL(model);

    return result;
}
#endif

#ifdef VISUAL_JOINTS
bool VART::Joint::DrawOGL() const
{
#ifdef VART_OGL
    bool result = true;
    list<VART::SceneNode*>::const_iterator iter;
    list<VART::Dof*>::const_iterator dofIter;
    int i = 0;

    glPushMatrix();

    for (dofIter = dofList.begin(); dofIter != dofList.end(); ++dofIter)
    {
        glMultMatrixd((*dofIter)->GetLim().GetData());
        GetMaterial(i).DrawOGL();
        (*dofIter)->DrawInstanceOGL();
        ++i;
    }
    for (iter = childList.begin(); iter != childList.end(); ++iter)
        result &= (*iter)->DrawOGL();
    glPopMatrix();
    return result;
#else
    #ifdef VART_OGL_IOS
        bool result = true;
        list<VART::SceneNode*>::const_iterator iter;
        list<VART::Dof*>::const_iterator dofIter;
        int i = 0;
    
        for (dofIter = dofList.begin(); dofIter != dofList.end(); ++dofIter)
        {
            GLKMatrix4 matrix;
            matrix.m00 = static_cast<float>((*dofIter)->GetLim().GetData()[0]);
            matrix.m01 = static_cast<float>((*dofIter)->GetLim().GetData()[1]);
            matrix.m02 = static_cast<float>((*dofIter)->GetLim().GetData()[2]);
            matrix.m03 = static_cast<float>((*dofIter)->GetLim().GetData()[3]);
            matrix.m10 = static_cast<float>((*dofIter)->GetLim().GetData()[4]);
            matrix.m11 = static_cast<float>((*dofIter)->GetLim().GetData()[5]);
            matrix.m12 = static_cast<float>((*dofIter)->GetLim().GetData()[6]);
            matrix.m13 = static_cast<float>((*dofIter)->GetLim().GetData()[7]);
            matrix.m20 = static_cast<float>((*dofIter)->GetLim().GetData()[8]);
            matrix.m21 = static_cast<float>((*dofIter)->GetLim().GetData()[9]);
            matrix.m22 = static_cast<float>((*dofIter)->GetLim().GetData()[10]);
            matrix.m23 = static_cast<float>((*dofIter)->GetLim().GetData()[11]);
            matrix.m30 = static_cast<float>((*dofIter)->GetLim().GetData()[12]);
            matrix.m31 = static_cast<float>((*dofIter)->GetLim().GetData()[13]);
            matrix.m32 = static_cast<float>((*dofIter)->GetLim().GetData()[14]);
            matrix.m33 = static_cast<float>((*dofIter)->GetLim().GetData()[15]);

            GLKMatrix4 _modelViewProjectionMatrix;
            GLKMatrix3 _normalMatrix;

            GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), 0.6666667f, 0.1f, 100.0f);

            projectionMatrix = GLKMatrix4Multiply(projectionMatrix, GLKMatrix4MakeTranslation(-0.5f, -1.0f, -2.0f));

            projectionMatrix = GLKMatrix4RotateX(projectionMatrix, GLKMathDegreesToRadians(15.0f));

            GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.5f, 0.0f, 1.5f);
            modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, matrix);
            
            GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);

            modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

            _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
            _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);

            GetMaterial(i).DrawOGL();
            (*dofIter)->DrawInstanceOGL();
            ++i;
        }

        for (iter = childList.begin(); iter != childList.end(); ++iter)
            result &= (*iter)->DrawOGL();
        return result;
    #else
        return false;
    #endif
#endif // VART_OGL
}

const VART::Material& VART::Joint::GetMaterial(int num)
{
    static VART::Material red(VART::Color::RED());
    static VART::Material green(VART::Color::GREEN());
    static VART::Material blue(VART::Color::BLUE());
    switch (num)
    {
        case 0:
            return red;
            break;
        case 1:
            return green;
            break;
        default:
            return blue;
    }
}
#endif // VISUAL_JOINTS

void VART::Joint::XmlPrintOn(ostream& os, unsigned int indent) const
// virtual method
{
    list<Dof*>::const_iterator dofIter = dofList.begin();
    list<SceneNode*>::const_iterator iter = childList.begin();
    string indentStr(indent,' ');

    os << indentStr << "<joint description=\"" << description << "\" type=\"";
    switch (GetNumDofs())
    {
        case 1:
            os << "uniaxial";
            break;
        case 2:
            os << "biaxial";
            break;
        default:
            os << "poliaxial";
    }
    os << "\">\n";
    while (dofIter != dofList.end())
    {
        (*dofIter)->XmlPrintOn(os, indent+2);
        ++dofIter;
    }
    if (recursivePrinting)
        while (iter != childList.end())
        {
            (*iter)->XmlPrintOn(os, indent+2);
            ++iter;
        }
    os << indentStr << "</joint>\n";
    os << flush;
}

ostream& VART::operator<<(ostream& output, const VART::Joint::DofID& dofId)
{
    switch (dofId)
    {
        case VART::Joint::FLEXION:
            output << "FLEXION";
            break;
        case VART::Joint::ADDUCTION:
            output << "ADDUCTION";
            break;
        default:
            output << "TWIST";
            break;
    }
    return output;
}

istream& VART::operator>>(istream& input, VART::Joint::DofID& dofId)
{
    string buffer;
    input >> buffer;
    if (buffer == "FLEXION")
        dofId = VART::Joint::FLEXION;
    else
    {
        if (buffer == "ADDUCTION")
            dofId = VART::Joint::ADDUCTION;
        else
        {
            if (buffer == "TWIST")
                dofId = VART::Joint::TWIST;
            else
                input.setstate(ios_base::failbit);
        }
    }
    return input;
}