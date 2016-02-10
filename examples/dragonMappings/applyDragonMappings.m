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
sceneNames = unique(sceneNames);
mappingsNames = unique(mappingsNames);
nSceneNames = numel(sceneNames);
nMappingsNames = numel(mappingsNames);
distances = zeros(nSceneNames, nMappingsNames);
for ss = 1:nSceneNames
    for mm = 1:nMappingsNames
        distances(ss,mm) = EditDistance(sceneNames{ss}, mappingsNames{mm});
    end
end
[matchMins, matchInds] = min(distances, [], 1);

% plot(1:nSceneNames, distances, matchInds, matchMins, '*k', 'MarkerSize', 10);
% set(gca(), ...
%     'XTick', 1:nSceneNames, ...
%     'XTickLabel', sceneNames, ...
%     'XTickLabelRotation', 45, ...
%     'XGrid', 'on');
% legend(mappingsNames);

% what did we get?
sceneNameMatches = sceneNames(matchInds);
disp([sceneNameMatches' mappingsNames'])

%% How would we pack up the mappings for mexximp?

% find the ELEMENT we want to adjust:
%   block type, class, and subclass -> scene.field
%   id -> query based on name

% directive for what to do at the ELEMENT
%   block type, class, and subclass -> directive for ELEMENT to set up
%   properties -> specifics to set within the ELEMENT
