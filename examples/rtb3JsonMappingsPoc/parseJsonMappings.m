function mappings = parseJsonMappings(fileName)
%% Read mappings from a JSON file and fill in default fields.
%
% mappings = parseJsonMappings(fileName) reads mappings from JSON stored in
% the given fileName.  Fills in any default fields that were omitted from
% the JSON and ignores fields that are recognized mappings fields.  Returns
% a struct array with standard mappings fields and one element per
% mapping.
%
% JSON for mappings must start with a top-level JSON array (ie square
% brackets [...]).  The elements of the top-level array must be JSON
% objects (ie curly braces {...}).  Each JSON object may contain any of the
% top-level mappings fields (see below).  Each JSON object may also contain
% a "properties" field which contains a
%
% See also rdtFromJson
%
% jsonString = rdtToJson(data)
%
% Copyright (c) 2015 RemoteDataToolbox Team

%% Read the given json into a struct.
argParser = inputParser();
argParser.addRequired('fileName', @ischar);
argParser.parse(fileName);
fileName = argParser.Results.fileName;

originalMappings = loadjson(fileName);

if ~iscell(originalMappings)
    error('parseJsonMappings:invalidJson', ...
        'Could not load mappings cell from JSON <%s>\n', fileName);
end

%% Validate and fill in each mapping element.

% standard fields for the top level of each element
topLevelParser = inputParser();
topLevelParser.StructExpand = true;
topLevelParser.addParameter('name', '', @ischar);
topLevelParser.addParameter('index', 0, @isnumeric);
topLevelParser.addParameter('broadType', '', @ischar);
topLevelParser.addParameter('specificType', '', @ischar);
topLevelParser.addParameter('operation', 'create', @ischar);
topLevelParser.addParameter('group', '', @ischar);
topLevelParser.addParameter('destination', 'Generic', @ischar);
topLevelParser.addParameter('properties', []);

% standard fields for nested properties of each element
propertyParser = inputParser();
propertyParser.StructExpand = true;
propertyParser.addParameter('name', '', @ischar);
propertyParser.addParameter('valueType', '', @ischar);
propertyParser.addParameter('value', []);
propertyParser.addParameter('operation', '=', @(o)any(strcmp(o, {'=', '+=', '-=', '*=', '/='})));

% check each element one at a time
nMappings = numel(originalMappings);
validatedMappings = cell(1, nMappings);
for mm = 1:nMappings
    topLevelParser.parse(originalMappings{mm});
    mapping = topLevelParser.Results;
    
    % convert single-element properties to cell, for processing convenience
    if isstruct(mapping.properties)
        mapping.properties = {mapping.properties};
    end
    
    % check each property element one at a time
    if iscell(mapping.properties)
        nProperties = numel(mapping.properties);
        validatedProperties = cell(1, nProperties);
        for pp = 1:nProperties
            propertyParser.parse(mapping.properties{pp});
            validatedProperties{pp} = propertyParser.Results;
        end
        mapping.properties = [validatedProperties{:}];
    end
    
    validatedMappings{mm} = mapping;
end
mappings = [validatedMappings{:}];
