function mitsubaScene = mexximpToMitsuba(mexximpScene, varargin)
%% Convert a mexximp scene struct to an mMitsuba scene object.
%
% mitsubaScene = mexximpToMitsuba(mexximpScene) converts the given
% mexximpScene struct to an mMitsuba scene object suitable for modifying,
% writing to file, rendering, etc.
%
% This function forwards any named parameters to various helper functions,
% including:
%   - mexximpCameraToMMitsuba()
%   - mexximpLightToMMitsuba()
%   - mexximpMaterialToMMitsuba()
%   - mexximpMeshToMMitsuba()
%   - mexximpNodeToMMitsuba()
% Please see these functions documentation about what parameters they
% accept.  (Sorry not to reproduce all of this this parameter documentation
% here. It would be handy for a while, but it would probably go out of
% date.)
%
% Returns an mMitsuba scene object based on the given mexximpScene struct.
%
% mitsubaScene = mexximpToMitsuba(mexximpScene, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('mexximpScene', @isstruct);
parser.parse(mexximpScene);
mexximpScene = parser.Results.mexximpScene;

%% Fresh scene to add to.
mitsubaScene = MMitsubaElement.scene();

%% Camera and POV transformations.
elements = mexximpSceneElements(mexximpScene);
elementTypes = {elements.type};
cameraInds = find(strcmp('cameras', elementTypes));
for cc = cameraInds
    mitsubaNode = mexximpCameraToMMitsuba(mexximpScene, elements(cc), varargin{:});
    mitsubaScene.append(mitsubaNode);
end

%% bsdf for each material.
%   Invoked by ref from shapes below.
materialInds = find(strcmp('materials', elementTypes));
for mm = materialInds
    mitsubaNode = mexximpMaterialToMMitsuba(mexximpScene, elements(mm), varargin{:});
    mitsubaScene.append(mitsubaNode);
end

%% Emitters and toWorld transformations.
lightInds = find(strcmp('lights', elementTypes));
for ll = lightInds
    mitsubaNode = mexximpLightToMMitsuba(mexximpScene, elements(ll), varargin{:});
    mitsubaScene.append(mitsubaNode);
end

%% Named ObjectBegin/End for each mesh.
%   Invoked by filename from shapes below.
meshInds = find(strcmp('meshes', elementTypes));
for mm = meshInds
    pbrtNode = mexximpMeshToMMitsuba(mexximpScene, elements(mm), varargin{:});
    mitsubaScene.append(pbrtNode);
end

%% Objects and world transformations with AttributeBegin/End.
% nodeInds = find(strcmp('nodes', elementTypes));
% for nn = nodeInds
%     objects = mexximpNodeToMPbrt(mexximpScene, elements(nn), varargin{:});
%
%     % skip nodes that don't invoke any mesh objects
%     for oo = 1:numel(objects)
%         mitsubaScene.world.append(objects{oo});
%     end
% end
