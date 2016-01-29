function [scene, info] = mexximpRecodeImages(scene, varargin)
%% Rewrite images of unwanted formats to some preferred format.
%
% The idea here is to re-write image files to some useful type, and also
% update the scene to point to the new file.  This avoids having to edit
% the scene manually.  This uses Matlab's built-in imread() and imwrite().
%
% scene = mexximpRecodeImages(scene) scans the given scene for mentions of
% image files of unwanted types, re-codes the mentioned files to a
% different type, and updates the scene to refer to the new, re-coded
% images.
%
% mexximpRecodeImages( ... 'toReplace', toReplace) specifies a cell array
% of file extensions (see imformats()) for unwanted images that should be
% found, re-coded, and replaced.  The default is {'gif'}, replace GIF
% images.
%
% mexximpResolveResources( ... 'targetFormat', targetFormat) specifies the
% file extension of the image format that should be used when re-coding and
% replacing images.  The default is 'png', recode images as PNG images.
%
% Returns the given scene, with modifications.  Also returns a struct array
% of information about all images that were re-coded and replaced.
%
% See also mexximpResolveResources imformats
%
% [scene, info] = mexximpRecodeImages(scene, varargin)
%
% Copyright (c) 2016 mexximp Teame

parser = rdtInputParser();
parser.addRequired('scene', @isstruct);
parser.addParameter('toReplace', {'gif'}, @iscellstr);
parser.addParameter('targetFormat', 'png', @ischar);
parser.parse(scene, varargin{:});
scene = parser.Results.scene;
toReplace = parser.Results.toReplace;
targetFormat = parser.Results.targetFormat;

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
        
        % is this an image in an unwanted format?
        mentionedFile = property.data;
        [imagePath, imageBase, imageExt] = fileparts(mentionedFile);
        if ~any(strcmp(imageExt(2:end), toReplace))
            continue;
        end
        
        % try to read the image
        try
            [imageData, colorMap] = imread(mentionedFile);
        catch ex
            % report an unreadable file
            fileInfo.verbatimName = mentionedFile;
            fileInfo.writtenName = mentionedFile;
            fileInfo.isRead = false;
            fileInfo.isWritten = false;
            fileInfo.error = ex;
            propertyCell{pp} = fileInfo;
            continue;
        end
        
        % try to re-code the image
        try
            writtenName = fullfile(imagePath, [imageBase '.' targetFormat]);
            imwrite(imageData, colorMap, writtenName, targetFormat);
        catch ex
            % report an unwritten file
            fileInfo.verbatimName = mentionedFile;
            fileInfo.writtenName = mentionedFile;
            fileInfo.isRead = true;
            fileInfo.isWritten = false;
            fileInfo.error = ex;
            propertyCell{pp} = fileInfo;
            continue;
        end
        
        % update the scene
        scene.materials(mm).properties(pp).data = writtenName;
        
        % report success
        fileInfo.verbatimName = mentionedFile;
        fileInfo.writtenName = writtenName;
        fileInfo.isRead = true;
        fileInfo.isWritten = true;
        fileInfo.error = [];
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
