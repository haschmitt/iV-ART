/// \file utilities.cpp
/// \brief Implementation file for VART.
/// \version $Revision: 0 $

#include "vart/utilities.h"
#include "vart/graphicobj.h"

using namespace std;
using namespace VART;

// Only debug source __________________________________________________________
#ifdef _DEBUG
void dumpStructMemoryVART( list<SceneNode*> listSN, string suffix, bool bbox, string recoil, unsigned int level )
{
    unsigned int    qtSN = 0;
    GraphicObj* objPtr;

    level++;
    for (list<SceneNode*>::const_iterator itListSN = listSN.begin(); itListSN != listSN.end(); ++itListSN)
    {
        qtSN++;
        //TODO: [D] GetChilds() ficou deprecated, arrumar...
        cout << recoil << "." << level << "/" << qtSN << ": " << (*itListSN)->GetDescription() << " [" << (*itListSN)->GetChilds().size() << "]" << endl;
        if (bbox) {
            objPtr = dynamic_cast<GraphicObj*>(*itListSN);
            if (objPtr) {
                cout << recoil << "   bbox: " << objPtr->GetBoundingBox() << endl;
                cout << recoil << "   bboxRec: " << objPtr->GetRecursiveBoundingBox() << endl;
            }
        }
        //TODO: [D] GetChilds() ficou deprecated, arrumar...
        dumpStructMemoryVART( (*itListSN)->GetChilds(), suffix, bbox, recoil+"   ", level );
    }
}
#endif
