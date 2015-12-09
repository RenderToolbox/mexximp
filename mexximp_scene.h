/** Convert Assimp <-> Matlab 3D scenes.
 *
 *  These functions are alllowed to allocate Matlab Heap memory themselves
 *  using functions like mxCreateDoubleMatrix() and mxCalloc().  Assimp
 *  might read this memory while exporting scene files.  Matlab will
 *  automatically free this memory after Assimp finishes and control
 *  returns to the Matlab prompt.
 *
 *  2015 benjamin.heasly@gmail.com
 */

#ifndef MEXXIMP_SCENE_H_
#define MEXXIMP_SCENE_H_

#include <matrix.h>
#include <assimp/scene.h>

#define COUNT(x) ((sizeof x) / (sizeof x[0]))

namespace mexximp {
    
    static const char* scene_field_names[] = {
        "cameras",
        "lights",
        "materials",
        "meshes",
        "embeddedTextures",
        "rootNode",
    };
    
    static const char* camera_field_names[] = {
        "name",
        "position",
        "lookAtDirection",
        "upDirection",
        "aspectRatio",
        "horizontalFov",
        "clipPlaneFar",
        "clipPlaneNear",
    };
    
    //TODO
    inline float get_scalar(const mxArray* matlab_struct, const char* field_name, const float default_value);
    inline void set_scalar(const mxArray* matlab_struct, const char* field_name, const float value);
    
    //TODO
    inline const char* get_string(const mxArray* matlab_struct, const char* field_name, const char* default_value);
    inline void set_string(const mxArray* matlab_struct, const char* field_name, const char* value);
    
    unsigned to_assimp_scene(const mxArray* matlab_scene, aiScene** assimp_scene);
    unsigned to_matlab_scene(const aiScene* assimp_scene, mxArray** matlab_scene);
    
    //TODO
    unsigned to_assimp_cameras(const mxArray* matlab_cameras, aiCamera** assimp_cameras);
    unsigned to_matlab_cameras(const aiScene* assimp_cameras, mxArray** matlab_cameras, unsigned num_cameras);
    
}

#endif  // MEXXIMP_SCENE_H_
