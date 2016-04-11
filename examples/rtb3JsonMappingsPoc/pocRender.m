function [status, result] = pocRender(originalScene, mappingsFile, varargin)
%% Proof of concept utility to render with JSON mappings and Mexximp.
%
% This is sandbox code.  We ask for parameters we need and then do a
% bunch of boilerplate to get a scene imported with mexximp, adjusted with
% JSON mappings, and rendered with PBRT.  Soon we can add Mitsuba!
%
% We should be able to use this with various input scenes and various
% formats of the same scene.
%
% BSH

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('originalScene', @ischar);
parser.addRequired('mappingsFile', @ischar);
parser.addParameter('fov', pi()/3, @isnumeric);
parser.addParameter('imageWidth', 320, @isnumeric);
parser.addParameter('imageHeight', 240, @isnumeric);
parser.addParameter('pbrt', '', @ischar);
parser.addParameter('pbrtMaterial', []);
parser.addParameter('mitsuba', '', @ischar);
parser.addParameter('mitsubaMaterial', []);
parser.addParameter('outputFolder', fullfile(tempdir(), 'mappings-poc'), @ischar);
parser.addParameter('lookAtDirection', [0 0 -1]', @isnumeric);
parser.addParameter('upDirection', [0 1 0]', @isnumeric);
parser.parse(originalScene, mappingsFile, varargin{:});
originalScene = parser.Results.originalScene;
mappingsFile = parser.Results.mappingsFile;
fov = parser.Results.fov;
imageWidth = parser.Results.imageWidth;
imageHeight = parser.Results.imageHeight;
pbrt = parser.Results.pbrt;
pbrtMaterial = parser.Results.pbrtMaterial;
mitsuba = parser.Results.mitsuba;
mitsubaMaterial = parser.Results.mitsubaMaterial;
outputFolder = parser.Results.outputFolder;
lookAtDirection = parser.Results.lookAtDirection;
upDirection = parser.Results.upDirection;

%% Setup.
[~, sceneBase, sceneExt] = fileparts(originalScene);
defaultMappingsFile = fullfile(outputFolder, 'pocDefaultMappings.json');

%% Default camera setup.
mm = 1;
defaultMappings{mm}.name = 'Camera';
defaultMappings{mm}.broadType = 'nodes';
defaultMappings{mm}.operation = 'update';
defaultMappings{mm}.destination = 'mexximp';
defaultMappings{mm}.properties(1).name = 'transformation';
defaultMappings{mm}.properties(1).valueType = 'matrix';
defaultMappings{mm}.properties(1).value = mexximpScale([-1 1 1]);
defaultMappings{mm}.properties(1).operation = 'value * oldValue';

mm = mm + 1;
defaultMappings{mm}.name = 'Camera';
defaultMappings{mm}.broadType = 'cameras';
defaultMappings{mm}.operation = 'update';
defaultMappings{mm}.destination = 'mexximp';
defaultMappings{mm}.properties(1).name = 'lookAtDirection';
defaultMappings{mm}.properties(1).valueType = 'lookAt';
defaultMappings{mm}.properties(1).value = lookAtDirection;

mm = mm + 1;
defaultMappings{mm}.name = 'Camera';
defaultMappings{mm}.broadType = 'cameras';
defaultMappings{mm}.operation = 'update';
defaultMappings{mm}.destination = 'mexximp';
defaultMappings{mm}.properties(1).name = 'upDirection';
defaultMappings{mm}.properties(1).valueType = 'lookAt';
defaultMappings{mm}.properties(1).value = upDirection;

mm = mm + 1;
defaultMappings{mm}.name = 'Camera';
defaultMappings{mm}.broadType = 'cameras';
defaultMappings{mm}.operation = 'update';
defaultMappings{mm}.destination = 'mexximp';
defaultMappings{mm}.properties(1).name = 'horizontalFov';
defaultMappings{mm}.properties(1).valueType = 'float';
defaultMappings{mm}.properties(1).value = fov;
defaultMappings{mm}.properties(2).name = 'aspectRatio';
defaultMappings{mm}.properties(2).valueType = 'float';
defaultMappings{mm}.properties(2).value = imageWidth / imageHeight;


%% Default setup for PBRT.
mm = mm + 1;
defaultMappings{mm}.name = 'integrator';
defaultMappings{mm}.broadType = 'SurfaceIntegrator';
defaultMappings{mm}.index = [];
defaultMappings{mm}.specificType = 'directlighting';
defaultMappings{mm}.operation = 'create';
defaultMappings{mm}.destination = 'PBRT';

mm = mm + 1;
defaultMappings{mm}.name = 'sampler';
defaultMappings{mm}.broadType = 'Sampler';
defaultMappings{mm}.index = [];
defaultMappings{mm}.specificType = 'lowdiscrepancy';
defaultMappings{mm}.operation = 'create';
defaultMappings{mm}.destination = 'PBRT';
defaultMappings{mm}.properties(1).name = 'pixelsamples';
defaultMappings{mm}.properties(1).valueType = 'integer';
defaultMappings{mm}.properties(1).value = 8;

mm = mm + 1;
defaultMappings{mm}.name = 'filter';
defaultMappings{mm}.broadType = 'PixelFilter';
defaultMappings{mm}.index = [];
defaultMappings{mm}.specificType = 'gaussian';
defaultMappings{mm}.operation = 'create';
defaultMappings{mm}.destination = 'PBRT';
defaultMappings{mm}.properties(1).name = 'alpha';
defaultMappings{mm}.properties(1).valueType = 'float';
defaultMappings{mm}.properties(1).value = 2;
defaultMappings{mm}.properties(2).name = 'xwidth';
defaultMappings{mm}.properties(2).valueType = 'float';
defaultMappings{mm}.properties(2).value = 2;
defaultMappings{mm}.properties(3).name = 'ywidth';
defaultMappings{mm}.properties(3).valueType = 'float';
defaultMappings{mm}.properties(3).value = 2;

mm = mm + 1;
defaultMappings{mm}.name = 'film';
defaultMappings{mm}.broadType = 'Film';
defaultMappings{mm}.specificType = 'image';
defaultMappings{mm}.operation = 'create';
defaultMappings{mm}.destination = 'PBRT';
defaultMappings{mm}.properties(1).name = 'xresolution';
defaultMappings{mm}.properties(1).valueType = 'integer';
defaultMappings{mm}.properties(1).value = imageWidth;
defaultMappings{mm}.properties(2).name = 'yresolution';
defaultMappings{mm}.properties(2).valueType = 'integer';
defaultMappings{mm}.properties(2).value = imageHeight;


%% Combine passed-in scene mappings with default mappings.
if 7 ~= exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
savejson('', defaultMappings, ...
    'FileName', defaultMappingsFile, ...
    'ArrayIndent', 1, ...
    'ArrayToStrut', 0);
mappings = parseJsonMappings(defaultMappingsFile);

if 2 == exist(mappingsFile, 'file')
    sceneMappings = parseJsonMappings(mappingsFile);
    mappings = cat(2, mappings, sceneMappings);
end

%% Get the scene!
scene = mexximpCleanImport(originalScene, varargin{:});
scene = applyMexximpMappings(scene, mappings);

%% Render with PBRT?
if 2 == exist(pbrt, 'file');
    datFile = fullfile(outputFolder, [sceneBase '.dat']);
    pbrtFile = fullfile(outputFolder, [sceneBase '.pbrt']);
    
    % use anisoward from pbrt-v2-spectral
    if isempty(pbrtMaterial)
        pbrtMaterial = MPbrtElement.makeNamedMaterial('', 'anisoward');
        pbrtMaterial.setParameter('Kd', 'spectrum', '300:0 800:0');
        pbrtMaterial.setParameter('Ks', 'rgb', [0.5 0.5 0.5]);
        pbrtMaterial.setParameter('alphaU', 'float', 0.15);
        pbrtMaterial.setParameter('alphaV', 'float', 0.15);
    end
    
    % convert to an mPbrt scene
    pbrtScene = mexximpToMPbrt(scene, ...
        'materialDefault', pbrtMaterial, ...
        'materialDiffuseParameter', 'Kd', ...
        'workingFolder', outputFolder, ...
        'meshSubfolder', 'pbrt-geometry', ...
        'rewriteMeshData', true);
    pbrtScene = applyMPbrtMappings(pbrtScene, mappings);
    pbrtScene = applyMPbrtGenericMappings(pbrtScene, mappings);
    
    
    % invoke the renderer
    pbrtScene.printToFile(pbrtFile);
    command = sprintf('%s --outfile %s %s', pbrt, datFile, pbrtFile);
    [status, result] = unix(command);
    
    imageData = ReadDAT(datFile);
    srgb = MultispectralToSRGB(imageData, getpref('PBRT', 'S'), 100, true);
    ShowXYZAndSRGB([], srgb, [sceneBase sceneExt]);
end

%% Render with Mitsuba?
if 2 == exist(mitsuba, 'file');
    exrFile = fullfile(outputFolder, [sceneBase '.exr']);
    mitsubaFile = fullfile(outputFolder, [sceneBase '.xml']);
    
    % use anisoward from pbrt-v2-spectral
    if isempty(mitsubaMaterial)
        mitsubaMaterial = MMitsubaElement('', 'bsdf', 'ward');
        mitsubaMaterial.append(MMitsubaProperty.withValue('diffuseReflectance', 'spectrum', '300:0 800:0'));
        mitsubaMaterial.append(MMitsubaProperty.withValue('specularReflectance', 'rgb', [0.5 0.5 0.5]));
        mitsubaMaterial.append(MMitsubaProperty.withValue('alphaU', 'float', 0.15));
        mitsubaMaterial.append(MMitsubaProperty.withValue('alphaV', 'float', 0.15));
    end
    
    % convert to an mMitsuba scene
    mitsubaScene = mexximpToMitsuba(scene, ...
        'materialDefault', mitsubaMaterial, ...
        'materialDiffuseParameter', 'diffuseReflectance', ...
        'workingFolder', outputFolder, ...
        'meshSubfolder', 'mitsuba-geometry', ...
        'rewriteMeshData', true);
    %pbrtScene = applyMPbrtMappings(pbrtScene, mappings);
    %pbrtScene = applyMPbrtGenericMappings(pbrtScene, mappings);
    
    % invoke the renderer
    libPath = fileparts(mitsuba);
    mitsubaScene.printToFile(mitsubaFile);
    command = sprintf('LD_LIBRARY_PATH="%s" "%s" -o "%s" "%s"', ...
        libPath, mitsuba, exrFile, mitsubaFile);
    [status, result] = unix(command);
    
    [imageData, ~, S] = ReadMultispectralEXR(exrFile);
    srgb = MultispectralToSRGB(imageData, S, 100, true);
    ShowXYZAndSRGB([], srgb, [sceneBase sceneExt]);
end
