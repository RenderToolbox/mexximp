
#include "mexximp_scene.h"
#include "mexximp_util.h"
#include "mexximp_strings.h"

namespace mexximp {
    
    // scene (top-level)
    
    unsigned to_assimp_scene(const mxArray* matlab_scene, aiScene** assimp_scene) {
        if (!matlab_scene || !assimp_scene || !mxIsStruct(matlab_scene)) {
            return 0;
        }
        
        *assimp_scene = mx_new_scene();
        if (!*assimp_scene) {
            return 0;
        }
        
        mxArray* matlab_cameras = mxGetField(matlab_scene, 0, "cameras");
        (*assimp_scene)->mNumCameras = to_assimp_cameras(matlab_cameras, (*assimp_scene)->mCameras);
        
        mxArray* matlab_lights = mxGetField(matlab_scene, 0, "lights");
        (*assimp_scene)->mNumLights = to_assimp_lights(matlab_lights, (*assimp_scene)->mLights);
        
        mxArray* matlab_materials = mxGetField(matlab_scene, 0, "materials");
        (*assimp_scene)->mNumMaterials = to_assimp_materials(matlab_materials, (*assimp_scene)->mMaterials);
        
        return 1;
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
        
        mxArray* matlab_cameras;
        to_matlab_cameras(*(assimp_scene->mCameras), &matlab_cameras, assimp_scene->mNumCameras);
        mxSetField(*matlab_scene, 0, "cameras", matlab_cameras);
        
        mxArray* matlab_lights;
        to_matlab_lights(*(assimp_scene->mLights), &matlab_lights, assimp_scene->mNumLights);
        mxSetField(*matlab_scene, 0, "lights", matlab_lights);
        
        mxArray* matlab_materials;
        to_matlab_materials(*(assimp_scene->mMaterials), &matlab_materials, assimp_scene->mNumMaterials);
        mxSetField(*matlab_scene, 0, "materials", matlab_materials);
        
        return 1;
    }
    
    // cameras
    
    unsigned to_assimp_cameras(const mxArray* matlab_cameras, aiCamera** assimp_cameras) {
        if (!matlab_cameras || !assimp_cameras || !mxIsStruct(matlab_cameras)) {
            return 0;
        }
        
        unsigned num_cameras = mxGetNumberOfElements(matlab_cameras);
        *assimp_cameras = (aiCamera*)mxCalloc(num_cameras, sizeof(aiCamera));
        if (!*assimp_cameras) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_cameras; i++) {
            (*assimp_cameras)[i].mPosition = get_xyz(matlab_cameras, i, "position", 0)[0];
            (*assimp_cameras)[i].mLookAt = get_xyz(matlab_cameras, i, "lookAtDirection", 0)[0];
            (*assimp_cameras)[i].mUp = get_xyz(matlab_cameras, i, "upDirection", 0)[0];
            (*assimp_cameras)[i].mName = get_string(matlab_cameras, i, "name", "camera")[0];
            (*assimp_cameras)[i].mAspect = get_scalar(matlab_cameras, i, "aspectRatio", 1.0);
            (*assimp_cameras)[i].mClipPlaneNear = get_scalar(matlab_cameras, i, "clipPlaneNear", 0.1);
            (*assimp_cameras)[i].mClipPlaneFar = get_scalar(matlab_cameras, i, "clipPlaneFar", 1000);
            (*assimp_cameras)[i].mHorizontalFOV = get_scalar(matlab_cameras, i, "horizontalFov", 3.14159/4.0);
        }
        
        return num_cameras;
    }
    
    unsigned to_matlab_cameras(const aiCamera* assimp_cameras, mxArray** matlab_cameras, unsigned num_cameras) {
        if (!matlab_cameras) {
            return 0;
        }
        
        if (!assimp_cameras || 0 == num_cameras) {
            *matlab_cameras = emptyDouble();
            return 0;
        }
        
        *matlab_cameras = mxCreateStructMatrix(
                1,
                num_cameras,
                COUNT(camera_field_names),
                &camera_field_names[0]);
        
        for (unsigned i = 0; i < num_cameras; i++) {
            set_xyz(*matlab_cameras, i, "position", &assimp_cameras[i].mPosition, 1);
            set_xyz(*matlab_cameras, i, "lookAtDirection", &assimp_cameras[i].mLookAt, 1);
            set_xyz(*matlab_cameras, i, "upDirection", &assimp_cameras[i].mUp, 1);
            set_string(*matlab_cameras, i, "name", &assimp_cameras[i].mName);
            set_scalar(*matlab_cameras, i, "aspectRatio", assimp_cameras[i].mAspect);
            set_scalar(*matlab_cameras, i, "clipPlaneNear", assimp_cameras[i].mClipPlaneNear);
            set_scalar(*matlab_cameras, i, "clipPlaneFar", assimp_cameras[i].mClipPlaneFar);
            set_scalar(*matlab_cameras, i, "horizontalFov", assimp_cameras[i].mHorizontalFOV);
        }
        
        return num_cameras;
    }
    
    // lights
    
    unsigned to_assimp_lights(const mxArray* matlab_lights, aiLight** assimp_lights) {
        if (!matlab_lights || !assimp_lights || !mxIsStruct(matlab_lights)) {
            return 0;
        }
        
        unsigned num_lights = mxGetNumberOfElements(matlab_lights);
        *assimp_lights = (aiLight*)mxCalloc(num_lights, sizeof(aiLight));
        if (!*assimp_lights) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_lights; i++) {
            (*assimp_lights)[i].mColorAmbient = get_rgb(matlab_lights, i, "ambientColor", 0)[0];
            (*assimp_lights)[i].mColorDiffuse = get_rgb(matlab_lights, i, "diffuseColor", 0)[0];
            (*assimp_lights)[i].mColorSpecular = get_rgb(matlab_lights, i, "specularColor", 0)[0];
            (*assimp_lights)[i].mPosition = get_xyz(matlab_lights, i, "position", 0)[0];
            (*assimp_lights)[i].mDirection = get_xyz(matlab_lights, i, "lookAtDirection", 0)[0];
            (*assimp_lights)[i].mName = get_string(matlab_lights, i, "name", "light")[0];
            (*assimp_lights)[i].mType = light_type_code(get_c_string(matlab_lights, i, "type", "undefined"));
            (*assimp_lights)[i].mAngleInnerCone = get_scalar(matlab_lights, i, "innerConeAngle", 2*3.14159);
            (*assimp_lights)[i].mAngleOuterCone = get_scalar(matlab_lights, i, "outerConeAngle", 2*3.14159);
            (*assimp_lights)[i].mAttenuationConstant = get_scalar(matlab_lights, i, "constantAttenuation", 1);
            (*assimp_lights)[i].mAttenuationLinear = get_scalar(matlab_lights, i, "linearAttenuation", 0);
            (*assimp_lights)[i].mAttenuationQuadratic = get_scalar(matlab_lights, i, "quadraticAttenuation", 0);
        }
        
        return num_lights;
    }
    
    unsigned to_matlab_lights(const aiLight* assimp_lights, mxArray** matlab_lights, unsigned num_lights) {
        if (!matlab_lights) {
            return 0;
        }
        
        if (!assimp_lights || 0 == num_lights) {
            *matlab_lights = emptyDouble();
            return 0;
        }
        
        *matlab_lights = mxCreateStructMatrix(
                1,
                num_lights,
                COUNT(light_field_names),
                &light_field_names[0]);
        
        for (unsigned i = 0; i < num_lights; i++) {
            set_rgb(*matlab_lights, i, "ambientColor", &assimp_lights[i].mColorAmbient, 1);
            set_rgb(*matlab_lights, i, "diffuseColor", &assimp_lights[i].mColorDiffuse, 1);
            set_rgb(*matlab_lights, i, "specularColor", &assimp_lights[i].mColorSpecular, 1);
            set_xyz(*matlab_lights, i, "position", &assimp_lights[i].mPosition, 1);
            set_xyz(*matlab_lights, i, "lookAtDirection", &assimp_lights[i].mDirection, 1);
            set_string(*matlab_lights, i, "name", &assimp_lights[i].mName);
            set_c_string(*matlab_lights, i, "type", light_type_string(assimp_lights[i].mType));
            set_scalar(*matlab_lights, i, "innerConeAngle", assimp_lights[i].mAngleInnerCone);
            set_scalar(*matlab_lights, i, "outerConeAngle", assimp_lights[i].mAngleOuterCone);
            set_scalar(*matlab_lights, i, "constantAttenuation", assimp_lights[i].mAttenuationConstant);
            set_scalar(*matlab_lights, i, "linearAttenuation", assimp_lights[i].mAttenuationLinear);
            set_scalar(*matlab_lights, i, "quadraticAttenuation", assimp_lights[i].mAttenuationQuadratic);
        }
        
        return num_lights;
    }
    
    // materials
    
    unsigned to_assimp_materials(const mxArray* matlab_materials, aiMaterial** assimp_materials) {
        if (!matlab_materials || !assimp_materials || !mxIsStruct(matlab_materials)) {
            return 0;
        }
        
        unsigned num_materials = mxGetNumberOfElements(matlab_materials);
        *assimp_materials = (aiMaterial*)mxCalloc(num_materials, sizeof(aiMaterial));
        if (!*assimp_materials) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_materials; i++) {
            (*assimp_materials)[i].mProperties = (aiMaterialProperty**)mxCalloc(1, sizeof(aiMaterialProperty*));
            
            mxArray* matlab_properties = mxGetField(matlab_materials, i, "properties");
            (*assimp_materials)[i].mNumProperties = to_assimp_material_properties(
                    matlab_properties,
                    (*assimp_materials)[i].mProperties);
        }
        
        return num_materials;
    }
    
    unsigned to_matlab_materials(const aiMaterial* assimp_materials, mxArray** matlab_materials, unsigned num_materials) {
        if (!matlab_materials) {
            return 0;
        }
        
        if (!assimp_materials || 0 == num_materials) {
            *matlab_materials = emptyDouble();
            return 0;
        }
        
        *matlab_materials = mxCreateStructMatrix(
                1,
                num_materials,
                COUNT(material_field_names),
                &material_field_names[0]);
        
        for (unsigned i = 0; i < num_materials; i++) {
            mxArray* matlab_properties;
            to_matlab_material_properties(*(assimp_materials[i].mProperties),
                    &matlab_properties,
                    assimp_materials[i].mNumProperties);
            if (matlab_properties) {
                mxSetField(*matlab_materials, i, "properties", matlab_properties);
            }
        }
        
        return num_materials;
    }
    
    // material properties
    
    unsigned to_assimp_material_properties(const mxArray* matlab_properties, aiMaterialProperty** assimp_properties) {
        if (!matlab_properties || !assimp_properties || !mxIsStruct(matlab_properties)) {
            return 0;
        }
        
        unsigned num_properties = mxGetNumberOfElements(matlab_properties);
        *assimp_properties = (aiMaterialProperty*)mxCalloc(num_properties, sizeof(aiMaterialProperty));
        if (!*assimp_properties) {
            return 0;
        }
        
        for (unsigned i = 0; i < num_properties; i++) {
            (*assimp_properties)[i].mKey = get_string(matlab_properties, i, "key", "property")[0];
            (*assimp_properties)[i].mIndex = get_scalar(matlab_properties, i, "textureIndex", 0);
            (*assimp_properties)[i].mSemantic = texture_type_code(get_c_string(matlab_properties, i, "textureSemantic", "unknown"));
            
            aiPropertyTypeInfo type_code = material_property_type_code(get_c_string(matlab_properties, i, "dataType", "buffer"));
            (*assimp_properties)[i].mType = type_code;
            
            unsigned num_bytes;
            (*assimp_properties)[i].mData = get_property_data(matlab_properties, i, "data", type_code, &num_bytes);
            (*assimp_properties)[i].mDataLength = num_bytes;
        }
        
        return num_properties;
    }
    
    unsigned to_matlab_material_properties(const aiMaterialProperty* assimp_properties, mxArray** matlab_properties, unsigned num_properties) {
        if (!matlab_properties) {
            return 0;
        }
        
        if (!assimp_properties || 0 == num_properties) {
            *matlab_properties = emptyDouble();
            return 0;
        }
        
        *matlab_properties = mxCreateStructMatrix(
                1,
                num_properties,
                COUNT(material_property_field_names),
                &material_property_field_names[0]);
        
        for (unsigned i = 0; i < num_properties; i++) {
            set_string(*matlab_properties, i, "key", &assimp_properties[i].mKey);
            set_scalar(*matlab_properties, i, "textureIndex", assimp_properties[i].mIndex);
            set_c_string(*matlab_properties, i, "textureSemantic", texture_type_string((aiTextureType)assimp_properties[i].mSemantic));
            
            aiPropertyTypeInfo type_code = assimp_properties[i].mType;
            set_c_string(*matlab_properties, i, "dataType", material_property_type_string(type_code));
            set_property_data(*matlab_properties, i, "data", assimp_properties[i].mData,  type_code, assimp_properties[i].mDataLength);
        }
        
        return num_properties;
    }
}