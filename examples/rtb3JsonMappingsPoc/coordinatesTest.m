%% Proof of concept for CoordinatesTest with JSON mappings and Mexximp.
%
%   This script is an attempt to reproduce our original RenderToolbox3
%   CoordinatesTest example scene, using some new infrastructure:
%       - our new Assimp/mexximp scene import er
%       - JSON mappings syntax and processing
%       - mappings with eval()able expressions as operators
%       - mPbrt object-oriented model for building and writing PBRT scenes
%
%   This won't reproduce all of our existing infrastructure.  For example,
%   it won't do any Conditions File processing.  But it should tell whether
%   the new stuff will work.
%
%   Compare the output to the PBRT output from MakeCoordinatesTest.m
%
% BSH

%% Render with all default mappings.
clear;
clc;

fov = 77.31962 * pi() / 180;
pbrt = '/home/ben/render/pbrt/pbrt-v2-spectral/src/bin/pbrt';

originalScene = which('CoordinatesTest.blend');
pocRender(originalScene, '', ...
    'imageWidth', 320, ...
    'imageHeight', 240, ...
    'fov', fov, ...
    'pbrt', pbrt);

originalScene = which('CoordinatesTest.dae');
pocRender(originalScene, '', ...
    'imageWidth', 320, ...
    'imageHeight', 240, ...
    'fov', fov, ...
    'pbrt', pbrt);
