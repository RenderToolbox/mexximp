% Sandbox to render some scenes from rtb3.
%   assmes RTB3 is on the Matlab path.
%
% Some notes on what I tried:
%
% 1. Our Interior scene from Blender.  Well, this crashed
% Assimp out of the gate.  This was an assimp problem, not Mexximp.  For
% example:
%   >> assimp info .../Interior/interior/source/interio.blend
%   Launching asset import ...           OK
%   Validating postprocessing flags ...  OK
%   Segmentation fault
%
% 2. Our Interior scene Collada file, as exported by Blender
% iteslf.  This worked fine for both renderers but wants more light, as we
% expect.
%
% 3. Our CoordinatesTest scene from Blender.  This worked
% OK for Mitsuba, though the materials look a bit funny and the coordinate
% convention has changed.  This broke our PBRT writer because some of the
% scene elements contained dots, for example, a light with id "Point.007",
% and this broke our SceneDOM utilities which interpret "." to mean
% "attribute of".  When we export from Blender, we Blender replaces the
% dots with underscores, so we are OK.
%
% 4. Our SpectralIllusion scene from Blender.  This worked OK for Mitsuba,
% though the sky area light was missing, so the lighting was dim.  This
% rendered in PBRT, but something is messed up with the geometry.  Perhaps
% related to multiple polylists in one mesh?
%
% 5. Our TableSphere scene from Blender.  This worked OK for both
% renderers.  The lighting was off, probably because we didn't set the
% materials.
%
% 6. Our Dice scene from Blender.  This worked OK for PBRT but the texture
% was missing.  Mitsuba failed on the missing texture.  This is because we
% specify the texture in the mappings file, and the Blender file points to
% a non-existent texture file.
%
% 7. Our Interreflection scene from Blender.  Worked great from both
% renderers!  None of our integrator tricks are applied.
%
% 8. Our RadianceTest scene from Blender.  Worked great from Mitsuba.  PBRT
% rendering was "grainy" for some reason.  None of our radiance tricks were
% applied. 
%
% 9. Our ScalingTest scene from Blender.  Worked great from both
% renderers!  Our material and scaling tricks were not applied.
%
% Conclusions.
%
% Aside from the segfault, we get a win from mexximp.  We can suck in
% Blender files and render them!
%
% Exporting Collada from Mexximp changes the scene element ids.  So we
% would need to fix our mappings files.
%
% If we could apply our mappings to Mexximp structures directly, we could
% avoid some of the id issues.  For example, we could identify and
% manipulate the camera by following the data structures, regardless of
% what its id is.
%
% Our ColladaToPBRT code needs attention.  It apparently contains
% Blender-specific assumptions and breaks on Collada produced by Mexximp.
% i fixed some of these.  We could put energy into fixing the rest.  I
% would prefer to change tack and go straight from Mexximp data structures
% to PBRT.  This would eliminate Collada problems altogether!
%
% Mitsuba does a better job with Collada files.  I think the reason is that
% is uses the official ColladaDom tool, which is a C++ project that we
% didn't feel like building and distributing, back in the day.  I still
% feel that way!
%
% I think it's a real problem that different Collada produces produce
% different element ids.  This means we can't use our existing mappings
% files with Mexximp, without updating the Ids.  This also means the
% Collada/SceneDom pipeline will never be compatible with a Mexximp
% pipeline.
%
% So what do we do?  Do we switch streams and embrace the Mexximp view of
% Collada ids?  This might work for a while.  But can't we do better?  I
% think we would like to rise above this id issue.  I think mexximp data
% structures could allow us to rise above.
%
% Each element can be located in the scene structure by some combination of
% field name and array indexes.  This is like a "path" to the element.  For
% unique elements, like the camera, this is a simple path and just as good
% as an Id.  For repeated elements, like various meshes, this might take
% some thinking.
%
% We need a way to represent mappings and adjustments so that things still
% line up.  Ids are a nice way to do this.  So, some thinking.
%
% If we export PBRT directly, we can avoid this issue, we just manipulate
% the mexximp structures, then traverse them and write them out.  Ids are
% irrelevant!
%
% For Collada->Mitsuba it's harder because be we need to fork the mexximp
% structures into vanilla Collada rgb stuff, and then produce a matching
% adjustments file.  So what ids do we write in the adjustments file?
%   * One approach is to grok and embrace the assimp id scheme.
%   * Another is to produce the Collada, then do some scanning and value
%   matching to figure out what the ids we should be using.
%   * Another approach is to skip the Collada and author the Mitsuba files
%   directly!
%
%   I don't love any of these yet.
%
% I looked at the Mitsuba converter.cpp to see how adjustment files work.
% they work by matching up elements by id and we can append, prepend, or
% remove, or insert whole elements.  To use this we'd have to author whole
% Mitsuba-Xml elements.
%
% We want to modify parts of elements, which is why we use our own SceneDom
% tool instead of Mitsuba's adjustments.  Still, we are stuck trying to
% line things up by id.
% 
%

%% Set up for RenderToolbox3
clear;
clc;

hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'rtbExampleTest';
ChangeToWorkingFolder(hints);

setpref('Mitsuba', 'adjustments', which('rtb-mitsuba-adjustments.xml'));
setpref('PBRT', 'adjustments', which('rtb-pbrt-adjustments.xml'));
mappingsFile = 'rtb-mappings.txt';

%% Suck in a scene -- try Collada and Blender
examplesFolder = fullfile(RenderToolboxRoot(), 'ExampleScenes');

%sceneFile = fullfile(examplesFolder, 'Interior', 'interior', 'source', 'interio.dae');
%sceneFile = fullfile(examplesFolder, 'CoordinatesTest', 'CoordinatesTest.blend');
%sceneFile = fullfile(examplesFolder, 'SpectralIllusion', 'SpectralIllusion.blend');
%sceneFile = fullfile(examplesFolder, 'TableSphere', 'TableSphere.blend');
sceneFile = fullfile(examplesFolder, 'Dice', 'Dice.blend');
%sceneFile = fullfile(examplesFolder, 'Interreflection', 'Interreflection.blend');
%sceneFile = fullfile(examplesFolder, 'RadianceTest', 'RadianceTest.blend');
%sceneFile = fullfile(examplesFolder, 'ScalingTest', 'ScalingTest.blend');

scene = mexximpImport(sceneFile);

format = 'collada';
colladaFile = fullfile(GetWorkingFolder('resources', false, hints), 'interior-export.dae');
status = mexximpExport(scene, format, colladaFile, []);

%% Render with Mitsuba and PBRT.
toneMapFactor = 100;
isScale = true;
for renderer = {'PBRT', 'Mitsuba'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(colladaFile, '', mappingsFile, hints);
    
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    montageName = sprintf('%s (%s)', hints.recipeName, hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
