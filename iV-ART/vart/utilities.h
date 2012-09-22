//deprecated (nao disponivel no VART)
/// \file utilities.h
/// \brief Header file for VART.
/// \version $Revision: 0 $

#ifndef UTILITIES_H
#define UTILITIES_H

#include "vart/scenenode.h"
#include <list>
#include <sstream>

/// \namespace VART
/// \brief VART namespace;
///
/// All VART classes and variables are declared inside this namespace.
namespace VART {
    #ifdef _DEBUG
        void DumpStructMemoryVART( std::list<VART::SceneNode*> listSN, std::string suffix="",  bool bbox=false, std::string recoil=" ", unsigned int level=0 );
    #endif
} // end namespace
#endif  // UTILITIES_H
