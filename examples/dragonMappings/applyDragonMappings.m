%% Try to apply a RenderToolbox3 Mappings file to an example scene.
%
% This is a proof of concept.  Can we process RenderToolbox3 mappings and
% apply them correctly to a scene and get a rendering -- using Mexximp
% instead of XML SceneDOM stuff?
%
% 2016 Mexximp Team.

%% Get the scene into Mexximp.
clear;
clc;

thisFolder = fileparts(which('applyDragonMappings.m'));
sceneFile = fullfile(thisFolder, 'Dragon.blend');
scene = mexximpImport(sceneFile);

% Flatten the node hierarchy, for sanity.
scene.rootNode = mexximpFlattenNodes(scene);

elements = mexximpSceneElements(scene);
disp({elements.name}');
disp(' ')

%% Write the scene out as Collada.
workingFolder = fullfile(tempdir(), 'mexximpDragonMappings');
if 7 ~= exist(workingFolder, 'dir')
    mkdir(workingFolder);
end
colladaFile = fullfile(workingFolder, 'dragon.dae');

mexximpExport(scene, 'collada', colladaFile);

%% Convert Collada to Mitsuba.
hints.filmType = 'hdrfilm';
hints.imageWidth = 640;
hints.imageHeight = 480;

mitsuba.importer = '/home/ben/render/mitsuba/mitsuba-spectral/mtsimport';

mitsubaFile = colladaToMitsuba(colladaFile, workingFolder, mitsuba, hints);

%% Get the Collada scene in memory.
[docNode, idMap] = ReadSceneDOM(mitsubaFile);
mitsubaIds = idMap.keys();
disp(mitsubaIds')
disp(' ')

%% Get all the names of things subject to mappings.
mappingsFile = fullfile(thisFolder, 'DragonMappings.txt');
mappings = parseMappings(mappingsFile);
adjustments = mappingsToAdjustments(mappings);
disp({adjustments.name}');
disp(' ')

% Here is a problem: Assimp exports Collada meshes by number, not by name!
% So the shapes in the new Mitsuba file will have boring numerical ids.  We
% do have a mapping from names to numbers, because we have
% scene.meshes(i).name
%
% So we need to do this:
%   adjustment name -> scene.meshes(i).name -> i -> mitsuba id
%
% How do we do the last bit?  Two hacks come to mind:
%	- Look in Assimp's Collada exporter code and scrape the schema for
%	constructing ids.  Construct similar ids ourselves, and happily match
%	ids.  This will work but is brittle wrt assimp updates (how ids are
%	constructed).
%   - Look in the Mitsuba scene and get the shapeIndex of each shape.
%   Assume that these indices are the same as in scene.meshes(i).  This is
%   brittle wrt assimp updates (order of exported meshes) and Mitsuba
%   updates (whether and how shapeIndex is used).
%
% Surprisingly, I like the first one better!
%
% For legacy mappings files and new mappings files, we want to use mesh
% names and not indexes.  So this issue will stay with us.
%
% This should will not be an issue for PBRT because we will control the
% whole process in Matlab.
%
