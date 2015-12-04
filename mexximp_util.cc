
#include "mexximp_util.h"

#include <mex.h>

namespace mexximp {
    
    unsigned to_assimp_vec3(const mxArray* matlab_vec3, aiVector3D** assimp_vec3) {
        if (!matlab_vec3 || !assimp_vec3) {
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
            *matlab_vec3 = emptyDouble();
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
    
}
