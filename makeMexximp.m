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
data = mexximp('Dragon.dae');

%% Mess with it.
figure(1)
data = mexximp('Dragon.dae');
scatter3(data(1,:), data(2,:), data(3,:), '.');
view([5 75])

figure(2)
data = data + 0.5*rand(size(data)) - 0.25;
data = mexximp('Dragon.dae', data);
scatter3(data(1,:), data(2,:), data(3,:), '.');
view([5 75])
