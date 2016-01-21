function hints = quickPreview(sceneFile, varargin)
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
parser.addParameter('imageHeight', 480, @isnumeric);
parser.addParameter('imageWidth', 640, @isnumeric);
parser.addParameter('resources', {}, @iscellstr);
parser.addParameter('cameraPosition', [0 0 25], @(a) isnumeric(a) && 3 == numel(a));
parser.parse(sceneFile, varargin{:});
sceneFile = parser.Results.sceneFile;
renderers = parser.Results.renderers;
imageWidth = parser.Results.imageWidth;
imageHeight = parser.Results.imageHeight;
resources = parser.Results.resources;
cameraPosition = parser.Results.cameraPosition;

[~, sceneBase, sceneExt] = fileparts(sceneFile);

%% Set up Render Toolbox 3
hints.imageWidth = imageWidth;
hints.imageHeight = imageHeight;
hints.recipeName = [sceneBase '-' sceneExt(2:end)];
ChangeToWorkingFolder(hints);

setpref('Mitsuba', 'adjustments', which('quick-mitsuba-adjustments.xml'));
setpref('PBRT', 'adjustments', which('quick-pbrt-adjustments.xml'));
mappingsFile = which('quick-mappings.txt');

%% Suck in the scene and try to export to Collada.
try
    scene = mexximpImport(sceneFile);
    if isempty(scene)
        error('imported scene was empty');
    end
catch ex
    error('quickPreview:importError', 'Could not import <%s>:\n%s\n', ...
        sceneFile, ex.message);
end

%% Fix up the camera.
if isempty(scene.cameras)
    % no camera!
    camera = mexximpConstants('camera');
    camera.name = 'Camera';
    camera.position = [0 0 0];
    camera.lookAtDirection = [0 0 1];
    camera.upDirection = [0 1 0];
    camera.aspectRatio = [1 1 1];
    camera.horizontalFov = pi()/4;
    camera.clipPlaneFar = 1e6;
    camera.clipPlaneNear = 0.1;
    scene.cameras = camera;
    
    cameraNode = mexximpConstants('node');
    cameraNode.name = camera.name;
    cameraNode.transformation = makehgtform('translate', cameraPosition)';
    
    if isempty(scene.rootNode.children)
        scene.rootNode.children = cameraNode;
    else
        scene.rootNode.children = [scene.rootNode.children cameraNode];
    end
else
    % rename camera to agree with adjustments file
    newCameraName = 'Camera';
    oldCameraName = scene.cameras(1).name;
    nodeNames = {scene.rootNode.children.name};
    cameraNodeIndexes = find(strcmp(oldCameraName, nodeNames));
    for ii = cameraNodeIndexes
        scene.rootNode.children(ii).name = newCameraName;
        cameraNode = scene.rootNode.children(ii);
    end
    scene.cameras(1).name = newCameraName;
end

%% Add a "lantern" near the camera.
lantern = mexximpConstants('light');
lantern.name = 'lantern';
lantern.position = [0 0 0];
lantern.type = 'point';
lantern.lookAtDirection = [0 0 0];
lantern.innerConeAngle = 0;
lantern.outerConeAngle = 0;
lantern.constantAttenuation = 1;
lantern.linearAttenuation = 0;
lantern.quadraticAttenuation = 1;
lantern.ambientColor = [1 1 1];
lantern.diffuseColor = [1 1 1];
lantern.specularColor = [1 1 1];

if isempty(scene.lights)
    scene.lights = lantern;
else
    scene.lights = [scene.lights lantern];
end

lanternNode = mexximpConstants('node');
lanternNode.name = lantern.name;
lanternNode.transformation = makehgtform('translate', -1*[1 1 1])' * cameraNode.transformation;

if isempty(scene.rootNode.children)
    scene.rootNode.children = lanternNode;
else
    scene.rootNode.children = [scene.rootNode.children lanternNode];
end

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

%% Copy resources like textures to the working folder.
for ii = 1:numel(resources)
    resourceFile = resources{ii};
    if 2 ~= exist(resourceFile, 'file')
        continue;
    end
    copyfile(resourceFile, GetWorkingFolder('', false, hints));
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
