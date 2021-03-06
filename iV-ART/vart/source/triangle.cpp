/// \file triangle.cpp
/// \brief Implementation file for VART class "Triangle".
/// \version $Revision: 0 $

#include "vart/triangle.h"
#ifdef VART_OGL
    #ifdef WIN32
        #include <windows.h>
    #endif

    #if defined(__APPLE__) || defined(MACOSX)
		#include <OpenGL/gl.h>
	#else
		#include <GL/gl.h>
	#endif
#else
    #ifdef VART_OGL_IOS
        #include <OpenGLES/ES2/gl.h>
        #include <OpenGLES/ES2/glext.h>
        #define BUFFER_OFFSET(i) ((char *)NULL + (i))
    #endif
#endif

using namespace VART;
using namespace std;

VART::Triangle::Triangle(void)
{
}

VART::Triangle::~Triangle(void)
{
}

VART::SceneNode* VART::Triangle::Copy()
{
    return 0;
}

void VART::Triangle::AddVertex(Point4D& v0,Point4D& v1,Point4D& v2)
{
    vertCoordVec.push_back(v0.GetX());
    vertCoordVec.push_back(v0.GetY());
    vertCoordVec.push_back(v0.GetZ());
    vertCoordVec.push_back(v1.GetX());
    vertCoordVec.push_back(v1.GetY());
    vertCoordVec.push_back(v1.GetZ());
    vertCoordVec.push_back(v2.GetX());
    vertCoordVec.push_back(v2.GetY());
    vertCoordVec.push_back(v2.GetZ());
    ComputeBoundingBox();
    ComputeRecursiveBoundingBox();
}

void VART::Triangle::ComputeBoundingBox() 
{
    bBox.SetBoundingBox(vertCoordVec[0],vertCoordVec[1],vertCoordVec[2],vertCoordVec[0],vertCoordVec[1],vertCoordVec[2]);
    bBox.ConditionalUpdate(vertCoordVec[3],vertCoordVec[4],vertCoordVec[5]);
    bBox.ConditionalUpdate(vertCoordVec[6],vertCoordVec[7],vertCoordVec[8]);
}

bool VART::Triangle::DrawOGL() const
{
#ifdef VART_OGL
    bool result = true;
    float colorVec[4];

    if (show)
    {
        //TODO: [L] De acordo com os coment�rios em vart/color.h, o 'blend' deve ser habilitado
        //na func�o 'main' do programa, e n�o pelo V-Art. Devemos remover isso daqui.
        if (color.GetA()<255)//if color has transparency, enable blending
	    {
            glPushAttrib( GL_COLOR_BUFFER_BIT | GL_ENABLE_BIT );//save the current blend and lightning status
            glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
		    glEnable( GL_BLEND );
            glDisable( GL_LIGHTING );

            color.Get(colorVec);
            glColor4fv(colorVec);
		    glBegin(GL_TRIANGLES);
                glVertex3d(vertCoordVec[0],vertCoordVec[1],vertCoordVec[2]);
    		    glVertex3d(vertCoordVec[3],vertCoordVec[4],vertCoordVec[5]);
		        glVertex3d(vertCoordVec[6],vertCoordVec[7],vertCoordVec[8]);
		    glEnd();

            glPopAttrib();//restores the last blend and lightning status
	    }
        else
        {
            color.Get(colorVec);
            glColor4fv(colorVec);
		    glBegin(GL_TRIANGLES);
                glVertex3d(vertCoordVec[0],vertCoordVec[1],vertCoordVec[2]);
    		    glVertex3d(vertCoordVec[3],vertCoordVec[4],vertCoordVec[5]);
		        glVertex3d(vertCoordVec[6],vertCoordVec[7],vertCoordVec[8]);
		    glEnd();
        }
    }
    if (bBox.visible)
        bBox.DrawInstanceOGL();
    if (recBBox.visible)
        recBBox.DrawInstanceOGL();
    return result;
#else
    #ifdef VART_OGL_IOS

//        GLfloat gTriangleVertexData[9] = {
//            1.0f, 0.0f, 0.0f,
//            0.0f, 0.0f, 0.0f,
//            0.0f, -1.0f, 0.0f,
//        };

        GLfloat gTriangleVertexData[9] = {
            static_cast<GLfloat>(vertCoordVec[0]), static_cast<GLfloat>(vertCoordVec[1]), static_cast<GLfloat>(vertCoordVec[2]),
            static_cast<GLfloat>(vertCoordVec[3]), static_cast<GLfloat>(vertCoordVec[4]), static_cast<GLfloat>(vertCoordVec[5]),
            static_cast<GLfloat>(vertCoordVec[6]), static_cast<GLfloat>(vertCoordVec[7]), static_cast<GLfloat>(vertCoordVec[8]),
        };

        GLuint _vertexArray;
        GLuint _vertexBuffer;

        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);

        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(gTriangleVertexData), gTriangleVertexData, GL_STATIC_DRAW);

        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));

        glDrawArrays(GL_TRIANGLES, 0, 3);

        glBindVertexArrayOES(0);

        return true;
    #endif

    return true;
#endif
}

Point4D VART::Triangle::GetVertex(unsigned int ind) {
    switch (ind) {
        case 0 :
            return Point4D(vertCoordVec[0],vertCoordVec[1],vertCoordVec[2]); break;
        case 1 :
            return Point4D(vertCoordVec[3],vertCoordVec[4],vertCoordVec[5]); break;
        case 2 :
            return Point4D(vertCoordVec[6],vertCoordVec[7],vertCoordVec[8]); break;
    }
    cerr << "[VART::Triangle::GetVertex], erroneous vertex ind" << endl;
    exit(EXIT_SUCCESS);
}
