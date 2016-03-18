function transformation = mexximpLookAt(from, to, up)
%% Build a 4x4 look-at matrix.
%
% transformation = mexximpLookAt(from, to, up) builds a 4x4 right-handed
% look-at matrix based on the given [x y z] from, to, and up points.
%
% transformation = mexximpLookAt(from, to, up)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('from', @(f) isnumeric(f) && 3 == numel(f));
parser.addRequired('to', @(t) isnumeric(t) && 3 == numel(t));
parser.addRequired('up', @(u) isnumeric(u) && 3 == numel(u));
parser.parse(from, to, up);
from = parser.Results.from;
to = parser.Results.to;
up = parser.Results.up;

% implementation based on Mitsuba's transform.cpp
%   https://www.mitsuba-renderer.org/repos/mitsuba/files/2489fe4741b22b2bc835bcc8056384328e810256/src/libcore/transform.cpp

% make some look-at axes
dir = normStrict(from - to, 'to and from vecors must be different');
left = normStrict(cross(up, dir), 'up vector must not fall along looking axis');
newUp = cross(dir, left);

transformation = eye(4);

transformation(1, 1:3) = left;
transformation(2, 1:3) = newUp;
transformation(3, 1:3) = dir;
transformation(4, 1:3) = from;

% normalize and make sure the norm is nonzero
function normalized = normStrict(original, message)
theNorm = norm(original);
if 0 == theNorm
    error(message);
end
normalized = original ./ theNorm;
