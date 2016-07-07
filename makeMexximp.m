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
% mexximp mex-functions.   This script will also run some tests on the
% functions as it goes.
%
% You should run this script from the mexximp root folder.
%
% Once this function completes, you can try an example, like the one in
% examples/scratch/exportTestScene.m.
%
% 2016 benjamin.heasly@gmail.com

% TODO: would like to make mexximp relocatable so that we can distribute
% the mex function along with libassimp and not make people buld assimp
% themselves.  If we download a libassimp somwhere we can add this path to
% LD_LIBRARY_PATH, and the linker should find it there.  We hate
% LD_LIBRARY_PATH, but this is how Matlab manages its own dependencies, so
% we may just roll with it.
%
% If we're using the Toolbox Toolbox, we can obtain libassimp as a
% "download" toolbox.  It can have a hook to add the correct path to
% LD_LIBRARY_PATH.
%
% It's too bad we can't build and execute mex functions in Docker
% container.

%% Choose library files.
clear;

INC = '-I/usr/local/include';
LINC = '-L/usr/local/lib';
LIBS = '-lassimp';

%% Set up build folder.
pathHere = fileparts(which('makeMexximp'));
cd(pathHere);

buildFolder = fullfile(pathHere, 'build');
if 7 ~= exist(buildFolder, 'dir')
    mkdir(buildFolder);
end

if isempty(strfind(path(), buildFolder))
    addpath(buildFolder);
end

%% Build a utility for getting string constants and default structs.
source = 'src/mexximp_constants.cc';
output = '-output build/mexximpConstants';

mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Build a utility for testing mexximp internals.
source = 'src/mexximp_test.cc src/mexximp_util.cc src/mexximp_scene.cc';
output = '-output build/mexximpTest';

mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Test mexximp internals.
runtests('test/MexximpUtilTests.m');
runtests('test/MexximpSceneTests.m');

%% Build the importer.
source = 'src/mexximp_import.cc src/mexximp_util.cc src/mexximp_scene.cc';
output = '-output build/mexximpImport';

mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Test the importer.
runtests('test/MexximpImportTests.m');

%% Build the exporter.
source = 'src/mexximp_export.cc src/mexximp_util.cc src/mexximp_scene.cc';
output = '-output build/mexximpExport';

mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Test the importer and exporter.
runtests('test/MexximpExportTests.m');
