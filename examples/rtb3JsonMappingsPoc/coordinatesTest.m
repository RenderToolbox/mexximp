%% Proof of concept for CoordinatesTest with JSON mappings and Mexximp.
%
%   This script is an attempt to reproduce our original RenderToolbox3
%   CoordinatesTest example scene, using some new infrastructure:
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
%       - The normals we get from Blender are "smooth" wherease the normals
%       we get from the Blender Collada exporter are "faceted".  I don't
%       know why they are different!
%
%   Compare the output to the PBRT output from MakeCoordinatesTest.m
%
% BSH

%% Setup.
clear;
clc;

originalScene = which('CoordinatesTest.blend');
[~, sceneBase, sceneExt] = fileparts(originalScene);

outputFolder = fullfile(tempdir(), 'mappings-poc');
datFile = fullfile(outputFolder, [sceneBase '.dat']);
pbrtFile = fullfile(outputFolder, [sceneBase '.pbrt']);

imageWidth = 640;
imageHeight = 480;

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


%% Camera default orientation depends on scene file format.
if strcmp('.dae', sceneExt)
    lookAtDirection = [0 1 0]';
    upDirection = [0 0 1]';
else
    lookAtDirection = [0 0 -1]';
    upDirection = [0 1 0]';
end

mm = mm + 1;
mappings{mm}.name = 'Camera';
mappings{mm}.broadType = 'cameras';
mappings{mm}.operation = 'update';
mappings{mm}.destination = 'mexximp';
mappings{mm}.properties(1).name = 'lookAtDirection';
mappings{mm}.properties(1).valueType = 'lookAt';
mappings{mm}.properties(1).value = lookAtDirection;

mm = mm + 1;
mappings{mm}.name = 'Camera';
mappings{mm}.broadType = 'cameras';
mappings{mm}.operation = 'update';
mappings{mm}.destination = 'mexximp';
mappings{mm}.properties(1).name = 'upDirection';
mappings{mm}.properties(1).valueType = 'lookAt';
mappings{mm}.properties(1).value = upDirection;


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
mm = mm + 1;
mappings{mm}.name = 'Camera';
mappings{mm}.broadType = 'cameras';
mappings{mm}.operation = 'update';
mappings{mm}.destination = 'mexximp';
mappings{mm}.properties(1).name = 'horizontalFov';
mappings{mm}.properties(1).valueType = 'float';
mappings{mm}.properties(1).value = 77.31962 * pi() / 180;
mappings{mm}.properties(2).name = 'aspectRatio';
mappings{mm}.properties(2).valueType = 'float';
mappings{mm}.properties(2).value = imageWidth / imageHeight;

mm = mm + 1;
mappings{mm}.name = 'film';
mappings{mm}.broadType = 'Film';
mappings{mm}.specificType = 'image';
mappings{mm}.operation = 'create';
mappings{mm}.destination = 'PBRT';
mappings{mm}.properties(1).name = 'xresolution';
mappings{mm}.properties(1).valueType = 'integer';
mappings{mm}.properties(1).value = imageWidth;
mappings{mm}.properties(2).name = 'yresolution';
mappings{mm}.properties(2).valueType = 'integer';
mappings{mm}.properties(2).value = imageHeight;


%% Dump mappings out to JSON.
mappingsFile = fullfile(outputFolder, 'coordinatesTestMappings.json');
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
materialDefault = MPbrtElement.makeNamedMaterial('', 'anisoward');
materialDefault.setParameter('Kd', 'spectrum', '300:0 800:0');
materialDefault.setParameter('Ks', 'rgb', [0.5 0.5 0.5]);
materialDefault.setParameter('alphaU', 'float', 0.15);
materialDefault.setParameter('alphaV', 'float', 0.15);
pbrtScene = mexximpToMPbrt(scene, ...
    'materialDefault', materialDefault, ...
    'materialDiffuseParameter', 'Kd', ...
    'workingFolder', outputFolder, ...
    'meshSubfolder', 'pbrt-geometry', ...
    'rewriteMeshData', true);

pbrtScene = applyMPbrtMappings(pbrtScene, validatedMappings);
pbrtScene = applyMPbrtGenericMappings(pbrtScene, validatedMappings);


%% Try to render the PBRT scene.
pbrtScene.printToFile(pbrtFile);

pbrt = '/home/ben/render/pbrt/pbrt-v2-spectral/src/bin/pbrt';
command = sprintf('%s --outfile %s %s', pbrt, datFile, pbrtFile);
[status, result] = unix(command);
disp(result);

imageData = ReadDAT(datFile);
srgb = MultispectralToSRGB(imageData, getpref('PBRT', 'S'), 100, true);

ShowXYZAndSRGB([], srgb, [sceneBase sceneExt]);

