function pbrtScene = applyMPbrtMappings(pbrtScene, mappings)
%% Apply mappings with the "PBRT" destination directly to the scene.
%
% scene = applyMPbrtMappings(pbrtScene, mappings) adjusts the given mPbrt
% pbrtScenein place, by applying the given mappings as scene adjustments.
%
% This generally amounts to locating scene elements of the scene object and
% updating their field values based on the mappings properties.
%
% scene = applyMPbrtMappings(pbrtScene, mappings)
%
% Copyright (c) 2016 RemoteDataToolbox Team

parser = inputParser();
parser.addRequired('pbrtScene', @isobject);
parser.addRequired('mappings', @isstruct);
parser.parse(pbrtScene, mappings);
pbrtScene = parser.Results.pbrtScene;
mappings = parser.Results.mappings;

%% Select only the mappings targeted at the PBRT object.
isPbrt = strcmp('PBRT', {mappings.destination});
pbrtMappings = mappings(isPbrt);
nPbrtMappings = numel(pbrtMappings);

%% Update the scene, one mapping at a time.
for mm = 1:nPbrtMappings
    mapping = pbrtMappings(mm);
    
    %% Locate the element.
    pbrtName = mexximpCleanName(mapping.name, mapping.index);
    switch mapping.operation
        case 'delete'
            % remove the node, if it can be found
            pbrtScene.find(mapping.broadType, ...
                'name', pbrtName, ...
                'remove', true);
            continue;
            
        case 'update'
            % need an existing element to update
            element = pbrtScene.find(mapping.broadType, 'name', pbrtName);
            if isempty(element)
                warning('applyMPbrtMappings:nodeNotFound', ...
                    'No node found with identifier <%s> and name <%s>', ...
                    mapping.broadType, pbrtName);
                continue;
            end
            
        case 'create'
            % append a brand new element regardless of any existing
            element = MPbrtElement(mapping.broadType, ...
                'name', pbrtName, ...
                'type', mapping.specificType);
            pbrtScene.append(element);
            
        otherwise
            warning('applyMPbrtMappings:unknownOperation', ...
                'Unsupported mapping operation: %s', mapping.operation);
            continue;
    end
    
    %% Update element properties.
    for pp = 1:numel(mapping.properties)
        property = mapping.properties(pp);
        elementParameter = element.getParameter(property.name);
        if isempty(elementParameter)
            oldValue = [];
        else
            oldValue = elementParameter.value;
        end
        newValue = applyPropertyOperation(property, oldValue);
        element.setParameter(property.name, property.valueType, newValue);
    end
end
