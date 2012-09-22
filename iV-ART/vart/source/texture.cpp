/// \file texture.cpp
/// \brief Implementation file for V-ART class "Texture".
/// \version $Revision: 1.3 $

#include "vart/texture.h"
#include <cassert>

bool VART::Texture::hasWhiteTexture=false;
unsigned int VART::Texture::whiteTextureId=0;

VART::Texture::Texture()
: hasTexture(false)
, textureId(0)
{
#ifdef IL_LIB
    IlInitialize();
#endif //IL_LIB
    WhiteTexture();
}

VART::Texture::Texture(const VART::Texture& texture)
{
    this->operator=(texture);
}

VART::Texture& VART::Texture::operator=(const VART::Texture& texture)
{
    textureId = texture.textureId;
    hasTexture = texture.hasTexture;
    return *this;
}

bool VART::Texture::LoadFromFile(const std::string& fileName)
{
    unsigned int width = 0;
    unsigned int height = 0;
    void * imageData = NULL;
    bool result = false;

    // Reads the image data, and assign it to width, height and imageData variables.
    // This is dependent of the image reader library.
#ifdef IL_LIB
    unsigned int ilTextName;

    ilGenImages(1, &ilTextName);
    ilBindImage(ilTextName);
    if( ilLoadImage( (ILstring)fileName.c_str() ) )
    {
        ilConvertImage(IL_RGB,IL_BYTE);
        width = ilGetInteger(IL_IMAGE_WIDTH);
        height = ilGetInteger(IL_IMAGE_HEIGHT);
        imageData = ilGetData();
    }
    else
    {
        result = false;
    }
#endif //IL_LIB

    //If we have the image data, generate a OpenGL texture.
#ifdef VART_OGL
    if( imageData!=NULL )
    {
        hasTexture = true;
        glGenTextures(1,&textureId);
        glBindTexture(GL_TEXTURE_2D, textureId);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, imageData);
        result = true;

        assert(glGetError()==GL_NO_ERROR);
    }
    else
    {
        result = false;
    }
#endif //VART_OGL

    //Free the image data.
#ifdef IL_LIB
    ilDeleteImages(1, &ilTextName);
#endif //IL_LIB

    return result;
}

VART::Texture::~Texture()
{
#ifdef VART_OGL
//    if(textureId)
//        glDeleteTextures(1, &textureId);
#endif //VART_OGL
}

bool VART::Texture::DrawOGL() const
{
    bool result = false;

#ifdef VART_OGL
/*
    if( hasTexture )
    {
        glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
        glBindTexture( GL_TEXTURE_2D, textureId );
    }
    else
    {
        glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
        glBindTexture( GL_TEXTURE_2D, whiteTextureId );
    }
/*/
    if( hasTexture )
    {
        glEnable(GL_TEXTURE_2D);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
        glBindTexture( GL_TEXTURE_2D, textureId );
    }
    else
    {
        glDisable(GL_TEXTURE_2D);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
//*/
    result = true;
#endif //VART_OGL

    return result;
}

void VART::Texture::WhiteTexture()
{
    if( VART::Texture::hasWhiteTexture )
        return;

#ifdef VART_OGL
    unsigned char data[3]={255,255,255};
    glGenTextures( 1, &whiteTextureId );
    glBindTexture( GL_TEXTURE_2D, whiteTextureId );
    glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR );
    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, 1, 1, 0, GL_RGB, GL_UNSIGNED_BYTE, data );
    VART::Texture::hasWhiteTexture=true;
#endif //VART_OGL
}


//We must initialize the Developer Image Library on first use.
#ifdef IL_LIB

bool VART::Texture::ilInitalized=false;

void VART::Texture::IlInitialize()
{
    if(!ilInitalized)
    {
        ilInit();
        ilInitalized=true;
    }
}

#endif //IL_LIB
