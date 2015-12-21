/** mexximp utilities like Assimp <-> Matlab data conversions.
 *
 *  These functions are alllowed to allocate Matlab Heap memory themselves
 *  using functions like mxCreateDoubleMatrix() and mxCalloc().  Assimp
 *  might read this memory while exporting scene files.  Matlab will
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
    
    inline mxArray* emptyString() {
        const mwSize dims[2] = {1, 0};
        return mxCreateCharArray(2, &dims[0]);
    }
    
    unsigned to_assimp_xyz(const mxArray* matlab_xyz, aiVector3D** assimp_xyz);
    unsigned to_matlab_xyz(const aiVector3D* assimp_xyz, mxArray** matlab_xyz, unsigned num_vectors);
    
    unsigned to_assimp_string(const mxArray* matlab_string, aiString** assimp_string);
    unsigned to_matlab_string(const aiString* assimp_string, mxArray** matlab_string);
    
    unsigned to_assimp_rgb(const mxArray* matlab_rgb, aiColor3D** assimp_rgb);
    unsigned to_matlab_rgb(const aiColor3D* assimp_rgb, mxArray** matlab_rgb, unsigned num_vectors);
    
    unsigned to_assimp_rgba(const mxArray* matlab_rgba, aiColor4D** assimp_rgba);
    unsigned to_matlab_rgba(const aiColor4D* assimp_rgba, mxArray** matlab_rgba, unsigned num_vectors);
    
    unsigned to_assimp_texel(const mxArray* matlab_texel, aiTexel** assimp_texel);
    unsigned to_matlab_texel(const aiTexel* assimp_texel, mxArray** matlab_texel, unsigned width, unsigned height);
    
    unsigned to_assimp_4x4(const mxArray* matlab_4x4, aiMatrix4x4** assimp_4x4);
    unsigned to_matlab_4x4(const aiMatrix4x4* assimp_4x4, mxArray** matlab_4x4, unsigned num_vectors);
    
}

#endif  // MEXXIMP_UTIL_H_
