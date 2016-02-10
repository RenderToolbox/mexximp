%% Scan all our RenderToolbox3 examples and look for element name collisions.

clear;
clc;

examplesFolder = fullfile(RenderToolboxRoot(), 'ExampleScenes');

%% Scan the Blender scenes.
blenderFiles = FindFiles(examplesFolder, '\.dae$');
nBlenderFiles = numel(blenderFiles);

% gather names of all elements in the scene
for ii = 1:nBlenderFiles
    disp(' ')
    disp(blenderFiles{ii})
    
    scene = mexximpImport(blenderFiles{ii});
    if ~isstruct(scene)
        disp('BWAR!')
        continue;
    end
    
    % get flat representation of scene elements
    elements = mexximpSceneElements(scene);
    nElements = numel(elements);
    
    % look for duplicate element names and display
    names = {elements.name};
    types = {elements.type};
    for ee = 1:nElements
        nameInds = find(strcmp(names{ee}, names));
        nAppearances = numel(nameInds);
        if nAppearances > 1
            dupNames = names(nameInds);
            dupTypes = types(nameInds);
            nNodes = sum(strcmp('node', dupTypes));
            
            % don't count nodes as duplicates -- can probably handle them
            if nAppearances - nNodes > 1
                disp([dupNames' dupTypes']);
            end
        end
    end
end

%% Scan the Mappings files.
mappingsFiles = FindFiles(examplesFolder, 'Mappings\.txt$');