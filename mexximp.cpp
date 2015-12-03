
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

mxArray* getAMesh(const aiScene* scene) {
    if (!scene || !scene->mNumMeshes) {
        return mxCreateDoubleScalar(0);
    }
    
    aiMesh* mesh = scene->mMeshes[0];
    mxArray* vertexData = mxCreateDoubleMatrix(3, mesh->mNumVertices, mxREAL);
    if (!mesh) {
        return mxCreateDoubleScalar(0);
    }
    
    double* mxData = mxGetPr(vertexData);
    if (!mxData) {
        return mxCreateDoubleScalar(0);
    }
    
    for (int i = 0; i < mesh->mNumVertices; i++) {
        mxData[3 * i] = mesh->mVertices[i].x;
        mxData[3 * i + 1] = mesh->mVertices[i].y;
        mxData[3 * i + 2] = mesh->mVertices[i].z;
    }
    return vertexData;
}

void setAMesh(const aiScene* scene, const mxArray* vertexData) {
    if (!scene || !scene->mNumMeshes || !vertexData) {
        return;
    }
    
    aiMesh* mesh = scene->mMeshes[0];
    if (!mesh) {
        return;
    }
    
    double* mxData = mxGetPr(vertexData);
    if (!mxData) {
        return;
    }
    
    int nVertices = mxGetNumberOfElements(vertexData) / 3;
    if (nVertices > mesh->mNumVertices) {
        nVertices = mesh->mNumVertices;
    }
    for (int i = 0; i < nVertices; i++) {
        mesh->mVertices[i].x = mxData[3 * i];
        mesh->mVertices[i].y = mxData[3 * i + 1];
        mesh->mVertices[i].z = mxData[3 * i + 2];
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs < 1 || !mxIsChar(prhs[0])) {
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
    
    if (2 == nrhs && mxIsDouble(prhs[1])) {
        setAMesh(scene, prhs[1]);
    }
    
    if (1 == nlhs) {
        plhs[0] = getAMesh(scene);
    }
}
