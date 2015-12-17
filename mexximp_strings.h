/** String constant declarations and enum conversions for mexximp.
 *
 *  2015 benjamin.heasly@gmail.com
 */

#ifndef MEXXIMP_STRINGS_H_
#define MEXXIMP_STRINGS_H_

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
    
    inline const char* light_type_string(aiLightSourceType type_code) {
        switch (type_code) {
            case aiLightSource_UNDEFINED:
                return "undefined";
            case aiLightSource_DIRECTIONAL:
                return "directional";
            case aiLightSource_POINT:
                return "point";
            case aiLightSource_SPOT:
                return "spot";
            default:
                return "unknown_code";
        }
    }
    
    inline aiLightSourceType light_type_code(const char* type_string) {
        if (!type_string || !strcmp("undefined", type_string)) {
            return aiLightSource_UNDEFINED;
        } else if (!strcmp("directional", type_string)) {
            return aiLightSource_DIRECTIONAL;
        } else if (!strcmp("point", type_string)) {
            return aiLightSource_POINT;
        } else if (!strcmp("spot", type_string)) {
            return aiLightSource_SPOT;
        }
        return aiLightSource_UNDEFINED;
    }
    
    // material property type <-> string
    
    inline const char* material_property_type_string(aiPropertyTypeInfo type_code) {
        switch (type_code) {
            case aiPTI_Float:
                return "float";
            case aiPTI_String:
                return "string";
            case aiPTI_Integer:
                return "integer";
            case aiPTI_Buffer:
                return "buffer";
            default:
                return "unknown_code";
        }
    }
    
    inline aiPropertyTypeInfo material_property_type_code(const char* type_string) {
        if (!type_string || !strcmp("buffer", type_string)) {
            return aiPTI_Buffer;
        } else if (!strcmp("float", type_string)) {
            return aiPTI_Float;
        } else if (!strcmp("string", type_string)) {
            return aiPTI_String;
        } else if (!strcmp("integer", type_string)) {
            return aiPTI_Integer;
        }
        return aiPTI_Buffer;
    }
    
    // texture type <-> string
    
    inline const char* texture_type_string(aiTextureType type_code) {
        switch (type_code) {
            case aiTextureType_NONE:
                return "none";
            case aiTextureType_DIFFUSE:
                return "diffuse";
            case aiTextureType_SPECULAR:
                return "specular";
            case aiTextureType_AMBIENT:
                return "ambient";
            case aiTextureType_EMISSIVE:
                return "emissive";
            case aiTextureType_HEIGHT:
                return "height";
            case aiTextureType_NORMALS:
                return "normals";
            case aiTextureType_SHININESS:
                return "shininess";
            case aiTextureType_OPACITY:
                return "opacity";
            case aiTextureType_DISPLACEMENT:
                return "displacement";
            case aiTextureType_LIGHTMAP:
                return "light_map";
            case aiTextureType_REFLECTION:
                return "reflection";
            case aiTextureType_UNKNOWN:
                return "unknown";
            default:
                return "unknown_code";
        }
    }
    
    inline aiTextureType texture_type_code(const char* type_string) {
        if (!type_string || !strcmp("unknown", type_string)) {
            return aiTextureType_UNKNOWN;
        } else if (!strcmp("none", type_string)) {
            return aiTextureType_NONE;
        } else if (!strcmp("diffuse", type_string)) {
            return aiTextureType_DIFFUSE;
        } else if (!strcmp("specular", type_string)) {
            return aiTextureType_SPECULAR;
        } else if (!strcmp("ambient", type_string)) {
            return aiTextureType_AMBIENT;
        } else if (!strcmp("emissive", type_string)) {
            return aiTextureType_EMISSIVE;
        } else if (!strcmp("height", type_string)) {
            return aiTextureType_HEIGHT;
        } else if (!strcmp("normals", type_string)) {
            return aiTextureType_NORMALS;
        } else if (!strcmp("shininess", type_string)) {
            return aiTextureType_SHININESS;
        } else if (!strcmp("opacity", type_string)) {
            return aiTextureType_OPACITY;
        } else if (!strcmp("displacement", type_string)) {
            return aiTextureType_DISPLACEMENT;
        } else if (!strcmp("light_map", type_string)) {
            return aiTextureType_LIGHTMAP;
        } else if (!strcmp("reflection", type_string)) {
            return aiTextureType_REFLECTION;
        }
        return aiTextureType_UNKNOWN;
    }
    
    // material property nice key <-> ugly key
    
    inline const char* nice_key(const char* key) {
        if (!key) {
            return "unknown_key";
        } else if (!strcmp("?mat.name", key)) {
            return "name";
        } else if (!strcmp("$mat.twosided", key)) {
            return "two_sided";
        } else if (!strcmp("$mat.shadingm", key)) {
            return "shading_model";
        } else if (!strcmp("$mat.wireframe", key)) {
            return "enable_wireframe";
        } else if (!strcmp("$mat.blend", key)) {
            return "blend_func";
        } else if (!strcmp("$mat.opacity", key)) {
            return "opacity";
        } else if (!strcmp("$mat.bumpscaling", key)) {
            return "bump_scaling";
        } else if (!strcmp("$mat.shininess", key)) {
            return "shininess";
        } else if (!strcmp("$mat.reflectivity", key)) {
            return "reflectivity";
        } else if (!strcmp("$mat.shinpercent", key)) {
            return "shininess_strength";
        } else if (!strcmp("$mat.refracti", key)) {
            return "refract_i";
        } else if (!strcmp("$clr.diffuse", key)) {
            return "diffuse";
        } else if (!strcmp("$clr.ambient", key)) {
            return "ambient";
        } else if (!strcmp("$clr.specular", key)) {
            return "specular";
        } else if (!strcmp("$clr.emissive", key)) {
            return "emissive";
        } else if (!strcmp("$clr.transparent", key)) {
            return "transparent";
        } else if (!strcmp("$clr.reflective", key)) {
            return "reflective";
        } else if (!strcmp("?bg.global", key)) {
            return "global_background_image";
        } else if (!strcmp(_AI_MATKEY_TEXTURE_BASE, key)) {
            return "texture";
        } else if (!strcmp(_AI_MATKEY_UVWSRC_BASE, key)) {
            return "uvw_source";
        } else if (!strcmp(_AI_MATKEY_TEXOP_BASE, key)) {
            return "texture_op";
        } else if (!strcmp(_AI_MATKEY_MAPPING_BASE, key)) {
            return "mapping";
        } else if (!strcmp(_AI_MATKEY_TEXBLEND_BASE, key)) {
            return "texture_blend";
        } else if (!strcmp(_AI_MATKEY_MAPPINGMODE_U_BASE, key)) {
            return "mapping_u";
        } else if (!strcmp(_AI_MATKEY_MAPPINGMODE_V_BASE, key)) {
            return "mapping_v";
        } else if (!strcmp(_AI_MATKEY_TEXMAP_AXIS_BASE, key)) {
            return "texture_map_axis";
        } else if (!strcmp(_AI_MATKEY_UVTRANSFORM_BASE, key)) {
            return "uv_transform";
        } else if (!strcmp(_AI_MATKEY_TEXFLAGS_BASE, key)) {
            return "texture_flags";
        }
        return "unknown_key";
    }
    
    inline const char* ugly_key(const char* key) {
        if (!key) {
            return "unknown_name";
        } else if (!strcmp("name", key)) {
            return "?mat.name";
        } else if (!strcmp("two_sided", key)) {
            return "$mat.twosided";
        } else if (!strcmp("shading_model", key)) {
            return "$mat.shadingm";
        } else if (!strcmp("enable_wireframe", key)) {
            return "$mat.wireframe";
        } else if (!strcmp("blend_func", key)) {
            return "$mat.blend";
        } else if (!strcmp("opacity", key)) {
            return "$mat.opacity";
        } else if (!strcmp("bump_scaling", key)) {
            return "$mat.bumpscaling";
        } else if (!strcmp("shininess", key)) {
            return "$mat.shininess";
        } else if (!strcmp("reflectivity", key)) {
            return "$mat.reflectivity";
        } else if (!strcmp("shininess_strength", key)) {
            return "$mat.shinpercent";
        } else if (!strcmp("refract_i", key)) {
            return "$mat.refracti";
        } else if (!strcmp("diffuse", key)) {
            return "$clr.diffuse";
        } else if (!strcmp("ambient", key)) {
            return "$clr.ambient";
        } else if (!strcmp("specular", key)) {
            return "$clr.specular";
        } else if (!strcmp("emissive", key)) {
            return "$clr.emissive";
        } else if (!strcmp("transparent", key)) {
            return "$clr.transparent";
        } else if (!strcmp("reflective", key)) {
            return "$clr.reflective";
        } else if (!strcmp("global_background_image", key)) {
            return "?bg.global";
        } else if (!strcmp("texture", key)) {
            return _AI_MATKEY_TEXTURE_BASE;
        } else if (!strcmp("uvw_source", key)) {
            return _AI_MATKEY_UVWSRC_BASE;
        } else if (!strcmp("texture_op", key)) {
            return _AI_MATKEY_TEXOP_BASE;
        } else if (!strcmp("mapping", key)) {
            return _AI_MATKEY_MAPPING_BASE;
        } else if (!strcmp("texture_blend", key)) {
            return _AI_MATKEY_TEXBLEND_BASE;
        } else if (!strcmp("mapping_u", key)) {
            return _AI_MATKEY_MAPPINGMODE_U_BASE;
        } else if (!strcmp("mapping_v", key)) {
            return _AI_MATKEY_MAPPINGMODE_V_BASE;
        } else if (!strcmp("texture_map_axis", key)) {
            return _AI_MATKEY_TEXMAP_AXIS_BASE;
        } else if (!strcmp("uv_transform", key)) {
            return _AI_MATKEY_UVTRANSFORM_BASE;
        } else if (!strcmp("texture_flags", key)) {
            return _AI_MATKEY_TEXFLAGS_BASE;
        }
        return "unknown_name";
    }
    
}

#endif  // MEXXIMP_STRINGS_H_
