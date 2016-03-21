function pbrtScene = applyMPbrtGenericMappings(pbrtScene, mappings)
%% Apply mappings with the "Generic" destination directly to the scene.
%
% pbrtScene = applyMPbrtGenericMappings(pbrtScene, mappings) adjusts the
% given mPbrt pbrtScene in place, by applying the given Generic mappings as
% scene adjustments.
%
% This generally amounts to translating Generic type names and values to
% PBRT type names and values, locating scene elements of the scene object
% and updating their field values based on the mappings properties.
%
% pbrtScene = applyMPbrtGenericMappings(pbrtScene, mappings)
%
% Copyright (c) 2016 RemoteDataToolbox Team

parser = inputParser();
parser.addRequired('pbrtScene', @isobject);
parser.addRequired('mappings', @isstruct);
parser.parse(pbrtScene, mappings);
pbrtScene = parser.Results.pbrtScene;
mappings = parser.Results.mappings;

%% Select only RenderToolbox3 "Generic" mappings.
isGeneric = strcmp('Generic', {mappings.destination});
genericMappings = mappings(isGeneric);
nGenericMappings = numel(genericMappings);

%% Update the scene, one mapping at a time.
for mm = 1:nGenericMappings
    
    %% Translate Generic type names to PBRT identifier names.
    %   this allows us to find mPbrtScene elements by PBRT identifier
    mapping = genericMappings(mm);
    switch mapping.broadType
        case 'meshes'
            identifier = 'Object';
        case 'lights'
            identifier = 'LightSource';
        case 'materials'
            identifier = 'MakeNamedMaterial';
        case {'floatTexture', 'spectrumTexture'}
            identifier = 'Texture';
        otherwise
            warning('applyMPbrtGenericMappings:invalidBroadType', ...
                'Unrecognized broadType <%s> for Generic mapping.', ...
                mapping.broadType);
            continue;
    end
    
    %% Create/find/delete a scene element.
    element = applyMPbrtMappingOperation(pbrtScene, mapping, ...
        'identifier', identifier);
    if isempty(element)
        continue;
    end
    
    %% Apply Generic mappings special operations.
    switch mapping.operation
        case 'blessAsAreaLight'
            % Turn an existing Object into an AreaLightSource
            %
            % We start with an Object declaration and instance:
            %   # 1_LightX
            %   ObjectBegin "1_LightX"
            %       NamedMaterial "1_ReflectorMaterial"
            %       Include "pbrt-geometry/1_LightX.pbrt"
            %   ObjectEnd
            %   ...
            %   # 1_LightX
            %   AttributeBegin
            %       ConcatTransform [-0.500001 0.000000 -0.866025 0.000000 0.000000 1.000000 0.000000 0.000000 0.866025 0.000000 -0.500001 0.000000 -11.000000 0.000000 11.000000 1.000000]
            %       ObjectInstance "1_LightX"
            %   AttributeEnd
            %
            % We combine these into one Attribute with an AreaLightSource:
            %   AttributeBegin
            %       ConcatTransform [-0.500001 0.000000 -0.866025 0.000000 0.000000 1.000000 0.000000 0.000000 0.866025 0.000000 -0.500001 0.000000 -11.000000 0.000000 11.000000 1.000000]
            %       AreaLightSource "diffuse"
            %           "spectrum L" "D65.spd"
            %           "integer nsamples" [8]
            %       NamedMaterial "1_ReflectorMaterial"
            %       Include "pbrt-geometry/1_LightX.pbrt"
            %   AttributeEnd
            
            % remove the original object declaration
            object = pbrtScene.find('Object', ...
                'name', element.name, ...
                'remove', true);
            
            % locate the object instance attribute
            attribute = pbrtScene.find('Attribute', 'name', element.name);
            
            % remove the original ObjectInstance invokation
            attribute.find('ObjectInstance', ...
                'remove', true);
            
            % declare the AreaLightSource
            areaLight = MPbrtElement('AreaLightSource', ...
                'name', element.name, ...
                'type', 'diffuse');
            areaLight.setParameter('L', 'spectrum', ...
                getMappingProperty(mapping, 'intensity', '300:1 800:1'));
            areaLight.setParameter('nsamples', 'integer', 8);
            attribute.append(areaLight);
            
            % move over the original material
            material = object.find('NamedMaterial');
            attribute.append(material);
            
            % move over the original include file
            include = object.find('Include');
            attribute.append(include);
            
        case 'bumpmap'
            
    end
    
    %% Apply Generic mappings properties as PBRT element parameters.
    switch mapping.broadType
        case 'materials'
            switch mapping.specificType
                case 'matte'
                    element.type = 'matte';
                    element.setParameter('Kd', 'spectrum', ...
                        getMappingProperty(mapping, 'diffuseReflectance', '300:0 800:0'));
                    
                case 'anisoward'
                    element.type = 'anisoward';
                    element.setParameter('Kd', 'spectrum', ...
                        getMappingProperty(mapping, 'diffuseReflectance', '300:0 800:0'));
                    element.setParameter('Ks', 'spectrum', ...
                        getMappingProperty(mapping, 'specularReflectance', '300:0 800:0'));
                    element.setParameter('alphaU', 'float', ...
                        getMappingProperty(mapping, 'alphaU', 0.15));
                    element.setParameter('alphaV', 'float', ...
                        getMappingProperty(mapping, 'alphaV', 0.15));
                    
                case 'metal'
                    element.type = 'metal';
                    element.setParameter('eta', 'spectrum', ...
                        getMappingProperty(mapping, 'eta', '300:0 800:0'));
                    element.setParameter('k', 'spectrum', ...
                        getMappingProperty(mapping, 'k', '300:0 800:0'));
                    element.setParameter('roughness', 'float', ...
                        getMappingProperty(mapping, 'roughness', .05) / 5);
            end
            
        case 'lights'
            switch mapping.specificType
                case {'point', 'spot'}
                    element.type = mapping.specificType;
                    element.setParameter('I', 'spectrum', ...
                        getMappingProperty(mapping, 'intensity', '300:0 800:0'));
                    
                case 'directional'
                    element.type = 'distant';
                    element.setParameter('L', 'spectrum', ...
                        getMappingProperty(mapping, 'intensity', '300:0 800:0'));
            end
            
        case {'floatTextures', 'spectrumTextures'}
            % texture name and pixel type declared in the element value
            if strcmp('spectrumTexture', mapping.broadType)
                pixelType = 'spectrum';
            else
                pixelType = 'float';
            end
            element.value = {element.name, pixelType};
            
            switch mapping.specificType
                case 'bitmap'
                    element.type = 'imagemap';
                    element.setParameter('filename', 'string', ...
                        getMappingProperty(mapping, 'filename', ''));
                    element.setParameter('gamma', 'float', ...
                        getMappingProperty(mapping, 'gamma', 1));
                    element.setParameter('maxanisotropy', 'float', ...
                        getMappingProperty(mapping, 'maxAnisotropy', 8));
                    element.setParameter('udelta', 'float', ...
                        getMappingProperty(mapping, 'offsetU', 0));
                    element.setParameter('vdelta', 'float', ...
                        getMappingProperty(mapping, 'offsetV', 0));
                    element.setParameter('uscale', 'float', ...
                        getMappingProperty(mapping, 'scaleU', 1));
                    element.setParameter('vscale', 'float', ...
                        getMappingProperty(mapping, 'scaleV', 1));
                    
                    wrap = getMappingProperty(mapping, 'wrapMode', 'repeat');
                    if strcmp('zero', wrap)
                        wrap = 'black';
                    end
                    element.setParameter('wrap', 'string', wrap);
                    
                    filterMode = getMappingProperty(mapping, 'filterMode', 'trilinear');
                    isTrilinear = strcmp('trilinear', filterMode);
                    element.setParameter('trilinear', 'bool', isTrilinear);
                    
                case 'checkerboard'
                    element.type = 'checkerboard';
                    
                    element.setParameter('udelta', 'float', ...
                        getMappingProperty(mapping, 'offsetU', 0));
                    element.setParameter('vdelta', 'float', ...
                        getMappingProperty(mapping, 'offsetV', 0));
                    element.setParameter('uscale', 'float', ...
                        getMappingProperty(mapping, 'checksPerU', 1));
                    element.setParameter('vscale', 'float', ...
                        getMappingProperty(mapping, 'checksPerV', 1));
                    element.setParameter('tex2', 'spectrum', ...
                        getMappingProperty(mapping, 'oddColor', '300:0 800:0'));
                    element.setParameter('tex1', 'spectrum', ...
                        getMappingProperty(mapping, 'evenColor', '300:0 800:0'));
                    element.setParameter('mapping', 'string', 'uv');
                    element.setParameter('dimension', 'integer', 2);
            end
    end
end
