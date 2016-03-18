function name = mexximpCleanName(originalName, index)
% Make a formatted name for a scene element.
%
% name = mexximpCleanName(originalName, index) returns a consistently
% formatted name to use for a scene element.  The name will include
% the given original name for readability, and the given index, to make the
% name unique.  In addition, the name will be restricted to alphanumeric
% characters and underscores.
%
% For example, mexximpCleanName('Cube.005', 2) will produce the name
% 'Cube_005_2'.
%
% Returns a formatted name based on the given originalName and index.
%
% name = mexximpCleanName(originalName, index)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('originalName', @ischar);
parser.addRequired('index');
parser.parse(originalName, index);
originalName = parser.Results.originalName;
index = parser.Results.index;

%% Convert unwanted characters to underscore.
isUpper = originalName >= 'A' & originalName <= 'Z';
isLower = originalName >= 'a' & originalName <= 'z';
isNumeric = originalName >= '0' & originalName <= '9';
isUnderscore = ~isUpper & ~isLower & ~isNumeric;
originalName(isUnderscore) = '_';

%% Build the new name.
if isempty(index) || ~isnumeric(index)
    name = originalName;
else
    name = sprintf('%d_%s', index, originalName);
end
