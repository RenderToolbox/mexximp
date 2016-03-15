function mapping = setMappingProperty(mapping, name, varargin)
%% Edit a property nested within a mapping struct.
%
% This is a convenience function for modifying properties that are nested
% under the given mapping.properties.  The name is used to select one of
% the elements of mapping.properties.  Subsequent name-value pairs are
% assigned to the selected property.
%
% mapping = setMappingProperty(mapping, name, ...) selects a nested
% property found in the given mapping.properties and applies subsequent
% parameter-value pairs to the selected property.
%
% setMappingProperty(... 'create', create) specify whether to create a new
% property if none with the given name was is found (true) or to simply
% return in that case (false).  The default is true, create a missing
% property.
%
% setMappingProperty(... 'updateExisting', updateExisting) specify whether
% to update an existing property if one is found with the given name (true)
% or to skip over an existing property, preserving its original value
% (false).  The default is false, preserve an existing property as-is.
%
% mapping = setMappingProperty(mapping, name, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('mapping', @isstruct);
parser.addRequired('name', @ischar);
parser.addParameter('create', true, @islogical);
parser.addParameter('updateExisting', false, @islogical);
parser.parse(mapping, name, varargin{:});
mapping = parser.Results.mapping;
name = parser.Results.name;
create = parser.Results.create;
updateExisting = parser.Results.updateExisting;

%% Locate the nested adjustment by name.
propertyNames = {mapping.properties.name};
propertyIndex = find(strcmp(propertyNames, name), 1, 'first');
if isempty(propertyIndex)
    if create
        % brand new property from defaults and arguments
        property = mappingProperty('name', name, varargin{:});
        if isempty(mapping.properties)
            mapping.properties = property;
        else
            mapping.properties = [mapping.properties property];
        end
    end
    return;
end

%% Update the nested adjustment.
if ~updateExisting
    return;
end

% updated property from defaults, original, and arguments
property = mappingProperty(mapping.properties(propertyIndex), varargin{:});
mapping.properties(propertyIndex) = property;
