function mitsubaFile = colladaToMitsuba(colladaFile, destinationFolder, mitsuba, hints)
%% Convert a Collada file to a mistuba file using mtsimport.
%
% mitsubaFile = colladaToMitsuba(colladaFile, destinationFolder, mitsuba)
% uses the mtsimport executable from the given mitsuba.importer to convert
% the given colladaFile to a Mitsuba scene file.  The new scene file and
% any auxiliary files will be created in the given destinationFolder.
%
% The new scene will use the given hints.imageWidth, hints.imageHeight, and
% hints.filmType.
%
% Returns the full path to the newly created Mitsuba scene file.
%
% mitsubaFile = colladaToMitsuba(colladaFile, destinationFolder, mitsuba)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('colladaFile', @ischar);
parser.addRequired('destinationFolder', @ischar);
parser.addRequired('mitsuba', @isstruct);
parser.addRequired('hints', @isstruct);
parser.parse(colladaFile, destinationFolder, mitsuba, hints);
colladaFile = parser.Results.colladaFile;
destinationFolder = parser.Results.destinationFolder;
mitsuba = parser.Results.mitsuba;
hints = parser.Results.hints;

%% Choose default scene parameters.
if isempty(hints.filmType)
    hints.filmType = 'hdrfilm';
end

if isempty(hints.imageWidth)
    hints.imageWidth = '320';
end

if isempty(hints.imageHeight)
    hints.imageHeight = '240';
end

%% Create destination folder if needed.
if 7 ~= exist(destinationFolder, 'dir')
    mkdir(destinationFolder);
end

%% Choose the new file to create.
[~, colladaBase] = fileparts(colladaFile);
mitsubaFile = fullfile(destinationFolder, [colladaBase '.xml']);

%% Choose the system's linrary path variable name.
if isunix()
    libPathName = 'LD_LIBRARY_PATH';
elseif ismac()
    libPathName = 'DYLD_LIBRARY_PATH';
else
    libPathName = 'PATH';
end

%% Invoke the mtsimport executable.
executable = mitsuba.importer;
executablePath = fileparts(executable);

importCommand = sprintf('%s=%s %s -r %dx%d -l %s %s %s', ...
    libPathName, ...
    executablePath, ...
    executable, ...
    hints.imageWidth, hints.imageHeight, ...
    hints.filmType, ...
    colladaFile, ...
    mitsubaFile);

%disp(importCommand);
[status, result] = unixInFolder(importCommand, destinationFolder);
if status ~= 0
    error('colladaToMitsuba:conversionFailed', ...
        'Error converting Collada to Mitsuba:\n%s\n', result);
end

%% Execute in destination folder to collect all outputs there.
function [status, result] = unixInFolder(command, destinationFolder)
originalFolder = pwd();
cd(destinationFolder);
[status, result] = unix(command);
cd(originalFolder);
