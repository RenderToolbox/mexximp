function transformation = mexximpIdentity()
%% Build the 4x4 identity matrix.
%
% transformation = mexximpIdentity() builds the 4x4 identity
% transformation, which is a do-nothing or placeholder for a
% transformation.
%
% This function is essentially documentation of the fact that eye(4) counts
% as a Mexximp transformation.
%
% transformation = mexximpIdentity()
%
% Copyright (c) 2016 mexximp Team

transformation = eye(4);
