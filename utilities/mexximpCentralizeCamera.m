function [scene, camera, cameraNode] = mexximpCentralizeCamera(scene, varargin)
%% Make the camera look towards, or out from, the middle of the scene.
%
% The idea here is to help you build a sensible lookAt transformation for
% the camera in the scene (the first camera, if there is more than one).
%
% Sometimes it's hard to know a priori where is a good place to lookAt.
% For example, this is often the case when working with "wild" scenes
% downloaded from the Web.  This funciton aims to help by scanning the
% scene geometry and building the lookAt relative to to middle point of the
% scene and a bounding box around all the scene's vertices.
%
% scene = mexximpCentralizeCamera(scene) orients the camera so as to look
% at the center of the scene, from enough distance so that all of the
% scene's vertices fit in the camera's field of view.
%
% mexximpCentralizeCamera( ... 'viewAxis', viewAxis) positions the camera
% along the given [x y z] viewAxis, which is relative to the middle point
% of the scene.  viewAxis need not be normalized, and scaling the viewAxis
% will cause the camera to move towards or away from the middle point.  The
% default is [0 0 -1], look up the z-axis.
%
% mexximpCentralizeCamera( ... 'viewOffset', viewOffset) adds the given
% [x y z] viewOffset to the scene's middle point and the viewAxis,
% so that the camera will look at a point offset from the middle.  The
% default is [0 0 0], look at the middle point.
%
% mexximpCentralizeCamera( ... 'viewUp', viewUp) uses the give [x y z]
% viewUp to orient the camera about the viewAxis.  The default is [0 1 0],
% let the positive-y direction be "up".
%
% mexximpCentralizeCamera( ... 'viewExterior', viewExterior) choose whether
% the camera should view the exterior of the scene from the outside (true),
% or view the interior of a scene from the inside (false).  The default is
% true, look at the viewExterior from the outside.
%
% Setting viewExterior to true should be useful when viewing single objects
% or "outdoor" scenes.  This will cause the camera to look *at* the middle
% point of the  scene from a point along the viewAxis.  The viewing
% distance will be calculated such that the camera's field of view
% encompasses all of the vertices in the scene.  The distance calculation
% assumes that the viewAxis is normalized.  Scaling the viewAxis will cause
% the camera to move closer to or farther from the middle point. 
%
% Setting viewExterior to false should be useful when viewing "indoor"
% scenes. This will cause the viewing direction to be reversed.  The camera
% will sit at the middle point and look *away from* there along the
% viewAxis. In this case scaling the viewAxis will have no effect.
%
% mexximpCentralizeCamera( ... 'ignoreNodes', ignoreNodes) optionally
% specify a cell array of node names, causing the named nodes to be ignored
% when calculating the scene middle point and bounding box.  This is useful
% when the scene contains outlying "cruft" geometry that you don't want to
% look at.
%
% Returns the given scene, with modifications.  Also returns the modified
% camera and cameraNode, for convenience.
%
% See also mexximpSceneBox mexximpSceneScatter
%
% [scene, camera, cameraNode] = mexximpCentralizeCamera(scene, varargin)
%
% Copyright (c) 2016 mexximp Teame

parser = rdtInputParser();
parser.addRequired('scene', @isstruct);
parser.addParameter('viewAxis', [0 0 -1], @(v) isnumeric(v) && 3 == numel(v));
parser.addParameter('viewOffset', [0 0 0], @(v) isnumeric(v) && 3 == numel(v));
parser.addParameter('viewUp', [0 1 0], @(v) isnumeric(v) && 3 == numel(v));
parser.addParameter('viewExterior', true, @islogical);
parser.addParameter('ignoreNodes', {}, @iscellstr);
parser.parse(scene, varargin{:});
scene = parser.Results.scene;
viewAxis = parser.Results.viewAxis;
viewOffset = parser.Results.viewOffset;
viewUp = parser.Results.viewUp;
viewExterior = parser.Results.viewExterior;
ignoreNodes = parser.Results.ignoreNodes;

%% Locate the first camera and the node that instantiates it.
if isempty(scene.cameras)
    error('mexximpCentralizeCamera:noCamera', 'Scene must have a camera.');
end
camera = scene.cameras(1);

% find the node with the same name as the camera
%   TODO: search the whole node tree, not just the first tier
nodeNames = {scene.rootNode.children.name};
cameraNodeIndex = find(strcmp(camera.name, nodeNames), 1, 'first');
if isempty(cameraNodeIndex)
    error('mexximpCentralizeCamera:noCameraNode', ...
        'Scene must have a node with the same name as the camera, <%s>.', ...
        camera.name);
end

%% Build the lookAt relative to the middle and the box.
[sceneBox, sceneMiddlePoint] = mexximpSceneBox(scene, ...
    'ignoreNodes', ignoreNodes);

viewMiddlePoint = sceneMiddlePoint' + viewOffset;

if viewExterior
    % construct a right triangle with the camera and the boinding box,
    % solve the "adjacent" side as the viewing distance.
    
    % bounding box diagonal is an upper bound on the span of all vertices
    halfWidth = norm(sceneBox(:,1) - sceneBox(:,2)) / 2;
    
    % Want the camera's half-viewing-angle, to match the the halfWidth
    % above.  The Assimp docs say that camera.horizontalFov *is* the
    % half-angle.  But it is behaving like the full viewing angle.  So
    % divide by 2.  Is this an Assimp bug?  Is it specific to a particular
    % importer or exporter file format?  Aaah!
    halfAngle = camera.horizontalFov / 2;
    viewingDistance = halfWidth / tan(halfAngle);
    
    % move out the viewing axis and look at the middle point
    cameraPoint = viewMiddlePoint + viewAxis .* viewingDistance;
    lookAt = mexximpLookAt(cameraPoint, viewMiddlePoint, viewUp);
    
else
    % sit at the middle point and look along the view axis
    viewTarget = viewMiddlePoint + viewAxis;
    lookAt = mexximpLookAt(viewMiddlePoint, viewTarget, viewUp);
end

%% Apply the view axis to the camera's node.
scene.rootNode.children(cameraNodeIndex).transformation = lookAt;
cameraNode = scene.rootNode.children(cameraNodeIndex);
