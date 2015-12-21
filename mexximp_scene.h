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
    
    // floats to from struct
    
    inline float* get_floats(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out) {
        if (num_elements_out) {
            *num_elements_out = 0;
        }
        
        const mxArray* field = mxGetField(matlab_struct, index, field_name);
        if (!field || !mxIsDouble(field)) {
            return 0;
        }
        
        double* data = mxGetPr(field);
        if (!data) {
            return 0;
        }
        
        unsigned num_elements = mxGetNumberOfElements(field);
        unsigned num_bytes = num_elements * sizeof(float);
        float* target = (float*)mxMalloc(num_bytes);
        if (!target) {
            return 0;
        }
        for (int i=0; i<num_elements; i++) {
            target[i] = data[i];
        }
        
        if (num_elements_out) {
            *num_elements_out = num_elements;
        }
        
        return target;
    }
    
    inline void set_floats(mxArray* matlab_struct, const unsigned index, const char* field_name, const float* floats, unsigned num_elements) {
        mxArray* field;
        
        if (!num_elements) {
            return;
        }
        
        field = mxCreateDoubleMatrix(1, num_elements, mxREAL);
        if (!field) {
            return;
        }
        
        double* data = mxGetPr(field);
        if (!data) {
            return;
        }
        
        for (int i=0; i<num_elements; i++) {
            data[i] = floats[i];
        }
        
        mxSetField(matlab_struct, index, field_name, field);
    }
    
    // integers to from struct
    
    inline int32_T* get_ints(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out) {
        if (num_elements_out) {
            *num_elements_out = 0;
        }
        
        const mxArray* field = mxGetField(matlab_struct, index, field_name);
        if (!field || !mxIsInt32(field)) {
            return 0;
        }
        
        void* data = mxGetData(field);
        if (!data) {
            return 0;
        }
        
        unsigned num_elements = mxGetNumberOfElements(field);
        unsigned num_bytes = num_elements * sizeof(int32_T);
        int32_T* target = (int32_T*)mxMalloc(num_bytes);
        if (!target) {
            return 0;
        }
        memcpy(target, data, num_bytes);
        
        if (num_elements_out) {
            *num_elements_out = num_elements;
        }
        
        return target;
    }
    
    inline void set_ints(mxArray* matlab_struct, const unsigned index, const char* field_name, const int32_T* ints, unsigned num_elements) {
        mxArray* field;
        
        if (!num_elements) {
            return;
        }
        
        field = mxCreateNumericMatrix(1, num_elements, mxINT32_CLASS, mxREAL);
        if (!field) {
            return;
        }
        
        double* data = mxGetPr(field);
        if (!data) {
            return;
        }
        
        unsigned num_bytes = num_elements * sizeof(int32_T);
        memcpy(data, ints, num_bytes);
        
        mxSetField(matlab_struct, index, field_name, field);
    }
    
    // indices to from struct
    
    inline uint32_T* get_indices(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out) {
        if (num_elements_out) {
            *num_elements_out = 0;
        }
        
        const mxArray* field = mxGetField(matlab_struct, index, field_name);
        if (!field || !mxIsUint32(field)) {
            return 0;
        }
        
        void* data = mxGetData(field);
        if (!data) {
            return 0;
        }
        
        unsigned num_elements = mxGetNumberOfElements(field);
        unsigned num_bytes = num_elements * sizeof(uint32_T);
        uint32_T* target = (uint32_T*)mxMalloc(num_bytes);
        if (!target) {
            return 0;
        }
        memcpy(target, data, num_bytes);
        
        if (num_elements_out) {
            *num_elements_out = num_elements;
        }
        
        return target;
    }
    
    inline void set_indices(mxArray* matlab_struct, const unsigned index, const char* field_name, const uint32_T* indices, unsigned num_elements) {
        mxArray* field;
        
        if (!num_elements) {
            return;
        }
        
        field = mxCreateNumericMatrix(1, num_elements, mxUINT32_CLASS, mxREAL);
        if (!field) {
            return;
        }
        
        double* data = mxGetPr(field);
        if (!data) {
            return;
        }
        
        unsigned num_bytes = num_elements * sizeof(uint32_T);
        memcpy(data, indices, num_bytes);
        
        mxSetField(matlab_struct, index, field_name, field);
    }
    
    // bytes to from struct
    
    inline char* get_bytes(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out) {
        if (num_elements_out) {
            *num_elements_out = 0;
        }
        
        const mxArray* field = mxGetField(matlab_struct, index, field_name);
        if (!field) {
            return 0;
        }
        
        void* data = mxGetData(field);
        if (!data) {
            return 0;
        }
        
        unsigned num_bytes = mxGetNumberOfElements(field);
        char* target = (char*)mxMalloc(num_bytes);
        if (!target) {
            return 0;
        }
        memcpy(target, data, num_bytes);
        
        if (num_elements_out) {
            *num_elements_out = num_bytes;
        }
        
        return target;
    }
    
    inline void set_bytes(mxArray* matlab_struct, const unsigned index, const char* field_name, const char* bytes, unsigned num_elements) {
        mxArray* field;
        
        if (!num_elements) {
            return;
        }
        
        field = mxCreateNumericMatrix(1, num_elements, mxUINT8_CLASS, mxREAL);
        if (!field) {
            return;
        }
        
        double* data = mxGetPr(field);
        if (!data) {
            return;
        }
        
        memcpy(data, bytes, num_elements);
        
        mxSetField(matlab_struct, index, field_name, field);
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
    
    // rgba to from struct
    
    inline aiColor4D* get_rgba(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out) {
        aiColor4D* target;
        unsigned num_vectors = to_assimp_rgba(mxGetField(matlab_struct, index, field_name), &target);
        if (num_vectors_out) {
            *num_vectors_out = num_vectors;
        }
        return target;
    }
    
    inline void set_rgba(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiColor4D* value, const unsigned num_vectors) {
        mxArray* rgba;
        to_matlab_rgba(value, &rgba, num_vectors);
        if (rgba) {
            mxSetField(matlab_struct, index, field_name, rgba);
        }
    }
    
    // 4x4 to from struct
    
    inline aiMatrix4x4* get_4x4(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out) {
        aiMatrix4x4* target;
        unsigned num_vectors = to_assimp_4x4(mxGetField(matlab_struct, index, field_name), &target);
        if (num_vectors_out) {
            *num_vectors_out = num_vectors;
        }
        return target;
    }
    
    inline void set_4x4(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiMatrix4x4* value, const unsigned num_vectors) {
        mxArray* matlab_4x4;
        to_matlab_4x4(value, &matlab_4x4, num_vectors);
        if (matlab_4x4) {
            mxSetField(matlab_struct, index, field_name, matlab_4x4);
        }
    }
    
    // material property data to from struct
    
    inline char* get_property_data(const mxArray* matlab_struct, const unsigned index, const char* field_name, aiPropertyTypeInfo type_code, unsigned* num_bytes_out) {
        
        if (num_bytes_out) {
            *num_bytes_out = 0;
        }
        
        unsigned num_elements;
        unsigned num_bytes;
        char* target;
        switch (type_code) {
            case aiPTI_Float:
                target = (char*)get_floats(matlab_struct, index, field_name, &num_elements);
                num_bytes = num_elements * sizeof(float);
                break;
            case aiPTI_String: {
                target = (char*)get_string(matlab_struct, index, field_name, "");
                num_bytes = sizeof(aiString);
                break;
            }
            case aiPTI_Integer:
                target = (char*)get_ints(matlab_struct, index, field_name, &num_elements);
                num_bytes = num_elements * sizeof(int32_T);
                break;
            case aiPTI_Buffer:
                // fall through to default
            default:
                target = (char*)get_bytes(matlab_struct, index, field_name, &num_elements);
                num_bytes = num_elements;
                break;
        }
        
        if (num_bytes_out) {
            *num_bytes_out = num_bytes;
        }
        
        return target;
    }
    
    inline void set_property_data(mxArray* matlab_struct, const unsigned index, const char* field_name, const char* value,  aiPropertyTypeInfo type_code, unsigned num_bytes) {
        if (!num_bytes) {
            return;
        }
        
        unsigned num_elements;
        switch (type_code) {
            case aiPTI_Float:
                num_elements = num_bytes / sizeof(float);
                set_floats(matlab_struct, index, field_name, (float*)value, num_elements);
                return;
            case aiPTI_String:
                set_string(matlab_struct, index, field_name, (aiString*)value);
                return;
            case aiPTI_Integer:
                num_elements = num_bytes / sizeof(int32_T);
                set_ints(matlab_struct, index, field_name, (int32_T*)value, num_elements);
                return;
            case aiPTI_Buffer:
                // fall through to default
            default:
                set_bytes(matlab_struct, index, field_name, (char*)value, num_bytes);
                return;
        }
    }
    
    // structs
    
    unsigned to_assimp_scene(const mxArray* matlab_scene, aiScene** assimp_scene);
    unsigned to_matlab_scene(const aiScene* assimp_scene, mxArray** matlab_scene);
    
    unsigned to_assimp_cameras(const mxArray* matlab_cameras, aiCamera*** assimp_cameras);
    unsigned to_matlab_cameras(aiCamera** assimp_cameras, mxArray** matlab_cameras, unsigned num_cameras);
    
    unsigned to_assimp_lights(const mxArray* matlab_lights, aiLight*** assimp_lights);
    unsigned to_matlab_lights(aiLight** assimp_lights, mxArray** matlab_lights, unsigned num_lights);
    
    unsigned to_assimp_materials(const mxArray* matlab_materials, aiMaterial*** assimp_materials);
    unsigned to_matlab_materials(aiMaterial** assimp_materials, mxArray** matlab_materials, unsigned num_materials);
    
    unsigned to_assimp_material_properties(const mxArray* matlab_properties, aiMaterialProperty*** assimp_properties);
    unsigned to_matlab_material_properties(aiMaterialProperty** assimp_properties, mxArray** matlab_properties, unsigned num_properties);
    
    unsigned to_assimp_meshes(const mxArray* matlab_meshes, aiMesh*** assimp_meshes);
    unsigned to_matlab_meshes(aiMesh** assimp_meshes, mxArray** matlab_meshes, unsigned num_meshes);
    
    unsigned to_assimp_faces(const mxArray* matlab_faces, aiFace** assimp_faces);
    unsigned to_matlab_faces(aiFace* assimp_faces, mxArray** matlab_faces, unsigned num_faces);
    
    unsigned to_assimp_nodes(const mxArray* matlab_node, unsigned index, aiNode** assimp_node, aiNode* assimp_parent);
    unsigned to_matlab_nodes(aiNode* assimp_node, mxArray** matlab_node, unsigned index);
    
}

#endif  // MEXXIMP_SCENE_H_
