% Sandbox to try a bunch of previews of wild scenes.

clear;
clc;

commonArgs = { ...
    'imageHeight', 240, ...
    'imageWidth', 320, ...
    'renderers', {'PBRT', 'Mitsuba'}};

%% Millenium Falcon
%   http://tf3dm.com/3d-model/millenium-falcon-82947.html

% textures that came with the model
resources = { ...
    '/home/ben/Downloads/4bw1cngyboxs_millenium_falcon/falcon.jpg', ...
    '/home/ben/Downloads/4bw1cngyboxs_millenium_falcon/Map__6_Noise.tga', ...
    };

% .max is not supported by Assimp import
%quickPreview('/home/ben/Downloads/4bw1cngyboxs_millenium_falcon/millenium-falcon.max');

% PBRT can't read the jpg texture
quickPreview('/home/ben/Downloads/4bw1cngyboxs_millenium_falcon/millenium-falcon.obj', ...
    'resources', resources, ...
    commonArgs{:});

% Geometry in here looks messed up.  "assimp info" and mexximpSceneBox()
% both show a really large bounding box.  mexximpSceneScatter() shows
% geometry located in different areas, really far apart.
quickPreview('/home/ben/Downloads/4bw1cngyboxs_millenium_falcon/millenium-falcon.3DS', ...
    'resources', resources, ...
    commonArgs{:});

