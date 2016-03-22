%% Proof of concept for the Dragon scene with JSON mappings and Mexximp.
%
%   This script is an attempt to reproduce our original RenderToolbox3
%   Dragon example scene, using some new infrastructure:
%       - our new Assimp/mexximp scene import er
%       - JSON mappings syntax and processing
%       - mappings with eval()able expressions as operators
%       - mPbrt object-oriented model for building and writing PBRT scenes
%
%   This won't reproduce all of our existing infrastructure.  For example,
%   it won't do any Conditions File processing.  But it should tell whether
%   the new stuff will work.
%
%   Compare the output to the PBRT output from MakeDragon.m
%
% BSH


%% Set up.
clear;
clc;

fov = 49.13434 * pi() / 180;
pbrt = '/home/ben/render/pbrt/pbrt-v2-spectral/src/bin/pbrt';

outputFolder = fullfile(tempdir(), 'mappings-poc');
mappingsFile = fullfile(outputFolder, 'dragonMappings.json');
if 7 ~= exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% Reproduce original mappings file in new JSON style.

% "bless" existing meshes to make them area lights
% Generic {
%     % make area lights with daylight spectrum
%     LightX-mesh:light:area
%     LightX-mesh:intensity.spectrum = D65.spd
%     LightY-mesh:light:area
%     LightY-mesh:intensity.spectrum = D65.spd
%     ...
% }
mm = 1;
mappings{mm}.name = 'LightX';
mappings{mm}.broadType = 'meshes';
mappings{mm}.operation = 'blessAsAreaLight';
mappings{mm}.properties(1).name = 'intensity';
mappings{mm}.properties(1).valueType = 'spectrum';
mappings{mm}.properties(1).value = which('D65.spd');

mm = mm + 1;
mappings{mm}.name = 'LightY';
mappings{mm}.broadType = 'meshes';
mappings{mm}.operation = 'blessAsAreaLight';
mappings{mm}.properties(1).name = 'intensity';
mappings{mm}.properties(1).valueType = 'spectrum';
mappings{mm}.properties(1).value = which('D65.spd');


% set the type and spectrum for materials
% Generic {
%     ...
%     % make the area lights perfect reflectors, too
%     ReflectorMaterial-material:material:matte
%     ReflectorMaterial-material:diffuseReflectance.spectrum = 300:1.0 800:1.0
%
%     % make gray walls and floor
%     WallMaterial-material:material:matte
%     WallMaterial-material:diffuseReflectance.spectrum = 300:0.75 800:0.75
%     FloorMaterial-material:material:matte
%     FloorMaterial-material:diffuseReflectance.spectrum = 300:0.5 800:0.5
%
%     % make a tan dragon
%     DragonMaterial-material:material:matte
%     DragonMaterial-material:diffuseReflectance.spectrum = mccBabel-1.spd
%     ...
% }
mm = mm + 1;
mappings{mm}.name = 'ReflectorMaterial';
mappings{mm}.broadType = 'materials';
mappings{mm}.specificType = 'matte';
mappings{mm}.operation = 'update';
mappings{mm}.properties(1).name = 'diffuseReflectance';
mappings{mm}.properties(1).valueType = 'spectrum';
mappings{mm}.properties(1).value = '300:1.0 800:1.0';

mm = mm + 1;
mappings{mm}.name = 'WallMaterial';
mappings{mm}.broadType = 'materials';
mappings{mm}.specificType = 'matte';
mappings{mm}.operation = 'update';
mappings{mm}.properties(1).name = 'diffuseReflectance';
mappings{mm}.properties(1).valueType = 'spectrum';
mappings{mm}.properties(1).value = '300:0.75 800:0.75';

mm = mm + 1;
mappings{mm}.name = 'FloorMaterial';
mappings{mm}.broadType = 'materials';
mappings{mm}.specificType = 'matte';
mappings{mm}.operation = 'update';
mappings{mm}.properties(1).name = 'diffuseReflectance';
mappings{mm}.properties(1).valueType = 'spectrum';
mappings{mm}.properties(1).value = '300:0.5 800:0.5';

mm = mm + 1;
mappings{mm}.name = 'DragonMaterial';
mappings{mm}.broadType = 'materials';
mappings{mm}.specificType = 'matte';
mappings{mm}.operation = 'update';
mappings{mm}.properties(1).name = 'diffuseReflectance';
mappings{mm}.properties(1).valueType = 'spectrum';
mappings{mm}.properties(1).value = which('mccBabel-1.spd');

% write to JSON-mappings file
savejson('', mappings, ...
    'FileName', mappingsFile, ...
    'ArrayIndent', 1, ...
    'ArrayToStrut', 0);


%% Render it.
originalScene = which('Dragon.blend');
pocRender(originalScene, mappingsFile, ...
    'imageWidth', 320, ...
    'imageHeight', 240, ...
    'fov', fov, ...
    'pbrt', pbrt);

%% TODO: something is amiss with this scene
originalScene = which('Dragon.dae');
pocRender(originalScene, mappingsFile, ...
    'imageWidth', 320, ...
    'imageHeight', 240, ...
    'fov', fov, ...
    'pbrt', pbrt);
