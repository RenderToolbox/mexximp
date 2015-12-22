
#include <mex.h>
#include <assimp/Importer.hpp>
#include "mexximp_constants.h"
#include "mexximp_scene.h"

void printUsage() {
    aiString extensions;
    Assimp::Importer importer;
    importer.GetExtensionList(extensions);
    
    mexPrintf("Import a scene file (%s):\n", extensions.C_Str());
    mexPrintf("  sceneInfo = mexximp(sceneFile, postprocessSteps)\n");
    mexPrintf("  see mexximpConstants('postprocessStep') for sample postprocessSteps\n");
    mexPrintf("\n");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs < 1 || !mxIsChar(prhs[0])) {
        printUsage();
        return;
    }
    
    int postprocessFlags = 0;
    if (1 < nrhs && mxIsStruct(prhs[1])) {
        postprocessFlags = mexximp::postprocess_step_codes(prhs[1]);
    }
    
    char* sceneFile = mxArrayToString(prhs[0]);
    const std::string& pFile(sceneFile);
    mxFree(sceneFile);
    
    Assimp::Importer importer;
    const aiScene* scene = importer.ReadFile(
            pFile,
            postprocessFlags);
    
    if(!scene) {
        mexPrintf("%s\n", importer.GetErrorString());
        mexPrintf("\n");
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    if (1 <= nlhs) {
        mexximp::to_matlab_scene(scene, &plhs[0]);
    }
}
