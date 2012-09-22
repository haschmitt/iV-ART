/// \file ikchain.cpp
/// \brief Implementation file for V-ART class "IKChain".
/// \version $Revision$

#include "vart/ikchain.h"
#include "vart/collector.h"
#include "vart/joint.h"
#include <list>
using namespace std;

VART::IKChain::IKChain(SGPath path, Point4D eePos, Point4D eeOri) :
    eePosition(eePos), eeOrientation(eeOri)
{
    Collector<Joint> jointCollector;
    path.Traverse(&jointCollector);
    list<const Joint*>::const_iterator iter = jointCollector.begin();
    for(; iter != jointCollector.end(); ++iter)
    {
        // get dofs from joint
        const_cast<Joint*>(*iter)->GetDofs(&dofChain);
    }
}

void VART::IKChain::SetEEPosition(const Point4D& eePos)
{
    eePosition = eePos;
}

void VART::IKChain::MoveTowardsSolution()
{
}