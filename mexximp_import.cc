
#include <mex.h>
#include <assimp/Importer.hpp>
#include <assimp/importerdesc.h>
#include "mexximp_constants.h"
#include "mexximp_scene.h"

void printUsage() {
    Assimp::Importer importer;
    
    mexPrintf("Import a scene file:\n");
    mexPrintf("  scene = mexximpImport(sceneFile, postprocessSteps)\n");
    mexPrintf("  see mexximpConstants('postprocessStep') for sample postprocessSteps\n");
    mexPrintf("The following formats are supported:\n");

    unsigned num_formats = importer.GetImporterCount();
    for (unsigned i=0; i<num_formats; i++) {
        const aiImporterDesc* format = importer.GetImporterInfo(i);
        if (!format) {
            continue;
        }
        mexPrintf("  %s (%s): %s\n", format->mName, format->mFileExtensions, format->mComments);
    }
    mexPrintf("\n");

}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs < 1 || !mxIsChar(prhs[0])) {
        printUsage();
        plhs[0] = mexximp::emptyDouble();
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
