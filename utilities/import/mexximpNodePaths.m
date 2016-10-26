function nodeElements = mexximpNodePaths(scene)
%% Traverse the node hierarchy and return a struct array accounting for all nodes.
%
% The idea here is to get flat struct array that's easy to iterate.  Each
% element of the struct array will "point" to one of the nodes nested in
% the scene node hierarchy.
%
% nodeElements = mexximpNodePaths(scene) traverses the node hierarchy
% rooted at the given scene.rootNode.  Returns a struct array with one
% element per node encountered.  The struct array will have a filed for the
% name of each node, and the "path" through the scene struct to reach each
% node.
%
% See also mexximpVisitNodes
%
% nodeElements = mexximpNodePaths(scene)
%
% Copyright (c) 2016 mexximp Teame

parser = inputParser();
parser.addRequired('scene', @isstruct);
parser.parse(scene);
scene = parser.Results.scene;

%% Apply a visitFunction to locate each scene node.
nodeElements = mexximpVisitNodes(scene, @collectNodeElements);


%% Prepend the scene root node to each element path.
nElements = numel(nodeElements);
for ee = 1:nElements
    nodeElements(ee).path = cat(2, {'rootNode'}, nodeElements(ee).path);
end


%% Node visitFunction to merge child nodes into a flat array.
function nodeElements = collectNodeElements(scene, node, childResults, workingTransformation)

% every node element gets a name and a default path
thisNode = struct( ...
    'name', node.name, ...
    'path', {{}});

% for each child of this node, prepend the path through this node
%   that way, as we back up the hierarchy, we end up with the full path
for rr = 1:numel(childResults)
    children = childResults{rr};
    for cc = 1:numel(children)
        children(cc).path = cat(2, {'children', rr}, children(cc).path);
    end
    childResults{rr} = children;
end

% flatten and continue
nodeElements = [thisNode childResults{:}];
