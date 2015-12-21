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


%% Choose source and library files.
source = 'mexximp_test.cc mexximp_util.cc mexximp_scene.cc';
output = '-output mexximpTest';


%% Build the function.
mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Test it.
runtests()
