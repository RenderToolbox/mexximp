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

#include <cstring>
#include <mex.h>
#include <matrix.h>
#include <tmwtypes.h>
#include <assimp/scene.h>
#include "mexximp_util.h"

namespace mexximp {
    
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
    
    inline const char* get_c_string(const mxArray* matlab_struct, const unsigned index, const char* field_name, const char* default_value) {
        mxArray* string = mxGetField(matlab_struct, index, field_name);
        if (!string) {
            return default_value;
        }
        return mxArrayToString(string);
    }
    
    inline void set_c_string(mxArray* matlab_struct, const unsigned index, const char* field_name, const char* value) {
        mxArray* string = mxCreateString(value);
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
    
    // rgb to from struct
    
    inline aiColor3D* get_rgb(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out) {
        aiColor3D* target;
        unsigned num_vectors = to_assimp_rgb(mxGetField(matlab_struct, index, field_name), &target);
        if (!target) {
            target = (aiColor3D*)mxCalloc(1, sizeof(aiColor3D));
            num_vectors = 1;
        }
        if (num_vectors_out) {
            *num_vectors_out = num_vectors;
        }
        return target;
    }
    
    inline void set_rgb(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiColor3D* value, const unsigned num_vectors) {
        mxArray* rgb;
        to_matlab_rgb(value, &rgb, num_vectors);
        if (rgb) {
            mxSetField(matlab_struct, index, field_name, rgb);
        }
    }
    
    // material property data to from struct
    
    inline char* get_property_data(const mxArray* matlab_struct, const unsigned index, const char* field_name, aiPropertyTypeInfo type_code, unsigned* num_bytes_out) {
        
        if (num_bytes_out) {
            *num_bytes_out = 0;
        }
        
        mxArray* property = mxGetField(matlab_struct, index, field_name);
        if (!property) {
            return 0;
        }
        
        unsigned num_elements = mxGetNumberOfElements(property);
        if (!num_elements) {
            return 0;
        }
        
        void* data = mxGetData(property);
        if (!data) {
            return 0;
        }
        
        char* target;
        unsigned num_bytes;
        switch (type_code) {
            case aiPTI_Float: {
                if (!mxIsDouble(property)) {
                    return 0;
                }
                num_bytes = num_elements * sizeof(float);
                target = (char*)mxMalloc(num_bytes);
                if (!target) {
                    return 0;
                }
                for (int i=0; i<num_elements; i++) {
                    ((float*)target)[i] = ((double*)data)[i];
                }
                break;
            }
            case aiPTI_String:
                if (!mxIsChar(property)) {
                    return 0;
                }
                num_bytes = sizeof(aiString);
                target = (char*)mxMalloc(num_bytes);
                ((aiString*)target)->Set(mxArrayToString(property));
                break;
            case aiPTI_Integer:
                if (!mxIsInt32(property)) {
                    return 0;
                }
                num_bytes = num_elements * sizeof(int32_T);
                target = (char*)mxMalloc(num_bytes);
                if (!target) {
                    return 0;
                }
                memcpy(target, data, num_bytes);
                break;
            case aiPTI_Buffer:
                if (!mxIsUint8(property)) {
                    return 0;
                }
                // fall through to default
            default:
                num_bytes = num_elements;
                target = (char*)mxMalloc(num_bytes);
                if (!target) {
                    return 0;
                }
                memcpy(target, data, num_bytes);
                break;
        }
        
        if (num_bytes_out) {
            *num_bytes_out = num_bytes;
        }
        return target;
    }
    
    inline void set_property_data(mxArray* matlab_struct, const unsigned index, const char* field_name, const char* value,  aiPropertyTypeInfo type_code, unsigned num_bytes) {
        mxArray* property;
        
        if (!num_bytes) {
            return;
        }
        
        switch (type_code) {
            case aiPTI_Float: {
                unsigned num_elements = num_bytes / sizeof(float);
                property = mxCreateDoubleMatrix(1, num_elements, mxREAL);
                if (!property) {
                    break;
                }
                double* data = mxGetPr(property);
                if (!data) {
                    break;
                }
                for (int i=0; i<num_elements; i++) {
                    data[i] = ((float*)value)[i];
                }
                break;
            }
            case aiPTI_String:
                property = mxCreateString(((aiString*)value)->C_Str());
                break;
            case aiPTI_Integer: {
                unsigned num_elements = num_bytes / sizeof(uint32_T);
                property = mxCreateNumericMatrix(1, num_elements, mxINT32_CLASS, mxREAL);
                if (!property) {
                    break;
                }
                double* data = mxGetPr(property);
                if (!data) {
                    break;
                }
                memcpy(data, value, num_bytes);
                break;
            }
            case aiPTI_Buffer:
            default: {
                property = mxCreateNumericMatrix(1, num_bytes, mxUINT8_CLASS, mxREAL);
                if (!property) {
                    break;
                }
                void* data = mxGetData(property);
                if (!data) {
                    break;
                }
                memcpy(data, value, num_bytes);
                break;
            }
        }
        
        if (property) {
            mxSetField(matlab_struct, index, field_name, property);
        }
    }
    
    // scene "constructor" using Matlab memory allocator
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
    
    unsigned to_assimp_lights(const mxArray* matlab_lights, aiLight** assimp_lights);
    unsigned to_matlab_lights(const aiLight* assimp_lights, mxArray** matlab_lights, unsigned num_lights);
    
    unsigned to_assimp_materials(const mxArray* matlab_materials, aiMaterial** assimp_materials);
    unsigned to_matlab_materials(const aiMaterial* assimp_materials, mxArray** matlab_materials, unsigned num_materials);
    
    unsigned to_assimp_material_properties(const mxArray* matlab_properties, aiMaterialProperty** assimp_properties);
    unsigned to_matlab_material_properties(const aiMaterialProperty* assimp_properties, mxArray** matlab_properties, unsigned num_properties);
}

#endif  // MEXXIMP_SCENE_H_
