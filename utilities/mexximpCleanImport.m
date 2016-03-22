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
parser.addRequired('sceneFile', @ischar);
parser.parse(sceneFile);
sceneFile = parser.Results.sceneFile;

%% Parse postprocessing flags.
flagParser = inputParser();
flagParser.StructExpand = true;

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

% reshape the node hierarchy to a consistent, "flat" form
scene.rootNode = mexximpFlattenNodes(scene);

% get an easy-to-iterate array of all scene elements
elements = mexximpSceneElements(scene);