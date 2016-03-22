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
%   Unresolved limitations so far:
%       - Blender scene import loses the camera fov.  So we have to supply
%       it explicitly with mappings.
%
%   Compare the output to the PBRT output from MakeDragon.m
%
% BSH

%% Setup.
clear;
clc;

outputFolder = fullfile(tempdir(), 'mappings-poc');

originalScene = which('Dragon.blend');


%% In the old Collada Mappings, we sometimes need to flip coordinates.
% Collada {
%     % swap camera handedness from Blender's Collada output
%     Camera:scale|sid=scale = -1 1 1
% }
%
% What we can do now is edit the mexximp camera node.

mm = 1;
mappings{mm}.name = 'Camera';
mappings{mm}.broadType = 'nodes';
mappings{mm}.operation = 'update';
mappings{mm}.destination = 'mexximp';
mappings{mm}.properties(1).name = 'transformation';
mappings{mm}.properties(1).valueType = 'matrix';
mappings{mm}.properties(1).value = mexximpScale([-1 1 1]);

% let users supply an arbitrary operation for combining the
% existing oldValue and the new value from the mappings
% (or just use the default, which is to replace the old with the new)
mappings{mm}.properties(1).operation = 'value * oldValue';


%% We need to "bless" two existing meshes to make them area lights.
% Generic {
%     % make area lights with daylight spectrum
%     LightX-mesh:light:area
%     LightX-mesh:intensity.spectrum = D65.spd
%     LightY-mesh:light:area
%     LightY-mesh:intensity.spectrum = D65.spd
%     ...
% }

mm = mm + 1;
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


%% We need set the type and spectrum for two materials.
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


%% Add some PBRT XML "default adjustments".
%     <SurfaceIntegrator id="integrator" type="directlighting"/>
%
%     <Sampler id="sampler" type="lowdiscrepancy">
%         <parameter name="pixelsamples" type="integer">8</parameter>
%     </Sampler>
%
%     <PixelFilter id="filter" type="gaussian">
%         <parameter name="alpha" type="float">2</parameter>
%         <parameter name="xwidth" type="float">2</parameter>
%         <parameter name="ywidth" type="float">2</parameter>
%     </PixelFilter>
%
% These set up scene elements that mexximp won't know about.
mm = mm + 1;
mappings{mm}.name = 'integrator';
mappings{mm}.broadType = 'SurfaceIntegrator';
mappings{mm}.index = [];
mappings{mm}.specificType = 'directlighting';
mappings{mm}.operation = 'create';
mappings{mm}.destination = 'PBRT';

mm = mm + 1;
mappings{mm}.name = 'sampler';
mappings{mm}.broadType = 'Sampler';
mappings{mm}.index = [];
mappings{mm}.specificType = 'lowdiscrepancy';
mappings{mm}.operation = 'create';
mappings{mm}.destination = 'PBRT';
mappings{mm}.properties(1).name = 'pixelsamples';
mappings{mm}.properties(1).valueType = 'integer';
mappings{mm}.properties(1).value = 8;

mm = mm + 1;
mappings{mm}.name = 'filter';
mappings{mm}.broadType = 'PixelFilter';
mappings{mm}.index = [];
mappings{mm}.specificType = 'gaussian';
mappings{mm}.operation = 'create';
mappings{mm}.destination = 'PBRT';
mappings{mm}.properties(1).name = 'alpha';
mappings{mm}.properties(1).valueType = 'float';
mappings{mm}.properties(1).value = 2;
mappings{mm}.properties(2).name = 'xwidth';
mappings{mm}.properties(2).valueType = 'float';
mappings{mm}.properties(2).value = 2;
mappings{mm}.properties(3).name = 'ywidth';
mappings{mm}.properties(3).valueType = 'float';
mappings{mm}.properties(3).value = 2;


%% A little fix-up for the camera fov and image size.
imageHeight = 240;
imageWidth = 320;
datFile = fullfile(outputFolder, 'poc.dat');

mm = mm + 1;
mappings{mm}.name = 'Camera';
mappings{mm}.broadType = 'cameras';
mappings{mm}.operation = 'update';
mappings{mm}.destination = 'mexximp';
mappings{mm}.properties(1).name = 'horizontalFov';
mappings{mm}.properties(1).valueType = 'float';
mappings{mm}.properties(1).value = 49.13434 * pi() / 180;
mappings{mm}.properties(2).name = 'aspectRatio';
mappings{mm}.properties(2).valueType = 'float';
mappings{mm}.properties(2).value = imageWidth / imageHeight;

mm = mm + 1;
mappings{mm}.name = 'film';
mappings{mm}.broadType = 'Film';
mappings{mm}.specificType = 'image';
mappings{mm}.operation = 'create';
mappings{mm}.destination = 'PBRT';
mappings{mm}.properties(1).name = 'filename';
mappings{mm}.properties(1).valueType = 'string';
mappings{mm}.properties(1).value = datFile;
mappings{mm}.properties(2).name = 'xresolution';
mappings{mm}.properties(2).valueType = 'integer';
mappings{mm}.properties(2).value = imageWidth;
mappings{mm}.properties(3).name = 'yresolution';
mappings{mm}.properties(3).valueType = 'integer';
mappings{mm}.properties(3).value = imageHeight;


%% Dump mappings out to JSON.
mappingsFile = fullfile(outputFolder, 'dragonMappings.json');
savejson('', mappings, ...
    'FileName', mappingsFile, ...
    'ArrayIndent', 1, ...
    'ArrayToStrut', 0);


%% And we can read it back with defaults filled in.
validatedMappings = parseJsonMappings(mappingsFile);


%% Get the scene and apply mappings to it.
[scene, ~, postFlags] = mexximpCleanImport(originalScene);

% modify the mexximp scene struct
scene = applyMexximpMappings(scene, validatedMappings);

% convert to an mPbrt scene
materialDefault = MPbrtElement.makeNamedMaterial('', 'matte');
materialDefault.setParameter('Kd', 'spectrum', '300:0 800:0');
pbrtScene = mexximpToMPbrt(scene, ...
    'materialDefault', materialDefault, ...
    'materialDiffuseParameter', 'Kd', ...
    'workingFolder', outputFolder, ...
    'meshSubfolder', 'pbrt-geometry', ...
    'rewriteMeshData', true);

pbrtScene = applyMPbrtMappings(pbrtScene, validatedMappings);
pbrtScene = applyMPbrtGenericMappings(pbrtScene, validatedMappings);


%% Try to render the PBRT scene.
pbrtFile = fullfile(outputFolder, 'dragon.pbrt');
pbrtScene.printToFile(pbrtFile);

pbrt = '/home/ben/render/pbrt/pbrt-v2-spectral/src/bin/pbrt';
command = sprintf('%s --outfile %s %s', pbrt, datFile, pbrtFile);
[status, result] = unix(command);
disp(result);

imageData = ReadDAT(datFile);
srgb = MultispectralToSRGB(imageData, getpref('PBRT', 'S'), 100, true);

[~, sceneBase, sceneExt] = fileparts(originalScene);
ShowXYZAndSRGB([], srgb, [sceneBase sceneExt]);

