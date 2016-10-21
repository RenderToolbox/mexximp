function f = mexximpCameraControls(ax)
%% Raise a figure with controls for the given axes camera.
%
% mexximpCameraControls(ax) creates a figure with controls for moving the
% camera of the current axes.
%
% Returns a handle to the new figure.
%
% Copyright (c) 2016 mexximp Teame

parser = inputParser();
parser.addRequired('ax', @(ax)isa(ax, 'matlab.graphics.axis.Axes'));
parser.parse(ax);
ax = parser.Results.ax;

f = figure();

originalPosition = get(ax, 'CameraPosition');
originalTarget = get(ax, 'CameraTarget');
originalUpVector = get(ax, 'CameraUpVector');
data = [originalPosition; originalTarget; originalUpVector];

table = uitable( ...
    'Parent', f, ...
    'FontSize', 16, ...
    'Units', 'normalized', ...
    'Position', [0.1 0.5 0.8 0.4], ...
    'CellEditCallback', @(obj, eventData)respondToEdit(obj, ax), ...
    'ColumnEditable', true, ...
    'Data', data, ...
    'RowName', {'from', 'to', 'up'}, ...
    'ColumnName', {'X', 'Y', 'Z'}, ...
    'ColumnWidth', {100, 100, 100});

uicontrol( ...
    'Parent', f, ...
    'Style', 'pushbutton', ...
    'FontSize', 16, ...
    'Units', 'normalized', ...
    'Position', [0.1 0.1 0.8 0.3], ...
    'String', 'Reset', ...
    'Callback', @(obj, data)updateCamera(ax, table, originalPosition, originalTarget, originalUpVector));


function updateCamera(ax, obj, cameraPosition, cameraTarget, cameraUpVector)
set(ax, 'CameraPosition', cameraPosition);
set(ax, 'CameraTarget', cameraTarget);
set(ax, 'CameraUpVector', cameraUpVector);

data = [cameraPosition; cameraTarget; cameraUpVector];
set(obj, 'Data', data);


function respondToEdit(obj, ax)
data = get(obj, 'Data');
cameraPosition = data(1,:);
cameraTarget = data(2,:);
cameraUpVector = data(3,:);
updateCamera(ax, obj, cameraPosition, cameraTarget, cameraUpVector);

