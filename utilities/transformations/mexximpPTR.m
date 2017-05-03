function transformation = mexximpPTR(pan, tilt, roll, lookAt, upDir)
%% Build a 4x4 pan-tilt-roll matrix.
%
% transformation = mexximpPTR(pan, tilt, roll, lookAt, upDir) 
% builds a 4x4 matrix that pans, tilts and rolls a given camera 
% defined in terms of lookAt and upDir. The camera is assumed to be at the
% origin (0,0,0). 
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('pan', @isnumeric);
parser.addRequired('tilt', @isnumeric);
parser.addRequired('roll', @isnumeric);
parser.addRequired('lookAt', @(d) isnumeric(d) && 3 == numel(d));
parser.addRequired('upDir', @(d) isnumeric(d) && 3 == numel(d));

parser.parse(pan, tilt, roll, lookAt, upDir);
upDir = parser.Results.upDir;
lookAt = parser.Results.lookAt;

pan = parser.Results.pan;
tilt = parser.Results.tilt;
roll = parser.Results.roll;

rollMat = mexximpRotate(lookAt,roll);

t1 = cross(lookAt,upDir);
tiltMat = mexximpRotate(t1,tilt);

% We pick the vector that has the smallest angle with 
% the up direction
t2 = cross(lookAt,t1);
if dot(t2,upDir) < -dot(t2,upDir);
    t2 = -t2;
end

panMat = mexximpRotate(t2,pan);



transformation = rollMat*panMat*tiltMat;
