function makeMexximp(varargin)
% Build the mexximp mex-functions.
%
% These instructions are for Linux.  Should be similar for OS X.  Windows?
%
% Mexximp depends on Assimp being installed.  For full Collada support you
% should get Assimp 3.1.1 or later.
%   - http://www.assimp.org/main_downloads.html
%   - https://github.com/assimp/assimp
%
% You may need to build Assimp from source in order to get the latest
% version.  This was easy for me on Linux:
%   - Unzip or clone the source
%   - cd to source folder
%   - cmake CMakeLists.txt -G 'Unix Makefiles'
%   - make
%
% On OS X, it should be as easy as:
%   - brew install assimp
%
% With Assimp installed, you can run this Matlab script to build the
% mexximp mex-functions.  You should run this script from the mexximp root
% folder.
%
% Once this function completes, you should run the tests in the test
% folder.  You can als try an example, like the one in
% examples/scratch/exportTestScene.m.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('outputFolder', fullfile(pwd(), 'build'), @ischar);
parser.addParameter('clean', true, @islogical);
parser.addParameter('addOutputToPath', true, @islogical);
parser.addParameter('includePaths', '-I/usr/local/include', @ischar);
parser.addParameter('libPaths', '-L/usr/local/lib', @ischar);
parser.addParameter('libs', '-lassimp', @ischar);
parser.parse(varargin{:});
outputFolder = parser.Results.outputFolder;
clean = parser.Results.clean;
addOutputToPath = parser.Results.addOutputToPath;
includePaths = parser.Results.includePaths;
libPaths = parser.Results.libPaths;
libs = parser.Results.libs;


%% Set up build folder.
outputFolderExists = 7 == exist(outputFolder, 'dir');
if clean && outputFolderExists
    rmdir(outputFolder, 's');
end

if ~outputFolderExists
    mkdir(outputFolder);
end

if addOutputToPath && isempty(strfind(path(), outputFolder))
    addpath(outputFolder, '-begin');
end


%% Build a utility for getting string constants and default structs.
source = which('mexximp_constants.cc');
output = sprintf('-output %s', fullfile(outputFolder, 'mexximpConstants'));

mexCmd = sprintf('mex -v %s %s %s %s %s', includePaths, libPaths, libs, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);


%% Build a utility for testing mexximp internals.
source = [which('mexximp_test.cc') ' ' which('mexximp_util.cc') ' ' which('mexximp_scene.cc')];
output = sprintf('-output %s', fullfile(outputFolder, 'mexximpTest'));

mexCmd = sprintf('mex %s %s %s %s %s', includePaths, libPaths, libs, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);


%% Build the importer.
source = [which('mexximp_import.cc') ' ' which('mexximp_util.cc') ' ' which('mexximp_scene.cc')];
output = sprintf('-output %s', fullfile(outputFolder, 'mexximpImport'));

mexCmd = sprintf('mex %s %s %s %s %s', includePaths, libPaths, libs, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);


%% Build the exporter.
source = [which('mexximp_export.cc') ' ' which('mexximp_util.cc') ' ' which('mexximp_scene.cc')];
output = sprintf('-output %s', fullfile(outputFolder, 'mexximpExport'));

mexCmd = sprintf('mex %s %s %s %s %s', includePaths, libPaths, libs, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);
