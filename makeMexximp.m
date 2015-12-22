clear;
clc;

%% Choose library files.
INC = '-I/usr/local/include';
LINC = '-L/usr/local/lib';
LIBS = '-lassimp';

%% Build a utility for getting string constants and default structs.
source = 'mexximp_constants.cc';
output = '-output mexximpConstants';

mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Build a utility for testing mexximp internals.
source = 'mexximp_test.cc mexximp_util.cc mexximp_scene.cc';
output = '-output mexximpTest';

mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Test mexximp internals.
runtests('MexximpUtilTests');
runtests('MexximpSceneTests');

%% Build the importer.
source = 'mexximp_import.cc mexximp_util.cc mexximp_scene.cc';
output = '-output mexximpImport';

mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Test the importer.
runtests('MexximpImportTests');

%% Build the exporter.
source = 'mexximp_export.cc mexximp_util.cc mexximp_scene.cc';
output = '-output mexximpExport';

mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Test the importer and exporter.
runtests('MexximpExportTests');
