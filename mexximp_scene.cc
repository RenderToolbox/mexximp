
#include "mexximp_scene.h"
#include "mexximp_util.h"

#include <mex.h>

namespace mexximp {
    
    // scene (top-level)
    
    unsigned to_assimp_scene(const mxArray* matlab_scene, aiScene** assimp_scene) {
        if (!matlab_scene || !assimp_scene || !mxIsStruct(matlab_scene)) {
            return 0;
        }
        
        *assimp_scene = (aiScene*)mxCalloc(1, sizeof(aiScene));
        if (!*assimp_scene) {
            return 0;
        }
        
        // get "cameras" field
        // if not null, to_assimp_cameras
    }
    
    unsigned to_matlab_scene(const aiScene* assimp_scene, mxArray** matlab_scene) {
        if (!matlab_scene) {
            return 0;
        }
        
        *matlab_scene = mxCreateStructMatrix(
                1,
                1,
                COUNT(scene_field_names),
                &scene_field_names[0]);
        
        if (!assimp_scene) {
            return 0;
        }
        
        // to_matlab_cameras
        // set "cameras" field
    }
}
