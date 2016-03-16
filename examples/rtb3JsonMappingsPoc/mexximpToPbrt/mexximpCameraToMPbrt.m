function pbrtNode = mexximpCameraToMPbrt(scene, camera, varargin)
%% Convert a mexximp camera to mPbrt transformation and Camera elements.
%
% pbrtNode = mexximpCameraToMPbrt(scene, camera) converts the given
% mexximp camera to create an mPbrt scene Camera element and
% associated transformations.
%
% The given camera should be an element with type "cameras" as
% returned from mexximpSceneElements().
%
% By default, the camera will have type "perspective".  This may be
% overidden by passing a named parameter.  For example:
%   mexximpCameraToMPbrt( ... 'type', 'orthographic');
%
% Returns an MPbrtElement with identifier Camera and parameters
% filled in based on the mexximp camera.
%
% pbrtNode = mexximpCameraToMPbrt(scene, camera, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('scene', @isstruct);
parser.addRequired('camera', @isstruct);
parser.addParameter('type', 'perspective', @ischar);
parser.parse(scene, camera, varargin{:});
scene = parser.Results.scene;
camera = parser.Results.camera;
type = parser.Results.type;

%% Dig out the name.
cameraName = camera.name;
cameraIndex = camera.path{end};
pbrtName = sprintf('%d-%s', cameraIndex, cameraName);

%% Dig out and convert parameter values.
internal = mPathGet(scene, camera.path);

% field of view in degrees
fov = internal.horizontalFov * 180 / pi();

% default camera orientation
internalTarget = internal.position + internal.lookAtDirection;
internalLookAt = [internal.position internalTarget internal.upDirection];
if 9 ~= numel(internalLookAt)
    internalLookAt = [0 0 0 0 0 -1 0 1 0];
end

% camera position in the scene
nameQuery = {'name', mexximpStringMatcher(camera.name)};
transformPath = cat(2, {'rootNode', 'children', nameQuery, 'transformation'});
externalTransform = mPathGet(scene, transformPath);
if isempty(externalTransform)
    externalTransform = mexximpIdentity();
end

% invert the scene transformation to get point of view
externalTransform = inv(externalTransform);

%% Build the pbrt camera and associated transforms.
pbrtCamera = MPbrtElement('Camera', ...
    'name', pbrtName, ...
    'type', type);
pbrtCamera.setParameter('fov', 'float', fov);

pbrtInternalLookAt = MPbrtElement.transformation('LookAt', internalLookAt, ...
    'comment', 'camera default orientation');

pbrtSceneTransform = MPbrtElement.transformation('ConcatTransform', externalTransform, ...
    'comment', 'camera scene position');

pbrtNode = MPbrtContainer('', 'indent', '');
pbrtNode.append(pbrtInternalLookAt);
pbrtNode.append(pbrtSceneTransform);
pbrtNode.append(pbrtCamera);
