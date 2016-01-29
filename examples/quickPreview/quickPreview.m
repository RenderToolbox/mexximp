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
parser.addParameter('lookToCenter', [0 0 -1], @(c) isnumeric(c) && 3 == numel(c));
parser.addParameter('cameraInside', false, @islogical);
parser.addParameter('ignoreNodes', {}, @iscellstr);
parser.parse(sceneFile, varargin{:});
sceneFile = parser.Results.sceneFile;
renderers = parser.Results.renderers;
hints = parser.Results.hints;
lookToCenter = parser.Results.lookToCenter;
cameraInside = parser.Results.cameraInside;
ignoreNodes = parser.Results.ignoreNodes;

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

%% Suck in the scene and try to export to Collada.
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

%% Fix up the camera.
if isempty(scene.cameras)
    % no camera!
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
    
    % figure out where to place the camera
    %   looking at geometry center
    %   far enough away to fit everything in Fov
    [sceneBox, middlePoint] = mexximpSceneBox(scene, ...
        'ignoreNodes', ignoreNodes);
    halfWidth = norm(sceneBox(:,1) - sceneBox(:,2)) / 2;
    
    if cameraInside
        % position camera inside the bounding box
        cameraScale = halfWidth;
    else
        % position camera far enough away to view all the vertices
        
        % Want half of the camera's viewing angle, which corresponds to the
        % halfWidth of the bounding box calculated above.  The Assimp docs
        % say that camera horizontalFov *is* the half-angle.  But it is
        % behaving like the full viewing angle.  So divide by 2.
        %
        % This seems to be a bug in the Assimp code or documentation.  It
        % might be specific to the import or export file format!  Ahh!
        halfAngle = camera.horizontalFov / 2;
        cameraScale = halfWidth / tan(halfAngle);
    end
    
    cameraPostion = middlePoint' + lookToCenter .* cameraScale;
    lookAt = mexximpLookAt(cameraPostion, middlePoint', [0 1 0]);
    
    cameraNode = mexximpConstants('node');
    cameraNode.name = camera.name;
    cameraNode.transformation = lookAt;
    
    if isempty(scene.rootNode.children)
        scene.rootNode.children = cameraNode;
    else
        scene.rootNode.children = [scene.rootNode.children cameraNode];
    end
else
    % pick first camera and rename to agree with our adjustments
    camera = scene.cameras(1);
    
    newCameraName = 'Camera';
    oldCameraName = camera.name;
    nodeNames = {scene.rootNode.children.name};
    cameraNodeIndexes = find(strcmp(oldCameraName, nodeNames));
    for ii = cameraNodeIndexes
        scene.rootNode.children(ii).name = newCameraName;
        cameraNode = scene.rootNode.children(ii);
    end
    camera.name = newCameraName;
    camera.clipPlaneFar = 1e6;
    camera.clipPlaneNear = 0.1;

    scene.cameras = camera;
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
lanternNode.transformation = mexximpTranslate([0 0 -1]) * cameraNode.transformation;

if isempty(scene.rootNode.children)
    scene.rootNode.children = lanternNode;
else
    scene.rootNode.children = [scene.rootNode.children lanternNode];
end

%% Gather resources located in the scene folder.
sceneDir = dir(scenePath);
isDir = [sceneDir.isdir];
resources = {sceneDir(~isDir).name};
nResources = numel(resources);

%% Fix up material resource files and file names.
for mm = 1:numel(scene.materials)
    for pp = 1:numel(scene.materials(mm).properties)
        if strcmp('string', scene.materials(mm).properties(pp).dataType)
            dataFile = scene.materials(mm).properties(pp).data;
            
            % match resources based on file name and extension
            %   fileparts() fails on cross-platform file names!
            fileWasFound = false;
            for ii = 1:nResources
                resource = resources{ii};
                fullResource = fullfile(scenePath, resource);
                
                if fuzzyMatch(dataFile, resource)
                    fileWasFound = true;
                    
                    % grrr: rename "-" to "_" to avoid utf8 transcoding
                    isHyphen = '-' == resource;
                    if any(isHyphen)
                        withoutHyphen = resource;
                        withoutHyphen(isHyphen) = '_';
                        
                        source = fullfile(scenePath, resource);
                        destination = fullfile(scenePath, withoutHyphen);
                        copyfile(source, destination, 'f');
                        
                        resource = withoutHyphen;
                        fullResource = fullfile(scenePath, resource);
                    end
                    
                    % grrr: reformat gif as png for Mitsuba
                    [~, resourceBase, resourceExt] = fileparts(resource);
                    if strcmp('.gif', resourceExt)
                        [imageData, colorMap] = imread(fullResource);
                        resource = [resourceBase '.png'];
                        fullResource = fullfile(scenePath, resource);
                        imwrite(imageData, colorMap, fullResource, 'png');
                    end
                    
                    scene.materials(mm).properties(pp).data = fullResource;
                    disp([dataFile ' -> ' fullResource]);
                    break;
                end
            end
            
            if ~fileWasFound && any('.' == dataFile)
                disp([dataFile ' ?']);
            end
        end
    end
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

%% Fuzzy matching for file names: is b probably a good substitute for a?
%   case insensitive
%   4851-nor.jpg matches 4851-normal.jpg
%   C:\foo\bar\baz.jpg matches baz.jpg
function isMatch = fuzzyMatch(a, b)
a = lower(a);
b = lower(b);

[~, aBase, aExt] = fileparts(a);
[~, bBase, bExt] = fileparts(b);

% one extension is a substring of the other,
%   and one file name is a substring of the other
isMatch = ...
    (~isempty(strfind(aExt, bExt)) || ~isempty(strfind(bExt, aExt))) ...
    && ...
    (~isempty(strfind(aBase, bBase)) || ~isempty(strfind(bBase, aBase)));
