function adjustments = mappingsToAdjustments(mappings)
%% Group and parse mappings into mexximp scene adjustments.
%
% adjustments = mappingsToAdjustments(mappings) parses mappings syntax from
% the given mappings struct into declarations and parameters, and groups
% the declarations and parameters by element type and name to form scene
% adjustments.
%
% adjustments = mappingsToAdjustments(mappings)
%
% See also parseMappings newAdjustment
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('mappings', @isstruct);
parser.parse(mappings);
mappings = parser.Results.mappings;

%% Pick out the ids of all mappings.
nMappings = numel(mappings);
ids = cell(1, nMappings);
for ii = 1:nMappings
    mapping = mappings(ii);
    pathCell = PathStringToCell(mapping.left.value);
    if isempty(pathCell)
        ids{ii} = '';
    else
        ids{ii} = pathCell{1};
    end
end

%% Parse mappings into adjustments, grouped by id.
uniqueIds = unique(ids);
nUniqueIds = numel(uniqueIds);
adjustmentCell = cell(1, nUniqueIds);
for ii = 1:nUniqueIds
    id = uniqueIds{ii};
    
    % collect all mappings under a top-level adjustment
    topLevelAdjustment = newAdjustment(id, 'placeholder', 'placeholder', [], ...
        'group', mapping.group, ...
        'destination', mapping.blockType);
    
    % look up all mappings that use this id
    mappingInds = find(strcmp(id, ids));
    for mm = mappingInds
        mapping = mappings(mm);
        
        % break
        pathCell = PathStringToCell(mapping.left.value);
        pathLength = numel(pathCell);
        
        if pathLength < 2
            continue;
        end
        
        if pathLength >= 2
            [~, broadType] = ScanPathPart(pathCell{2});
        else
            broadType = 'unknown';
        end
        
        if pathLength >= 3
            [~, specificType] = ScanPathPart(pathCell{3});
        else
            specificType = 'unknown';
        end
        
        if isempty(mapping.operator)
            % fill in the top-level declaration
            topLevelAdjustment.broadType = broadType;
            topLevelAdjustment.specificType = specificType;
            topLevelAdjustment.operator = 'declare';
        else
            % nest property adjustments within the top-level adjustment
            nestedAdjustment = newAdjustment(id, broadType, specificType, mapping.right.value, ...
                'operator', mapping.operator, ...
                'group', mapping.group, ...
                'destination', mapping.blockType);
            topLevelAdjustment.value = [topLevelAdjustment.value, nestedAdjustment];
        end
    end
    
    if strcmp('placeholder', topLevelAdjustment.broadType)
        % raw properties with no containing declaration
        adjustmentCell{ii} = topLevelAdjustment.value;
    else
        % element declaration plus nested properties
        adjustmentCell{ii} = topLevelAdjustment;
    end
    
end
adjustments = [adjustmentCell{:}];
