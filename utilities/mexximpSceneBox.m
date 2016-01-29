function [sceneBox, middlePoint] = mexximpSceneBox(scene, varargin)
%% Visit and nodes in a scene and calculate a minimim bounding box.
%
% sceneBox = mexximpSceneBox(scene) calculates a minimum bounding
% box that contains all of the vertices in the given mexximp scene.
%
% It does this by recursively traversing all nodes of the scene, locating
% any meshes used, applying each node's transformation to its mesh
% vertices, and calculating a coordinate-aligned bounding box that
% just-contains all of the transformed vertices.
%
% Returns a bounding box in the form of a min point and a max point:
%   [xmin xmax; ymin ymax; zmin zmax],
% or else [] if the scene contains no vertices or the bounding box could
% not be calculated for some other reason.
%
% Also returns a "middle" point which is the mean of the min and max points
% (it is *not* the true centroid/center-of-mass/barycenter).
%
% See also mexximpVisitNodes
%
% [sceneBox, middlePoint] = mexximpSceneBox(scene)
%
% Copyright (c) 2016 mexximp Teame

parser = rdtInputParser();
parser.addRequired('scene', @isstruct);
parser.addParameter('ignoreNodes', {}, @iscellstr);
parser.parse(scene, varargin{:});
scene = parser.Results.scene;
ignoreNodes = parser.Results.ignoreNodes;

%% Apply a visitFunction to each scene node.
sceneBox = mexximpVisitNodes(scene, @minBoundingBox, ignoreNodes);
middlePoint = mean(sceneBox, 2);

%% Node visitFunction to calculate min box around a node and its children.
function minBox = minBoundingBox(scene, node, childResults, workingTransformation, ignoreNodes)

% ignore this node?
if any(strcmp(node.name, ignoreNodes))
    meshBoxes = {};
else
    % transform and bound meshes at this node
    nMeshes = numel(node.meshIndices);
    meshBoxes = cell(1, nMeshes);
    for ii = 1:nMeshes
        meshIndex = node.meshIndices(ii);
        vertices = scene.meshes(meshIndex + 1).vertices;
        transformed = mexximpApplyTransform(vertices, workingTransformation);
        meshBoxes = cat(2, min(transformed, [], 2), max(transformed, [], 2));
    end
end

% combine with results from child nodes
allMyBoxes = cat(2, meshBoxes, childResults);
minBox = mergeBoxes(allMyBoxes{:});

%% Merge multiple bounding boxes into one grand box.
%   Each input should be [] or [xmin xmax; ymin ymax; zmin zmax]
function grandBox = mergeBoxes(varargin)
allBoxes = cat(2, varargin{:});
if isempty(allBoxes)
    grandBox = [];
    return;
end
mins = cat(2, allBoxes(:,1:2:end));
maxes = cat(2, allBoxes(:,2:2:end));
grandBox = cat(2, min(mins, [], 2), max(maxes, [], 2));
