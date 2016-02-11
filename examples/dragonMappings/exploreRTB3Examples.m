%% Scan all our RenderToolbox3 examples and look for element name collisions.

clear;
clc;

examplesFolder = fullfile(RenderToolboxRoot(), 'ExampleScenes');

%% Scan the scene files.
sceneFiles = FindFiles(examplesFolder, '\.dae$');
nSceneFiles = numel(sceneFiles);

% gather names of all elements in the scene
for ss = 1:nSceneFiles
    disp(' ')
    disp(sceneFiles{ss})
    
    scene = mexximpImport(sceneFiles{ss});
    if ~isstruct(scene)
        disp('BWAR!')
        continue;
    end
    
    % get flat representation of scene elements
    elements = mexximpSceneElements(scene);
    nElements = numel(elements);
    
    % look for duplicate element names
    names = {elements.name};
    types = {elements.type};
    isDup = false(1, nElements);
    for ee = 1:nElements
        isName = strcmp(names{ee}, names);
        nNodes = sum(strcmp('node', types(isName)));
        if sum(isName) - nNodes > 1
            isDup = isDup | isName;
        end
    end
    dupNames = names(isDup);
    dupTypes = types(isDup);
    
    %% Check each associated mappings file.
    sceneFolder = fileparts(sceneFiles{ss});
    mappingsFiles = FindFiles(sceneFolder, 'Mappings\.txt$');
    nMappingsFiles = numel(mappingsFiles);
    
    % gather ids from all mapped elements of the scene
    for mm = 1:nMappingsFiles
        disp(' ')
        disp(mappingsFiles{mm})
        
        mappings = parseMappings(mappingsFiles{mm});
        objects = MappingsToObjects(mappings);
        nObjects = numel(objects);
        
        % are we trying to adjust elements with dup names and no type hint?
        if ~isempty(dupNames)
            disp([dupNames' dupTypes'])
            
            isClassless = strcmp('', {objects.class});
            ids = {objects(isClassless).id};
            classes = {objects(isClassless).class};
            subclasses = {objects(isClassless).subclass};
            disp([ids' classes' subclasses'])
        end
    end
end
