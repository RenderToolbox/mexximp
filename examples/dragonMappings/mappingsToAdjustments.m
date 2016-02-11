function adjustments = mappingsToAdjustments(mappings)
%% Group and parse mappings into mexximp scene adjustments.
%
% adjustments = mappingsToAdjustments(mappings) parses mappings syntax from
% the given mappings struct into declarations and parameters, and groups
% the declarations and parameters by element type and name, to form mexximp
% scene adjustments.
%
% Mappings from Collada blocks and "-path" blocks will be parsed using
% RenderToolbox3 SceneDom syntax.  For example:
%	Camera:scale|sid=scale = -1 1 1
% This syntax is *deprecated* but included for compatibility with legacy
% RenderToolbox3 example scenes.
%
% Mappings from all other blocks will be parsed using RenderToolbox3
% SceneTarget syntax.  For example:
%   Material-material:material:anisoward
%   Material-material:diffuseReflectance.spectrum = mccBabel-2.spd
%
% TODO: document the format of the adjustments struct.  First, I have to
% figure it out!  BSH
%
% adjustments = mappingsToAdjustments(mappings)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('mappings', @isstruct);
parser.parse(mappings);
mappings = parser.Results.mappings;

%% Separate mappings blocks by expected syntax.
nMappings = numel(mappings);
isSceneDom = false(1, nMappings);
isLegacyPath = false(1, nMappings);
for ii = 1:nMappings
    blockType = mappings(ii).blockType;
    isSceneDom(ii) = strcmp(blockType, 'Collada');
    isLegacyPath(ii) = ~isempty(strfind(blockType, '-path'));
end

%% Should update legacy path syntax.
fprintf('Ignoring %d legacy "-path" mappings.\n', sum(isLegacyPath));
mappings = mappings(~isLegacyPath);
isSceneDom = isSceneDom(~isLegacyPath);

%% Collada as Scene Dom node transformation adjustments.
scenePathInds = find(isSceneDom);
nScenePathAdjustments = numel(scenePathInds);
scenePathAdjustments = cell(1, nScenePathAdjustments);
for ii = 1:nScenePathAdjustments
    mapping = mappings(scenePathInds(ii));
    
    % basic metadata
    adj = adjustmentTemplate();
    adj.blockType = mapping.blockType;
    adj.blockNumber = mapping.blockNumber;
    adj.group = mapping.group;
    
    % actual path syntax
    pathCell = PathStringToCell(mapping.left.value);
    pathLength = numel(pathCell);
    if pathLength < 1
        scenePathAdjustments{ii} = adj;
        continue;
    end
    
    % path id -> name of the node element
    adj.elementName = pathCell{1};
    
    % rest of path -> node transformation
    %   this is special-casey based on legacy mappings
    [~, targetName] = ScanPathPart(pathCell{end});
    switch targetName
        case {'scale', 'translate', 'rotate', 'matrix'}
            adj.elementType = 'node';
            nameQuery = {'name', mexximpStringMatcher(adj.elementName)};
            adj.elementPath = {'rootNode', 'children', nameQuery};
            adj.directives = makeDirective( ...
                'update', 'transformation', mapping.operator, mapping.right.value, targetName);
        case 'xfov'
            adj.elementType = 'camera';
            nameQuery = {'name', mexximpStringMatcher(adj.elementName)};
            adj.elementPath = {'cameras', nameQuery};
            adj.directives = makeDirective( ...
                'update', 'horizontalFov', mapping.operator, mapping.right.value, 'float');
        otherwise
            disp(['handle this path: ' mapping.left.value])
    end
    
    scenePathAdjustments{ii} = adj;
end

%% Other blocks as Scene Target syntax.
sceneTargetInds = find(~isSceneDom);

% identify uniue ids among the mappings
nSceneTargetAdjustments = numel(sceneTargetInds);
ids = cell(1, nSceneTargetAdjustments);
for ii = 1:nSceneTargetAdjustments
    mapping = mappings(sceneTargetInds(ii));
    pathCell = PathStringToCell(mapping.left.value);
    if isempty(pathCell)
        ids{ii} = '';
    else
        ids{ii} = pathCell{1};
    end
end

% each target id gets an adjustment
%   each adjustment may have multiple mappings -> directives
uniqueIds = unique(ids);
nUniqueIds = numel(uniqueIds);
sceneTargetAdjustments = cell(1, nUniqueIds);
for ii = 1:nUniqueIds
    id = uniqueIds{ii};
    
    % basic metadata
    adj = adjustmentTemplate();
    adj.blockType = mapping.blockType;
    adj.blockNumber = mapping.blockNumber;
    adj.group = mapping.group;
    
    % target id -> name of the scene element
    adj.elementName = id;
    
    % suck up the mappings that have the same id
    mappingInds = find(strcmp(id, ids));
    for mm = mappingInds
        mapping = mappings(sceneTargetInds(mm));
        
        % actual target syntax
        pathCell = PathStringToCell(mapping.left.value);
        pathLength = numel(pathCell);
        if pathLength < 1
            sceneTargetAdjustments{ii} = adj;
            continue;
        end
        
        if isempty(mapping.operator)
            % declare an element
            adj.elementType = [pathCell{2:end}];
            nameQuery = {'name', mexximpStringMatcher(adj.elementName)};
            adj.elementPath = {adj.elementType, nameQuery};
            directive = makeDirective( ...
                'create', adj.elementType, '', '', 'element');
            adj.directives = [directive adj.directives];
            
        else
            % set properties of an element
            [~, property] = ScanPathPart(pathCell{2});
            [~, type] = ScanPathPart(pathCell{3});
            directive = makeDirective( ...
                'update', property, mapping.operator, mapping.right.value, type);
            adj.directives = [adj.directives directive];
            
        end
    end
    
    sceneTargetAdjustments{ii} = adj;
end
adjustments = [scenePathAdjustments{:} sceneTargetAdjustments{:}];

%% Get an adjustments template.
function adjustment = adjustmentTemplate()
adjustment = struct( ...
    'elementName', '', ...
    'elementType', '', ...
    'elementPath', '', ...
    'blockType', '', ...
    'blockNumber', [], ...
    'group', '', ...
    'directives', []);


%% Get a directive templage.
function property = makeDirective(verb, target, operator, value, type)
if ~isempty(value) && value(1) == '(' && value(end) == ')'
    value = value(2:end-1);
    isVariable = true;
else
    isVariable = false;
end

property = struct( ...
    'verb', verb, ...
    'target', target, ...
    'operator', operator, ...
    'value', value, ...
    'isVariable', isVariable, ...
    'type', type);
