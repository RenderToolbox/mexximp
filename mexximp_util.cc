

#include "mexximp_util.h"

#include <mex.h>

namespace mexximp {
    
    // xyz
    
    unsigned to_assimp_xyz(const mxArray* matlab_xyz, aiVector3D** assimp_xyz) {
        if (!matlab_xyz || !assimp_xyz || !mxIsDouble(matlab_xyz)) {
            return 0;
        }
        
        double* matlab_data = mxGetPr(matlab_xyz);
        if (!matlab_data) {
            *assimp_xyz = 0;
            return 0;
        }
        
        unsigned num_vectors = mxGetNumberOfElements(matlab_xyz) / 3;
        *assimp_xyz = (aiVector3D*)mxCalloc(num_vectors, sizeof(aiVector3D));
        if (!*assimp_xyz) {
            *assimp_xyz = 0;
            return 0;
        }
        
        for (unsigned i = 0; i < num_vectors; i++) {
            (*assimp_xyz)[i].x = matlab_data[3 * i];
            (*assimp_xyz)[i].y = matlab_data[3 * i + 1];
            (*assimp_xyz)[i].z = matlab_data[3 * i + 2];
        }
        
        return num_vectors;
    }
    
    unsigned to_matlab_xyz(const aiVector3D* assimp_xyz, mxArray** matlab_xyz, unsigned num_vectors) {
        if (!matlab_xyz) {
            return 0;
        }
        
        if (!assimp_xyz || 0 == num_vectors) {
            *matlab_xyz = mxCreateDoubleMatrix(3, 0, mxREAL);
            return 0;
        }
        
        *matlab_xyz = mxCreateDoubleMatrix(3, num_vectors, mxREAL);
        
        double* matlab_data = mxGetPr(*matlab_xyz);
        if (!matlab_data) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_vectors; i++) {
            matlab_data[3 * i] = assimp_xyz[i].x;
            matlab_data[3 * i + 1] = assimp_xyz[i].y;
            matlab_data[3 * i + 2] = assimp_xyz[i].z;
        }
        
        return num_vectors;
    }
    
    // string
    
    unsigned to_assimp_string(const mxArray* matlab_string, aiString** assimp_string) {
        if (!matlab_string || !assimp_string || !mxIsChar(matlab_string)) {
            return 0;
        }
        
        char* matlab_data = mxArrayToString(matlab_string);
        if (!matlab_data) {
            *assimp_string = 0;
            return 0;
        }
        
        *assimp_string = (aiString*)mxCalloc(1, sizeof(aiString));
        if (!*assimp_string) {
            return 0;
        }
        
        (*assimp_string)->Set(matlab_data);
        
        return (*assimp_string)->length;
    }
    
    unsigned to_matlab_string(const aiString* assimp_string, mxArray** matlab_string) {
        if (!matlab_string) {
            return 0;
        }
        
        if (!assimp_string || 0 == assimp_string->length) {
            *matlab_string = emptyString();
            return 0;
        }
        
        *matlab_string = mxCreateString(assimp_string->C_Str());
        
        return assimp_string->length;
    }
    
    // rgb
    
    unsigned to_assimp_rgb(const mxArray* matlab_rgb, aiColor3D** assimp_rgb) {
        if (!matlab_rgb || !assimp_rgb || !mxIsDouble(matlab_rgb)) {
            return 0;
        }
        
        double* matlab_data = mxGetPr(matlab_rgb);
        if (!matlab_data) {
            *assimp_rgb = 0;
            return 0;
        }
        
        unsigned num_vectors = mxGetNumberOfElements(matlab_rgb) / 3;
        *assimp_rgb = (aiColor3D*)mxCalloc(num_vectors, sizeof(aiColor3D));
        if (!*assimp_rgb) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_vectors; i++) {
            (*assimp_rgb)[i].r = matlab_data[3 * i];
            (*assimp_rgb)[i].g = matlab_data[3 * i + 1];
            (*assimp_rgb)[i].b = matlab_data[3 * i + 2];
        }
        
        return num_vectors;
    }
    
    unsigned to_matlab_rgb(const aiColor3D* assimp_rgb, mxArray** matlab_rgb, unsigned num_vectors) {
        if (!matlab_rgb) {
            return 0;
        }
        
        if (!assimp_rgb || 0 == num_vectors) {
            *matlab_rgb = mxCreateDoubleMatrix(3, 0, mxREAL);
            return 0;
        }
        
        *matlab_rgb = mxCreateDoubleMatrix(3, num_vectors, mxREAL);
        
        double* matlab_data = mxGetPr(*matlab_rgb);
        if (!matlab_data) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_vectors; i++) {
            matlab_data[3 * i] = assimp_rgb[i].r;
            matlab_data[3 * i + 1] = assimp_rgb[i].g;
            matlab_data[3 * i + 2] = assimp_rgb[i].b;
        }
        
        return num_vectors;
    }
    
    // rgba (float values)
    
    unsigned to_assimp_rgba(const mxArray* matlab_rgba, aiColor4D** assimp_rgba) {
        if (!matlab_rgba || !assimp_rgba || !mxIsDouble(matlab_rgba)) {
            return 0;
        }
        
        double* matlab_data = mxGetPr(matlab_rgba);
        if (!matlab_data) {
            *assimp_rgba = 0;
            return 0;
        }
        
        unsigned num_vectors = mxGetNumberOfElements(matlab_rgba) / 4;
        *assimp_rgba = (aiColor4D*)mxCalloc(num_vectors, sizeof(aiColor4D));
        if (!*assimp_rgba) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_vectors; i++) {
            (*assimp_rgba)[i].r = matlab_data[4 * i];
            (*assimp_rgba)[i].g = matlab_data[4 * i + 1];
            (*assimp_rgba)[i].b = matlab_data[4 * i + 2];
            (*assimp_rgba)[i].a = matlab_data[4 * i + 3];
        }
        
        return num_vectors;
    }
    
    unsigned to_matlab_rgba(const aiColor4D* assimp_rgba, mxArray** matlab_rgba, unsigned num_vectors) {
        if (!matlab_rgba) {
            return 0;
        }
        
        if (!assimp_rgba || 0 == num_vectors) {
            *matlab_rgba = mxCreateDoubleMatrix(4, 0, mxREAL);
            return 0;
        }
        
        *matlab_rgba = mxCreateDoubleMatrix(4, num_vectors, mxREAL);
        
        double* matlab_data = mxGetPr(*matlab_rgba);
        if (!matlab_data) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_vectors; i++) {
            matlab_data[4 * i] = assimp_rgba[i].r;
            matlab_data[4 * i + 1] = assimp_rgba[i].g;
            matlab_data[4 * i + 2] = assimp_rgba[i].b;
            matlab_data[4 * i + 3] = assimp_rgba[i].a;
        }
        
        return num_vectors;
    }
    
    // texel (ARGB8888 values)
    
    unsigned to_assimp_texel(const mxArray* matlab_texel, aiTexel** assimp_texel) {
        if (!matlab_texel || !assimp_texel || !mxIsUint8(matlab_texel)) {
            return 0;
        }
        
        char* matlab_data = (char*)mxGetData(matlab_texel);
        if (!matlab_data) {
            *assimp_texel = 0;
            return 0;
        }
        
        unsigned num_vectors = mxGetNumberOfElements(matlab_texel) / 4;
        *assimp_texel = (aiTexel*)mxCalloc(num_vectors, sizeof(aiTexel));
        if (!*assimp_texel) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_vectors; i++) {
            (*assimp_texel)[i].r = matlab_data[4 * i];
            (*assimp_texel)[i].g = matlab_data[4 * i + 1];
            (*assimp_texel)[i].b = matlab_data[4 * i + 2];
            (*assimp_texel)[i].a = matlab_data[4 * i + 3];
        }
        
        return num_vectors;
    }
    
    unsigned to_matlab_texel(const aiTexel* assimp_texel, mxArray** matlab_texel, unsigned width, unsigned height) {
        if (!matlab_texel) {
            return 0;
        }
        
        if (!assimp_texel || 0 == width || 0 == height) {
            *matlab_texel = mxCreateNumericMatrix(4, 0, mxUINT8_CLASS, mxREAL);
            return 0;
        }
        
        // dims as row-major for Assimp
        mwSize dims[3];
        dims[0] = 4;
        dims[1] = width;
        dims[2] = height;
        *matlab_texel = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
        
        char* matlab_data = (char*)mxGetData(*matlab_texel);
        if (!matlab_data) {
            return 0;
        }
        
        unsigned num_vectors = width * height;
        for (unsigned i = 0; i < num_vectors; i++) {
            matlab_data[4 * i] = assimp_texel[i].r;
            matlab_data[4 * i + 1] = assimp_texel[i].g;
            matlab_data[4 * i + 2] = assimp_texel[i].b;
            matlab_data[4 * i + 3] = assimp_texel[i].a;
        }
        
        return num_vectors;
    }
    
    // 4x4 matrix
    
    unsigned to_assimp_4x4(const mxArray* matlab_4x4, aiMatrix4x4** assimp_4x4) {
        if (!matlab_4x4 || !assimp_4x4 || !mxIsDouble(matlab_4x4)) {
            return 0;
        }
        
        double* matlab_data = mxGetPr(matlab_4x4);
        if (!matlab_data) {
            *assimp_4x4 = 0;
            return 0;
        }
        
        unsigned num_matrices = mxGetNumberOfElements(matlab_4x4) / 16;
        *assimp_4x4 = (aiMatrix4x4*)mxCalloc(num_matrices, sizeof(aiMatrix4x4));
        if (!*assimp_4x4) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_matrices; i++) {
            (*assimp_4x4)[i].a1 = matlab_data[16 * i];
            (*assimp_4x4)[i].a2 = matlab_data[16 * i + 1];
            (*assimp_4x4)[i].a3 = matlab_data[16 * i + 2];
            (*assimp_4x4)[i].a4 = matlab_data[16 * i + 3];
            
            (*assimp_4x4)[i].b1 = matlab_data[16 * i + 4];
            (*assimp_4x4)[i].b2 = matlab_data[16 * i + 5];
            (*assimp_4x4)[i].b3 = matlab_data[16 * i + 6];
            (*assimp_4x4)[i].b4 = matlab_data[16 * i + 7];
            
            (*assimp_4x4)[i].c1 = matlab_data[16 * i + 8];
            (*assimp_4x4)[i].c2 = matlab_data[16 * i + 9];
            (*assimp_4x4)[i].c3 = matlab_data[16 * i + 10];
            (*assimp_4x4)[i].c4 = matlab_data[16 * i + 11];
            
            (*assimp_4x4)[i].d1 = matlab_data[16 * i + 12];
            (*assimp_4x4)[i].d2 = matlab_data[16 * i + 13];
            (*assimp_4x4)[i].d3 = matlab_data[16 * i + 14];
            (*assimp_4x4)[i].d4 = matlab_data[16 * i + 15];
        }
        
        return num_matrices;
    }
    
    unsigned to_matlab_4x4(const aiMatrix4x4* assimp_4x4, mxArray** matlab_4x4, unsigned num_matrices) {
        if (!matlab_4x4) {
            return 0;
        }
        
        mwSize dims[3] = {4,4,0};
        
        if (!assimp_4x4 || 0 == num_matrices) {
            *matlab_4x4 = mxCreateNumericArray(3, &dims[0], mxDOUBLE_CLASS, mxREAL);
            return 0;
        }
        
        dims[2] = num_matrices;
        *matlab_4x4 = mxCreateNumericArray(3, &dims[0], mxDOUBLE_CLASS, mxREAL);
        
        double* matlab_data = mxGetPr(*matlab_4x4);
        if (!matlab_data) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_matrices; i++) {
            matlab_data[16 * i] = assimp_4x4[i].a1;
            matlab_data[16 * i + 1] = assimp_4x4[i].a2;
            matlab_data[16 * i + 2] = assimp_4x4[i].a3;
            matlab_data[16 * i + 3] = assimp_4x4[i].a4;
            
            matlab_data[16 * i + 4] = assimp_4x4[i].b1;
            matlab_data[16 * i + 5] = assimp_4x4[i].b2;
            matlab_data[16 * i + 6] = assimp_4x4[i].b3;
            matlab_data[16 * i + 7] = assimp_4x4[i].b4;
            
            matlab_data[16 * i + 8] = assimp_4x4[i].c1;
            matlab_data[16 * i + 9] = assimp_4x4[i].c2;
            matlab_data[16 * i + 10] = assimp_4x4[i].c3;
            matlab_data[16 * i + 11] = assimp_4x4[i].c4;
            
            matlab_data[16 * i + 12] = assimp_4x4[i].d1;
            matlab_data[16 * i + 13] = assimp_4x4[i].d2;
            matlab_data[16 * i + 14] = assimp_4x4[i].d3;
            matlab_data[16 * i + 15] = assimp_4x4[i].d4;
        }
        
        return num_matrices;
    }
}
