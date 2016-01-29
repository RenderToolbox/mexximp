function [scene, hints] = quickPreview(sceneFile, varargin)
% Sandbox to quickly import and render a scene with mexximp and RTB3.
%
% Assumes RTB3 is on the Matlab path.  Imports the sceneFile with mexximp
% then exports to Collada.
%
% 2016 Mexximp team.

parser = inputParser();
parser.CaseSensitive = true;
parser.KeepUnmatched = true;
parser.PartialMatching = false;
parser.StructExpand = false;
parser.addRequired('sceneFile', @(a) 2 == exist(a, 'file'));
parser.addParameter('renderers', {'Mitsuba', 'PBRT'}, @iscellstr);
parser.addParameter('hints', GetDefaultHints(), @isstruct);
parser.parse(sceneFile, varargin{:});
sceneFile = parser.Results.sceneFile;
renderers = parser.Results.renderers;
hints = parser.Results.hints;

[scenePath, sceneBase, sceneExt] = fileparts(sceneFile);
if isempty(scenePath)
    scenePath = pwd();
end

%% Set up Render Toolbox 3
hints.recipeName = [sceneBase '-' sceneExt(2:end)];
ChangeToWorkingFolder(hints);

setpref('Mitsuba', 'adjustments', which('quick-mitsuba-adjustments.xml'));
setpref('PBRT', 'adjustments', which('quick-pbrt-adjustments.xml'));
mappingsFile = which('quick-mappings.txt');

%% Suck in the scene.
try
    % some light cleanup?
    importFlags = mexximpConstants('postprocessStep');
    importFlags.joinIdenticalVertices = true;
    
    scene = mexximpImport(sceneFile,importFlags);
    if isempty(scene)
        error('imported scene was empty');
    end
catch ex
    error('quickPreview:importError', 'Could not import <%s>:\n%s\n', ...
        sceneFile, ex.message);
end

%% Overwrite the camera with a known camera.
camera = mexximpConstants('camera');
camera.name = 'Camera';
camera.position = [0 0 0];
camera.lookAtDirection = [0 0 -1];
camera.upDirection = [0 1 0];
camera.aspectRatio = [1 1 1];
camera.horizontalFov = pi()/3;
camera.clipPlaneFar = 1e6;
camera.clipPlaneNear = 0.1;
scene.cameras = camera;
    
cameraNode = mexximpConstants('node');
cameraNode.name = camera.name;
cameraNode.transformation = eye(4);

if isempty(scene.rootNode.children)
    scene.rootNode.children = cameraNode;
else
    scene.rootNode.children = [scene.rootNode.children cameraNode];
end

%% Make the camera look at or away from the middle point of vertices.
[scene, camera, cameraNode] = mexximpCentralizeCamera(scene, varargin{:});

%% Add some "lanterns" near the camera.
[scene, lanterns, lanternNodes] = mexximpAddLanterns(scene, varargin{:});

%% Fix references to resource files.
[scene, resourceInfo] = mexximpResolveResources(scene, ...
    'resourceFolder', scenePath, ...
    varargin{:});

%% Re-code gifs as pngs so that Mitsuba can read them.
[scene, imageInfo] = mexximpRecodeImages(scene, ...
    'toReplace', {'gif'}, ...
    'targetFormat', 'png', ...
    varargin{:});

%% Try to spit out the scene as Collada.
format = 'collada';
colladaFile = fullfile(GetWorkingFolder('resources', false, hints), 'quick-export.dae');

try
    status = mexximpExport(scene, format, colladaFile, []);
    if 0 > status
        error('export bad status: %d', status);
    end
catch ex
    error('quickPreview:exportError', 'Could not export <%s>:\n%s\n', ...
        colladaFile, ex.message);
end

%% Render the scene with empty mappings and no conditions.
toneMapFactor = 100;
isScale = true;
for renderer = renderers
    try
        hints.renderer = renderer{1};
        nativeSceneFiles = MakeSceneFiles(colladaFile, '', mappingsFile, hints);
        radianceDataFiles = BatchRender(nativeSceneFiles, hints);
        
        % pop up a figure with results
        montageName = sprintf('%s-%s', hints.recipeName, hints.renderer);
        montageFile = [montageName '.png'];
        SRGBMontage = MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
        ShowXYZAndSRGB([], SRGBMontage, montageName);
    catch ex
        disp(ex.message)
    end
end

