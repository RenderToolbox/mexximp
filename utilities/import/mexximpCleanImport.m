function [scene, elements, postFlags] = mexximpCleanImport(sceneFile, varargin)
%% Import the given scene file and clean it up with Assimp postprocessing.
%
% scene = mexximpCleanImport(sceneFile) imports the given scene file using
% mexximp, and applies several of Assimp's useful postprocessing steps,
% like triangulating meshes, joining identical vertices, calculating
% missing normals, etc.
%
% mexximpCleanImport( ... 'name', value) specifies the value of one or more
% of Assimp's post-processing flags.  These may be used to override the
% default post-processing flags.  All values must be logical.  See
% mexximpConstants('postprocessStep') for allowed flag names.
%
% Returns a mexximp struct representation of the scene contained in the
% given sceneFile.
%
% Also returns a struct array of scene "elements", which is an
% easy-to-iterate collection of pointers into the scene struct.
%
% Also returns a struct of Assimp post-processing flag names and values,
% indicating which post-processing steps were taken when importing the
% scene.
%
% [scene, elements, postFlags] = mexximpCleanImport(sceneFile, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('sceneFile', @ischar);
parser.addParameter('ignoreRootTransform', true, @islogical);
parser.addParameter('toReplace', {}, @iscellstr);
parser.addParameter('targetFormat', 'png', @ischar);
parser.addParameter('imagemagicImage', 'rendertoolbox/imagemagick', @ischar);
parser.addParameter('workingFolder', '', @ischar);
parser.addParameter('strictMatching', false, @islogical);
parser.addParameter('useMatlabPath', false, @islogical);
parser.addParameter('options', '', @ischar);
parser.parse(sceneFile, varargin{:});
sceneFile = parser.Results.sceneFile;
ignoreRootTransform = parser.Results.ignoreRootTransform;
toReplace = parser.Results.toReplace;
targetFormat = parser.Results.targetFormat;
imagemagicImage = parser.Results.imagemagicImage;
workingFolder = parser.Results.workingFolder;
strictMatching = parser.Results.strictMatching;
useMatlabPath = parser.Results.useMatlabPath;
options = parser.Results.options;

%% Parse postprocessing flags.
flagParser = inputParser();
flagParser.StructExpand = true;
flagParser.KeepUnmatched = true;

% get flag names from mexximp mex-function itself
flags = mexximpConstants('postprocessStep');
flagNames = fieldnames(flags);
for ff = 1:numel(flagNames)
    flagParser.addParameter(flagNames{ff}, false, @islogical);
end

% Assimp to the max!  Handy post-processing steps.
defaultFlags.calculateTangentSpace = true;
defaultFlags.joinIdenticalVertices = true;
defaultFlags.triangulate = true;
defaultFlags.generateNormals = true;
defaultFlags.validateDataStructure = true;
defaultFlags.fixInfacingNormals = true;
defaultFlags.findInvalidData = true;
defaultFlags.generateUVCoordinates = true;

% combine defaults and given flags
flagParser.parse(defaultFlags, varargin{:});
postFlags = flagParser.Results;

%% Import the scene.
scene = mexximpImport(sceneFile, postFlags);


%% Fix up the node hierarchy.
% sometimes Assimp gives us a misleading root node transform
%   for example with "Z_UP" Collada exported from Blender
if ignoreRootTransform
    scene.rootNode.transformation = mexximpIdentity();
end

% reshape the node hierarchy to a consistent, "flat" form
scene.rootNode = mexximpFlattenNodes(scene);


%% Locate specific scene elements.
elements = mexximpSceneElements(scene);

%% Repair file references in the scene?
if ~isempty(workingFolder)
    mightBeFile = @(s) ischar(s) && 1 <= sum('.' == s);
    sceneFolder = fileparts(sceneFile);
    filesToMatch = mexximpCollectFiles(sceneFolder);
    scene = mexximpVisitStructFields(scene, @mexximpResolveResource, ...
        'filterFunction', mightBeFile, ...
        'ignoreFields', {'rootNode', 'embeddedTextures', 'meshes', 'lights', 'cameras'}, ...
        'visitArgs', { ...
        'sourceFolder', sceneFolder, ...
        'sourceFiles', filesToMatch, ...
        'useMatlabPath', useMatlabPath, ...
        'strictMatching', strictMatching, ...
        'outputFolder', workingFolder});
end

%% Recode images?
if ~isempty(toReplace)
    mightBeFile = @(s) ischar(s) && 1 <= sum('.' == s);
    if isempty(workingFolder)
        sceneFolder = fileparts(sceneFile);
    else
        sceneFolder = workingFolder;
    end
    scene = mexximpVisitStructFields(scene, @mexximpRecodeImage, ...
        'filterFunction', mightBeFile, ...
        'ignoreFields', {'rootNode', 'embeddedTextures', 'meshes', 'lights', 'cameras'}, ...
        'visitArgs', { ...
        'sceneFolder', sceneFolder, ...
        'toReplace', toReplace, ...
        'targetFormat', targetFormat, ...
        'skipExisting', true, ...
        'imagemagicImage', imagemagicImage,...
        'options', options});
end

