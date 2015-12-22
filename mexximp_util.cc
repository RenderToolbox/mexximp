// Utility functions for converting Assimp types and structures to Matlab.

#include "mexximp_util.h"

#include <cstring>
#include <mex.h>
#include <matrix.h>
#include <tmwtypes.h>
#include "mexximp_util.h"

namespace mexximp {
    
    // basic Assimp type conversions
    
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
        *assimp_xyz = new aiVector3D[num_vectors];
        if (!*assimp_xyz) {
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
    
    unsigned to_assimp_string(const mxArray* matlab_string, aiString* assimp_string) {
        if (!matlab_string || !assimp_string || !mxIsChar(matlab_string)) {
            return 0;
        }
        char* matlab_data = mxArrayToString(matlab_string);
        if (!matlab_data) {
            return 0;
        }
        assimp_string->Set(matlab_data);
        return assimp_string->length;
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
        *assimp_rgb = new aiColor3D[num_vectors];
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
        *assimp_rgba = new aiColor4D[num_vectors];
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
        *assimp_texel = new aiTexel[num_vectors];
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
        *assimp_4x4 = new aiMatrix4x4[num_matrices];
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
    
    // data to and from Matlab structs
    
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
    
    // data to and from structs
    
    float get_scalar(const mxArray* matlab_struct, const unsigned index, const char* field_name, const float default_value) {
        if (!matlab_struct || !mxIsStruct(matlab_struct)) {
            return default_value;
        }
        const mxArray* field = mxGetField(matlab_struct, index, field_name);
        if (!field || !mxIsNumeric(field)) {
            return default_value;
        }
        return mxGetScalar(field);
    }
    
    void set_scalar(mxArray* matlab_struct, const unsigned index, const char* field_name, const float value) {
        if (!matlab_struct || !mxIsStruct(matlab_struct)) {
            return;
        }
        mxArray* scalar = mxCreateDoubleScalar(value);
        mxSetField(matlab_struct, index, field_name, scalar);
    }
    
    // floats to from struct
    
    float* get_floats(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out) {
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
        float* target = new float[num_elements];
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
    
    void set_floats(mxArray* matlab_struct, const unsigned index, const char* field_name, const float* floats, unsigned num_elements) {
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
    
    int32_T* get_ints(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out) {
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
        int32_T* target = new int32_T[num_elements];
        if (!target) {
            return 0;
        }
        memcpy(target, data, num_bytes);
        
        if (num_elements_out) {
            *num_elements_out = num_elements;
        }
        
        return target;
    }
    
    void set_ints(mxArray* matlab_struct, const unsigned index, const char* field_name, const int32_T* ints, unsigned num_elements) {
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
    
    uint32_T* get_indices(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out) {
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
        uint32_T* target = new uint32_T[num_bytes];
        if (!target) {
            return 0;
        }
        memcpy(target, data, num_bytes);
        
        if (num_elements_out) {
            *num_elements_out = num_elements;
        }
        
        return target;
    }
    
    void set_indices(mxArray* matlab_struct, const unsigned index, const char* field_name, const uint32_T* indices, unsigned num_elements) {
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
    
    char* get_bytes(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out) {
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
        char* target = new char[num_bytes];
        if (!target) {
            return 0;
        }
        memcpy(target, data, num_bytes);
        
        if (num_elements_out) {
            *num_elements_out = num_bytes;
        }
        
        return target;
    }
    
    void set_bytes(mxArray* matlab_struct, const unsigned index, const char* field_name, const char* bytes, unsigned num_elements) {
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
    
    unsigned get_string(const mxArray* matlab_struct, const unsigned index, const char* field_name, aiString* target, const char* default_value) {
        unsigned length = to_assimp_string(mxGetField(matlab_struct, index, field_name), target);
        if (!length) {
            target->Set(default_value);
        }
        return target->length;
    }
    
    void set_string(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiString* value) {
        mxArray* string;
        to_matlab_string(value, &string);
        if (string) {
            mxSetField(matlab_struct, index, field_name, string);
        }
    }
    
    const char* get_c_string(const mxArray* matlab_struct, const unsigned index, const char* field_name, const char* default_value) {
        mxArray* string = mxGetField(matlab_struct, index, field_name);
        if (!string) {
            return default_value;
        }
        return mxArrayToString(string);
    }
    
    void set_c_string(mxArray* matlab_struct, const unsigned index, const char* field_name, const char* value) {
        mxArray* string = mxCreateString(value);
        if (string) {
            mxSetField(matlab_struct, index, field_name, string);
        }
    }
    
    // xyz to from struct
    
    aiVector3D* get_xyz(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out) {
        aiVector3D* target;
        unsigned num_vectors = to_assimp_xyz(mxGetField(matlab_struct, index, field_name), &target);
        if (num_vectors_out) {
            *num_vectors_out = num_vectors;
        }
        return target;
    }
    
    void set_xyz(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiVector3D* value, const unsigned num_vectors) {
        mxArray* xyz;
        to_matlab_xyz(value, &xyz, num_vectors);
        if (xyz) {
            mxSetField(matlab_struct, index, field_name, xyz);
        }
    }
    
    // rgb to from struct
    
    aiColor3D* get_rgb(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out) {
        aiColor3D* target;
        unsigned num_vectors = to_assimp_rgb(mxGetField(matlab_struct, index, field_name), &target);
        if (num_vectors_out) {
            *num_vectors_out = num_vectors;
        }
        return target;
    }
    
    void set_rgb(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiColor3D* value, const unsigned num_vectors) {
        mxArray* rgb;
        to_matlab_rgb(value, &rgb, num_vectors);
        if (rgb) {
            mxSetField(matlab_struct, index, field_name, rgb);
        }
    }
    
    // rgba to from struct
    
    aiColor4D* get_rgba(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out) {
        aiColor4D* target;
        unsigned num_vectors = to_assimp_rgba(mxGetField(matlab_struct, index, field_name), &target);
        if (num_vectors_out) {
            *num_vectors_out = num_vectors;
        }
        return target;
    }
    
    void set_rgba(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiColor4D* value, const unsigned num_vectors) {
        mxArray* rgba;
        to_matlab_rgba(value, &rgba, num_vectors);
        if (rgba) {
            mxSetField(matlab_struct, index, field_name, rgba);
        }
    }
    
    // texel to from struct
    
    aiTexel* get_texel(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out) {
        aiTexel* target;
        unsigned num_vectors = to_assimp_texel(mxGetField(matlab_struct, index, field_name), &target);
        if (num_vectors_out) {
            *num_vectors_out = num_vectors;
        }
        return target;
    }
    
    void set_texel(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiTexel* value, const unsigned width, const unsigned height) {
        mxArray* texel;
        to_matlab_texel(value, &texel, width, height);
        if (texel) {
            mxSetField(matlab_struct, index, field_name, texel);
        }
    }
    
    // 4x4 to from struct
    
    aiMatrix4x4* get_4x4(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out) {
        aiMatrix4x4* target;
        unsigned num_vectors = to_assimp_4x4(mxGetField(matlab_struct, index, field_name), &target);
        if (num_vectors_out) {
            *num_vectors_out = num_vectors;
        }
        return target;
    }
    
    void set_4x4(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiMatrix4x4* value, const unsigned num_vectors) {
        mxArray* matlab_4x4;
        to_matlab_4x4(value, &matlab_4x4, num_vectors);
        if (matlab_4x4) {
            mxSetField(matlab_struct, index, field_name, matlab_4x4);
        }
    }
    
    // material property data to from struct
    
    char* get_property_data(const mxArray* matlab_struct, const unsigned index, const char* field_name, aiPropertyTypeInfo type_code, unsigned* num_bytes_out) {
        
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
                // expect a material property to delete this eventually
                aiString* string = new aiString();
                target = (char*) string;                
                get_string(matlab_struct, index, field_name, string, "");
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
    
    void set_property_data(mxArray* matlab_struct, const unsigned index, const char* field_name, const char* value,  aiPropertyTypeInfo type_code, unsigned num_bytes) {
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
}
