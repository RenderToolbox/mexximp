function [outputFile, isFound] = mexximpResolveResource(resourceFile, varargin)
%% Locate a file referenced from a scene, among files that really exist.
%
% The idea here is to resolve file references and clean up those reference
% so that they point to files that really exist, locally.  This is  useful
% because "wild" scenes from the web often contain:
%   - renferences to non-existent files
%   - absolute file paths from another computer
%   - truncated file names
%   - file names with the wrong CASE
%   - file names with non-ASCII characters
%   - etc.
% These are all a pain in the neck, but many of these can be resolved
% automatically.
%
% [outputFile, isUpdated] = mexximpResolveResource(resourceFile) attempts
% to do fuzzy matching between the given fileName and local files found
% within pwd() or the given sourceFolder.
%
% If a match is found, returns the path to the local file, relative to
% pwd() or the given sourceFolder. Otherwise, returns the given
% resourceFile as-is. Also returns a flag indicating whether or not a match
% was found. 
%
% mexximpResolveResource( ... 'sourceFolder', sourceFolder) specify the folder to
% search for local files.  The default is pwd().
%
% mexximpResolveResource( ... 'useMatlabPath', useMatlabPath) whether or
% not to look for resource matches on the Matlab path, in addition to pwd()
% or the given sourceFolder.  This only works when outputFolder is
% provided, so that the resolved resource can be copied and refered to by
% relative path.  The default is false, don't use the Matlab path.
%
% mexximpResolveResource( ... 'strictMatching', strictMatching) whether to
% perform exact file name matching (true) or fuzzy matching, which is more
% permissive and less accurate (false).  The default is false, do
% permissive fuzzy matching.
%
% mexximpResolveResource( ... 'outputFolder', outputFolder) specify a
% folder to receive a copy of the resource file if a match is found.  In
% this case the returned file path will be relative to the
% destinationFolder.  The default is '', don't relocate resource files.
%
% mexximpResolveResource( ... 'outputPrefix', outputPrefix) specify a path
% prefix to prepend to the output path if a match is found.  This is useful
% if you want to build a scene that refers to resources in a path relative
% to the scene file.  This only works when outputFolder is provided.  The
% default is '', don't prepend any prefix.
%
% mexximpResolveResource( ... 'outputReplaceCharacters', outputReplaceCharacters)
% specify a string containing characters that should be replaced in the
% output path if a match is found.  When found, these characters will be
% replaced with underscores "_".  This is useful when integrating various
% programs that prefer different character sets.  The default is '-:',
% replace hyphens and colons with underscores.
%
% mexximpResolveResource( ... 'outputReplaceWith', outputReplaceWith)
% specify the character to use when replacing outputReplaceCharacters.  The
% default is the underscore "_".
%
% [outputFile, isFound] = mexximpResolveResource(resourceFile, varargin)
%
% Copyright (c) 2017 mexximp Team

parser = inputParser();
parser.addRequired('resourceFile', @ischar);
parser.addParameter('sourceFolder', pwd(), @ischar);
parser.addParameter('useMatlabPath', false, @islogical);
parser.addParameter('strictMatching', false, @islogical);
parser.addParameter('outputFolder', '', @ischar);
parser.addParameter('outputPrefix', '', @ischar);
parser.addParameter('outputReplaceCharacters', '-:', @ischar);
parser.addParameter('outputReplaceWith', '_', @ischar);
parser.parse(resourceFile, varargin{:});
resourceFile = parser.Results.resourceFile;
sourceFolder = parser.Results.sourceFolder;
useMatlabPath = parser.Results.useMatlabPath;
strictMatching = parser.Results.strictMatching;
outputFolder = parser.Results.outputFolder;
outputPrefix = parser.Results.outputPrefix;
outputReplaceCharacters = parser.Results.outputReplaceCharacters;
outputReplaceWith = parser.Results.outputReplaceWith;

if strictMatching
    matchFunction = @strictMatch;
else
    matchFunction = @fuzzyMatch;
end


%% Find a match for the given resourceFile.
[~, resourceBase, resourceExt] = fileparts(resourceFile);

% look in sourceFolder
sourceFiles = mexximpCollectFiles(sourceFolder);
matchRelativePath = '';
matchFolder = '';
nSources = numel(sourceFiles);
for ss = 1:nSources
    [~, sourceBase, sourceExt] = fileparts(sourceFiles{ss});
    if feval(matchFunction, resourceBase, resourceExt, sourceBase, sourceExt);
        matchRelativePath = sourceFiles{ss};
        matchFolder = sourceFolder;
        break;
    end
end

% look on Matlab path?
if isempty(matchRelativePath) && useMatlabPath && ~isempty(outputFolder)
    pathMatch = which([resourceBase resourceExt]);
    [matchFolder, matchBase, matchExt] = fileparts(pathMatch);
    matchRelativePath = [matchBase matchExt];
end

if isempty(matchRelativePath)
    % no match found
    outputFile = resourceFile;
    isFound = false;
    return;
end


%% Choose a new name for the matched file.
matchRelativePathReplaced = replaceCharacters(matchRelativePath, outputReplaceCharacters, outputReplaceWith);

if isempty(outputFolder)
    % output in the same place where it was found
    outputFile = matchRelativePathReplaced;
    outputFullPath = fullfile(matchFolder, matchRelativePathReplaced);
else
    % flatten output into given outputRoot
    [~, outputBase, outputExt] = fileparts(matchRelativePathReplaced);
    outputFile = fullfile(outputPrefix, [outputBase outputExt]);
    outputFullPath = fullfile(outputFolder, outputFile);
end


%% Create a copy of the resource file with new name and location.
if 2 ~= exist(outputFullPath, 'file')
    
    % create output parent folder as needed
    outputParent = fileparts(outputFullPath);
    if 7 ~= exist(outputParent, 'dir')
        mkdir(outputParent);
    end
    
    matchFullPath = fullfile(matchFolder, matchRelativePath);
    copyfile(matchFullPath, outputFullPath, 'f');
end

isFound = true;


%% Find unwanted characters and replace.
function newName = replaceCharacters(name, toReplace, replaceWith)
newName = name;

% OR together masks from replacement character matches
needsReplacement = false(1, numel(name));
for ii = 1:numel(toReplace)
    needsReplacement = needsReplacement | toReplace(ii) == name;
end

% replace at the mask
if any(needsReplacement)
    newName(needsReplacement) = replaceWith;
end


%% Fuzzy matching for file names: is b seems reasonably simialar to a.
function isMatch = fuzzyMatch(aBase, aExt, bBase, bExt)
% case insensitive
aBase = lower(aBase);
aExt = lower(aExt);
bBase = lower(bBase);
bExt = lower(bExt);

% one base name is a substring of the other
baseMatch = ~isempty(strfind(aBase, bBase)) || ~isempty(strfind(bBase, aBase));

% one extension is a substring of the other
extMatch = ~isempty(strfind(aExt, bExt)) || ~isempty(strfind(bExt, aExt));

isMatch = baseMatch && extMatch;


%% Strict matching for file names: b is the same as a.
function isMatch = strictMatch(aBase, aExt, bBase, bExt)

% base names and extensions match
isMatch = strcmpi(aBase, bBase) && strcmpi(aExt, bExt);
