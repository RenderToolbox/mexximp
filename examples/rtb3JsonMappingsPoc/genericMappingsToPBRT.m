function mappings = genericMappingsToPBRT(mappings)
%% Convert RenderToolbox3 Generic mappings to native PBRT names and values.
%
% mappings = genericMappingsToPBRT(mappings) converts any mappings with a
% RenderToolbox3 "Generic" destination to equivalent mappings with a "PBRT"
% destination.
%
% The conversion amounts to updating property names and sometimes values,
% filling in default property values, and changing the destinations to
% "PBRT".
%
% mappings = genericMappingsToPBRT(mappings)
%
% Copyright (c) 2016 RemoteDataToolbox Team

parser = inputParser();
parser.addRequired('mappings', @isstruct);
parser.parse(mappings);
mappings = parser.Results.mappings;

%% Select only the mappings targeted as RenderToolbox3 "Generic".
isGeneric = strcmp('Generic', {mappings.destination});

%% TODO: convert this old code to work with shiny new JSON-based mappings.
for mm = find(isGeneric)
    mapping = mappings(mm);
    
    switch mapping.broadType
        case 'material'
            mapping.broadType = 'Material';
            
            switch mapping.specificType
                case 'matte'
                    mapping = EditObjectProperty(mapping, 'diffuseReflectance', 'Kd');
                case 'anisoward'
                    mapping = EditObjectProperty(mapping, 'diffuseReflectance', 'Kd');
                    mapping = EditObjectProperty(mapping, 'specularReflectance', 'Ks');
                    mapping = EditObjectProperty(mapping, 'alphaU', 'alphaU');
                    mapping = EditObjectProperty(mapping, 'alphaV', 'alphaV');
                case 'metal'
                    mapping = EditObjectProperty(mapping, 'eta', 'eta');
                    mapping = EditObjectProperty(mapping, 'k', 'k');
                    mapping = EditObjectProperty(mapping, 'roughness', 'roughness');
                    r = StringToVector(GetObjectProperty(mapping, 'roughness'))/5;
                    mapping = SetObjectProperty(mapping, 'roughness', VectorToString(r));
                case 'bumpmap'
                    mapping.hints = 'bumpmap';
                    % bump map conversion happens in ApplyPBRTObjects()
            end
            
        case 'light'
            mapping.broadType = 'merge';
            
            switch mapping.specificType
                case {'point', 'spot'}
                    mapping = EditObjectProperty(mapping, 'intensity', 'I');
                case 'directional'
                    mapping.specificType = 'distant';
                    mapping = EditObjectProperty(mapping, 'intensity', 'L');
                case 'area'
                    mapping.hints = 'AreaLightSource';
                    mapping.specificType = 'diffuse';
                    mapping = EditObjectProperty(mapping, 'intensity', 'L');
                    mapping = FillInObjectProperty(mapping, 'nsamples', 'integer', '8');
            end
            
        case {'floatTexture', 'spectrumTexture'}
            % for textures, supply an extra "dataType" property
            %   which is a hint to WritePBRTFile()
            if strcmp('spectrumTexture', mapping.broadType)
                dataType = 'spectrum';
            else
                dataType = 'float';
            end
            mapping = FillInObjectProperty(mapping, 'dataType', 'string', dataType);
            
            % all textures use the PBRT 'Texture' identifier
            mapping.broadType = 'Texture';
            
            switch mapping.specificType
                case 'bitmap'
                    mapping.specificType = 'imagemap';
                    mapping = EditObjectProperty(mapping, 'filename', 'filename');
                    mapping = EditObjectProperty(mapping, 'wrapMode', 'wrap');
                    if strcmp('zero', GetObjectProperty(mapping, 'wrap'))
                        mapping = SetObjectProperty(mapping, 'wrap', 'black');
                    end
                    mapping = EditObjectProperty(mapping, 'gamma', 'gamma');
                    mapping = EditObjectProperty(mapping, 'filterMode', 'trilinear', 'bool');
                    if strcmp('trilinear', GetObjectProperty(mapping, 'trilinear'))
                        mapping = SetObjectProperty(mapping, 'trilinear', 'true');
                    else
                        mapping = SetObjectProperty(mapping, 'trilinear', 'false');
                    end
                    mapping = EditObjectProperty(mapping, 'maxAnisotropy', 'maxanisotropy');
                    mapping = EditObjectProperty(mapping, 'offsetU', 'udelta');
                    mapping = EditObjectProperty(mapping, 'offsetV', 'vdelta');
                    mapping = EditObjectProperty(mapping, 'scaleU', 'uscale');
                    mapping = EditObjectProperty(mapping, 'scaleV', 'vscale');
                    
                case 'checkerboard'
                    mapping = EditObjectProperty(mapping, 'checksPerU', 'uscale');
                    mapping = EditObjectProperty(mapping, 'checksPerV', 'vscale');
                    mapping = EditObjectProperty(mapping, 'offsetU', 'udelta');
                    mapping = EditObjectProperty(mapping, 'offsetV', 'vdelta');
                    mapping = EditObjectProperty(mapping, 'oddColor', 'tex2');
                    mapping = EditObjectProperty(mapping, 'evenColor', 'tex1');
                    
                    % PBRT needs some extra parameters
                    mapping = FillInObjectProperty(mapping, 'mapping', 'string', 'uv');
                    mapping = FillInObjectProperty(mapping, 'dimension', 'integer', '2');
            end
    end
    
    % mark this mapping as converted
    mapping.destination = 'PBRT';
    mappings(mm) = mapping;
end
