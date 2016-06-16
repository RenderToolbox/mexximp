function [scene, lanterns, lanternNodes] = mexximpAddLanterns(scene, varargin)
%% Add lights surrounding the camera to guarante illumination.
%
% The idea here is to make sure that the camera (the first camera if there
% is more than one) will get some light.  This should help when working
% with "wild" scenes downloaded from the Web. Often these scens don't
% specify any lights, and it's not obvious a priori where lights should be
% added.  So, as a first guess, arrange several lights around the camera
% itself.
%
% scene = mexximpAddLanterns(scene) adds 8 point lights to the scene,
% arranged like a unit cube centered at the camera.
%
% mexximpAddLanterns( ... 'lanternDistance', lanternDistance) arranges
% lanterns about the camera like a cube with side length lanternDistance.
% the default is 1, the unit cube.
%
% Returns the given scene, with modifications.  Also returns a struct array
% of lights and lightNodes that were added to the scene.
%
% [scene, lanterns, lanternNodes] = mexximpAddLanterns(scene, varargin)
%
% Copyright (c) 2016 mexximp Teame

parser = inputParser();
parser.addRequired('scene', @isstruct);
parser.addParameter('lanternDistance', 1, @isscalar);
parser.parse(scene, varargin{:});
scene = parser.Results.scene;
lanternDistance = parser.Results.lanternDistance;

%% Locate the first camera and the node that instantiates it.
if isempty(scene.cameras)
    error('mexximpAddLanterns:noCamera', 'Scene must have a camera.');
end
camera = scene.cameras(1);

% find the node with the same name as the camera
%   TODO: search the whole node tree, not just the first tier
nodeNames = {scene.rootNode.children.name};
cameraNodeIndex = find(strcmp(camera.name, nodeNames), 1, 'first');
if isempty(cameraNodeIndex)
    error('mexximpAddLanterns:noCameraNode', ...
        'Scene must have a node with the same name as the camera, <%s>.', ...
        camera.name);
end
cameraNode = scene.rootNode.children(cameraNodeIndex);

%% Arrange point lights like a cube around the camera.
positions = lanternDistance * sqrt(3) * [ ...
    -1 -1 -1; ...
    -1 -1 +1; ...
    -1 +1 -1; ...
    -1 +1 +1; ...
    +1 -1 -1; ...
    +1 +1 -1; ...
    +1 -1 +1; ...    
    +1 +1 +1];
nLanterns = size(positions, 1);
lanternCell = cell(1, nLanterns);
lanternNodeCell = cell(1, nLanterns);

for ii = 1:nLanterns
    position = positions(ii,:);
    
    lantern = mexximpConstants('light');
    lantern.name = sprintf('lantern-%d', ii);
    lantern.position = [0 0 0]';
    lantern.type = 'point';
    lantern.lookAtDirection = [0 0 0]';
    lantern.innerConeAngle = 0;
    lantern.outerConeAngle = 0;
    lantern.constantAttenuation = 1;
    lantern.linearAttenuation = 0;
    lantern.quadraticAttenuation = 1;
    lantern.ambientColor = [1 1 1]';
    lantern.diffuseColor = [1 1 1]';
    lantern.specularColor = [1 1 1]';
    
    lanternNode = mexximpConstants('node');
    lanternNode.name = lantern.name;
    lanternNode.transformation = mexximpTranslate(position) * cameraNode.transformation;
    
    lanternCell{ii} = lantern;
    lanternNodeCell{ii} = lanternNode;
end

%% Add the new lights and nodes to the scene.
lanterns = [lanternCell{:}];
lanternNodes = [lanternNodeCell{:}];

if isempty(scene.lights)
    scene.lights = lanterns;
else
    scene.lights = [scene.lights lanterns];
end

if isempty(scene.rootNode.children)
    scene.rootNode.children = lanternNodes;
else
    scene.rootNode.children = [scene.rootNode.children lanternNodes];
end
