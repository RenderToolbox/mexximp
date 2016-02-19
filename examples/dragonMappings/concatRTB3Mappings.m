% Scan all the RTB3 example mappings files and concatenate for review.

clear;
clc;

examplesFolder = fullfile(RenderToolboxRoot(), 'ExampleScenes');

%% Read each mappings file into memory.
mappingsFiles = FindFiles(examplesFolder, 'Mappings\.txt$');
nMappingsFiles = numel(mappingsFiles);
mappings = cell(1, nMappingsFiles);
for ii = 1:nMappingsFiles
    mappings{ii} = parseMappings(mappingsFiles{ii});
end

%% Pretty-print each mappings line.
grandMappings = cat(2, mappings{:});
nMappings = numel(grandMappings);
prettyLines = cell(1, nMappings);
for ii = 1:nMappings
    mapping = grandMappings(ii);
    prettyLines{ii} = [...
        mapping.blockType, ' ', ...
        mapping.left.enclosing, ...
        mapping.left.value, ...
        mapping.operator, ...
        mapping.right.enclosing, ...
        mapping.right.value];
end

%% Get uniques from the pretty-printed lines.
uniqueLines = unique(prettyLines);