function [pbrtNode, nObjects] = mexximpNodeToMPbrt(scene, node, varargin)
%% Convert a mexximp node to an mPbrt ObjectInstance and transformation.
%
% pbrtNode = mexximpNodeToMPbrt(scene, node, varargin) converts the given
% mexximp node to an mPbrt Attribute container which includes the
% node's transformation and one ObjectInstance for each of the node's
% meshIndices.
%
% Returns an Attribute MPbrtContainer that includes the node's
% transformation and zero or more ObjectInstance elements.  Also returns
% the number of object instance elements.
%
% [pbrtNode, nObjects] = mexximpNodeToMPbrt(scene, node, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('scene', @isstruct);
parser.addRequired('node', @isstruct);
parser.parse(scene, node, varargin{:});
scene = parser.Results.scene;
node = parser.Results.node;

%% Dig out the name.
nodeName = node.name;
nodeIndex = node.path{end};
pbrtName = mexximpCleanName(nodeName, nodeIndex);

%% Add the node transformation to an Attribute.
data = mPathGet(scene, node.path);

pbrtNode = MPbrtContainer('Attribute', 'name', pbrtName);
pbrtTransformation = MPbrtElement.transformation('ConcatTransform', data.transformation');
pbrtNode.append(pbrtTransformation);

%% Follow 0-based indices to instantiated meshes.
nObjects = numel(data.meshIndices);

if 0 == nObjects
    % no objects to instantiate!
    return;
end

meshIndices = data.meshIndices + 1;
for oo = 1:nObjects
    meshIndex = meshIndices(oo);
    meshName = mexximpCleanName(scene.meshes(meshIndex).name, meshIndex);
    pbrtObjectInstance = MPbrtElement('ObjectInstance', 'value', meshName);
    pbrtNode.append(pbrtObjectInstance);
end
