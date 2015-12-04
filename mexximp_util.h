/** mexximp utilities like Assimp <-> Matlab data conversions.
 *
 *  These functions are alllowed to allocate Matlab Heap memory themselves
 *  using functions like mxCreateDoubleMatrix() and mxCalloc().  Assimp
 *  might use this memory while exporting scene files.  Matlab will
 *  automatically free this memory after Assimp finishes and control
 *  returns to the Matlab prompt.
 *
 *  2015 benjamin.heasly@gmail.com
 */

#ifndef MEXXIMP_UTIL_H_
#define MEXXIMP_UTIL_H_

#include <matrix.h>

#include <assimp/texture.h>
#include <assimp/types.h>

namespace mexximp {
    
    inline mxArray* emptyDouble() {
        return mxCreateDoubleMatrix(0, 0, mxREAL);
    }
    
    unsigned to_assimp_vec3(const mxArray* matlab_vec3, aiVector3D** assimp_vec3);
    unsigned to_matlab_vec3(const aiVector3D* assimp_vec3, mxArray** matlab_vec3, unsigned num_vectors);
    
}

#endif  // MEXXIMP_UTIL_H_
