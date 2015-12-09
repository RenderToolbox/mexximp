
#include "mexximp_util.h"

#include <mex.h>

namespace mexximp {
    
    // vec3
    
    unsigned to_assimp_vec3(const mxArray* matlab_vec3, aiVector3D** assimp_vec3) {
        if (!matlab_vec3 || !assimp_vec3 || !mxIsDouble(matlab_vec3)) {
            return 0;
        }
        
        double* matlab_data = mxGetPr(matlab_vec3);
        if (!matlab_data) {
            return 0;
        }
        
        unsigned num_vectors = mxGetNumberOfElements(matlab_vec3) / 3;
        *assimp_vec3 = (aiVector3D*)mxCalloc(num_vectors, sizeof(aiVector3D));
        if (!*assimp_vec3) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_vectors; i++) {
            (*assimp_vec3)[i].x = matlab_data[3 * i];
            (*assimp_vec3)[i].y = matlab_data[3 * i + 1];
            (*assimp_vec3)[i].z = matlab_data[3 * i + 2];
        }
        
        return num_vectors;
    }
    
    unsigned to_matlab_vec3(const aiVector3D* assimp_vec3, mxArray** matlab_vec3, unsigned num_vectors) {
        if (!matlab_vec3) {
            return 0;
        }
        
        if (!assimp_vec3 || 0 == num_vectors) {
            *matlab_vec3 = mxCreateDoubleMatrix(3, 0, mxREAL);
            return 0;
        }
        
        *matlab_vec3 = mxCreateDoubleMatrix(3, num_vectors, mxREAL);
        if (0 == num_vectors) {
            *matlab_vec3 = emptyDouble();
            return 0;
        }
        
        double* matlab_data = mxGetPr(*matlab_vec3);
        if (!matlab_data) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_vectors; i++) {
            matlab_data[3 * i] = assimp_vec3[i].x;
            matlab_data[3 * i + 1] = assimp_vec3[i].y;
            matlab_data[3 * i + 2] = assimp_vec3[i].z;
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
        if (0 == num_vectors) {
            *matlab_rgb = emptyDouble();
            return 0;
        }
        
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
}
