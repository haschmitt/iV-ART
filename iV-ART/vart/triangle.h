//deprecated (nao disponivel no VART)
/// \file triangle.h
/// \brief Header file for VART class "Triangle".
/// \version $Revision: 0 $

#ifndef TRIANGLE_H
#define TRIANGLE_H

#include "vart/point4d.h"
#include "vart/color.h"
#include "vart/graphicobj.h"
#include <vector>

/// \namespace VART
/// \brief VART namespace;
///
/// All VART classes and variables are declared inside this namespace.
namespace VART {
    class Triangle : public VART::GraphicObj
    {
    public:
        Triangle(void);
        ~Triangle();
        virtual VART::SceneNode* Copy();
        void AddVertex(VART::Point4D& v0,VART::Point4D& v1,VART::Point4D& v2);
        virtual void ComputeBoundingBox();
        void SetColor(const VART::Color& color) { this->color = color; }
        VART::Point4D GetVertex(unsigned int ind);

    private:
        /// \brief Vector of all vertices (their coordinates in sequence).
        ///
        /// This is the optimized storage of vertices. It must be a vector (not
        /// a list) because OpenGL will see it as a C array. Every 3 sucessive
        /// coordinates in the array describe a vertex in the object.
        std::vector<double> vertCoordVec;

        VART::Color color;
        virtual bool DrawOGL() const;
    };
} // end namespace
#endif  // TRIANGLE_H
