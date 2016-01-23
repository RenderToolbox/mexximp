function result = mexximpVisitNodes(scene, visitFunction, varargin)
%% Recursively visit all the nodes in a scene and apply function to each.
%
% result = mexximpVisitNodes(scene, visitFunction) recursively traverses
% child nodes, starting at scene.rootNode.  For each node, applies the
% given visitFunction.
%
% The idea here is to recursively traverse all the nodes in a scene.  And
% we want to write the fussy recursive code once, here in
% mexximpVisitNodes().  Then we want to reuse this traversal for various
% different computations, each implemented in a different visitFunction.
%
% visitFunction expect the following inputs:
%   funciton result = myVisitFun(scene, node, childResult, workingTransformation, varargin)
% These expected inputs may help the visitFunction do something
% interesting at each node:
%   scene -- the given scene
%   node -- the node currently being visited, reachable from scene.rootNode
%   childResults -- cell array containing the results of applying
%   visitFunction to each of the current node's children
%   workingTransformation -- the working coordinate transformation, which
%   is the product of transformations starting at the
%   scene.rootNode.transformation, up to and including the current
%   node.transformation
%   varargin -- any extra arguments passed to mexximpVisitNodes()
%
% Each time visitFunction is invoked, it is expected to compute something
% related to the current node, combine this result with any childResults,
% and return this value.
%
% result = mexximpVisitNodes(scene, visitFunction, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('scene', @isstruct);
parser.addRequired('visitFunction', @(f) isa(f, 'function_handle'));
parser.parse(scene, visitFunction);
scene = parser.Results.scene;
visitFunction = parser.Results.visitFunction;

% Kick off recursion at the root node.
result = traverseChildren(scene, scene.rootNode, scene.rootNode.transformation, visitFunction, varargin);

%% Recursively traverse a node and its children.
function result = traverseChildren(scene, node, workingTransformation, visitFunction, extraArgs)
% base case is when nChildren = 0
nChildren = numel(node.children);
childResults = cell(1, nChildren);
for ii = 1:nChildren
    child = node.children(ii);
    childTransformation = workingTransformation * child.transformation;
    childResults{ii} = traverseChildren(scene, child, childTransformation, visitFunction, extraArgs);
end
result = feval(visitFunction, scene, node, childResults, workingTransformation, extraArgs{:});
