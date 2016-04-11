function transformed = mexximpApplyTransform(vertices, transformation)
%% Apply a 4x4 transformation to some vertices.
%
% transformed = mexximpApplyTransform(vertices, transformation) applies the
% given 4x4 transformation matrix to the given vertices.  The given
% vertices must be a matrix of points of the form 
% [x1 ... xn; y1 ... yn; z1... zn].
%
% Assumes the "w" component is 1, so don't try projection transformations.
%
% Returns a matrix of transformed points of the same size as the given
% vertices.
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('vertices', @(v) isnumeric(v) && 3 == size(v, 1));
parser.addRequired('transformation', @(t) isnumeric(t) && all([4 4] == size(t)));
parser.parse(vertices, transformation);
vertices = parser.Results.vertices;
transformation = parser.Results.transformation;

% pad out the vertices with w = 1
nVertices = size(vertices, 2);
paddedVertices = ones(4, nVertices);
paddedVertices(1:3, :) = vertices;

% transform is matrix multiply
paddedTransformed = (paddedVertices' * transformation)';

% discard the w component
transformed = paddedTransformed(1:3, :);
