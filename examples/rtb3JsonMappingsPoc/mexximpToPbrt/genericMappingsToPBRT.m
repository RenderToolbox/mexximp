function [mappings, isGeneric] = genericMappingsToPBRT(mappings)
%% Convert RenderToolbox3 Generic mappings to native PBRT names and values.
%
% mappings = genericMappingsToPBRT(mappings) converts any mappings with a
% RenderToolbox3 "Generic" destination to equivalent mappings with a "PBRT"
% destination.
%
% The conversion amounts to updating property names and values, filling in
% default properties, and changing the destinations to "PBRT".
%
% Returns the given mappings struct, updated with Generic elements
% converted to native PBRT syntax.  Also returns a logical array, true
% where elements of the given mappings were converted from Generic to PBRT.
%
% [mappings, isGeneric] = genericMappingsToPBRT(mappings)
%
% Copyright (c) 2016 RemoteDataToolbox Team

%% TODO
% I don't like this conversion style.  It seems clumsy.  It's a God switch!
% Instead, I should have small functions that can handle the conversion for
% each type.  These will be natural places to define necessary defaults for
% each type of element and then update them with mappings values.  An
% inputParser can do most of the work.
%
% Then I can defer the conversion until scene writing time.

parser = inputParser();
parser.addRequired('mappings', @isstruct);
parser.parse(mappings);
mappings = parser.Results.mappings;

%% Select only the mappings targeted as RenderToolbox3 "Generic".
isGeneric = strcmp('Generic', {mappings.destination});

for mm = find(isGeneric)
    mapping = mappings(mm);
    
    switch mapping.broadType
        case 'materials'
            mapping.broadType = 'Material';
            
            switch mapping.specificType
                case 'matte'
                    mapping = setMappingProperty(mapping, 'diffuseReflectance', 'name', 'Kd');
                case 'anisoward'
                    mapping = setMappingProperty(mapping, 'diffuseReflectance', 'name', 'Kd');
                    mapping = setMappingProperty(mapping, 'specularReflectance', 'name', 'Ks');
                    mapping = setMappingProperty(mapping, 'alphaU', 'name', 'alphaU');
                    mapping = setMappingProperty(mapping, 'alphaV', 'name', 'alphaV');
                case 'metal'
                    mapping = setMappingProperty(mapping, 'eta', 'name', 'eta');
                    mapping = setMappingProperty(mapping, 'k', 'name', 'k');
                    mapping = setMappingProperty(mapping, 'roughness', 'name', 'roughness');
                    
                    % for rough compatibility, scale down the roughness
                    r = getMappingProperty(mapping, 'roughness', 1)/5;
                    mapping = setMappingProperty(mapping, 'roughness', 'value', r);
            end
            
        case 'lights'
            mapping.broadType = 'LightSource';
            
            switch mapping.specificType
                case {'point', 'spot'}
                    mapping = setMappingProperty(mapping, 'intensity', 'name', 'I');
                case 'directional'
                    mapping.specificType = 'distant';
                    mapping = setMappingProperty(mapping, 'intensity', 'name', 'L');
            end
            
        case {'floatTexture', 'spectrumTexture'}
            % for textures, supply an extra "pixelType" property
            %   which is a hint to mPbrt
            if strcmp('spectrumTexture', mapping.broadType)
                pixelType = 'spectrum';
            else
                pixelType = 'float';
            end
            mapping = setMappingProperty(mapping, 'pixelType', ...
                'value', pixelType, ...
                'valueType', 'string');
            
            % all textures use the PBRT 'Texture' identifier
            mapping.broadType = 'Texture';
            
            switch mapping.specificType
                case 'bitmap'
                    mapping.specificType = 'imagemap';
                    mapping = setMappingProperty(mapping, 'filename', 'name', 'filename');
                    mapping = setMappingProperty(mapping, 'wrapMode', 'name', 'wrap');
                    if strcmp('zero', getMappingProperty(mapping, 'value', 'wrap', 'zero'))
                        mapping = setMappingProperty(mapping, 'wrap', 'value', 'black');
                    end
                    mapping = setMappingProperty(mapping, 'gamma', 'name', 'gamma');
                    mapping = setMappingProperty(mapping, 'filterMode', 'name', 'trilinear', 'type', 'bool');
                    if strcmp('trilinear', getMappingProperty(mapping, 'trilinear', ''))
                        mapping = SetObjectProperty(mapping, 'trilinear', 'value', 'true');
                    else
                        mapping = SetObjectProperty(mapping, 'trilinear', 'value', 'false');
                    end
                    mapping = setMappingProperty(mapping, 'maxAnisotropy', 'name', 'maxanisotropy');
                    mapping = setMappingProperty(mapping, 'offsetU', 'name', 'udelta');
                    mapping = setMappingProperty(mapping, 'offsetV', 'name', 'vdelta');
                    mapping = setMappingProperty(mapping, 'scaleU', 'name', 'uscale');
                    mapping = setMappingProperty(mapping, 'scaleV', 'name', 'vscale');
                    
                case 'checkerboard'
                    mapping = setMappingProperty(mapping, 'checksPerU', 'name', 'uscale');
                    mapping = setMappingProperty(mapping, 'checksPerV', 'name', 'vscale');
                    mapping = setMappingProperty(mapping, 'offsetU', 'name', 'udelta');
                    mapping = setMappingProperty(mapping, 'offsetV', 'name', 'vdelta');
                    mapping = setMappingProperty(mapping, 'oddColor', 'name', 'tex2');
                    mapping = setMappingProperty(mapping, 'evenColor', 'name', 'tex1');
                    
                    % PBRT needs some extra parameters
                    mapping = setMappingProperty(mapping, 'mapping', ...
                        'valueType', 'string', ...
                        'value', 'uv');
                    mapping = setMappingProperty(mapping, 'dimension', ...
                        'valueType', 'integer', ...
                        'value', '2');
            end
    end
    
    % mark this mapping as converted
    mapping.destination = 'PBRT';
    mappings(mm) = mapping;
end

