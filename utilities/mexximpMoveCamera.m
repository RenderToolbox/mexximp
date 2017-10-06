function scene = mexximpMoveCamera(cameraTransform,scene)
%% Find the camera in a scene and move it according to the transform.
%
% Example:
% cameraTransform = mexximpLookAt(from, to, up);
% scene = mexximpMoveCamera(cameraTransform,scene);
%
% Trisha Lian 

cameraNodeSelector = strcmp(scene.cameras.name, {scene.rootNode.children.name});
if(isempty(cameraNodeSelector))
    error('Camera could not be found in scene.');
end
scene.rootNode.children(cameraNodeSelector).transformation = cameraTransform;

