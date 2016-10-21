function ax = mexximpScenePreview(scene, varargin)
%% Visit and nodes in a scene and make a quick Matlab rendering.
%
% ax = mexximpScenePreview(scene) makes a quick Matlab rendering from the
% meshes in the given scene.
%
% mexximpScenePreview( ...'axes', a) plots into the given axes.
%
% Returns the axes used for plotting.
%
% See also mexximpScenePreview
%
% ax = mexximpScenePreview(scene, varargin)
%
% Copyright (c) 2016 mexximp Teame

parser = inputParser();
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

mexximpVisitNodes(scene, @scatterMeshes, ax, cameraNames, lightNames);
xlabel('X');
ylabel('Y');
zlabel('Z');
set(ax, 'DataAspectRatio', [1 1 1], 'CameraViewAngle', 178);

%% Node visitFunction to plot mesh into given axes.
function ax = scatterMeshes(scene, node, ~, workingTransformation, ax, cameraNames, lightNames)

% camera node?
isCamera = strcmp(node.name, cameraNames);
if any(isCamera)
    cameraIndex = find(isCamera, 1, 'first') - 1;
    camera = scene.cameras(cameraIndex + 1);
    vertices = [camera.position(:) camera.lookAtDirection(:)];
    transformed = mexximpApplyTransform(vertices, workingTransformation);
    drawArrow(ax, transformed, camera.name, [0 0 0]);
    
    set(ax, ...
        'CameraPosition', transformed(:,1), ...
        'CameraTarget', transformed(:,2), ...
        'CameraUpVector', camera.upDirection);
end


% light node?
isLight = strcmp(node.name, lightNames);
if any(isLight)
    lightIndex = find(isLight, 1, 'first') - 1;
    light = scene.lights(lightIndex + 1);
    vertices = [light.position(:) light.lookAtDirection(:)];
    transformed = mexximpApplyTransform(vertices, workingTransformation);
    lineColor = light.diffuseColor / max(light.diffuseColor);
    drawArrow(ax, transformed, light.name, lineColor);
end

% transform and scatter plot meshes at this node
nMeshes = numel(node.meshIndices);
for ii = 1:nMeshes
    % get the vertex and face data
    meshIndex = node.meshIndices(ii);
    vertices = scene.meshes(meshIndex + 1).vertices;
    transformed = mexximpApplyTransform(vertices, workingTransformation);
    faces = scene.meshes(meshIndex + 1).faces;
    
    % build a name for this mesh
    meshName = scene.meshes(meshIndex + 1).name;
    name = [node.name ' : ' meshName ' # ' num2str(meshIndex)];
    
    % dig out an rgb color for this mesh
    materialIndex = scene.meshes(meshIndex + 1).materialIndex;
    material = scene.materials(materialIndex + 1);
    query = {'key', mexximpStringMatcher('diffuse')};
    [resultIndex, resultScore] = mPathQuery(material.properties, query);
    if 1 == resultScore
        meshColor = material.properties(resultIndex).data;
    else
        meshColor = [0.5 0.5 0.5];
    end
    
    drawMesh(ax, transformed, faces, name, meshColor);
end


%% Make a ball with a pointer to show orientation.
function drawArrow(ax, vertices, name, lineColor)

x = vertices(1,:);
y = vertices(2,:);
z = vertices(3,:);
line(x, y, z, ...
    'Parent', ax, ...
    'Marker', '.', ...
    'MarkerSize', 30, ...
    'LineStyle', '-', ...
    'Color', lineColor);


%% Scatter plot the given mesh vertices into the given axes.
function drawMesh(ax, vertices, faces, name, color)

f = 1 + cat(1, faces.indices);
v = vertices';
patch(ax, ...
    'Faces', f, ...
    'Vertices', v, ...
    'FaceColor', color, ...
    'FaceAlpha', 0.1, ...
    'EdgeColor', 'none');
