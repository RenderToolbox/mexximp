function transformation = mexximpTranslate(destination)
%% Build a 4x4 translation matrix.
%
% transformation = mexximpTranslate(destination) builds a 4x4 translation
% matrix based on the given [x y z] destination.
%
% transformation = mexximpTranslate(destination)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('destination', @(d) isnumeric(d) && 3 == numel(d));
parser.parse(destination);
destination = parser.Results.destination;

transformation = eye(4);
transformation(4, 1:3) = destination;
