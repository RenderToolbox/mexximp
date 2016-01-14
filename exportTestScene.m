% Sandbox to export the test sene from makeTestScene()

clear;
clc;

scene = makeTestScene();
format = 'collada';
sceneFile = 'test-export.dae';
status = mexximpExport(scene, format, sceneFile, []);
status
