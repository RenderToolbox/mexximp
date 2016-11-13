function [outFile, result] = mexximpExrTools(inFile, varargin)
%% Rewrite an image using the exrtool utility.
%
% This is a Matlab wrapper around the "exrtool" Linux utility, for
% converting and manipulating OpenExr images.  This wrapper will attempt to
% invoke a Dockerized version of exrtool.  If Docker doesn't work, it will
% attempt to invoke a local install of exrtool.
%  http://scanline.ca/exrtools/
%  https://hub.docker.com/r/ninjaben/exrtools
%
% outFile = mexximpExrTools(inFile) will attempt image
% conversion based on the type of the given inFile.  If inFile is a
% jpeg, png, or ppm, will attempt to convert to exr and return the name of
% the new exr file.  If inFile is an exr file, will convert to png.
%
% rtbRecodeImage( ... 'operation', operation) specify which exrtool
% operation to apply to the given inFile.  The default is chosen based
% on the type of inFile.  The allowed operations correspond to the
% exrtool executables.  From the exrtool the documentation:
%   - exrblur - Applies a gaussian blur to an image.
%   - exrchr - Applies spatially-varying chromatic adaptation to an image.
%   - exricamtm - Performs tone mapping using the iCAM method.
%   - exrnlm - Performs non-linear masking correction to an image.
%   - exrnormalize - Normalize an image.
%   - exrpptm - Performs tone mapping using the photoreceptor physiology method.
%   - exrstats - Displays statistics about an image.
%   - exrtopng - Converts an image to PNG format.
%   - jpegtoexr - Converts an image to EXR format from JPEG.
%   - pngtoexr - Converts an image to EXR format from PNG.
%   - ppmtoexr - Converts an image to EXR format from PPM. Works with the
%   16 bit per channel PPM files from dcraw for digital cameras with RAW modes.
%
% rtbRecodeImage( ... 'options', options) specifies options to pass to
% the given operation, before the input file.  For example:
%   exrpptm [options] input.exr output.exr
%
% rtbRecodeImage( ... 'blurFile', blurFile) specifies a blur file to pass
% to the given operation, between the input and output files.  For example:
%   exricamtm input.exr blur.exr output.exr
%
% rtbRecodeImage( ... 'args', args) specifies arguments to pass to the
% given operation, after the output file.  For example:
%   exrnormalize input.exr output.exr [ maxval ]
%
% rtbRecodeImage( ... 'dockerImage', dockerImage) specifies the name of
% a docker image that contains exrtools.  The default is
% 'ninjaben/exrtools'.
%
% rtbRecodeImage( ... 'outFile', outFile) specifies the name of the output
% file to write.  The default is chosen from the given inputFile and
% operation.  The extension of outFile may be changes so that it agrees
% with the given operation.
%
% Copyright (c) 2016 mexximp team

parser = inputParser();
parser.addRequired('inFile', @ischar);
parser.addParameter('outFile', '', @ischar);
parser.addParameter('operation', '', @ischar);
parser.addParameter('options', '', @ischar);
parser.addParameter('blurFile', '', @ischar);
parser.addParameter('args', '', @ischar);
parser.addParameter('exrtoolsImage', 'ninjaben/exrtools-docker', @ischar);
parser.addParameter('podSelector', 'app=exrtools', @ischar);
parser.parse(inFile, varargin{:});
inFile = parser.Results.inFile;
outFile = parser.Results.outFile;
operation = parser.Results.operation;
options = parser.Results.options;
blurFile = parser.Results.blurFile;
args = parser.Results.args;
dockerImage = parser.Results.exrtoolsImage;
podSelector = parser.Results.podSelector;

%% Choose operation.
[inPath, inBase, inExt] = fileparts(inFile);
if isempty(operation)
    switch inExt(2:end)
        case {'jpeg', 'jpg'}
            operation = 'jpegtoexr';
        case 'png'
            operation = 'pngtoexr';
        case 'ppm'
            operation = 'ppmtoexr';
        case 'exr'
            operation = 'exrtopng';
        otherwise
            error('Unsupported exrtool input file type "%s".', inExt);
    end
end

%% Choose outFile.
if isempty(outFile)
    outPath = inPath;
    outBase = inBase;
else
    [outPath, outBase] = fileparts(outFile);
end
switch operation
    case {'exrblur', 'exrchr', 'exricamtm', 'exrnlm', 'exrnormalize', ...
            'exrpptm', 'jpegtoexr', 'pngtoexr', 'ppmtoexr'}
        outExt = '.exr';
    case {'exrtopng'}
        outExt = '.png';
    case {'exrstats'}
        outExt = '';
    otherwise
        error('Unsupported exrtool operation "%s".', operation);
end
outFile = fullfile(outPath, [outBase outExt]);

%% Locate exrtools.
[status, ~] = system(['docker pull ' dockerImage]);
[kubeStatus, ~] = system('kubectl version --client');
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
    
    
elseif 0 == kubeStatus
    podCommand = sprintf('kubectl get pods --selector="%s" -o jsonpath=''{.items[0].metadata.name}''', ...
        podSelector);
    [status, podName] = system(podCommand);
    if 0 ~= status
        error('Could not locate Kubernetes pod with selector "%s"', podSelector);
    end
    podName = strtrim(podName);
    commandPrefix = sprintf('kubectl exec %s -- ', podName);
    
else
    % try local install
    [status, result] = system('which exrblur');
    if 0 ~= status
        error('Could not locate local install of exrtools: %s', result);
    end
    commandPrefix = strtrim(result);
end

%% Convert the image.
command = sprintf('%s%s %s %s %s %s %s', ...
    commandPrefix, ...
    operation, ...
    options, ...
    inFile, ...
    blurFile, ...
    outFile, ...
    args);
disp(command)
[status, result] = system(command);
if 0 ~= status
    error('exrtool operation failed: "%s".', result);
end
