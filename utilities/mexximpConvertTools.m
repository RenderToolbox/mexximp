function [outFile, result] = mexximpConvertTools(inFile, varargin)
%% Rewrite an image using the convert utility.
%
% This is a Matlab wrapper around the "convert" utility from Imagemagic, for
% converting between image formats.  This wrapper will attempt to
% invoke a Dockerized version of convert.  If Docker doesn't work, it will
% attempt to invoke a local install. Refer to:
% http://www.imagemagic.org
%
% outFile = mexximpConvertTools(inFile) will attempt image
% conversion based on the type of the given inFile.  If inFile is a
% jpeg, png, or ppm, will attempt to convert to exr and return the name of
% the new exr file.
%
% mexximpConvertTools( ... 'options', options) specifies options to pass to
% the given operation, before the input file.  For example:
%   convert input.exr [options] output.exr
%
% mexximpConvertTools( ... 'imagemagicImage', dockerImage) specifies the name of
% a docker image that contains imagemagic.  The default is
% 'hblasins/imagemagic-docker'.
%
% mexximpConvertTools( ... 'outFile', outFile) specifies the name of the output
% file to write.  The default is chosen from the given inputFile and
% operation.  The extension of outFile may be changes so that it agrees
% with the given operation.
%
% Copyright (c) 2016 mexximp team

parser = inputParser();
parser.addRequired('inFile', @ischar);
parser.addParameter('outFile', '', @ischar);
parser.addParameter('options', '', @ischar);
parser.addParameter('imagemagicImage', 'hblasins/imagemagic-docker', @ischar);
parser.parse(inFile, varargin{:});
inFile = parser.Results.inFile;
outFile = parser.Results.outFile;
options = parser.Results.options;
dockerImage = parser.Results.imagemagicImage;


%% Choose operation.
[inPath, inBase] = fileparts(inFile);


%% Choose outFile.
if isempty(outFile)
    outPath = inPath;
    outBase = inBase;
    outExt = '.exr';
else
    [outPath, outBase, outExt] = fileparts(outFile);
end


outFile = fullfile(outPath, [outBase outExt]);

%% Locate exrtools.
[status, ~] = system(['docker pull ' dockerImage]);
if 0 == status;
    % try running in Docker
    [~, uid] = system('id -u `whoami`');
    workDir = pwd();
    
    % When inPath == outPath
    if strcmp(inPath,outPath)
    
        % Don't map the same directory twice
        commandPrefix = sprintf('docker run --rm -u %s:%s -v "%s":"%s" -v "%s":"%s" -w "%s" %s ', ...
        strtrim(uid), strtrim(uid), ...
        outPath, outPath, ...
        workDir, workDir, ...
        workDir, ...
        dockerImage);
        
    else
        
        commandPrefix = sprintf('docker run --rm -u %s:%s -v "%s":"%s" -v "%s":"%s" -v "%s":"%s" -w "%s" %s ', ...
        strtrim(uid), strtrim(uid), ...
        inPath, inPath, ...
        outPath, outPath, ...
        workDir, workDir, ...
        workDir, ...
        dockerImage);
    
    end
    
else
    % try local install
    [status, result] = system('which exrblur');
    if 0 ~= status
        error('Could not locate local install of exrtools: %s', result);
    end
    commandPrefix = strtrim(result);
end

%% Convert the image.


command = sprintf('%sconvert "%s" %s "%s"', ...
    commandPrefix, ...
    inFile, ...
    options, ...
    outFile);

disp(command)
[status, result] = system(command);
if 0 ~= status
    error('convert operation failed: "%s".', result);
end
