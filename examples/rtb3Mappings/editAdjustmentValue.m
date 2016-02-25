function adjustment = editAdjustmentValue(adjustment, valueName, varargin)
%% Edit a value nested within a top-level adjustment.
%
% This is a convenience function for modifying adjustments that are nested
% under the given adjustment.value.  The valueName is used to select one of
% the elements of the nested array of adjustments.  The selected element is
% modified according to passed in parameters.  The selected element can be
% created if it's missing.
%
% adjustment = editAdjustmentValue(adjustment, valueName, ... ) selects
% one of the nested adjustments found in the given adjustments.value and
% applies edits according to the given parameter-value paris.  See below
% for valid name-value pairs.
%
% adjustment = editAdjustmentValue(... 'create', create) specify what to do
% if no nested adjustment is found with the given valueName: create a new
% adjustment (true) or do nothing (false).  The default is true, create a
% new adjustment if needed.
%
% adjustment = editAdjustmentValue(... parameter, value) edit the given
% parameter of the selected adjustment.  The given parameter must be one of
% the adjustment field names: name, broadType, specificType, value,
% destination, operator, or group.
%
% adjustment = editAdjustmentValue(adjustment, valueName, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('adjustment', @isstruct);
parser.addRequired('valueName', @ischar);
parser.addParameter('create', true, @islogical);
parser.parse(adjustment, valueName, varargin{:});
adjustment = parser.Results.adjustment;
valueName = parser.Results.valueName;
create = parser.Results.create;

%% Locate the nested adjustment by name.
valueNames = {adjustment.value.name};
valueIndex = find(strcmp(valueNames, valueName), 1, 'first');
if isempty(valueIndex)
    if create
        nested = newAdjustment(varargin{:});
        adjustment.value = [adjustment.value nested];
    end
    return;
end

%% Update the nested adjustment.
nested = adjustment.value(valueIndex);

properties = varargin(1:2:end);
values = varargin(2:2:end);
for pp = 1:numel(properties)
    property = properties{pp};
    if isfield(nested, property)
        nested.(property) = values{pp};
    end
end

adjustment.value(valueIndex) = nested;
