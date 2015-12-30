/** Convert Assimp <-> Matlab 3D scenes.
 *
 *  These functions are alllowed to allocate heap memory themselves
 *  using new and new [].  Assimp might read this memory while exporting 
 *  scene files.  Assimp recursively calls delete and delete [] for 
 *  these allocations when the top-level scene is destroyed.  So just make
 *  sure the top-level scene gets destroyed!
 *
 *  2015 benjamin.heasly@gmail.com
 */

#ifndef MEXXIMP_SCENE_H_
#define MEXXIMP_SCENE_H_

#include <assimp/scene.h>
#include "mexximp_util.h"

namespace mexximp {
    
    // aiScene to and from Matlab structs
    
    unsigned to_assimp_scene(const mxArray* matlab_scene, aiScene* assimp_scene);
    unsigned to_matlab_scene(const aiScene* assimp_scene, mxArray** matlab_scene);
    
    unsigned to_assimp_cameras(const mxArray* matlab_cameras, aiCamera*** assimp_cameras);
    unsigned to_matlab_cameras(aiCamera** assimp_cameras, mxArray** matlab_cameras, unsigned num_cameras);
    
    unsigned to_assimp_lights(const mxArray* matlab_lights, aiLight*** assimp_lights);
    unsigned to_matlab_lights(aiLight** assimp_lights, mxArray** matlab_lights, unsigned num_lights);
    
    unsigned to_assimp_materials(const mxArray* matlab_materials, aiMaterial*** assimp_materials);
    unsigned to_matlab_materials(aiMaterial** assimp_materials, mxArray** matlab_materials, unsigned num_materials);
    
    unsigned to_assimp_material_properties(const mxArray* matlab_properties, aiMaterialProperty*** assimp_properties);
    unsigned to_matlab_material_properties(aiMaterialProperty** assimp_properties, mxArray** matlab_properties, unsigned num_properties);
    
    unsigned to_assimp_meshes(const mxArray* matlab_meshes, aiMesh*** assimp_meshes);
    unsigned to_matlab_meshes(aiMesh** assimp_meshes, mxArray** matlab_meshes, unsigned num_meshes);
    
    unsigned to_assimp_faces(const mxArray* matlab_faces, aiFace** assimp_faces);
    unsigned to_matlab_faces(aiFace* assimp_faces, mxArray** matlab_faces, unsigned num_faces);
    
    unsigned to_assimp_nodes(const mxArray* matlab_node, unsigned index, aiNode** assimp_node, aiNode* assimp_parent);
    unsigned to_matlab_nodes(aiNode* assimp_node, mxArray** matlab_node, unsigned index);

    unsigned to_assimp_textures(const mxArray* matlab_textures, aiTexture*** assimp_textures);
    unsigned to_matlab_textures(aiTexture** assimp_textures, mxArray** matlab_textures, unsigned num_textures);

}

#endif  // MEXXIMP_SCENE_H_
