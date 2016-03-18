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

parser = inputParser();
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
    topLevelAdjustment = newAdjustment( ...
        'name', id);
    
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
            [~, partOne] = ScanPathPart(pathCell{2});
        else
            partOne = 'unknown';
        end
        
        if pathLength >= 3
            [~, partTwo] = ScanPathPart(pathCell{3});
        else
            partTwo = 'unknown';
        end
        
        if isempty(mapping.operator)
            % fill in the top-level declaration
            topLevelAdjustment.broadType = partOne;
            topLevelAdjustment.specificType = partTwo;
            topLevelAdjustment.operator = 'declare';
            topLevelAdjustment.group = mapping.group;
            topLevelAdjustment.destination = mapping.blockType;
        else
            % nest property adjustments within the top-level adjustment
            nestedAdjustment = newAdjustment( ...
                'name', partOne, ...
                'broadType', 'parameter', ...
                'specificType', partTwo, ...
                'value', mapping.right.value, ...
                'operator', mapping.operator, ...
                'group', mapping.group, ...
                'destination', mapping.blockType);
            topLevelAdjustment.value = [topLevelAdjustment.value, nestedAdjustment];
        end
    end
    
    % element declaration plus nested properties
    adjustmentCell{ii} = topLevelAdjustment;
    
end
adjustments = [adjustmentCell{:}];
