%% Sandbox.  Dragon scene mappings as Matlab struct -> JSON file.
%
% I am thinking about a new way to do rtb mappings, in the world of
% Mexximp.
%
% I think we should no longer do our own text parsing.  Instead,
% we should use JSON.  This way we can delete parsing code and use jsonlab
% instead.  We can also convert JSON <-> struct in both directions.  We can
% also access mappings with other tools that understand JSON, if that ever
% comes up.
%
% So here is a stab at some struct/JSON mappings.  I'll try to reproduce
% our original DragonMappings.txt in this new, shinier style.  I'll also
% include some PBRT defaults which come from our original
% PBRTDefaultAdjustments.xml.
%
% Here are some additional differences I want to introduce:
%
% - Instead of treating mappings line by line, add some structure: some
%   top-level structure to identify the scene element of interest and what
%   to do with it (create it fresh, find it and update it, delete it,
%   others?).  Then some nested structure to specify zero or more
%   properties of that element.  We already gropu delcarations and
%   properties when processing mappings now.  Let's just make this clear
%   and explicit in the mappings syntax.
%
% - Instead of identifying elements by strict id matching, which is
%   brittle, allow a few ways to identify elements: by name/id fuzzy
%   matching, by type, and by index.  Specifying all three is overkill.
%   Sometimes it will make most sense to use an element's name, like when
%   looking at a name specified in Blender.  Sometimes it will be good to
%   provide the element's type as well, to narrow the search and eliminate
%   false matches.  Sometimes it will be more natural to identify an
%   element by type and index, like when looking at a mexximp scene struct.
%   Sometimes, just the type will do, like when referring to the single
%   camera and we don't care what its name is.  So name, type, and index
%   will proscribe a well-defined element *search*, rather than a
%   brittle id match.
%


%% For reference, I want to look at the original Dragon scene.
clear;
clc;

%originalScene = which('Dragon.blend');
originalScene = which('CoordinatesTest.blend');

% Assimp to the max!  Clean up the scene.
importFlags = mexximpConstants('postprocessStep');
importFlags.calculateTangentSpace = true;
importFlags.joinIdenticalVertices = true;
importFlags.triangulate = true;
importFlags.generateNormals = true;
importFlags.validateDataStructure = true;
importFlags.fixInfacingNormals = true;
importFlags.findInvalidData = true;
importFlags.generateUVCoordinates = true;

scene = mexximpImport(originalScene, importFlags);
scene.rootNode = mexximpFlattenNodes(scene);

%% In the old Collada Mappings, we sometimes need to flip coordinates.
% Collada {
%     % swap camera handedness from Blender's Collada output
%     Camera:scale|sid=scale = -1 1 1
% }
%
% What we can do now is edit the root node instead of the camera.

% top-level structure to identify the scene element and operation
flip.index = 1;
flip.broadType = 'nodes';
flip.operation = 'update';
flip.destination = 'mexximp';

% zero or more nested properties of the element
flip.properties(1).name = 'transformation';
flip.properties(1).valueType = 'matrix';
flip.properties(1).value = mexximpScale([-1 1 1]);


%% We need to "bless" two existing meshes to make them area lights.
% Generic {
%     % make area lights with daylight spectrum
%     LightX-mesh:light:area
%     LightX-mesh:intensity.spectrum = D65.spd
%     LightY-mesh:light:area
%     LightY-mesh:intensity.spectrum = D65.spd
%     ...
% }

blessX.name = 'LightX';
blessX.broadType = 'meshes';
blessX.operation = 'blessThisMesh';
blessX.properties(1).name = 'intensity';
blessX.properties(1).valueType = 'spectrum';
blessX.properties(1).value = 'D65.spd';

blessY.name = 'LightY';
blessY.broadType = 'meshes';
blessY.operation = 'blessThisMesh';
blessY.properties(1).name = 'intensity';
blessY.properties(1).valueType = 'spectrum';
blessY.properties(1).value = 'D65.spd';


%% We need set the type and spectrum for two materials.
% Generic {
%     ...
%     % make the area lights perfect reflectors, too
%     ReflectorMaterial-material:material:matte
%     ReflectorMaterial-material:diffuseReflectance.spectrum = 300:1.0 800:1.0
%
%     % make gray walls and floor
%     WallMaterial-material:material:matte
%     WallMaterial-material:diffuseReflectance.spectrum = 300:0.75 800:0.75
%     FloorMaterial-material:material:matte
%     FloorMaterial-material:diffuseReflectance.spectrum = 300:0.5 800:0.5
%
%     % make a tan dragon
%     DragonMaterial-material:material:matte
%     DragonMaterial-material:diffuseReflectance.spectrum = mccBabel-1.spd
%     ...
% }

reflectorMaterial.name = 'ReflectorMaterial';
reflectorMaterial.broadType = 'materials';
reflectorMaterial.specificType = 'matte';
reflectorMaterial.operation = 'update';
reflectorMaterial.properties(1).name = 'diffuseReflectance';
reflectorMaterial.properties(1).valueType = 'spectrum';
reflectorMaterial.properties(1).value = '300:1.0 800:1.0';

wallMaterial.name = 'WallMaterial';
wallMaterial.broadType = 'materials';
wallMaterial.specificType = 'matte';
wallMaterial.operation = 'update';
wallMaterial.properties(1).name = 'diffuseReflectance';
wallMaterial.properties(1).valueType = 'spectrum';
wallMaterial.properties(1).value = '300:0.75 800:0.75';

floorMaterial.name = 'FloorMaterial';
floorMaterial.broadType = 'materials';
floorMaterial.specificType = 'matte';
floorMaterial.operation = 'update';
floorMaterial.properties(1).name = 'diffuseReflectance';
floorMaterial.properties(1).valueType = 'spectrum';
floorMaterial.properties(1).value = '300:0.5 800:0.5';

dragonMaterial.name = 'DragonMaterial';
dragonMaterial.broadType = 'materials';
dragonMaterial.specificType = 'matte';
dragonMaterial.operation = 'update';
dragonMaterial.properties(1).name = 'diffuseReflectance';
dragonMaterial.properties(1).valueType = 'spectrum';
dragonMaterial.properties(1).value = 'mccBabel-1.spd';

%% For POC, add an additional property to one of the mappings.
% This will let us see what happens when we write a JSON array of
% properties, as opposed to a single properties object.
dragonMaterial.properties(2).name = 'extraProperty';
dragonMaterial.properties(2).valueType = 'float';
dragonMaterial.properties(2).value = 33.567;

%% For POC, modify a node that's not the root node.
% This will let us see what happens when we have nested node adjustments.
dragonNode.name = 'dragon';
dragonNode.broadType = 'nodes';
dragonNode.operation = 'update';
dragonNode.destination = 'mexximp';
dragonNode.properties(1).name = 'transformation';
dragonNode.properties(1).valueType = 'matrix';
dragonNode.properties(1).operation = '*=';
dragonNode.properties(1).value = mexximpIdentity();

%% Add some PBRT XML "default adjustments".
%     <SurfaceIntegrator id="integrator" type="directlighting"/>
%
%     <Sampler id="sampler" type="lowdiscrepancy">
%         <parameter name="pixelsamples" type="integer">8</parameter>
%     </Sampler>
%
%     <PixelFilter id="filter" type="gaussian">
%         <parameter name="alpha" type="float">2</parameter>
%         <parameter name="xwidth" type="float">2</parameter>
%         <parameter name="ywidth" type="float">2</parameter>
%     </PixelFilter>
%
% These set up scene elements that mexximp won't know about.
integrator.name = 'integrator';
integrator.broadType = 'SurfaceIntegrator';
integrator.index = 1;
integrator.specificType = 'directlighting';
integrator.operation = 'create';
integrator.destination = 'PBRT';

sampler.name = 'sampler';
sampler.broadType = 'Sampler';
sampler.index = 1;
sampler.specificType = 'lowdiscrepancy';
sampler.operation = 'create';
sampler.destination = 'PBRT';
sampler.properties(1).name = 'pixelsamples';
sampler.properties(1).valueType = 'integer';
sampler.properties(1).value = 8;

filter.name = 'filter';
filter.broadType = 'PixelFilter';
filter.index = 1;
filter.specificType = 'gaussian';
filter.operation = 'create';
filter.destination = 'PBRT';
filter.properties(1).name = 'alpha';
filter.properties(1).valueType = 'float';
filter.properties(1).value = 2;
filter.properties(2).name = 'xwidth';
filter.properties(2).valueType = 'float';
filter.properties(2).value = 2;
filter.properties(3).name = 'ywidth';
filter.properties(3).valueType = 'float';
filter.properties(3).value = 2;

%% Now we can write the mappings file.
% Just pack up all the mappings as a struct array and dump out to JSON.
% That's it!
allMappings = { ...
    flip, ...
    blessX, ...
    blessY, ...
    reflectorMaterial, ...
    wallMaterial, ...
    floorMaterial, ...
    dragonMaterial, ...
    dragonNode, ...
    integrator, ...
    sampler, ...
    filter};

pathHere = fileparts(which('writeDragonJsonMappings'));
mappingsFile = fullfile(pathHere, 'DragonMappings.json');
savejson('', allMappings, ...
    'FileName', mappingsFile, ...
    'ArrayIndent', 1, ...
    'ArrayToStrut', 0);

%% And we can read it back.
% Do we get the same as we wrote out, plus filled in defaults?
validatedMappings = parseJsonMappings(mappingsFile);

%% We can apply "mexximp" mappings directly to the scene.
scene = applyMexximpMappings(scene, validatedMappings);

%% We can convert Generic mappings to renderer-specific.

%% And we can organize remaining mappings as scene element adjustments.
adjustments = mexximpConstants('scene');
nMappings = numel(validatedMappings);
for mm = 1:nMappings
    mapping = validatedMappings(mm);
    element = findSceneElement(scene, ...
        'name', mapping.name, ...
        'broadType', mapping.broadType, ...
        'index', mapping.index);
    if isempty(element)
        % not a mexximp element, add manually to the adjustments
        adjustments.(mapping.broadType)(mapping.index) = mapping;
    else
        % add to adjustments at the same path in the scene struct
        adjustments = mPathSet(adjustments, element.path, mapping);
    end
end

%% Next we want to write a PBRT scene.
elements = mexximpSceneElements(scene);
elementTypes = {elements.type};
pbrtScene = MPbrtScene();

pathHere = fileparts(which('writeDragonJsonMappings'));

% convert cameras to mPbrt
cameraInds = find(strcmp('cameras', elementTypes));
for cc = cameraInds
    pbrtNode = mexximpCameraToMPbrt(scene, elements(cc));
    pbrtScene.overall.append(pbrtNode);
end

% convert materials to mPbrt
materialInds = find(strcmp('materials', elementTypes));
for mm = materialInds
    pbrtNode = mexximpMaterialToMPbrt(scene, elements(mm), ...
        'type', 'anisoward', ...
        'diffuse', 'Kd', ...
        'specular', 'Ks');
    pbrtScene.overall.append(pbrtNode);
end

% convert lights to mPbrt
lightInds = find(strcmp('lights', elementTypes));
for ll = lightInds
    pbrtNode = mexximpLightToMPbrt(scene, elements(ll));
    pbrtScene.world.append(pbrtNode);
end

% convert meshes to mPbrt object declarations
meshInds = find(strcmp('meshes', elementTypes));
for mm = meshInds
    pbrtNode = mexximpMeshToMPbrt(scene, elements(mm), ...
        'workingFolder', pathHere, ...
        'meshSubfolder', 'pbrt-geometry', ...
        'rewriteMeshData', true);
    pbrtScene.world.append(pbrtNode);
end

% % convert nodes to mPbrt object instances
% nodeInds = find(strcmp('nodes', elementTypes));
% for nn = nodeInds
%     pbrtNode = mexximpNodeToMPbrt(scene, elements(n));
%     pbrtScene.world.append(pbrtNode);
% end

% dump pbrt to file
pbrtFile = fullfile(pathHere, 'poc.pbrt');
pbrtScene.printToFile(pbrtFile);
