function [outputFile, isRecoded] = mexximpRecodeImage(imageFile, varargin)
%% Rewrite an image of an unwanted format to a preferred format.
%
% The idea here is to re-write an image file to some useful type, and
% return info about the new file.  This usually uses Matlab's built-in
% imread() and imwrite().
%
% For OpenEXR images, attempts to use the Imagemagic convert utility.
% If convert is not present, attempts to invoke the Docker image
% hblasins/imagemagic-docker
%
% [outputFile, info] = rtbRecodeImage(imageFile) checks the given
% imageFile of to see if it's of an unwanted type.  If so, re-codes the
% image to a desirable type.  The recoded file will sit in the same folder
% as the given imageFile.
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
% rtbRecodeImage( ... 'sceneFolder', sceneFolder) specifies the folder
% where to search for the given imageFile, in case imageFile contains a
% relative path.  The default is pwd().
%
% rtbRecodeImage( ... 'imagemagicImage', imagemagicImage) specifies the
% name of a docker image that contains convert.  The default is
% 'hblasins/imagemagic-docker'.
%
% Returns the path to the recoded image file, or the original file if it
% was not recoded.  Also returns a flag indicating whether the image was
% recoded.
%
% See also imformats
%
% [outputFile, isRecoded] = mexximpRecodeImage(imageFile, varargin)
%
% Copyright (c) 2017 mexximp Team

parser = inputParser();
parser.addRequired('imageFile', @ischar);
parser.addParameter('toReplace', {'gif'}, @iscellstr);
parser.addParameter('targetFormat', 'png', @ischar);
parser.addParameter('sceneFolder', pwd(), @ischar);
parser.addParameter('imagemagicImage','hblasins/imagemagic-docker',@ischar);
parser.parse(imageFile, varargin{:});
imageFile = parser.Results.imageFile;
toReplace = parser.Results.toReplace;
targetFormat = parser.Results.targetFormat;
sceneFolder = parser.Results.sceneFolder;
imagemagicImage = parser.Results.imagemagicImage;


%% Do we need to recode this image?
[imagePath, imageBase, imageExt] = fileparts(imageFile);
if ~any(strcmp(toReplace, imageExt(2:end)))
    outputFile = imageFile;
    isRecoded = false;
    return;
end


%% Try to locate the image.
if 2 == exist(imageFile, 'file') && ~isempty(imagePath)
    % treat as absolute path
    % The first part of the condidion will also return true if the imageFile is on
    % Matlab path and the imageFile is just a file name. To eliminate this
    % condition we need to check if imageFile contains a a path.
    originalFile = imageFile;
    outputFile = fullfile(imagePath, [imageBase '.' targetFormat]);
else
    % treat as relative to sceneFolder
    originalFile = fullfile(sceneFolder, imageFile);
    outputFile = fullfile(sceneFolder, imagePath, [imageBase '.' targetFormat]);
end

%% Try to recode the image.
outputFolder = fileparts(outputFile);
if 7 ~= exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Recode the file only if it does not already exist.
% This saves time if the same texture file is referenced multiple times.
if 2 == exist(outputFile, 'file')
    fprintf('<%s>: Already recoded.\n', outputFile);
    
else
    
    if strcmp(targetFormat, 'exr') || strcmp(imageExt(2:end), 'exr')
        % with Imagemagic Convert tools
        try
            
            outputFile = mexximpConvertTools(originalFile, ...
                'imagemagicImage', imagemagicImage, ...
                'outFile', outputFile);
            
        catch ex
            % conversion error
            fprintf('Error using mexximpConvertTools: %s.\n', ex.message);
            outputFile = imageFile;
            isRecoded = false;
            return;
        end
        
    else
        % with imread()/imwrite()
        try
            [imageData, colorMap] = imread(originalFile);
        catch ex
            % report an unreadable file
            fprintf('Error using imread: %s.\n', ex.message);
            outputFile = imageFile;
            isRecoded = false;
            return;
        end
        
        try
            if isempty(colorMap)
                imwrite(imageData, outputFile, targetFormat);
            else
                imwrite(imageData, colorMap, outputFile, targetFormat);
            end
        catch ex
            % report an unwritable file
            fprintf('Error using imwrite: %s.\n', ex.message);
            outputFile = imageFile;
            isRecoded = false;
            return;
        end
    end
end

%% Report success.
isRecoded = true;
