function ax = mexximpSceneScatter(scene, varargin)
%% Visit and nodes in a scene and make a quick scatter plot.
%
% ax = mexximpSceneScatter(scene) makes a quick scatter plot summarizing
% all the meshes in a scene.
%
% mexximpSceneScatter( ...'axes', a) plots into the given axes.
%
% Returns the axes used for plotting.
%
% See also mexximpVisitNodes
%
% ax = mexximpSceneScatter(scene, varargin)
%
% Copyright (c) 2016 mexximp Teame

parser = rdtInputParser();
parser.addRequired('scene', @isstruct);
parser.addParameter('axes', []);
parser.parse(scene, varargin{:});
scene = parser.Results.scene;
ax = parser.Results.axes;

% use given axes, or open new figure
if isempty(ax) || ~isa(ax, 'matlab.graphics.axis.Axes');
    fig = figure();
    ax = axes('Parent', fig);
end

%% Apply a visitFunction to each scene node.
mexximpVisitNodes(scene, @scatterMeshes, ax);

%% Node visitFunction to plot mesh into given axes.
function ax = scatterMeshes(scene, node, ~, workingTransformation, varargin)

% axes for plotting
ax = varargin{1};

% transform and scatter plot meshes at this node
nMeshes = numel(node.meshIndices);
for ii = 1:nMeshes
    meshIndex = node.meshIndices(ii);
    vertices = scene.meshes(meshIndex + 1).vertices;
    name = scene.meshes(meshIndex + 1).name;
    transformed = mexximpApplyTransform(vertices, workingTransformation);
    scatterMesh(transformed, name, ax);
end


%% Scatter plot the given mesh vertices into the given axes.
function scatterMesh(vertices, name, ax)

% hash the name into a color
map = colormap(ax);
nameNum = 1 + mod(sum(name), size(map, 1));
meshColor = map(nameNum, :);

% show vertices as separate colored points
x = vertices(1,:);
y = vertices(2,:);
z = vertices(3,:);
line(x, y, z, ...
    'Parent', ax, ...
    'Marker', '.', ...
    'LineStyle', 'none', ...
    'Color', meshColor);
