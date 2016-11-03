function mexximpSave(scene, fileName)
% Save a mexximp scene to disk, directly as a mat-file.
%
% mexximpSave(scene, fileName) saves the given scene to disk in a mat file
% with the given fileName.  Load it again with mexximpLoad().
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('scene', @isstruct);
parser.addRequired('fileName', @ischar);
parser.parse(scene, fileName);
scene = parser.Results.scene;
fileName = parser.Results.fileName;

[filePath, fileBase, fileExt] = fileparts(fileName);

if ~isempty(filePath) && 7 ~= exist(filePath, 'dir')
    mkdir(filePath);
end

if isempty(fileExt)
    outFile = fullfile(filePath, [fileBase '.mat']);
else
    outFile = fileExt;
end

save(outFile, '-struct', 'scene');
