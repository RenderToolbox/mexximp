
#include "mexximp_scene.h"
#include "mexximp_util.h"

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
}
