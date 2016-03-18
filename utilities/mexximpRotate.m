function transformation = mexximpRotate(about, radians)
%% Build a 4x4 rotation matrix.
%
% transformation = mexximpRotate(about, radians) builds a 4x4 right-handed
% rotation matrix based on the given [x y z] about axis and scalar radians.
%
% transformation = mexximpRotate(about, radians)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('about', @(d) isnumeric(d) && 3 == numel(d));
parser.addRequired('radians', @(r) isnumeric(r) && isscalar(r));
parser.parse(about, radians);
about = parser.Results.about;
radians = parser.Results.radians;

% implementation based on Mitsuba's transform.cpp
%   https://www.mitsuba-renderer.org/repos/mitsuba/files/2489fe4741b22b2bc835bcc8056384328e810256/src/libcore/transform.cpp

% normalize the axis
about = about ./ norm(about);

% precompute a few values
x = about(1);
y = about(2);
z = about(3);
cosAngle = cos(radians);
oneMinusCos = 1 - cosAngle;
sinAngle = sin(radians);

transformation = eye(4);

transformation(1, 1) = x * x + (1 - x * x) * cosAngle;
transformation(2, 1) = x * y * oneMinusCos - z * sinAngle;
transformation(3, 1) = x * z * oneMinusCos + y * sinAngle;

transformation(1, 2) = x * y * oneMinusCos + z * sinAngle;
transformation(2, 2) = y * y + (1 - y * y) * cosAngle;
transformation(3, 2) = y * z * oneMinusCos - x * sinAngle;

transformation(1, 3) = x * z * oneMinusCos - y * sinAngle;
transformation(2, 3) = y * z * oneMinusCos + x * sinAngle;
transformation(3, 3) = z * z + (1 - z * z) * cosAngle;
