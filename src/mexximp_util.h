/** mexximp utilities like Assimp <-> Matlab data conversions.
 *
 *  These functions are alllowed to allocate heap memory themselves
 *  using new and new [].  Assimp might read this memory while exporting 
 *  scene files.  Assimp recursively calls delete and delete [] for 
 *  these allocations when the top-level scene is destroyed.  So just make
 *  sure the top-level scene gets destroyed!
 *
 *  2015 benjamin.heasly@gmail.com
 */

#ifndef MEXXIMP_UTIL_H_
#define MEXXIMP_UTIL_H_

#include <matrix.h>
#include <assimp/scene.h>
#include <assimp/texture.h>
#include <assimp/types.h>

namespace mexximp {
    
    inline mxArray* emptyDouble() {
        return mxCreateDoubleMatrix(0, 0, mxREAL);
    }
    
    inline mxArray* emptyString() {
        const mwSize dims[2] = {1, 0};
        return mxCreateCharArray(2, &dims[0]);
    }
    
    // basic Assimp type conversions
    
    unsigned to_assimp_xyz(const mxArray* matlab_xyz, aiVector3D** assimp_xyz);
    unsigned to_matlab_xyz(const aiVector3D* assimp_xyz, mxArray** matlab_xyz, unsigned num_vectors);
    
    unsigned to_assimp_string(const mxArray* matlab_string, aiString* assimp_string);
    unsigned to_matlab_string(const aiString* assimp_string, mxArray** matlab_string);
    
    unsigned to_assimp_rgb(const mxArray* matlab_rgb, aiColor3D** assimp_rgb);
    unsigned to_matlab_rgb(const aiColor3D* assimp_rgb, mxArray** matlab_rgb, unsigned num_vectors);
    
    unsigned to_assimp_rgba(const mxArray* matlab_rgba, aiColor4D** assimp_rgba);
    unsigned to_matlab_rgba(const aiColor4D* assimp_rgba, mxArray** matlab_rgba, unsigned num_vectors);
    
    unsigned to_assimp_texel(const mxArray* matlab_texel, aiTexel** assimp_texel);
    unsigned to_matlab_texel(const aiTexel* assimp_texel, mxArray** matlab_texel, unsigned width, unsigned height);
    
    unsigned to_assimp_4x4(const mxArray* matlab_4x4, aiMatrix4x4** assimp_4x4);
    unsigned to_matlab_4x4(const aiMatrix4x4* assimp_4x4, mxArray** matlab_4x4, unsigned num_vectors);
    
    // data to and from Matlab structs
    
    float get_scalar(const mxArray* matlab_struct, const unsigned index, const char* field_name, const float default_value);
    void set_scalar(mxArray* matlab_struct, const unsigned index, const char* field_name, const float value);
    
    float* get_floats(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out);
    void set_floats(mxArray* matlab_struct, const unsigned index, const char* field_name, const float* floats, unsigned num_elements);    
    
    int32_T* get_ints(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out);
    void set_ints(mxArray* matlab_struct, const unsigned index, const char* field_name, const int32_T* ints, unsigned num_elements);
    
    uint32_T* get_indices(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out);
    void set_indices(mxArray* matlab_struct, const unsigned index, const char* field_name, const uint32_T* indices, unsigned num_elements);
    
    char* get_bytes(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_elements_out);
    void set_bytes(mxArray* matlab_struct, const unsigned index, const char* field_name, const char* bytes, unsigned num_elements);
    
    unsigned get_string(const mxArray* matlab_struct, const unsigned index, const char* field_name, aiString* target, const char* default_value);
    void set_string(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiString* value);
    const char* get_c_string(const mxArray* matlab_struct, const unsigned index, const char* field_name, const char* default_value);
    void set_c_string(mxArray* matlab_struct, const unsigned index, const char* field_name, const char* value);
    
    aiVector3D* get_xyz(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out);
    void get_xyz_in_place(const mxArray* matlab_struct, const unsigned index, const char* field_name, aiVector3D* target);
    void set_xyz(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiVector3D* value, const unsigned num_vectors);
    
    aiColor3D* get_rgb(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out);
    void get_rgb_in_place(const mxArray* matlab_struct, const unsigned index, const char* field_name, aiColor3D* target);
    void set_rgb(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiColor3D* value, const unsigned num_vectors);
    
    aiColor4D* get_rgba(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out);
    void set_rgba(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiColor4D* value, const unsigned num_vectors);

    aiTexel* get_texel(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out);
    void set_texel(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiTexel* value, const unsigned width, const unsigned height);
    
    aiMatrix4x4* get_4x4(const mxArray* matlab_struct, const unsigned index, const char* field_name, unsigned* num_vectors_out);
    void get_4x4_in_place(const mxArray* matlab_struct, const unsigned index, const char* field_name, aiMatrix4x4* target);
    void set_4x4(mxArray* matlab_struct, const unsigned index, const char* field_name, const aiMatrix4x4* value, const unsigned num_vectors);
    
    char* get_property_data(const mxArray* matlab_struct, const unsigned index, const char* field_name, aiPropertyTypeInfo type_code, unsigned* num_bytes_out);
    void set_property_data(mxArray* matlab_struct, const unsigned index, const char* field_name, const char* value,  aiPropertyTypeInfo type_code, unsigned num_bytes);    
}

#endif  // MEXXIMP_UTIL_H_
