function scene = mexximpLoad(fileName)
% Load a mexximp scene from a mat-file on disk.
%
% scene = mexximpLoad(fileName) loads a scene from a mat-file on disk
% with the given fileName.  It should have been saved previously with
% mexximpSave().
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('fileName', @ischar);
parser.parse(fileName);
fileName = parser.Results.fileName;

scene = load(fileName);
