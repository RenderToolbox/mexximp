function [recodedFile, isRecoded, info] = mexximpRecodeImage(imageFile, varargin)
%% Rewrite an image of an unwanted format to a preferred format.
%
% The idea here is to re-write an image file to some useful type, and
% return info about the new file.  This usually uses Matlab's built-in
% imread() and imwrite().
%
% For OpenEXR images, attempts to use the system utility exrtools:
%   http://scanline.ca/exrtools/
% If exrtools is not present, attempts to invoke the Docker image
% ninjaben/exrtools
%   https://hub.docker.com/r/ninjaben/exrtools
%
% [recodedFile, info] = rtbRecodeImage(imageFile) checks the given
% imageFile of to see if it's of an unwanted type.  If so, re-codes the
% image to a desirable type.
%
% rtbRecodeImage( ... 'toReplace', toReplace) specifies a cell array
% of file extensions (see imformats()) for unwanted images types that
% should be re-coded.  The default is {'gif'}, replace only GIF images.
%
% rtbRecodeImage( ... 'targetFormat', targetFormat) specifies the
% file extension of the desirable image format that should be used when
% re-coding the given image.  The default is 'png', recode the image as a
% PNG.
%
% rtbRecodeImage( ... 'sceneFolder', sceneFolder) specifies the folder where
% to search for the given imageFile, in case imageFile contains a relative
% path.  The default is pwd().
%
% rtbRecodeImage( ... 'workingFolder', workingFolder) specifies the folder
% where write recoded image files, the default is pwd().
%
% rtbRecodeImage( ... 'exrtoolsImage', exrtoolsImage) specifies the name of a
% docker image that contains exrtools.  The default is 'ninjaben/exrtools'.
%
% Returns the given imageFile name, scene, which may have been changed to a
% new name.  Also returns a logical flag true when the given imageFile was
% recoded. Also returns a struct with info about the recoding process.
%
% See also imformats
%
% [imageFile, isRecoded, info] = rtbRecodeImage(imageFile, varargin)
%
% Copyright (c) 2016 mexximp Teame

parser = inputParser();
parser.addRequired('imageFile', @ischar);
parser.addParameter('toReplace', {'gif'}, @iscellstr);
parser.addParameter('targetFormat', 'png', @ischar);
parser.addParameter('sceneFolder', pwd(), @ischar);
parser.addParameter('workingFolder', pwd(), @ischar);
parser.addParameter('exrtoolsImage', 'ninjaben/exrtools', @ischar);
parser.parse(imageFile, varargin{:});
imageFile = parser.Results.imageFile;
toReplace = parser.Results.toReplace;
targetFormat = parser.Results.targetFormat;
sceneFolder = parser.Results.sceneFolder;
workingFolder = parser.Results.workingFolder;
exrtoolsImage = parser.Results.exrtoolsImage;

isRecoded = false;

%% Do we need to recode this image?
[imagePath, imageBase, imageExt] = fileparts(imageFile);
if ~any(strcmp(toReplace, imageExt(2:end)))
    info.verbatimName = imageFile;
    info.recodedFile = '';
    info.recodedFile = '';
    info.isRead = false;
    info.isWritten = false;
    info.error = [];
    return;
end

%% Try to locate the image.
if 2 == exist(imageFile, 'file')
    % given as absolute path
    originalPath = imageFile;
else
    % given as relative to sceneFolder
    originalPath = fullfile(sceneFolder, imageFile);
end

%% Try to recode the image.
recodedFile = fullfile(imagePath, [imageBase '.' targetFormat]);
recodedPath = fullfile(workingFolder, recodedFile);
recodedFolder = fullfile(workingFolder, imagePath);
if 7 ~= exist(recodedFolder, 'dir')
    mkdir(recodedFolder);
end

if strcmp(targetFormat, 'exr') || strcmp(imageExt(2:end), 'exr')
    % with exrtools
    try
        recodedPath = mexximpExrTools(originalPath, ...
            'exrtoolsImage', exrtoolsImage, ...
            'outFile', recodedPath);
        
    catch ex
        % report an unreadable file
        info.verbatimName = imageFile;
        info.recodedFile = '';
        info.recodedPath = '';
        info.isRead = false;
        info.isWritten = false;
        info.error = ex;
        return;
    end
    
else
    % with imread()/imwrite()
    try
        [imageData, colorMap] = imread(originalPath);
    catch ex
        % report an unreadable file
        info.verbatimName = imageFile;
        info.recodedFile = '';
        info.recodedPath = '';
        info.isRead = false;
        info.isWritten = false;
        info.error = ex;
        return;
    end
    
    try
        if isempty(colorMap)
            imwrite(imageData, recodedPath, targetFormat);
        else
            imwrite(imageData, colorMap, recodedPath, targetFormat);
        end
    catch ex
        % report an unwritten file
        info.verbatimName = imageFile;
        info.recodedFile = recodedFile;
        info.recodedPath = recodedPath;
        info.isRead = true;
        info.isWritten = false;
        info.error = ex;
        return;
    end
end

%% Report success.
isRecoded = true;
info.verbatimName = imageFile;
info.recodedFile = recodedFile;
info.recodedPath = recodedPath;
info.isRead = true;
info.isWritten = true;
info.error = [];
