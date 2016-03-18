function elements = mexximpSceneElements(scene)
%% Explore a scene and make a flattened-out representation of its elements.
%
% The idea here is to explore the entire scene and discover all of the
% elements that make it up.  "Elements" are things like cameras, lights,
% meshes, nodes, materials, etc.  This gives us an array of elements that
% we can easily iterate.  This takes care of a bunch of ugly iterative and
% recusrive code that the caller doesn't feel like writing.
%
% elements = mexximpSceneElements(scene) explores the given scene and finds
% all the elements that make it up.  For each element it chooses a name and
% records the "path" through the original scene to that element.
%
% Returns a struct array representing elements of the scene.  The struct
% elements will indicate the name, type, and path of each scene element.
%
% elements = mexximpSceneElements(scene)
%
% Copyright (c) 2016 mexximp Teame

parser = inputParser();
parser.addRequired('scene', @isstruct);
parser.parse(scene);
scene = parser.Results.scene;

%% Cameras.
cameras = sceneElementsByName(scene.cameras, 'cameras', {'cameras'});

%% Lights.
lights = sceneElementsByName(scene.lights, 'lights', {'lights'});

%% Materials.
% tricky format, but materials also have names:
%   scene.materials(mm).properties(pp).key = 'name';
%   scene.materials(mm).properties(pp).data = 'myName';
nMaterials = numel(scene.materials);
materials = cell(1, nMaterials);
isNameFunction = @(s) strcmp(s, 'name');
for mm = 1:nMaterials
    q = {'key', isNameFunction};
    p = {'materials', mm, 'properties', q, 'data'};
    
    name = mPathGet(scene, p);
    materials{mm} = sceneElement(name, 'materials', {'materials', mm});
end

%% Meshes.
meshes = sceneElementsByName(scene.meshes, 'meshes', {'meshes'});

%% Embedded Textures.
embeddedTextures = sceneElementsByName(scene.embeddedTextures, 'embeddedTextures', {'embeddedTextures'});

%% Nodes
scene.rootNode = mexximpFlattenNodes(scene);
rootNode = sceneElement(scene.rootNode.name, 'nodes', {'rootNode'});
nodes = sceneElementsByName(scene.rootNode.children, 'nodes', {'rootNode', 'children'});

%% Concatenate them all.
elements = [cameras{:}, lights{:}, materials{:}, meshes{:}, embeddedTextures{:}, rootNode, nodes{:}];

%% Pack up scene elements from a struct array with a "name" field.
function elements = sceneElementsByName(s, type, pathBase)
nElements = numel(s);
elements = cell(1, nElements);
for ii = 1:nElements
    name = s(ii).name;
    path = cat(2, pathBase, {ii});
    elements{ii} = sceneElement(name, type, path);
end

%% Pack up a scene element struct representation.
function element = sceneElement(name, type, path)
element = struct( ...
    'name', name, ...
    'type', type, ...
    'path', {path});
