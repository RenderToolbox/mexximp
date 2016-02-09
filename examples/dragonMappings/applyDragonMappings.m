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
%mexximpSceneScatter(scene);

% Flatten the node hierarchy, for sanity.
flatScene = scene;
flatScene.rootNode = mexximpFlattenNodes(flatScene);
%mexximpSceneScatter(flatScene);

%% Dig out names of materials.
%   want util to put materials in standard, "flat" form?
nMaterials = numel(flatScene.materials);
materialNames = cell(1, nMaterials);
isName = @(s) strcmp(s, 'name');
for ii = 1:nMaterials
    q = {'key', isName};
    p = {'materials', ii, 'properties', q, 'data'};
    materialNames{ii} = mPathGet(flatScene, p);
end

%% Get all the names of things in the scene.
sceneNames = { ...
    flatScene.cameras.name, ...
    materialNames{:}, ...
    flatScene.meshes.name, ...
    flatScene.rootNode.name, ...
    flatScene.rootNode.children.name};

%% Get all the names of things subject to mappings.
mappingsFile = fullfile(thisFolder, 'DragonMappings.txt');
mappings = ParseMappings(mappingsFile);
objects = MappingsToObjects(mappings);
mappingsNames = {objects.id};

%% For each name in the mappings, can we pick the correct scene name?
%   use substring of?
%   use edit distance?
%   use mappings class/subclass as a hint?
