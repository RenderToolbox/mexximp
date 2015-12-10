clear;
clc;

%% Choose source and library files.
source = 'mexximp_test.cc mexximp_util.cc mexximp_scene.cc';
output = '-output mexximpTest';

INC = '-I/usr/local/include';
LINC = '-L/usr/local/lib';
LIBS = '-lassimp';

%% Build the function.
mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Test it.
runtests('MexximpSceneTests/testCamerasRoundTrip');
%runtests();
