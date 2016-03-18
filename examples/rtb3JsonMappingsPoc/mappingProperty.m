function property = mappingProperty(varargin)
%% Create a mappings property struct with standard fields.
%
% property = mappingProperty(struct) creates a new property struct based on
% the given struct.  The new property struct will contain standard fields
% and values, updated with any applicable fields of the given struct.
%
% property = mappingProperty(name, value, ...) creates a new property
% struct based on the given name-value paris.  The new property struct will
% contain standard fields and values, updated with any of the given
% name-value paris that are applicable.
%
% property = mappingProperty(varargin)
%
% Copyright (c) 2016 mexximp Team

% standard fields for nested properties of each element
parser = inputParser();
parser.StructExpand = true;
parser.KeepUnmatched = true;
parser.addParameter('name', '', @ischar);
parser.addParameter('valueType', '', @ischar);
parser.addParameter('value', []);
parser.addParameter('operation', '=', @ischar);
parser.parse(varargin{:});

%% Let the input parser do all the work!
property = parser.Results();
