%% Proof of concept for MaterialSphereBumps with JSON mappings and Mexximp.
%
%   This script is an attempt to reproduce our original RenderToolbox3
%   MaterialSphereBumps example scene, using some new infrastructure:
%       - our new Assimp/mexximp scene import er
%       - JSON mappings syntax and processing
%       - mappings with eval()able expressions as operators
%       - mPbrt object-oriented model for building and writing PBRT scenes
%
%   This won't reproduce all of our existing infrastructure.  For example,
%   it won't do any Conditions File processing.  But it should tell whether
%   the new stuff will work.
%
%   Compare the output to the PBRT output from MakeMaterialSphereBumps.m
%
% BSH

%% Set up.
clear;
clc;

fov = 49.13434 * pi() / 180;
pbrt = '/home/ben/render/pbrt/pbrt-v2-spectral/src/bin/pbrt';

outputFolder = fullfile(tempdir(), 'mappings-poc');
mappingsFile = fullfile(outputFolder, 'materialSphereBumpsMappings.json');
if 7 ~= exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% Reproduce original mappings file in new JSON style.

% explicit spectrum for the point light
% Generic {
%     % explicit spectrum for the point light
%     Point-light:light:point
%     Point-light:intensity.spectrum = 300:1 800:1
% }
mm = 1;
mappings{mm}.name = 'Point';
mappings{mm}.broadType = 'lights';
mappings{mm}.specificType = 'point';
mappings{mm}.operation = 'update';
mappings{mm}.properties(1).name = 'intensity';
mappings{mm}.properties(1).valueType = 'spectrum';
mappings{mm}.properties(1).value = '300:1 800:1';


% metal material
% Generic metalGroup {
%     % generic metal sphere material
%     Material-material:material:metal
%
%     % make the surface somewhat rough
%     Material-material:roughness.float = 0.4
%
%     % make it out of gold!
%     Material-material:eta.spectrum = Au.eta.spd
%     Material-material:k.spectrum = Au.k.spd
% }
mm = mm + 1;
mappings{mm}.name = 'Material';
mappings{mm}.broadType = 'materials';
mappings{mm}.specificType = 'metal';
mappings{mm}.operation = 'update';
mappings{mm}.properties(1).name = 'roughness';
mappings{mm}.properties(1).valueType = 'float';
mappings{mm}.properties(1).value = 0.4;
mappings{mm}.properties(2).name = 'eta';
mappings{mm}.properties(2).valueType = 'spectrum';
mappings{mm}.properties(2).value = which('Au.eta.spd');
mappings{mm}.properties(3).name = 'k';
mappings{mm}.properties(3).valueType = 'spectrum';
mappings{mm}.properties(3).value = which('Au.k.spd');

% add bumps to the sphere material under all conditions
% Generic {
%     % load an image into a texture
%     earthTexture:floatTexture:bitmap
%     earthTexture:filename.string = earthbump1k-stretch-rgb.exr
%
%     % add bumps to the existing sphere material
%     earthBumpMap:material:bumpmap
%     earthBumpMap:materialID.string = Material-material
%     earthBumpMap:textureID.string = earthTexture
%     earthBumpMap:scale.float = 0.1
% }
mm = mm + 1;
mappings{mm}.name = 'earthTexture';
mappings{mm}.broadType = 'floatTextures';
mappings{mm}.specificType = 'bitmap';
mappings{mm}.operation = 'create';
mappings{mm}.properties(1).name = 'filename';
mappings{mm}.properties(1).valueType = 'string';
mappings{mm}.properties(1).value = which('earthbump1k-stretch-rgb.exr');

mm = mm + 1;
mappings{mm}.name = 'Material';
mappings{mm}.broadType = 'materials';
mappings{mm}.operation = 'blessAsBumpMap';
mappings{mm}.properties(1).name = 'texture';
mappings{mm}.properties(1).valueType = 'string';
mappings{mm}.properties(1).value = 'earthTexture';
mappings{mm}.properties(2).name = 'scale';
mappings{mm}.properties(2).valueType = 'float';
mappings{mm}.properties(2).value = 0.1;


%% Dump mappings out to JSON.
savejson('', mappings, ...
    'FileName', mappingsFile, ...
    'ArrayIndent', 1, ...
    'ArrayToStrut', 0);


%% Render it.
originalScene = which('MaterialSphere.blend');
pocRender(originalScene, mappingsFile, ...
    'imageWidth', 320, ...
    'imageHeight', 240, ...
    'fov', fov, ...
    'pbrt', pbrt, ...
    'flipUVs', true);

originalScene = which('MaterialSphere.dae');
pocRender(originalScene, mappingsFile, ...
    'imageWidth', 320, ...
    'imageHeight', 240, ...
    'fov', fov, ...
    'pbrt', pbrt, ...
    'ignoreRootTransform', true, ...
    'flipUVs', true);
