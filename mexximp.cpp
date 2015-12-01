
#include <math.h>
#include <matrix.h>
#include <mex.h>

#include <Importer.hpp>
#include <scene.h>
#include <postprocess.h>

void printUsage() {
    aiString extensions;
    Assimp::Importer importer;
    importer.GetExtensionList(extensions);
    
    mexPrintf("Import a scene file (%s):\n", extensions.C_Str());
    mexPrintf("  sceneInfo = mexximp(sceneFile)\n");
    mexPrintf("\n");
}

void describeScene(const aiScene* scene) {
    mexPrintf("  %d animations\n", scene->mNumAnimations);
    mexPrintf("  %d cameras\n", scene->mNumCameras);
    mexPrintf("  %d lights\n", scene->mNumLights);
    mexPrintf("  %d materials\n", scene->mNumMaterials);
    mexPrintf("  %d meshes\n", scene->mNumMeshes);
    mexPrintf("  %d textures\n", scene->mNumTextures);
    mexPrintf("  root node: \"%s\"\n", scene->mRootNode->mName.C_Str());
    mexPrintf("\n");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (1 != nrhs || !mxIsChar(prhs[0])) {
        printUsage();
        return;
    }
    
    char* sceneFile = mxArrayToString(prhs[0]);
    const std::string& pFile(sceneFile);
    mxFree(sceneFile);
    
    Assimp::Importer importer;
    const aiScene* scene = importer.ReadFile(
            pFile,
            aiProcess_CalcTangentSpace
            | aiProcess_Triangulate
            | aiProcess_JoinIdenticalVertices
            | aiProcess_SortByPType);
    
    if(!scene) {
        mexPrintf("%s\n", importer.GetErrorString());
        mexPrintf("\n");
        return;
    }
    
    mexPrintf("Loaded scene from \"%s\"\n", pFile.c_str());
    describeScene(scene);
}
