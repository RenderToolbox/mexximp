function [element, matchScore] = mexximpFindElement(scene, name, varargin)
%% Search a scene for an element with the given name.
%
% The idea here is to query the scene for an element, by name and
% optionally by type. The name is fuzzy-matched against elements of the
% scene and the element with the best match is returned.  The type
% corresponds to one of the fields of the scene struct and is used to limit
% the scope of the search.
%
% element = mexximpFindElement(scene, name) searches the entire given scene
% for an element with a name like the given name.
%
% element = mexximpFindElement( ... 'type', type) limits the search to
% elements of the given type.  The default is '', no limit.  Valid types
% are: camera, light, material, mesh, embeddedTexture, or node.
%
% Returns a struct representation of the best-matching scene element.  The
% struct will have the following fields:
%   name - the name of the matching element
%   type - the type of the matching element
%   path - the mPath through the scene struct to the matching element
%
% Also returns the fuzzy matching score of the winning element.
%
% See also mexximpStringMatcher mexximpSceneElements mPathGet
%
% [element, matchScore] = mexximpFindElement(scene, name, varargin)
%
% Copyright (c) 2016 mexximp Teame

parser = rdtInputParser();
parser.addRequired('scene', @isstruct);
parser.addRequired('name', @ischar);
parser.addParameter('type', '', @(t)any(strcmp(t, ...
    {'camera', 'light', 'material', 'mesh', 'embeddedTexture', 'node'})));
parser.parse(scene, name, varargin{:});
scene = parser.Results.scene;
name = parser.Results.name;
type = parser.Results.type;

%% Get a flat view of scene elements.
elements = mexximpSceneElements(scene);

% filter by type?
if ~isempty(type)
    isType = strcmp({elements.type}, type);
    elements = elements(isType);
end

%% Query the elements for a name match.
nameMatcher = mexximpStringMatcher(name);
query = {'name', nameMatcher};
[elementIndex, matchScore] = mPathQuery(elements, query);
element = elements(elementIndex);
