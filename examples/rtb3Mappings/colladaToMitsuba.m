function mitsubaFile = colladaToMitsuba(colladaFile, mitsubaFile, mitsuba, hints)
%% Convert a Collada file to a mistuba file using mtsimport.
%
% mitsubaFile = colladaToMitsuba(colladaFile, mitsubaFile, mitsuba)
% uses the mtsimport executable from the given mitsuba.importer to convert
% the given colladaFile to a Mitsuba scene file.  The new scene file will
% be written at the given mitsubaFile.  Any auxiliary files will be created
% in the same folder as mitsubaFile.
%
% The new scene will use the given hints.imageWidth, hints.imageHeight, and
% hints.filmType.
%
% Returns the full path to the newly created Mitsuba scene file.
%
% mitsubaFile = colladaToMitsuba(colladaFile, mitsubaFile, mitsuba)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('colladaFile', @ischar);
parser.addRequired('mitsubaFile', @ischar);
parser.addRequired('mitsuba', @isstruct);
parser.addRequired('hints', @isstruct);
parser.parse(colladaFile, mitsubaFile, mitsuba, hints);
colladaFile = parser.Results.colladaFile;
mitsubaFile = parser.Results.mitsubaFile;
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
mitsubaFolder = fileparts(mitsubaFile);
if 7 ~= exist(mitsubaFolder, 'dir')
    mkdir(mitsubaFolder);
end

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
[status, result] = unixInFolder(importCommand, mitsubaFolder);
if status ~= 0
    error('colladaToMitsuba:conversionFailed', ...
        'Error converting Collada to Mitsuba:\n%s\n', result);
end

%% Execute in destination folder to collect all outputs there.
function [status, result] = unixInFolder(command, mitsubaFile)
originalFolder = pwd();
cd(mitsubaFile);
[status, result] = unix(command);
cd(originalFolder);
