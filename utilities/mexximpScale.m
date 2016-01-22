function transformation = mexximpScale(stretch)
%% Build a 4x4 scale matrix.
%
% transformation = mexximpScale(stretch) builds a 4x4 scale
% matrix based on the given [x y z] stretch factors.
%
% transformation = mexximpScale(stretch)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('stretch', @(s) isnumeric(s));
parser.parse(stretch);
stretch = parser.Results.stretch;

if numel(stretch) < 3
    stretch = stretch(1) * [1 1 1];
end

transformation = eye(4);
transformation([1 6 11]) = stretch(1:3);
