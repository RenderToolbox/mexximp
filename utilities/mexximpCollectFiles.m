function files = mexximpCollectFiles(rootDir)
% Collect all files within a given rootDir.
%
% files = mexximpCollectFiles(rootDir) searches the given rootDir
% recursively and returns all files found within.  Each will come with its
% relative path, relative to rootDir.
%
% This may take a long time if rootDir contains a lot of files or folders.
%
% files = mexximpCollectFiles(rootDir)
%
% Copyright (c) 2016 mexximp Team

files = collectFiles(rootDir, '');


%% Descend recursively and build up the path relative to rootDir.
function files = collectFiles(rootDir, relativePath)

workingDir = fullfile(rootDir, relativePath);

contents = dir(workingDir);

% collect the files
fileContents = contents(~[contents.isdir]);
nFiles = numel(fileContents);
workingFiles = cell(1, nFiles);
for ww = 1:nFiles
    workingFiles{ww} = fullfile(relativePath, fileContents(ww).name);
end

% descend into subfolders
subdirContents = contents([contents.isdir]);
nSubdirs = numel(subdirContents);
subfolderFiles = cell(1, nSubdirs);
useSubdir = true(1, nSubdirs);
for dd = 1:nSubdirs
    name = subdirContents(dd).name;
    
    if strcmp(name, '.') || strcmp(name, '..')
        useSubdir(dd) = false;
        continue;
    end
    
    subRelativePath = fullfile(relativePath, name);
    subfolderFiles{dd} = collectFiles(rootDir, subRelativePath);
end
subfolderFiles = subfolderFiles(useSubdir);

% assemble results
files = cat(2, workingFiles, subfolderFiles{:});
