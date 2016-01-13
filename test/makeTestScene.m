%% Make Mexximp scene from scratch.
%
% This is intended as a well-known input or "fixture" to be used by the
% accompanying tests.  It's not inteded to be a general-purpose utility.
%
% It's also an explicit and long-winded deomonstration of how to construct
% a valid scene.  Being explicit and long-winded seems good to do once.
% Surely we will want utilities to make this easier going forward.
%
% BSH
function scene = makeTestScene()

% mexximpConstants gives us template structs to fill in
scene = mexximpConstants('scene');

%% Camera.
camera = mexximpConstants('camera');
camera.name = 'camera';
camera.position = [0 0 -10];
camera.lookAtDirection = [0 0 1];
camera.upDirection = [0 1 0];
camera.aspectRatio = [1 1 1];
camera.horizontalFov = pi()/4;
camera.clipPlaneFar = 1000;
camera.clipPlaneNear = 0.1;
scene.cameras = camera;

%% Lights.
topLight = mexximpConstants('light');
topLight.name = 'topLight';
topLight.position = [0 10 0];
topLight.type = 'spot';
topLight.lookAtDirection = [0 -1 0];
topLight.innerConeAngle = pi()/6;
topLight.outerConeAngle = pi()/3;
topLight.constantAttenuation = 1;
topLight.linearAttenuation = 0;
topLight.quadraticAttenuation = 1;
topLight.ambientColor = [0 0 0];
topLight.diffuseColor = [1 .5 .5];
topLight.specularColor = [1 .5 .5];

rearLight = mexximpConstants('light');
rearLight.name = 'rearlight';
rearLight.position = [0 0 -20];
rearLight.type = 'directional';
rearLight.lookAtDirection = [0 0 1];
rearLight.innerConeAngle = 0;
rearLight.outerConeAngle = 0;
rearLight.constantAttenuation = 1;
rearLight.linearAttenuation = 0;
rearLight.quadraticAttenuation = 0;
rearLight.ambientColor = [0 0 0];
rearLight.diffuseColor = [.5 .5 1];
rearLight.specularColor = [.5 .5 1];

scene.lights = [topLight rearLight];

%% Materials.
grayShiny = mexximpConstants('material');
grayShiny.properties = makeUberMaterial('gray', ...
    [0 0 0 1], ...
    [.5 .5 .5 1], ...
    [.5 .5 .5 1], ...
    [0 0 0 1], ...
    [0 0 0 0], ...
    10, ...
    1);

redMatte = mexximpConstants('material');
redMatte.properties = makeUberMaterial('gray', ...
    [0 0 0 1], ...
    [1 0 0 1], ...
    [0 0 0 1], ...
    [0 0 0 1], ...
    [0 0 0 0], ...
    0, ...
    1);

scene.materials = [grayShiny, redMatte];

%% Meshes.
plane = makeMesh('plane', 0);
plane.vertices = [ ...
    -1 -1 0;
    -1 +1 0;
    +1 -1 0;
    +1 +1 0]';
% normals perpendicular to plane, towards camera
plane.normals = [ ...
    0 0 -1;
    0 0 -1;
    0 0 -1;
    0 0 -1]';
plane.faces(1) = makeFace([0 2 1]);
plane.faces(2) = makeFace([1 2 3]);
plane.primitiveTypes = mexximpConstants('meshPrimitive');
plane.primitiveTypes.triangle = true;

cube = makeMesh('cube', 1);
cube.vertices = [ ...
    -1 -1 -1;
    -1 -1 +1;
    -1 +1 -1;
    -1 +1 +1;
    +1 -1 -1;
    +1 -1 +1;
    +1 +1 -1;
    +1 +1 +1]';
% normals along cube diagonals, away from center
cube.normals = sqrt(3) * cube.vertices;
cube.faces(1) = makeFace([0 6 2]);
cube.faces(2) = makeFace([0 4 6]);
cube.faces(3) = makeFace([1 5 4]);
cube.faces(4) = makeFace([1 4 0]);
cube.faces(5) = makeFace([3 5 1]);
cube.faces(6) = makeFace([3 7 5]);
cube.faces(7) = makeFace([1 0 2]);
cube.faces(8) = makeFace([1 2 3]);
cube.faces(9) = makeFace([7 6 5]);
cube.faces(10) = makeFace([6 4 5]);
cube.faces(11) = makeFace([3 2 7]);
cube.faces(12) = makeFace([2 6 7]);
cube.primitiveTypes = mexximpConstants('meshPrimitive');
cube.primitiveTypes.triangle = true;

scene.meshes = [plane, cube];

%% Embedded Textures.
% we don't need embedded textures

%% Node Hierarchy.
rootNode = mexximpConstants('node');
rootNode.name = 'root';
rootNode.transformation = eye(4);

% node with same name as camera will contain the camera
cameraNode = mexximpConstants('node');
cameraNode.name = camera.name;
cameraNode.transformation = eye(4);

% node with same name as a light will contain the light
topLightNode = mexximpConstants('node');
topLightNode.name = topLight.name;
topLightNode.transformation = eye(4);

rearLightNode = mexximpConstants('node');
rearLightNode.name = rearLight.name;
rearLightNode.transformation = eye(4);

% nodes instantiante meshes using indexes into scene.meshes
backdropNode = mexximpConstants('node');
backdropNode.name = 'backdrop';
backdropNode.transformation = makeLookAt([0 0 10], [0 0 0], [0 1 0]);
backdropNode.meshIndices = uint32(0);

objectNode = mexximpConstants('node');
objectNode.name = 'object';
objectNode.transformation = makeLookAt([0 0 5], [0 0 0], [0 1 0]);
objectNode.meshIndices = uint32(1);

rootNode.children = [cameraNode, ...
    topLightNode, ...
    rearLightNode, ...
    backdropNode, ...
    objectNode];
scene.rootNode = rootNode;

%% Make a face struct with the given vertex indices.
function face = makeFace(indices)
face = mexximpConstants('face');
face.nIndices = numel(indices);
face.indices = uint32(indices);


%% Make a right-handed lookat transformation.
function transformation = makeLookAt(eye, target, up)
z = normalize(eye - target);
x = normalize(cross(up, z));
y = cross(z, x);

% mexximp will convert Matlab column-major to Assimp row-major
transformation = [ ...
    x(1), y(1), z(1), 0; ...
    x(2), y(2), z(2), 0; ...
    x(3), y(3), z(3), 0; ...
    -dot(x, eye), -dot(y, eye), -dot(z, eye), 1];


%% Normalize a vector.
function normalized = normalize(original)
normalized = original ./ norm(original);

%% Pack up a mesh including some defaults.
function mesh = makeMesh(name, materialIndex)
mesh = mexximpConstants('mesh');
mesh.name = name;
mesh.materialIndes = materialIndex;

mesh.tangents = zeros(3,0);
mesh.bitangents = zeros(3,0);

mesh.colors0 = zeros(4,0);
mesh.colors1 = zeros(4,0);
mesh.colors2 = zeros(4,0);
mesh.colors3 = zeros(4,0);
mesh.colors4 = zeros(4,0);
mesh.colors5 = zeros(4,0);
mesh.colors6 = zeros(4,0);
mesh.colors7 = zeros(4,0);

mesh.textureCoordinates0 = zeros(3,0);
mesh.textureCoordinates1 = zeros(3,0);
mesh.textureCoordinates2 = zeros(3,0);
mesh.textureCoordinates3 = zeros(3,0);
mesh.textureCoordinates4 = zeros(3,0);
mesh.textureCoordinates5 = zeros(3,0);
mesh.textureCoordinates6 = zeros(3,0);
mesh.textureCoordinates7 = zeros(3,0);

%% Pack up properties for an "uber" material.
function properties = makeUberMaterial(name, ambient, diffuse, specular, emissive, reflective, shininess, refractIndex)
% a material is a flexible collection of "properties"
properties(1) = struct( ...
    'key', 'name', ...
    'dataType', 'string', ...
    'data', name, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(2) = struct( ...
    'key', 'shading_model', ...
    'dataType', 'integer', ...
    'data', 2, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(3) = struct( ...
    'key', 'two_sided', ...
    'dataType', 'integer', ...
    'data', 1, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(4) = struct( ...
    'key', 'enable_wireframe', ...
    'dataType', 'integer', ...
    'data', 0, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(5) = struct( ...
    'key', 'ambient', ...
    'dataType', 'float', ...
    'data', ambient, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(6) = struct( ...
    'key', 'diffuse', ...
    'dataType', 'float', ...
    'data', diffuse, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(7) = struct( ...
    'key', 'specular', ...
    'dataType', 'float', ...
    'data', specular, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(8) = struct( ...
    'key', 'emissive', ...
    'dataType', 'float', ...
    'data', emissive, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(9) = struct( ...
    'key', 'reflective', ...
    'dataType', 'float', ...
    'data', reflective, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(10) = struct( ...
    'key', 'shininess', ...
    'dataType', 'float', ...
    'data', shininess, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(11) = struct( ...
    'key', 'reflectivity', ...
    'dataType', 'float', ...
    'data', 0, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
properties(12) = struct( ...
    'key', 'refract_i', ...
    'dataType', 'float', ...
    'data', refractIndex, ...
    'textureSemantic', 'none', ...
    'textureIndex', 0);
