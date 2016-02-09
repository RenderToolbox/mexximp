function rootNode = mexximpFlattenNodes(scene)
%% Flatten the node hierarchy so all nodes are children of the root node.
%
% The idea here is to "flatten out" an arbitrarily complex tree of nodes
% into a simple tree of exactly two levels: the root node, and a single
% array of children of the root node.  This should make it easier to
% explore and compare scenes coming from different sources/formats, etc.
% The new and original root nodes should be eqivalent and "look the same"
% when rendered.
%
% rootNode = mexximpFlattenNodes(scene, varargin) traverses all nodes of
% the given scene, starting at scene.rootNode.  It builds a new root node
% whose direct children are all of the nodes from the original scene.  The
% new root node will have the identity transformation.  Each child of the
% new root node will have the "inherited", combined transformation from
% each of its parent nodes in the origingal scene.
%
% The name of each node will be unchanged.
%
% Returns new rootNode struct, which is equivalent to the given
% scene.rootNode, but with all its descendents "flattened out".
%
% See also mexximpVisitNodes
%
% rootNode = mexximpFlattenNodes(scene)
%
% Copyright (c) 2016 mexximp Teame

parser = rdtInputParser();
parser.addRequired('scene', @isstruct);
parser.parse(scene);
scene = parser.Results.scene;

%% Apply a visitFunction to each scene node.
children = mexximpVisitNodes(scene, @flattenChildren);

%% Build a new root node equivalent to the original.
rootNode = scene.rootNode;

% root transform was already applied to each node
rootNode.transformation = mexximpIdentity();

% first "child" is really the root itself
rootNode.children = children(2:end);

%% Node visitFunction to merge child nodes into a flat array.
function children = flattenChildren(scene, node, childResults, workingTransformation)

% apply "inherited", combined transformation directly to this node 
node.transformation = workingTransformation;

% suck up child results and combine
children = [node, childResults{:}];
