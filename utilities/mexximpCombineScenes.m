function [combined, outerElements, innerElements] = mexximpCombineScenes(outer, inner, varargin)
%% Combine two scenes by copying materials, meshes, and nodes.
%
% combined = mexximpCombineScenes(outer, inner) combines the two given
% scenes by copying all materials, meshes, and nodes from the given innder
% scene into the given outer scene.  Updates material and mesh indeices
% accordingly.
%
% mexximpCombineScenes( ... 'cleanupTransform', cleanupTransform) specify a
% transformation matrix to apply to the inner scene, before combining.
% This can help resolve mismatches in scene scaling, etc.  The default is
% to transform the inner scene so that its bounding box is centered at the
% origin, and its longest dimension is 1.
%
% mexximpCombineScenes( ... 'insertTransform', insertTransform) specify a
% transformation matrix to apply to the innner scene, after the
% cleanupTransform.  This is a good way to place the inner scene where it
% belongs in the outer scene.  The default is to place the inner scene at
% the center of the outer scene's bounding box.
%
% mexximpCombineScenes( ... 'insertPrefix', insertPrefix) specify a prefix to
% add to each node name from the inner scene.  The default is '', don't add
% any prefix.
%
% Returns a new, combined scene struct.  Also returns an array of scene
% elements that came from the outer scene, and an array of elements that
% came from the inner scene.
%
% [combined, outerElements, innerElements] = mexximpCombineScenes(outer, inner, varargin)
%
% Copyright (c) 2016 mexximp team

parser = inputParser();
parser.addRequired('outer', @isstruct);
parser.addRequired('inner', @isstruct);
parser.addParameter('cleanupTransform', [], @isnumeric);
parser.addParameter('insertTransform', [], @isnumeric);
parser.addParameter('insertPrefix', '', @ischar);
parser.parse(outer, inner, varargin{:});
outer = parser.Results.outer;
inner = parser.Results.inner;
cleanupTransform = parser.Results.cleanupTransform;
insertTransform = parser.Results.insertTransform;
insertPrefix = parser.Results.insertPrefix;

combined = outer;

%% Choose transforms to reconcile the scenes.
[innerBox, innerMidpoint] = mexximpSceneBox(inner);
if isempty(cleanupTransform)
    innerSize = max(abs(innerBox(:,1) - innerBox(:,2)));
    innerScale = 1 / innerSize;
    cleanupTransform = mexximpTranslate(-innerMidpoint) * mexximpScale(innerScale * [1 1 1]);
end

[outerBox, outerMidpoint] = mexximpSceneBox(outer);
if isempty(insertTransform)
    insertTransform = mexximpTranslate(outerMidpoint);
end

importTransform = cleanupTransform * insertTransform;

%% Copy materials.
nOuterMaterials = numel(outer.materials);
combined.materials = cat(2, outer.materials, inner.materials);

%% Copy Meshes with material offset.
nOuterMeshes = numel(outer.meshes);
nInnerMeshes = numel(inner.meshes);

for mm = 1:nInnerMeshes
    if ~isempty(inner.meshes(mm).materialIndex)
        inner.meshes(mm).materialIndex = ...
            inner.meshes(mm).materialIndex + nOuterMaterials;
    end
end

combined.meshes = cat(2, outer.meshes, inner.meshes);

%% Copy Nodes with mesh offset and transformation.
nOuterNodes = numel(outer.rootNode.children);
nInnerNodes = numel(inner.rootNode.children);

for mm = 1:nInnerNodes
    if ~isempty(inner.rootNode.children(mm).meshIndices)
        inner.rootNode.children(mm).name = ...
            [insertPrefix inner.rootNode.children(mm).name];
        inner.rootNode.children(mm).meshIndices = ...
            inner.rootNode.children(mm).meshIndices + nOuterMeshes;
        inner.rootNode.children(mm).transformation = ...
            importTransform * inner.rootNode.children(mm).transformation;
    end
end

combined.rootNode.children = cat(2, outer.rootNode.children, inner.rootNode.children);

%% Report where elements in the combined scene came from.
combinedElements = mexximpSceneElements(combined);
nElements = numel(combinedElements);
isOuterElement = true(1, nElements);
for ee = 1:nElements
    % all elements are outer elements, except:
    %   appended materials
    %   appended meshes
    %   appended nodes
    element = combinedElements(ee);
    elementIndex = element.path{end};
    switch element.type
        case 'materials'
            isOuterElement(ee) = elementIndex <= nOuterMaterials;
        case 'meshes'
            isOuterElement(ee) = elementIndex <= nOuterMeshes;
        case 'nodes'
            isOuterElement(ee) = isnumeric(elementIndex) && elementIndex <= nOuterNodes;
    end
end
outerElements = combinedElements(isOuterElement);
innerElements = combinedElements(~isOuterElement);

