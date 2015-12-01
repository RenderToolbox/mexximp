clear;
clc;

%% Choose source and library files.
source = 'mexximp.cpp';
output = '-output mexximp';

INC = '-I/usr/local/include/assimp';
LINC = '-L/usr/local/lib';
LIBS = '-lassimp';

%% Build the function.
mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Run it.
mexximp();
mexximp('notcare');
mexximp('Dragon.dae');
