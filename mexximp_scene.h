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

#include <mex.h>
#include <matrix.h>
#include <assimp/scene.h>
#include "mexximp_util.h"

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
    
    // scalar to from struct
    
    inline float get_scalar(const mxArray* matlab_struct, const unsigned index, const char* field_name, const float default_value) {
        if (!matlab_struct || !mxIsStruct(matlab_struct)) {
            return default_value;
        }
        const mxArray* field = mxGetField(matlab_struct, index, field_name);
        if (!field || !mxIsNumeric(field)) {
            return default_value;
        }
        return mxGetScalar(field);
    }
    
    inline void set_scalar(mxArray* matlab_struct, const unsigned index, const char* field_name, const float value) {
        if (!matlab_struct || !mxIsStruct(matlab_struct)) {
            return;
        }
        mxArray* scalar = mxCreateDoubleScalar(value);
        mxSetField(matlab_struct, index, field_name, scalar);
    }
    
    // string to from struct
    
    inline aiString* get_string(const mxArray* matlab_struct, const unsigned index, const char* field_name, const char* default_value) {
        aiString* string;
        to_assimp_string(mxGetField(matlab_struct, index, field_name), &string);
        if (!string) {
            string = (aiString*)mxCalloc(1, sizeof(aiString));
            string->Set(default_value);
        }
        return string;
    }
    
    inline void set_string(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiString* value) {
        mxArray* string;
        to_matlab_string(value, &string);
        if (string) {
            mxSetField(matlab_struct, index, field_name, string);
        }
    }
    
    // xyz to from struct
    
    inline aiVector3D* get_xyz(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out) {
        aiVector3D* target;
        unsigned num_vectors = to_assimp_xyz(mxGetField(matlab_struct, index, field_name), &target);
        if (!target) {
            target = (aiVector3D*)mxCalloc(1, sizeof(aiVector3D));
            num_vectors = 1;
        }
        if (num_vectors_out) {
            *num_vectors_out = num_vectors;
        }
        return target;
    }
    
    inline void set_xyz(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiVector3D* value, const unsigned num_vectors) {
        mxArray* xyz;
        to_matlab_xyz(value, &xyz, num_vectors);
        if (xyz) {
            mxSetField(matlab_struct, index, field_name, xyz);
        }
    }
    
    // allocate a scene from Matlab's memory
    inline aiScene* mx_new_scene() {
        aiScene* assimp_scene = (aiScene*)mxCalloc(1, sizeof(aiScene));
        if (!assimp_scene) {
            return 0;
        }
        assimp_scene->mAnimations = (aiAnimation**)mxCalloc(1, sizeof(aiAnimation*));
        assimp_scene->mCameras = (aiCamera**)mxCalloc(1, sizeof(aiCamera*));
        assimp_scene->mLights = (aiLight**)mxCalloc(1, sizeof(aiLight*));
        assimp_scene->mMaterials = (aiMaterial**)mxCalloc(1, sizeof(aiMaterial*));
        assimp_scene->mMeshes = (aiMesh**)mxCalloc(1, sizeof(aiMesh*));
        assimp_scene->mTextures = (aiTexture**)mxCalloc(1, sizeof(aiTexture*));
        return assimp_scene;
    }
    
    // structs
    
    unsigned to_assimp_scene(const mxArray* matlab_scene, aiScene** assimp_scene);
    unsigned to_matlab_scene(const aiScene* assimp_scene, mxArray** matlab_scene);
    
    unsigned to_assimp_cameras(const mxArray* matlab_cameras, aiCamera** assimp_cameras);
    unsigned to_matlab_cameras(const aiCamera* assimp_cameras, mxArray** matlab_cameras, unsigned num_cameras);
    
}

#endif  // MEXXIMP_SCENE_H_
