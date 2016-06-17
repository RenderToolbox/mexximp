% Example of creating a scene from scratch using mexximp.
%
% This example creates a mexximp scene from scratch.  It uses the function
% makeTestScene() to create a plain old Matlab struct with the correct
% fields expected by mexximp.
%
% Then it uses mexximp and Assimp to export the scene to a Collada file.
%
% You can view the Collada file directly in the Matlab editor.  Or you can
% open it with an external program like Blender.
%
% 2016 benjamin.heasly@gmail.com


%% Make and export the scene.
clear;
clc;

pathHere = fileparts(which('exportTestScene.m'));

scene = makeTestScene();
format = 'collada';
colladaFile = fullfile(pathHere, 'test-export.dae');
status = mexximpExport(scene, format, colladaFile, []);

%% Look at the XML Collada document.
edit(colladaFile);
