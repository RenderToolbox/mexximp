function ax = mexximpScenePreview(scene, varargin)
%% Visit and nodes in a scene and make a quick Matlab rendering.
%
% ax = mexximpScenePreview(scene) makes a quick Matlab rendering from the
% meshes in the given scene.
%
% mexximpScenePreview( ...'axes', axes) plots into the given axes.
%
% Returns the figure used for plotting.
%
% See also mexximpScenePreview
%
% f = mexximpScenePreview(scene, varargin)
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
    f = figure();
    ax = axes('Parent', f);
end

%% Set up axes.
set(ax, ...
    'DataAspectRatio', [1 1 1], ...
    'Projection', 'perspective', ...
    'XGrid', 'on', ...
    'YGrid', 'on', ...
    'ZGrid', 'on', ...
    'ButtonDownFcn', @(obj, eventData)respondToClick(obj, eventData, []));
xlabel('X');
ylabel('Y');
zlabel('Z');


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

%% Print some usage info.
disp('mexximpScenePreview:')
disp('  left click: look around')
disp('  right click: move forward')
disp('  middle clock: display camera and mesh info')


%% Node visitFunction to plot mesh into given axes.
function ax = scatterMeshes(scene, node, ~, workingTransformation, ax, cameraNames, lightNames)

% camera node?
isCamera = strcmp(node.name, cameraNames);
if any(isCamera)
    cameraIndex = find(isCamera, 1, 'first') - 1;
    camera = scene.cameras(cameraIndex + 1);
    vertices = [camera.position(:) camera.lookAtDirection(:) camera.upDirection(:)];
    transformed = mexximpApplyTransform(vertices, workingTransformation);
    drawArrow(ax, transformed(:,1:2), camera, [0 0 0]);
    
    set(ax, ...
        'CameraPosition', transformed(:,1), ...
        'CameraTarget', transformed(:,2), ...
        'CameraUpVector', transformed(:,3) - transformed(:,1), ...
        'CameraViewAngle', rad2deg(camera.horizontalFov));
end


% light node?
isLight = strcmp(node.name, lightNames);
if any(isLight)
    lightIndex = find(isLight, 1, 'first') - 1;
    light = scene.lights(lightIndex + 1);
    vertices = [light.position(:) light.lookAtDirection(:)];
    transformed = mexximpApplyTransform(vertices, workingTransformation);
    lineColor = light.diffuseColor / max(light.diffuseColor);
    drawArrow(ax, transformed, light, lineColor);
end

% transform and scatter plot meshes at this node
nMeshes = numel(node.meshIndices);
for ii = 1:nMeshes
    % get the vertex and face data
    meshIndex = node.meshIndices(ii);
    vertices = scene.meshes(meshIndex + 1).vertices;
    transformed = mexximpApplyTransform(vertices, workingTransformation);
    faces = scene.meshes(meshIndex + 1).faces;
    
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
    
    query = {'key', mexximpStringMatcher('name')};
    [resultIndex, resultScore] = mPathQuery(material.properties, query);
    if 1 == resultScore
        materialName = material.properties(resultIndex).data;
    else
        materialName = 'unknown';
    end
    
    
    info.nodeName = node.name;
    info.meshName = scene.meshes(meshIndex + 1).name;
    info.meshIndex = meshIndex;
    info.materialName = materialName;
    info.materialIndex = materialIndex;
    drawMesh(ax, transformed, faces, info, meshColor);
end


%% Make a ball with a pointer to show orientation.
function drawArrow(ax, vertices, info, lineColor)

x = vertices(1,:);
y = vertices(2,:);
z = vertices(3,:);
line(x(1), y(1), z(1), ...
    'Parent', ax, ...
    'Marker', '.', ...
    'MarkerSize', 50, ...
    'LineStyle', 'none', ...
    'Color', lineColor, ...
    'ButtonDownFcn', @(obj, eventData)respondToClick(obj, eventData, info));

line(x, y, z, ...
    'Parent', ax, ...
    'Marker', 'none', ...
    'LineStyle', '-', ...
    'LineWidth', 10, ...
    'Color', lineColor, ...
    'ButtonDownFcn', @(obj, eventData)respondToClick(obj, eventData, info));


%% Scatter plot the given mesh vertices into the given axes.
function drawMesh(ax, vertices, faces, info, color)

f = 1 + cat(1, faces.indices);
v = vertices';
patch(ax, ...
    'Faces', f, ...
    'Vertices', v, ...
    'FaceColor', color, ...
    'FaceAlpha', 1, ...
    'EdgeColor', 'none', ...
    'ButtonDownFcn', @(obj, eventData)respondToClick(obj, eventData, info));


%% Point the camera or print mesh info.
function respondToClick(obj, eventData, objectInfo)
ax = gca();
clickPoint = eventData.IntersectionPoint;

switch eventData.Button
    case 1
        % point the camera at the click point
        currentPoint = get(ax, 'CurrentPoint');
        set(ax, 'CameraTarget', currentPoint(1,:));
        
    case 3
        % move the camera towards the click point
        currentPosition = get(ax, 'CameraPosition');
        newPosition = (currentPosition + clickPoint) / 2;
        set(ax, ...
            'CameraTarget', clickPoint, ...
            'CameraPosition', newPosition);
end

viewInfo.clickPoint = clickPoint;
viewInfo.cameraPosition = get(ax, 'CameraPosition');
viewInfo.cameraTarget = get(ax, 'CameraTarget');
viewInfo.cameraUp = get(ax, 'CameraUpVector');
disp('View:')
disp(viewInfo);

if ~isempty(objectInfo)
    disp('Object:');
    disp(objectInfo);
    disp(' ');
end