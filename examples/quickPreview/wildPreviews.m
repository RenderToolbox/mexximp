% Sandbox to try a bunch of previews of wild scenes.

clear;
clc;

hints.imageWidth = 320;
hints.imageHeight = 240;
commonArgs = { ...
    'cameraRelative', [1 0 0], ...
    'hints', hints, ...
    'renderers', {'Mitsuba'}};

%% Millenium Falcon
%   http://tf3dm.com/3d-model/millenium-falcon-82947.html

% Basically works fine
%   PBRT can't read the jpeg texture
scene = quickPreview('/home/ben/Downloads/4bw1cngyboxs_millenium_falcon/millenium-falcon.obj', ...
    commonArgs{:});
mexximpSceneScatter(scene);

% Geometry in here looks messed up:
%   "assimp info" and mexximpSceneBox() both show a huge bounding box.
%   mexximpSceneScatter() shows separate, distant clumps of vertices.
scene = quickPreview('/home/ben/Downloads/4bw1cngyboxs_millenium_falcon/millenium-falcon.3DS', ...
    commonArgs{:});
mexximpSceneScatter(scene);

%% Bat Cave
%   http://www.turbosquid.com/3d-models/free-bat-cave-3d-model/639123

scene = quickPreview('/home/ben/Downloads/Batcave_MR_OBJ/batcave.obj', ...
    commonArgs{:});
mexximpSceneScatter(scene);
