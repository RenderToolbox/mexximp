% Sandbox to try a bunch of previews of wild scenes.

clear;
clc;

hints.imageWidth = 320;
hints.imageHeight = 240;
commonArgs = { ...
    'hints', hints, ...
    'renderers', {'Mitsuba'}};

%% Millenium Falcon OBJ
%   http://tf3dm.com/3d-model/millenium-falcon-82947.html
%   Basically works fine
%   PBRT can't read the jpeg texture

scene = quickPreview('/home/ben/Downloads/4bw1cngyboxs_millenium_falcon/millenium-falcon.obj', ...
    commonArgs{:});
mexximpSceneScatter(scene);

%% Millenium Falcon 3DS
%   http://tf3dm.com/3d-model/millenium-falcon-82947.html
%   Geometry in here looks messed up:
%   "assimp info" and mexximpSceneBox() both show a huge bounding box.
%   mexximpSceneScatter() shows separate, distant clumps of vertices.

scene = quickPreview('/home/ben/Downloads/4bw1cngyboxs_millenium_falcon/millenium-falcon.3DS', ...
    commonArgs{:});
mexximpSceneScatter(scene);

%% Bat Cave OBJ
%   http://www.turbosquid.com/3d-models/free-bat-cave-3d-model/639123
%   PBRT conversion is very slow -- 1400 meshes!
%   Basically works, but camera and lighting are not glamorous

% nodes named like "g Shape04" seem to be cruft.
nIgnore = 100;
ignoreNodes = cell(1, nIgnore);
for ii = 1:100
    ignoreNodes{ii} = sprintf('g Shape%02d', ii-1);
end

% zoom in to get to the inside
lookToCenter = 0.10 * [0 1 1];

scene = quickPreview('/home/ben/Downloads/Batcave_MR_OBJ/batcave.obj', ...
    commonArgs{:}, ...
    'ignoreNodes', ignoreNodes, ...
    'cameraInside', true, ...
    'lookToCenter', lookToCenter, ...
    'renderers', {'Mitsuba'});
mexximpSceneScatter(scene, 'ignoreNodes', ignoreNodes);

%% Bat Cave 3DS
%   http://www.turbosquid.com/3d-models/free-bat-cave-3d-model/639123
%   Looks reasonable in scatter, with light cruft around the edges.
%   Has 13 cameras, which is odd.
%   Had to create missing PIPE_TEX.JPG
%   Basically works, but first camera points at a mostly nothing

scene = quickPreview('/home/ben/Downloads/Batcave_MR_3DS/batcave.3DS', ...
    commonArgs{:}, ...
    'renderers', {'Mitsuba'});
mexximpSceneScatter(scene);
