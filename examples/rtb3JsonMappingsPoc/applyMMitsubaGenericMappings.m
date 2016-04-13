function mitsubaScene = applyMMitsubaGenericMappings(mitsubaScene, mappings)
%% Apply mappings with the "Generic" destination directly to the scene.
%
% mitsubaScene = applyMMitsubaGenericMappings(mitsubaScene, mappings)
% adjusts the given mMitsuba scene in place, by applying the given Generic
% mappings as scene adjustments.
%
% This generally amounts to translating Generic type names and values to
% Mitsuba type names and values, locating scene elements of the scene
% object and updating their field values based on the mappings properties.
%
% mitsubaScene = applyMMitsubaGenericMappings(mitsubaScene, mappings)
%
% Copyright (c) 2016 RemoteDataToolbox Team

parser = inputParser();
parser.addRequired('mitsubaScene', @isobject);
parser.addRequired('mappings', @isstruct);
parser.parse(mitsubaScene, mappings);
mitsubaScene = parser.Results.mitsubaScene;
mappings = parser.Results.mappings;

%% Select only RenderToolbox3 "Generic" mappings.
isGeneric = strcmp('Generic', {mappings.destination});
genericMappings = mappings(isGeneric);
nGenericMappings = numel(genericMappings);

%% Update the scene, one mapping at a time.
for mm = 1:nGenericMappings
    
    %% Translate Generic type names to Mitsuba type names.
    %   this allows us to find scene elements by Mitsuba element type
    mapping = genericMappings(mm);
    switch mapping.broadType
        case 'meshes'
            type = 'shape';
        case 'lights'
            type = 'emitter';
        case 'materials'
            type = 'bsdf';
        case {'floatTextures', 'spectrumTextures'}
            type = 'texture';
        otherwise
            warning('applyMMitsubaGenericMappings:invalidBroadType', ...
                'Unrecognized broadType <%s> for Generic mapping.', ...
                mapping.broadType);
            continue;
    end
    
    %% Create/find/delete a scene element.
    element = applyMMitsubaMappingOperation(mitsubaScene, mapping, ...
        'type', type);
    if isempty(element)
        continue;
    end
    
    %% Apply Generic mappings special operations.
    switch mapping.operation
        case 'blessAsAreaLight'
            % Turn an existing shape into an emitter.
            %
            % We start with a shape declaration:
            % <shape id="LightY-mesh_0" type="serialized">
            %   <string name="filename" value="Dragon-001Unadjusted.serialized"/>
            %   ...
            % </shape>
            %
            % We add an emitter nested in the mesh
            % <shape id="LightY-mesh_0" type="serialized">
            %   <string name="filename" value="Dragon-001Unadjusted.serialized"/>
            %   <emitter id="LightY-mesh_0-area-light" type="area">
            %     <spectrum filename="/home/ben/render/RenderToolbox3/RenderData/D65.spd" name="radiance"/>
            %   </emitter>
            %   ...
            % </shape>
            
            % the emitter
            emitterId = [element.id '-emitter'];
            emitter = MMitsubaElement(emitterId, 'emitter', 'area');
            emitter.setProperty('radiance', 'spectrum', ...
                getMappingProperty(mapping, 'intensity', '300:1 800:1'));
            
            % nested in the original shape
            element.append(emitter);
            
        case 'blessAsBumpMap'
            %             %% Turn an existing material into a bumpmap material.
            %             %
            %             % We start with a float imagemap texture and a material
            %             % # texture earthTexture
            %             % Texture "earthTexture" "float" "imagemap"
            %             %	"string filename" "earthbump1k-stretch-rgb.exr"
            %             %	"float gamma" [1]
            %             %	"float maxanisotropy" [20]
            %             %	"bool trilinear" "false"
            %             %	"float udelta" [0.0]
            %             %	"float uscale" [1.0]
            %             %	"float vdelta" [0.0]
            %             %	"float vscale" [1.0]
            %             %	"string wrap" "repeat"
            %             % ...
            %             % # material Material-material
            %             % MakeNamedMaterial "Material-material"
            %             %   "string type" "matte"
            %             %   "spectrum Kd" "mccBabel-11.spd"
            %             %
            %             % We enclose the texture in a "scale" texture so that we can
            %             % apply a scale factor.  Then we add this scale texture to the
            %             % existing material.  We also need to sort these elements
            %             % because they depend on each other.
            %             %
            %             % Texture "earthTexture" "float" "imagemap" ...
            %             %
            %             % Texture "earthBumpMap-scaled" "float" "scale"
            %             %    "texture tex1" "earthTexture"
            %             %    "float tex2" [0.1]
            %             %
            %             % # material Material-material
            %             % MakeNamedMaterial "Material-material"
            %             %    "string type" "matte"
            %             %    "spectrum Kd" "mccBabel-11.spd"
            %             %    "texture bumpmap" "earthBumpMap-scaled"
            %
            %             % locate the original texture
            %             textureName = getMappingProperty(mapping, 'texture', '');
            %             originalTexture = mitsubaScene.world.find('Texture', ...
            %                 'name', textureName);
            %
            %             % wrap the original texture in a new scale texture
            %             scaledTextureName = [originalTexture.name '_scaled'];
            %             scaleTexture = MPbrtElement.texture(scaledTextureName, 'float', 'scale');
            %             scaleTexture.setProperty('tex1', 'texture', originalTexture.name);
            %             scaleTexture.setProperty('tex2', 'float', ...
            %                 getMappingProperty(mapping, 'scale', 1));
            %             mitsubaScene.world.prepend(scaleTexture);
            %
            %             % move textures to the front, in dependency order
            %             mitsubaScene.world.prepend(scaleTexture);
            %             mitsubaScene.world.prepend(originalTexture);
            %
            %             % add the scale texture to the blessed material
            %             element.setProperty('bumpmap', 'texture', scaledTextureName);
    end
    
    %% Apply Generic mappings properties as PBRT element parameters.
    switch mapping.broadType
        case 'materials'
            switch mapping.specificType
                case 'matte'
                    element.pluginType = 'diffuse';                    
                    element.setProperty('reflectance', 'spectrum', ...
                        getMappingProperty(mapping, 'diffuseReflectance', '300:0 800:0'));
                    
                case 'anisoward'
                    element.pluginType = 'ward';
                    element.setProperty('diffuseReflectance', 'spectrum', ...
                        getMappingProperty(mapping, 'diffuseReflectance', '300:0 800:0'));
                    element.setProperty('specularReflectance', 'spectrum', ...
                        getMappingProperty(mapping, 'specularReflectance', '300:0 800:0'));
                    element.setProperty('alphaU', 'float', ...
                        getMappingProperty(mapping, 'alphaU', 0.15));
                    element.setProperty('alphaV', 'float', ...
                        getMappingProperty(mapping, 'alphaV', 0.15));
                    
                case 'metal'
                    element.pluginType = 'roughconductor';
                    element.setProperty('eta', 'spectrum', ...
                        getMappingProperty(mapping, 'eta', '300:0 800:0'));
                    element.setProperty('k', 'spectrum', ...
                        getMappingProperty(mapping, 'k', '300:0 800:0'));
                    element.setProperty('alpha', 'float', ...
                        getMappingProperty(mapping, 'roughness', .05));
            end
            
        case 'lights'
            switch mapping.specificType
                case {'point', 'spot'}
                    element.pluginType = mapping.specificType;
                    element.setProperty('intensity', 'spectrum', ...
                        getMappingProperty(mapping, 'intensity', '300:0 800:0'));
                    
                case 'directional'
                    element.pluginType = 'directional';
                    element.setProperty('irradiance', 'spectrum', ...
                        getMappingProperty(mapping, 'intensity', '300:0 800:0'));
            end
            
        case {'floatTextures', 'spectrumTextures'}
            
            switch mapping.specificType
                case 'bitmap'
                    element.pluginType = 'bitmap';
                    element.setProperty('filename', 'string', ...
                        getMappingProperty(mapping, 'filename', ''));
                    element.setProperty('gamma', 'float', ...
                        getMappingProperty(mapping, 'gamma', 1));
                    element.setProperty('maxAnisotropy', 'float', ...
                        getMappingProperty(mapping, 'maxAnisotropy', 8));
                    element.setProperty('uoffset', 'float', ...
                        getMappingProperty(mapping, 'offsetU', 0));
                    element.setProperty('voffset', 'float', ...
                        getMappingProperty(mapping, 'offsetV', 0));
                    element.setProperty('uscale', 'float', ...
                        getMappingProperty(mapping, 'scaleU', 1));
                    element.setProperty('vscale', 'float', ...
                        getMappingProperty(mapping, 'scaleV', 1));
                    element.setProperty('wrap', 'string', ...
                        getMappingProperty(mapping, 'wrapMode', 'repeat'));
                    element.setProperty('filterType', 'string', ...
                        getMappingProperty(mapping, 'filterMode', 'trilinear'));
                    
                case 'checkerboard'
                    element.pluginType = 'checkerboard';
                    
                    element.setProperty('uoffset', 'float', ...
                        getMappingProperty(mapping, 'offsetU', 0));
                    element.setProperty('voffset', 'float', ...
                        getMappingProperty(mapping, 'offsetV', 0));
                    element.setProperty('uscale', 'float', ...
                        getMappingProperty(mapping, 'checksPerU', 2) / 2);
                    element.setProperty('vscale', 'float', ...
                        getMappingProperty(mapping, 'checksPerV', 2) / 2);
                    element.setProperty('color1', 'spectrum', ...
                        getMappingProperty(mapping, 'oddColor', '300:0 800:0'));
                    element.setProperty('color2', 'spectrum', ...
                        getMappingProperty(mapping, 'evenColor', '300:0 800:0'));
            end
    end
end
