clear;
clc;

%% Choose library files.
INC = '-I/usr/local/include';
LINC = '-L/usr/local/lib';
LIBS = '-lassimp';

%% Set up build folder.
buildFolder = fullfile(pwd(), 'build');
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
