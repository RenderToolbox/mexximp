
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
mitsubaElements = struct( ...
    'id', idMap.keys(), ...
    'element', idMap.values());

%% Get all the names of things subject to mappings.
mappingsFile = fullfile(thisFolder, 'DragonMappings.txt');
mappings = parseMappings(mappingsFile);
adjustments = mappingsToAdjustments(mappings);

%% Figure out how to land the adjustments in mexximp scene and collada.
for ii = 1:numel(adjustments)
    destination = adjustments(ii).destination;
    name = adjustments(ii).name;
    broadType = adjustments(ii).broadType;
    
    if strcmp('Collada', destination)
        disp([name ' (manual Collada to mPath)']);
        continue;
    end
    
    if ~isempty(strfind(destination, '-path'))
        disp([name ' (manual path to literal)']);
        continue;
    end
    
    % map to mexximp scene element
    q = {'name', mexximpStringMatcher(name)};
    element = mPathGet(elements, {q});
    elementIndex = element.path{end};
    
    % map to mitsuba element
    if strcmp('mesh', element.type)
        mistubaId = sprintf('meshId%d', elementIndex-1);
    else
        mistubaId = element.name;
    end
    q = {'id', mexximpStringMatcher(mistubaId)};
    mitsubaElement = mPathGet(mitsubaElements, {q});
    
    % how did we do?
    disp([
        name ' (' broadType ')', ...
        ' -> ', ...
        element.name ' (' element.type ') [' num2str(elementIndex) ']', ...
        ' -> ', ...
        mitsubaElement.id]);
end
