// Expose data conversion utilities to convert data through round trips.

#include <mex.h>

#include "mexximp_scene.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (2 != nrhs || !mxIsChar(prhs[0])) {
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    char* whichTest = mxArrayToString(prhs[0]);
    if (!whichTest) {
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    if (0 == strcmp("xyz", whichTest)) {
        aiVector3D* assimp_xyz;
        unsigned num_vectors = mexximp::to_assimp_xyz(prhs[1], &assimp_xyz);
        mexximp::to_matlab_xyz(assimp_xyz, &plhs[0], num_vectors);
        delete [] assimp_xyz;
        
    } else if(0 == strcmp("string", whichTest)) {
        aiString* assimp_string;
        mexximp::to_assimp_string(prhs[1], &assimp_string);
        mexximp::to_matlab_string(assimp_string, &plhs[0]);
        delete assimp_string;
        
    } else if(0 == strcmp("rgb", whichTest)) {
        aiColor3D* assimp_rgb;
        unsigned num_vectors = mexximp::to_assimp_rgb(prhs[1], &assimp_rgb);
        mexximp::to_matlab_rgb(assimp_rgb, &plhs[0], num_vectors);
        delete [] assimp_rgb;
        
    } else if(0 == strcmp("rgba", whichTest)) {
        aiColor4D* assimp_rgba;
        unsigned num_vectors = mexximp::to_assimp_rgba(prhs[1], &assimp_rgba);
        mexximp::to_matlab_rgba(assimp_rgba, &plhs[0], num_vectors);
        delete [] assimp_rgba;
        
    } else if(0 == strcmp("texel", whichTest)) {
        aiTexel* assimp_texel;
        unsigned num_vectors = mexximp::to_assimp_texel(prhs[1], &assimp_texel);
        mexximp::to_matlab_texel(assimp_texel, &plhs[0], num_vectors, 1);
        delete [] assimp_texel;
        
    } else if(0 == strcmp("4x4", whichTest)) {
        aiMatrix4x4* assimp_4x4;
        unsigned num_matrices = mexximp::to_assimp_4x4(prhs[1], &assimp_4x4);
        mexximp::to_matlab_4x4(assimp_4x4, &plhs[0], num_matrices);
        delete [] assimp_4x4;
        
    } else if(0 == strcmp("scene", whichTest)) {
        aiScene assimp_scene;
        mexximp::to_assimp_scene(prhs[1], &assimp_scene);
        mexximp::to_matlab_scene(&assimp_scene, &plhs[0]);
    }
}
