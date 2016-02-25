function adjustMitsubaDocument(idMap, adjustments, scene)
%% Modify a Mistuba scene document with adjustments.
%
% The idea here is to take a struct array of "adjustments" and apply it to
% the Mitsuba scene, which is represented in memory by the given idMap.
% This will produce a variant of the scene which can then be written to
% disk and rendered.  We also need access to the mexximp scene struct
% because it contains information about the names and indexes of elements
% in the scene which are not always apparaent from the adjustments
% themselves.
%
% adjustMitsubaDocument(idMap, adjustments, scene) modifies the Mitsuba
% scene document represented by the given idMap, as specified in the given
% struct array of adjustments.  The given scene is used for reference and
% not modified.
%
% adjustMitsubaDocument(idMap, adjustments, scene)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('idMap', @isobject);
parser.addRequired('adjustments', @isstruct);
parser.addRequired('scene', @isstruct);
parser.parse(idMap, adjustments, scene);
idMap = parser.Results.idMap;
adjustments = parser.Results.adjustments;
scene = parser.Results.scene;

%% Organize Mitsuba document elements for easy search and access.
mitsubaElements = struct( ...
    'id', idMap.keys(), ...
    'element', idMap.values());

%% Apply adjustments to the document one at a time.
for ii = 1:numel(adjustments)
    % pull out one adjustment to apply
    adj = adjustments(ii);
    
    % choose a document id for this adjustment
    %   by fuzzy matching and convention
    elementId = chooseElementId(adj.name, adj.broadType, adj.specificType, mitsubaElements, scene);
    adj.name = elementId;
    
    if strcmp('area-light', adj.operator)
        % area lights are a special case where we we "bless a mesh":
        %   declare an emitter nested in a shape node
        %   redirect configuration to the nested emitter
        
        % add a new, nested area emitter, with its own id
        meshId = adj.name;
        emitterId = [adj.name '-area-light'];
        path = {meshId, ...
            PrintPathPart(':', 'emitter', 'id', emitterId), ...
            PrintPathPart('.', 'type')};
        SetSceneValue(idMap, path, 'area', true, '=');
        
        % add the new emitter to the idMap
        path = {meshId, ...
            PrintPathPart(':', 'emitter', 'id', emitterId)};
        emitterNode = SearchScene(idMap, path);
        idMap(emitterId) = emitterNode;
        
        % continue with config, applied to the new emitter
        adj.name = emitterId;
        adj.broadType = 'emitter';
        applyAdjustment(idMap, adj);
        
        continue;
    end
    
    if strcmp('bumpmap', adj.operator)
        % bump maps are a special case:
        %   we start with an existing material and an existing texture
        %   make a "pass through" scale texture to scale the original
        %   we make a bumpmap and point it at the material and scale texture
        
        % make a new scale texture that scales the original texture
        textureName = queryAdjustmentValue(adj, 'textureID', 'value', '');
        textureId = chooseElementId(textureName, 'texture', '', mitsubaElements, scene);
        scaledId = [textureId '-scaled'];
        declareElement(idMap, scaledId, 'texture', 'scale');
        configureElement(idMap, scaledId, 'value', 'ref', textureId);
        scaleFactor = queryAdjustmentValue(adj, 'scale', 'value', '1');
        configureElement(idMap, scaledId, 'scale', 'float', scaleFactor);
        
        % let the new bump map steal the name of the original material
        %   give the original a new "inner" id
        materialName = queryAdjustmentValue(adj, 'materialID', 'value', '');
        materialId = chooseElementId(materialName, 'material', '', mitsubaElements, scene);
        innerMaterialId = [materialId '-inner'];
        innerMaterial = idMap(materialId);
        innerMaterial.setAttribute('id', innerMaterialId);
        idMap(innerMaterialId) = innerMaterial;
        idMap.remove(materialId);
        
        % make a new bump map material
        %   point it at the original material and the scale texture
        declareElement(idMap, materialId, 'bsdf', 'bumpmap');
        configureElement(idMap, materialId, 'texture', 'ref', scaledId);
        configureElement(idMap, materialId, 'bsdf', 'ref', innerMaterialId);
        
        continue;
    end
    
    % not a special case: just declare and configure elements as needed
    applyAdjustment(idMap, adj);
end


%% Use fuzzy matching and convention to choose a document element id.
function elementId = chooseElementId(name, broadType, specificType, mitsubaElements, scene)

% sometimes we need to build an id based on its index in the scene
if strcmp('mesh', broadType) || strcmp('area', specificType)
    % convert adjustment name to mesh id
    [element, elementScore] = mexximpFindElement(scene, name, 'type', 'mesh');
    elementIndex = element.path{end};
    idToMatch = sprintf('meshId%d_0', elementIndex - 1);
    
elseif strcmp('material', broadType) || strcmp('bsdf', broadType)
    % convert adjustment name to material id
    [element, elementScore] = mexximpFindElement(scene, name, 'type', 'material');
    elementIndex = element.path{end};
    idToMatch = sprintf('m%d%s', elementIndex - 1, element.name);
    
else
    % use adjustment name as-is
    elementScore = 1;
    idToMatch = name;
end

% did we fail to build an id based on its index?
%   the cut-off 0.3 is a hack
if elementScore < 0.3
    elementId = name;
    return;
end

% choose the best-matching id out of the Mitsuba document
idMatcher = mexximpStringMatcher(idToMatch);
idQuery = {'id', idMatcher};
[mitsubaIndex, mitsubaScore] = mPathQuery(mitsubaElements, idQuery);

% did we fail to choose a best-matching id?
%   the cut-off 0.7 is a hack
if mitsubaScore < .7
    elementId = name;
    return;
end
elementId = mitsubaElements(mitsubaIndex).id;


%% Make sure the DOM contains a node for the given object.
function ensureDomNode(idMap, id, nodeName)
if ~idMap.isKey(id)
    docNode = idMap('document');
    docRoot = docNode.getDocumentElement();
    objectNode = CreateElementChild(docRoot, nodeName, id, 'first');
    idMap(id) = objectNode;
end


% Apply a whole adjustment struct to the DOM.
function applyAdjustment(idMap, adj)

% need to declare element that doesn't exist yet?
if strcmp(adj.operator, 'declare')
    declareElement(idMap, adj.name, adj.broadType, adj.specificType);
end

% nested properties for the declared/existing element
for ii = 1:numel(adj.value)
    nested = adj.value(ii);
    configureElement(idMap, adj.name, nested.name, nested.specificType, nested.value);
end


%% Add an object declaration to the DOM.
function declareElement(idMap, id, broadType, specificType)

if isempty(broadType)
    return;
end

% make sure the DOM has a node for this object
ensureDomNode(idMap, id, broadType);

% set the node name
path = {id, PrintPathPart('$')};
SetSceneValue(idMap, path, broadType, true, '=');

if nargin >= 4
    % set the node type
    path = {id, PrintPathPart('.', 'type')};
    SetSceneValue(idMap, path, specificType, true, '=');
end


%% Configure an existing element of the DOM.
function configureElement(idMap, id, name, type, value)

if ~idMap.isKey(id)
    error('adjustMitsubaDocument:missingElement', ...
        'Mitsuba document has no element with id <%s>', id);
end

if strcmp(type, 'texture') || strcmp(type, 'ref')
    % Mitsuba textures use a "ref" node type and "id" instead of "value"
    type = 'ref';
    flavor = 'id';
    
elseif 0 == numel(StringToVector(value)) ...
        && ~strcmp('string', type) ...
        && ~strcmp('boolean', type)
    % Mitsuba sometimes takes a "filename" instead of a "value"
    %   detect this as non-numeric value,
    %   with a non-string, non-boolean type
    flavor = 'filename';
    
else
    % Mitsuba stores most things in the "value" attribute.
    flavor = 'value';
end

% set the type in the node name and the "name" attribute
%   store the value in the attribute of the correct flavor
path = {id, ...
    PrintPathPart(':', type, 'name', name), ...
    PrintPathPart('.', flavor)};
disp(path);
SetSceneValue(idMap, path, value, true, '=');
