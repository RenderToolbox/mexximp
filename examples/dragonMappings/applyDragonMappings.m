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
mexximpSceneScatter(scene);

% Flatten the node hierarchy, for sanity.
flatScene = scene;
flatScene.rootNode = mexximpFlattenNodes(flatScene);
mexximpSceneScatter(flatScene);

