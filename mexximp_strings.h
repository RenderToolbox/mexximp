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
        "textureIndex"
    };
    
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
}

#endif  // MEXXIMP_STRINGS_H_
