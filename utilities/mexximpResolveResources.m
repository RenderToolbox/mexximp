function [scene, info] = mexximpResolveResources(scene, varargin)
%% Resolve file resources mentioned in the given scene.
%
% The idea here is to scan the scene for file references and clean up those
% reference so that they point to existing local files.  This is
% useful because "wild" scenes from the web often contain:
%   - renferences to non-existent files
%   - absolute file paths from another computer
%   - truncated file names
%   - file names with the wrong CASE
%   - file names with non-ASCII characters
%   - etc.
% These are all a pain in the neck, but many of these can be resolved
% automatically.
%
% scene = mexximpResolveResources(scene) attempts to do fuzzy matching
% between files mentioned in the given scene and files found in pwd().
% When a match is found, the references in the scene will be updated.
%
% mexximpResolveResources( ... 'resourceFolder', resourceFolder) specifies
% a folder to search for local existing files.  The default is pwd().
%
% mexximpResolveResources( ... 'writeFullPaths', writeFullPaths) choose
% whether to update the given scene with full, absolute paths to resource
% files (true), or to write just file names without any leading path
% (false).  The default is true, write full, absolute paths.
%
% mexximpResolveResources( ... 'toReplace', toReplace)
% specifies a string containing characters to be replaced in resource file
% names.  When found, these characters will be replaced with "_"
% underscores.  This is useful to prevent Assimp from transcoding non-ASCII
% characters.  For example, Assimp transcodes "-" as "%2d", which is good
% for UTF-8, but breaks some downstream programs like PBRT and Mitsuba.
% The default is '-:', replace hyphens and colons with underscores.
%
% mexximpResolveResources( ... 'copyOnReplace', copyOnReplace) choose
% whether to copy files when their names contain replaced characters (true)
% or not (false).  This is useful so that renamed resources will point to
% existing files.  The default is true, make new copies or resource files
% as their names are replaced.
%
% Returns the given scene, with modifications.  Also returns a struct array
% of information about all resources mentioned in the given scene.  For
% example, which local existing file was matched to each mentioned file, if
% any, and what file names were updated in the returned scene.
%
% [scene, info] = mexximpResolveResources(scene, varargin)
%
% Copyright (c) 2016 mexximp Teame

parser = rdtInputParser();
parser.addRequired('scene', @isstruct);
parser.addParameter('resourceFolder', pwd(), @ischar);
parser.addParameter('writeFullPaths', true, @logical);
parser.addParameter('toReplace', '-:', @ischar);
parser.addParameter('copyOnReplace', true, @logical);
parser.parse(scene, varargin{:});
scene = parser.Results.scene;
resourceFolder = parser.Results.resourceFolder;
writeFullPaths = parser.Results.writeFullPaths;
toReplace = parser.Results.toReplace;
copyOnReplace = parser.Results.copyOnReplace;

%% Collect files in the resourceFolder.
resourceDir = dir(resourceFolder);
isDir = [resourceDir.isdir];
resources = {resourceDir(~isDir).name};

%% Fix up material resource files and file names.
nMaterials = numel(scene.materials);
materialCell = cell(1, nMaterials);
for mm = 1:nMaterials
    nProperties = numel(scene.materials(mm).properties);
    propertyCell = cell(1, nProperties);
    for pp = 1:nProperties
        
        % treat any strings that contain dots as file mentions
        property = scene.materials(mm).properties(pp);
        if ~strcmp('string', property.dataType) || ~any('.' == property.data);
            continue;
        end
                
        % try to find a local resource match
        mentionedFile = property.data;
        resourceMatch = matchResource(mentionedFile, resources);
        if isempty(resourceMatch)
            % report an unmatched file
            fileInfo.verbatimName = mentionedFile;
            fileInfo.writtenName = mentionedFile;
            fileInfo.isMatched = false;
            fileInfo.matchName = '';
            fileInfo.matchFullPath = '';
            propertyCell{pp} = fileInfo;
            continue;
        end
        
        % replace unwanted characters
        newName = replaceCharacters(resourceMatch, toReplace);
        if copyOnReplace && ~isempty(newName)
            source = fullfile(resourceFolder, resourceMatch);
            destination = fullfile(resourceFolder, newName);
            copyfile(source, destination, 'f');
            resourceMatch = newName;
        end
        
        % update the scene with the local, existing file name
        resourceFullPath = fullfile(resourceFolder, resourceMatch);
        if writeFullPaths
            writtenName = resourceFullPath;
        else
            writtenName = resourceMatch;
        end
        scene.materials(mm).properties(pp).data = writtenName;

        % report a successful match
        fileInfo.verbatimName = mentionedFile;
        fileInfo.writtenName = writtenName;
        fileInfo.isMatched = true;
        fileInfo.matchName = resourceMatch;
        fileInfo.matchFullPath = resourceFullPath;
        propertyCell{pp} = fileInfo;
    end
    
    materialCell{mm} = [propertyCell{:}];
end

% ignore duplicate file mentions
info = [materialCell{:}];
if isempty(info)
    return;
end
[~, selector] = unique({info.verbatimName});
info = info(selector);

%% Find unwanted characters and replace with underscores.
function newName = replaceCharacters(name, toReplace)
newName = '';
needsReplacement = false(1, numel(name));
for ii = 1:numel(toReplace)
    needsReplacement = needsReplacement | toReplace(ii) == name;
end
if any(needsReplacement)
    newName = name;
    newName(needsReplacement) = '_';
end

%% Iterate resources and try to match against a given file.
function resourceMatch = matchResource(mentionedFile, resources)
resourceMatch = '';
nResources = numel(resources);
for ii = 1:nResources
    resource = resources{ii};
    if fuzzyMatch(mentionedFile, resource)
        resourceMatch = resource;
        return;
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

