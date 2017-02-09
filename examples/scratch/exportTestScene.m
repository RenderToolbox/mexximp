function [scene, outputFile, status] = exportTestScene(varargin)
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

parser = inputParser();
parser.addParameter('outputFile', fullfile(tempdir(), 'test-export.dae'), @ischar);
parser.addParameter('outputFormat', 'collada', @ischar);
parser.addParameter('openResult', false, @islogical);
parser.parse(varargin{:});
outputFile = parser.Results.outputFile;
outputFormat = parser.Results.outputFormat;
openResult = parser.Results.openResult;

%% Make and export a scene.
scene = makeTestScene();

status = mexximpExport(scene, outputFormat, outputFile, []);

%% Look at the XML Collada document.
if openResult
    edit(colladaFile);
end