clear;
clc;

%% Choose source and library files.
source = 'mexximp_test.cc mexximp_util.cc';
output = '-output mexximpTest';

INC = '-I/usr/local/include';
LINC = '-L/usr/local/lib';
LIBS = '-lassimp';

%% Build the function.
mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Run it.
mexximpTest();

for ii = 0:100
    in = 1:ii;
    out = mexximpTest('vec3', in);
    disp(in)
    disp(out)
end