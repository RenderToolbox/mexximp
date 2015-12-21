/** String constant declarations and enum conversions for mexximp.
 *
 *  2015 benjamin.heasly@gmail.com
 */

#ifndef MEXXIMP_CONSTANTS_H_
#define MEXXIMP_CONSTANTS_H_

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
    
    static const char* light_field_names[] = {
        "name",
        "position",
        "type",
        "lookAtDirection",
        "innerConeAngle",
        "outerConeAngle",
        "constantAttenuation",
        "linearAttenuation",
        "quadraticAttenuation",
        "ambientColor",
        "diffuseColor",
        "specularColor",
    };
    
    static const char* material_field_names[] = {
        "properties",
    };
    
    static const char* material_property_field_names[] = {
        "key",
        "dataType",
        "data",
        "textureSemantic",
        "textureIndex",
    };
    
    static const char* mesh_field_names[] = {
        "name",
        "materialIndex",
        "primitiveTypes",
        "vertices",
        "faces",
        "colors0",
        "colors1",
        "colors2",
        "colors3",
        "colors4",
        "colors5",
        "colors6",
        "colors7",
        "normals",
        "tangents",
        "bitangents",
        "textureCoordinates0",
        "textureCoordinates1",
        "textureCoordinates2",
        "textureCoordinates3",
        "textureCoordinates4",
        "textureCoordinates5",
        "textureCoordinates6",
        "textureCoordinates7",
    };
    
    static const char* face_field_names[] = {
        "nIndices",
        "indices",
    };
    
    static const char* node_field_names[] = {
        "name",
        "meshIndices",
        "transformation",
        "children",
    };
    
    static const char* texture_field_names[] = {
        "image",
        "format",
    };
    
    // find index of a declared string constant
    inline int string_index(const char* declared[], unsigned num_declared, const char* string) {
        if (!string) {
            return -1;
        }
        for (int i=0; i<num_declared; i++) {
            if (0 == strcmp(declared[i], string)) {
                return i;
            }
        }
        return -1;
    }
    
    // find index of a declared integer constant
    inline int integer_index(const int declared[], unsigned num_declared, int integer) {
        for (int i=0; i<num_declared; i++) {
            if (integer == declared[i]) {
                return i;
            }
        }
        return -1;
    }
    
    // get some declared strings as a cell array of strings
    inline mxArray* create_string_cell(const char* declared[], unsigned num_declared) {
        if (!declared) {
            return mxCreateCellMatrix(1,0);
        }
        
        mxArray* string_cell = mxCreateCellMatrix(1, num_declared);
        for (unsigned i=0; i<num_declared; i++) {
            mxArray* string = mxCreateString(declared[i]);
            if (!string) {
                continue;
            }
            mxSetCell(string_cell, i, string);
        }
        
        return string_cell;
    }
    
    // get some declared strings as a blank struct array
    inline mxArray* create_blank_struct(const char* declared[], unsigned num_declared) {
        if (!declared) {
            return emptyString();
        }
        
        return mxCreateStructMatrix(
                1,
                1,
                num_declared,
                declared);
    }
    
    // mesh primitive type <-> struct
    
    static const char* mesh_primitive_types[] = {
        "point",
        "line",
        "triangle",
        "polygon",
    };
    
    inline mxArray* mesh_primitive_struct(unsigned codes) {
        mxArray* primitives = mxCreateStructMatrix(
                1,
                1,
                COUNT(mesh_primitive_types),
                &mesh_primitive_types[0]);
        if (!primitives) {
            return 0;
        }
        mxSetField(primitives, 0, "point", mxCreateLogicalScalar(codes & aiPrimitiveType_POINT));
        mxSetField(primitives, 0, "line", mxCreateLogicalScalar(codes & aiPrimitiveType_LINE));
        mxSetField(primitives, 0, "triangle", mxCreateLogicalScalar(codes & aiPrimitiveType_TRIANGLE));
        mxSetField(primitives, 0, "polygon", mxCreateLogicalScalar(codes & aiPrimitiveType_POLYGON));
        return primitives;
    }
    
    inline unsigned mesh_primitive_codes(const mxArray* primitives) {
        if (!primitives) {
            return 0;
        }
        
        unsigned codes = 0;
        
        mxArray* point = mxGetField(primitives, 0, "point");
        if (point && mxIsLogicalScalarTrue(point)) {
            codes |= aiPrimitiveType_POINT;
        }
        
        mxArray* line = mxGetField(primitives, 0, "line");
        if (line && mxIsLogicalScalarTrue(line)) {
            codes |= aiPrimitiveType_LINE;
        }
        
        mxArray* triangle = mxGetField(primitives, 0, "triangle");
        if (triangle && mxIsLogicalScalarTrue(triangle)) {
            codes |= aiPrimitiveType_TRIANGLE;
        }
        
        mxArray* polygon = mxGetField(primitives, 0, "polygon");
        if (polygon && mxIsLogicalScalarTrue(polygon)) {
            codes |= aiPrimitiveType_POLYGON;
        }
        
        return codes;
    }
    
    // light type <-> string
    
    static const char* light_type_strings[] = {
        "undefined",
        "directional",
        "point",
        "spot",
    };
    
    static const aiLightSourceType light_type_codes[] = {
        aiLightSource_UNDEFINED,
        aiLightSource_DIRECTIONAL,
        aiLightSource_POINT,
        aiLightSource_SPOT,
    };
    
    inline const char* light_type_string(aiLightSourceType type_code) {
        int index = integer_index((const int*)light_type_codes, COUNT(light_type_codes), type_code);
        return index < 0 ? "unknown_code" : light_type_strings[index];
    }
    
    inline aiLightSourceType light_type_code(const char* type_string) {
        int index = string_index(light_type_strings, COUNT(light_type_strings), type_string);
        return index < 0 ? aiLightSource_UNDEFINED : light_type_codes[index];
    }
    
    // material property type <-> string
    
    static const char* material_property_type_strings[] = {
        "float",
        "string",
        "integer",
        "buffer",
    };
    
    static const aiPropertyTypeInfo material_property_type_codes[] = {
        aiPTI_Float,
        aiPTI_String,
        aiPTI_Integer,
        aiPTI_Buffer,
    };
    
    inline const char* material_property_type_string(aiPropertyTypeInfo type_code) {
        int index = integer_index((const int*)material_property_type_codes, COUNT(material_property_type_codes), type_code);
        return index < 0 ? "unknown_code" : material_property_type_strings[index];
    }
    
    inline aiPropertyTypeInfo material_property_type_code(const char* type_string) {
        int index = string_index(material_property_type_strings, COUNT(material_property_type_strings), type_string);
        return index < 0 ? aiPTI_Buffer : material_property_type_codes[index];
    }
    
    // texture type <-> string
    
    static const char* texture_type_strings[] = {
        "none",
        "diffuse",
        "specular",
        "ambient",
        "emissive",
        "height",
        "normals",
        "shininess",
        "opacity",
        "displacement",
        "light_map",
        "reflection",
        "unknown"
    };
    
    static const aiTextureType texture_type_codes[] = {
        aiTextureType_NONE,
        aiTextureType_DIFFUSE,
        aiTextureType_SPECULAR,
        aiTextureType_AMBIENT,
        aiTextureType_EMISSIVE,
        aiTextureType_HEIGHT,
        aiTextureType_NORMALS,
        aiTextureType_SHININESS,
        aiTextureType_OPACITY,
        aiTextureType_DISPLACEMENT,
        aiTextureType_LIGHTMAP,
        aiTextureType_REFLECTION,
        aiTextureType_UNKNOWN,
    };
    
    inline const char* texture_type_string(aiTextureType type_code) {
        int index = integer_index((const int*)texture_type_codes, COUNT(texture_type_codes), type_code);
        return index < 0 ? "unknown_code" : texture_type_strings[index];
    }
    
    inline aiTextureType texture_type_code(const char* type_string) {
        int index = string_index(texture_type_strings, COUNT(texture_type_strings), type_string);
        return index < 0 ? aiTextureType_UNKNOWN : texture_type_codes[index];
    }
    
    // material property nice key <-> ugly key
    
    static const char* nice_key_strings[] = {
        "name",
        "two_sided",
        "shading_model",
        "enable_wireframe",
        "blend_func",
        "opacity",
        "bump_scaling",
        "shininess",
        "reflectivity",
        "shininess_strength",
        "refract_i",
        "diffuse",
        "ambient",
        "specular",
        "emissive",
        "transparent",
        "reflective",
        "global_background_image",
        "texture",
        "uvw_source",
        "texture_op",
        "mapping",
        "texture_blend",
        "mapping_u",
        "mapping_v",
        "texture_map_axis",
        "uv_transform",
        "texture_flags",
    };
    
    static const char* ugly_key_strings[] = {
        "?mat.name",
        "$mat.twosided",
        "$mat.shadingm",
        "$mat.wireframe",
        "$mat.blend",
        "$mat.opacity",
        "$mat.bumpscaling",
        "$mat.shininess",
        "$mat.reflectivity",
        "$mat.shinpercent",
        "$mat.refracti",
        "$clr.diffuse",
        "$clr.ambient",
        "$clr.specular",
        "$clr.emissive",
        "$clr.transparent",
        "$clr.reflective",
        "?bg.global",
        _AI_MATKEY_TEXTURE_BASE,
        _AI_MATKEY_UVWSRC_BASE,
        _AI_MATKEY_TEXOP_BASE,
        _AI_MATKEY_MAPPING_BASE,
        _AI_MATKEY_TEXBLEND_BASE,
        _AI_MATKEY_MAPPINGMODE_U_BASE,
        _AI_MATKEY_MAPPINGMODE_V_BASE,
        _AI_MATKEY_TEXMAP_AXIS_BASE,
        _AI_MATKEY_UVTRANSFORM_BASE,
        _AI_MATKEY_TEXFLAGS_BASE,
    };
    
    inline const char* nice_key(const char* key) {
        int index = string_index(ugly_key_strings, COUNT(ugly_key_strings), key);
        return index < 0 ? "unknown_key" : nice_key_strings[index];
    }
    
    inline const char* ugly_key(const char* key) {
        int index = string_index(nice_key_strings, COUNT(nice_key_strings), key);
        return index < 0 ? "unknown_key" : ugly_key_strings[index];
    }
}

#endif  // MEXXIMP_CONSTANTS_H_
