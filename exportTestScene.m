% Sandbox to export the test scene from makeTestScene

%% Make and export the scene.
clear;
clc;

pathHere = '/home/ben/render/mexximp';

scene = makeTestScene();
format = 'collada';
colladaFile = fullfile(pathHere, 'test-export.dae');
status = mexximpExport(scene, format, colladaFile, []);

%% Try to render with RenderToolbox3!
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.recipeName = 'mexximpExportTest';
ChangeToWorkingFolder(hints);

setpref('Mitsuba', 'adjustments', fullfile(pathHere, 'mitsuba-adjustments.xml'));

%% Render with Mitsuba and PBRT.
toneMapFactor = 100;
isScale = true;
for renderer = {'Mitsuba'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(colladaFile, '', '', hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    montageName = sprintf('%s (%s)', hints.recipeName, hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
