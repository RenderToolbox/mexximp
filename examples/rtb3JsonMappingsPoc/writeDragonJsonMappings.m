%% Sandbox.  Dragon scene mappings as Matlab struct -> JSON file.
%
% I am thinking about a new way to do rtb mappings, in the world of
% Mexximp.
%
% I think we should no longer do our own text parsing.  Instead,
% we should use JSON.  This way we can delete parsing code and use jsonlab
% instead.  We can also convert JSON <-> struct in both directions.  We can
% also access mappings with other tools that understand JSON, if that ever
% comes up.
%
% So here is a stab at some struct/JSON mappings.  I'll try to reproduce
% our original DragonMappings.txt in this new, shinier style.  I'll also
% include some PBRT defaults which come from our original
% PBRTDefaultAdjustments.xml.
%
% Here are some additional differences I want to introduce:
%
% - Instead of treating mappings line by line, add some structure: some
%   top-level structure to identify the scene element of interest and what
%   to do with it (create it fresh, find it and update it, delete it,
%   others?).  Then some nested structure to specify zero or more
%   properties of that element.  We already gropu delcarations and
%   properties when processing mappings now.  Let's just make this clear
%   and explicit in the mappings syntax.
%
% - Instead of identifying elements by strict id matching, which is
%   brittle, allow a few ways to identify elements: by name/id fuzzy
%   matching, by type, and by index.  Specifying all three is overkill.
%   Sometimes it will make most sense to use an element's name, like when
%   looking at a name specified in Blender.  Sometimes it will be good to
%   provide the element's type as well, to narrow the search and eliminate
%   false matches.  Sometimes it will be more natural to identify an
%   element by type and index, like when looking at a mexximp scene struct.
%   Sometimes, just the type will do, like when referring to the single
%   camera and we don't care what its name is.  So name, type, and index
%   will prescribe a well-defined element *search*, rather than a
%   brittle id match.
%


%% Setup.
clear;
clc;

outputFolder = fullfile(tempdir(), 'mappings-poc');

originalScene = which('Dragon.blend');
%originalScene = which('CoordinatesTest.blend');


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


%% For POC, modify a node that's not the root node.
% This will let us see what happens when we have nested node adjustments.
mm = mm + 1;
mappings{mm}.name = 'dragon';
mappings{mm}.broadType = 'nodes';
mappings{mm}.operation = 'update';
mappings{mm}.destination = 'mexximp';
mappings{mm}.properties(1).name = 'transformation';
mappings{mm}.properties(1).valueType = 'matrix';
mappings{mm}.properties(1).value = mexximpIdentity();
mappings{mm}.properties(1).operation = 'value * oldValue';


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
pathHere = fileparts(which('writeDragonJsonMappings'));
mappingsFile = fullfile(pathHere, 'DragonMappings.json');
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
    'materialSpecularParameter', 'Ks', ...
    'workingFolder', outputFolder, ...
    'meshSubfolder', 'pbrt-geometry', ...
    'rewriteMeshData', true);

pbrtScene = applyMPbrtMappings(pbrtScene, validatedMappings);
pbrtScene = applyMPbrtGenericMappings(pbrtScene, validatedMappings);


%% Try to render the PBRT scene.
pbrtFile = fullfile(outputFolder, 'poc.pbrt');
pbrtScene.printToFile(pbrtFile);

pbrt = '/home/ben/render/pbrt/pbrt-v2-spectral/src/bin/pbrt';
command = sprintf('%s --outfile %s %s', pbrt, datFile, pbrtFile);
[status, result] = unix(command);
disp(result);

imageData = ReadDAT(datFile);
srgb = MultispectralToSRGB(imageData, getpref('PBRT', 'S'), 100, true);

[~, sceneBase, sceneExt] = fileparts(originalScene);
ShowXYZAndSRGB([], srgb, [sceneBase sceneExt]);

