function nestedValue = queryAdjustmentValue(adjustment, valueName, propertyName, defaultValue)
%% Get a value nested within a top-level adjustment.
%
% This is a convenience function for digging a value ouf of adjustments
% that are nested under the given adjustment.value.  The valueName is used
% to select one of the elements of the nested array of adjustments.  The
% selected element is
% modified according to passed in parameters.  The selected element can be
% created if it's missing.
%
% nestedValue = queryAdjustmentValue(adjustment, valueName, propertyName, defaultValue)
% selects one of the nested adjustments found in the given
% adjustments.value and returns the value of the given propertyName.
%
% If no nested element with valueName can be found, or if propertyName is
% no the name of an adjustments property, returns the given defaultValue.
%
% nestedValue = queryAdjustmentValue(adjustment, valueName, propertyName, defaultValue)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('adjustment', @isstruct);
parser.addRequired('valueName', @ischar);
parser.addRequired('propertyName', @ischar);
parser.addRequired('defaultValue');
parser.parse(adjustment, valueName, propertyName, defaultValue);
adjustment = parser.Results.adjustment;
valueName = parser.Results.valueName;
propertyName = parser.Results.propertyName;
defaultValue = parser.Results.defaultValue;

%% Locate the nested adjustment by name.
valueNames = {adjustment.value.name};
valueIndex = find(strcmp(valueNames, valueName), 1, 'first');
if isempty(valueIndex)
    nestedValue = defaultValue;
    return;
end

%% Query the nested adjustment.
nested = adjustment.value(valueIndex);
if isfield(nested, propertyName)
    nestedValue = nested.(propertyName);
else
    nestedValue = defaultValue;
end
