function ax = mexximpSceneScatter(scene, varargin)
%% Visit and nodes in a scene and make a quick scatter plot.
%
% ax = mexximpSceneScatter(scene) makes a quick scatter plot summarizing
% all the meshes that are instantiated in a scene.
%
% Each instantiated mesh will get a text label which includes the name of
% the node that instantiated the mesh, the name of the mesh, and the index
% of the mesh in scene.meshes.  Clicking on one of these labels will print
% the same information to the command window.  This may be useful when
% identifying nodes to focus on or ignore.
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

parser = inputParser();
parser.addRequired('scene', @isstruct);
parser.addParameter('axes', []);
parser.addParameter('ignoreNodes', {}, @iscellstr);
parser.parse(scene, varargin{:});
scene = parser.Results.scene;
ax = parser.Results.axes;
ignoreNodes = parser.Results.ignoreNodes;

% use given axes, or open new figure
if isempty(ax) || ~isa(ax, 'matlab.graphics.axis.Axes');
    fig = figure();
    ax = axes('Parent', fig);
end

%% Apply a visitFunction to each scene node.
if isempty(scene.cameras)
    cameraNames = {};
else
    cameraNames = {scene.cameras.name};
end

if isempty(scene.lights)
    lightNames = {};
else
    lightNames = {scene.lights.name};
end

mexximpVisitNodes(scene, @scatterMeshes, ax, ignoreNodes, cameraNames, lightNames);

%% Node visitFunction to plot mesh into given axes.
function ax = scatterMeshes(scene, node, ~, workingTransformation, ax, ignoreNodes, cameraNames, lightNames)

% ignore this node?
if any(strcmp(node.name, ignoreNodes))
    return;
end

% camera node?
isCamera = strcmp(node.name, cameraNames);
if any(isCamera)
    cameraIndex = find(isCamera, 1, 'first') - 1;
    camera = scene.cameras(cameraIndex + 1);
    vertices = [camera.position(:) camera.lookAtDirection(:)];
    transformed = mexximpApplyTransform(vertices, workingTransformation);
    scatterMesh(ax, transformed, node.name, camera.name, cameraIndex, true);
end


% light node?
isLight = strcmp(node.name, lightNames);
if any(isLight)
    lightIndex = find(isLight, 1, 'first') - 1;
    light = scene.lights(lightIndex + 1);
    vertices = [light.position(:) light.lookAtDirection(:)];
    transformed = mexximpApplyTransform(vertices, workingTransformation);
    scatterMesh(ax, transformed, node.name, light.name, lightIndex, true);
end

% transform and scatter plot meshes at this node
nMeshes = numel(node.meshIndices);
for ii = 1:nMeshes
    meshIndex = node.meshIndices(ii);
    vertices = scene.meshes(meshIndex + 1).vertices;
    transformed = mexximpApplyTransform(vertices, workingTransformation);
    meshName = scene.meshes(meshIndex + 1).name;
    scatterMesh(ax, transformed, node.name, meshName, meshIndex, false);
end


%% Scatter plot the given mesh vertices into the given axes.
function scatterMesh(ax, vertices, nodeName, meshName, meshIndex, emphasis)

% hash the name into a color
lineName = [nodeName ' : ' meshName ' # ' num2str(meshIndex)];
map = colormap(ax);
nameNum = 1 + mod(sum(lineName), size(map, 1));
meshColor = map(nameNum, :);

% show vertices as separate colored points
x = vertices(1,:);
y = vertices(2,:);
z = vertices(3,:);
l = line(x, y, z, ...
    'Parent', ax, ...
    'Marker', '.', ...
    'LineStyle', 'none', ...
    'Color', meshColor);
set(l, 'ButtonDownFcn', {@meshCallback, lineName, [x(1), y(1), z(1)], l});

t = text(x(1), y(1), z(1), lineName, ...
    'Parent', ax, ...
    'Color', meshColor, ...
    'ButtonDownFcn', {@meshCallback, lineName, [x(1), y(1), z(1)], l}, ...
    'Interpreter', 'none');

if emphasis
    set(l, 'Marker', '*', ...
        'LineStyle', '-');
    set(t, 'Color', 'k', ...
        'BackgroundColor', meshColor);
end

% let the user click on the mesh label
function meshCallback(obj, eventData, lineName, position, l)
disp([lineName ' @ [' num2str(position) ']']);

lineStyle = get(l, 'LineStyle');
if strcmp('none', lineStyle)
    newLineStyle = '-';
else
    newLineStyle = 'none';
end
set(l, 'LineStyle', newLineStyle);

