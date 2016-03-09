%% Look at all RTB3 examples mappings files and trace ids through mexximp.
%
% 2016 Mexximp Team.

%% Gather example scenes.
clear;
clc;

examplesFolder = fullfile(RenderToolboxRoot(), 'ExampleScenes');
sceneFiles = FindFiles(examplesFolder, '\.dae$');

sceneFiles = sceneFiles([3 8 13]);

nSceneFiles = numel(sceneFiles);

%% Explore mappings for each scene.
for ss = 1:nSceneFiles
    if ~isempty(strfind(sceneFiles{ss}, 'NotYetWorking'))
        continue;
    end
    
    %% Load the scene itself.
    scene = mexximpImport(sceneFiles{ss});
    if ~isstruct(scene)
        disp('BWAR!')
        continue;
    end
    
    % flatten the node hierarchy for sanity
    scene.rootNode = mexximpFlattenNodes(scene);
    
    % fix resource references
    [scenePath, sceneBase] = fileparts(sceneFiles{ss});
    scene = mexximpResolveResources(scene, 'resourceFolder', scenePath);
    
    %% Write the scene out as Collada.
    workingFolder = fullfile(tempdir(), 'mitsuba-poc', sceneBase);
    if 7 ~= exist(workingFolder, 'dir')
        mkdir(workingFolder);
    end
    colladaFile = fullfile(workingFolder, [sceneBase '.dae']);
    mexximpExport(scene, 'collada', colladaFile);
    
    %% Convert Collada to Mitsuba.
    hints.filmType = 'hdrfilm';
    hints.imageWidth = 320;
    hints.imageHeight = 240;
    
    mitsuba.importer = '/home/ben/render/mitsuba/mitsuba-spectral/mtsimport';
    mitsubaFile = fullfile(workingFolder, [sceneBase '.xml']);
    colladaToMitsuba(colladaFile, mitsubaFile, mitsuba, hints);
    
    %% Check each associated mappings file.
    sceneFolder = fileparts(sceneFiles{ss});
    mappingsFiles = FindFiles(sceneFolder, 'Mappings\.txt$');
    nMappingsFiles = numel(mappingsFiles);
    for mm = 1:nMappingsFiles
        
        %% Get a fresh copy of the Mitsuba scene in memory.
        %   Mitsuba nodes named "ref" have "id" attributes,
        %   but they don't count as first-class "id nodes"
        excludePattern = '^ref$';
        [docNode, idMap] = ReadSceneDOM(mitsubaFile, excludePattern);
        mitsubaElements = struct( ...
            'id', idMap.keys(), ...
            'element', idMap.values());
        
        %% Trace adjustment names/ids through mexximp and Collada.
        mappings = parseMappings(mappingsFiles{mm});
        adjustments = mappingsToAdjustments(mappings);
        
        % only care about Generic and Mitsuba stuff right now
        isGeneric = strcmp({adjustments.destination}, 'Generic');
        isMitsuba = strcmp({adjustments.destination}, 'Mitsuba');
        adjustments = adjustments(isMitsuba | isGeneric);
        
        for aa = 1:numel(adjustments)
            adj = adjustments(aa);
            
            if strcmp('mesh', adj.broadType) ...
                    || strcmp('area', adj.specificType)
                % convert adjustment name to mesh id
                [element, elementScore] = mexximpFindElement(scene, adj.name, ...
                    'type', 'mesh');
                elementIndex = element.path{end};
                idToMatch = sprintf('meshId%d_0', elementIndex - 1);
                
            elseif strcmp('material', adj.broadType) || strcmp('bsdf', adj.broadType)
                % convert adjustment name to material id
                [element, elementScore] = mexximpFindElement(scene, adj.name, ...
                    'type', 'material');
                elementIndex = element.path{end};
                idToMatch = sprintf('m%d%s', elementIndex - 1, element.name);
                
            else
                % use adjustment name as-is
                elementScore = 1;
                elementIndex = 0;
                idToMatch = adj.name;
            end
            
            % find a matching mitusba xml id
            idMatcher = mexximpStringMatcher(idToMatch);
            idQuery = {'id', idMatcher};
            [mitsubaIndex, mitsubaScore] = mPathQuery(mitsubaElements, idQuery);
            mitsubaId = mitsubaElements(mitsubaIndex).id;
            
            % paste this into a spreadsheet and review
            %   does mitsubaId look like a good match for idToMatch?
            %   or, does elementScore or mitsubaScore indicate no match?
            TAB = sprintf('\t');
            disp([ ...
                mappingsFiles{mm} TAB ...
                adj.destination TAB ...
                adj.broadType TAB ...
                adj.specificType TAB ...
                num2str(elementIndex) TAB ...
                adj.name TAB ...
                num2str(elementScore) TAB ...
                idToMatch TAB ...
                num2str(mitsubaScore) TAB ...
                mitsubaId TAB ...
                ]);
        end
        
        %% Continue the proof of concept.
        
        % convert adjustments and apply to the DOM
        adjustments = genericAdjustmentsToMitsuba(adjustments);
        adjustMitsubaDocument(idMap, adjustments, scene);
        
        % write out the adjusted scene
        [~, mappingsBase] = fileparts(mappingsFiles{mm});
        adjustedMitusbaFile = fullfile(workingFolder, [mappingsBase '-adjusted.xml']);
        WriteSceneDOM(adjustedMitusbaFile, docNode);
    end
end
