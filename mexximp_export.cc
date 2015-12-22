
#include <mex.h>
#include <assimp/Exporter.hpp>
#include "mexximp_constants.h"
#include "mexximp_scene.h"

void printUsage() {
    Assimp::Exporter exporter;
    
    mexPrintf("Export a scene file:\n");
    mexPrintf("  status = mexximpExport(scene, format, sceneFile, postprocessSteps)\n");
    mexPrintf("  see mexximpConstants('postprocessStep') for sample postprocessSteps\n");
    mexPrintf("The following formats are supported:\n");
    
    unsigned num_formats = exporter.GetExportFormatCount();
    for (unsigned i=0; i<num_formats; i++) {
        const aiExportFormatDesc* format = exporter.GetExportFormatDescription(i);
        if (!format) {
            continue;
        }
        mexPrintf("  %s (%s): %s\n", format->id, format->fileExtension, format->description);
    }
    
    mexPrintf("\n");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs < 3 || !mxIsStruct(prhs[0]) || !mxIsChar(prhs[1]) || !mxIsChar(prhs[2])) {
        printUsage();
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    unsigned postprocessFlags = 0;
    if (3 < nrhs && mxIsStruct(prhs[3])) {
        postprocessFlags = mexximp::postprocess_step_codes(prhs[3]);
    }
    
    aiScene scene;
    unsigned count = mexximp::to_assimp_scene(prhs[0], &scene);
    if (!count) {
        mexPrintf("Could not convert scene to Assimp format.\n");
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    char* format = mxArrayToString(prhs[1]);
    const std::string& pFormat(format);
    mxFree(format);
    
    char* sceneFile = mxArrayToString(prhs[2]);
    const std::string& pFile(sceneFile);
    mxFree(sceneFile);
        
    Assimp::Exporter exporter;
    aiReturn status = exporter.Export(&scene, pFormat, pFile, postprocessFlags);
    
    if(AI_SUCCESS != status) {
        mexPrintf("%s\n", exporter.GetErrorString());
        mexPrintf("\n");
    }
    
    plhs[0] = mxCreateDoubleScalar(status);
}
