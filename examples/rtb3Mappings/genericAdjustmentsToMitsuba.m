function adjustments = genericAdjustmentsToMitsuba(adjustments)
%% Convert Generic adjustment types and values to Mitsuba-specific.
%
% The idea here is to interpret RenderToolbox3 Generic mappings syntax in
% the context of Mitsuba.  The given adjustments will be modified and
% supplemented as necessary to represent Generic scene adjustments in a
% way that can be understood by Mistuba.
%
% adjustments = genericAdjustmentsToMitsuba(adjustments) modifies the given
% Generic adjustments to make them into equivalent Mitsuba adjustments.
%
% Returns the given adjustments, updated.
%
% adjustments = genericAdjustmentsToMitsuba(adjustments)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('adjustments', @isstruct);
parser.parse(adjustments);
adjustments = parser.Results.adjustments;

for aa = 1:numel(adjustments)
    % pull out one adjustment to modify
    adj = adjustments(aa);
    
    switch adj.broadType
        case 'material'
            adj.broadType = 'bsdf';
            
            switch adj.specificType
                case 'matte'
                    adj.specificType = 'diffuse';
                    adj = editAdjustmentValue(adj, 'diffuseReflectance', ...
                        'name', 'reflectance');
                case 'anisoward'
                    adj.specificType = 'ward';
                    adj = editAdjustmentValue(adj, 'diffuseReflectance', ...
                        'name', 'diffuseReflectance');
                    adj = editAdjustmentValue(adj, 'specularReflectance', ...
                        'name', 'specularReflectance');
                    adj = editAdjustmentValue(adj, 'alphaU', ...
                        'name', 'alphaU');
                    adj = editAdjustmentValue(adj, 'alphaV', ...
                        'name', 'alphaV');
                    adj = editAdjustmentValue(adj, 'variant', ...
                        'create', true, ...
                        'name', 'ward', ...
                        'broadType', 'parameter', ...
                        'specificType', 'string', ...
                        'value', 'ward');
                case 'metal'
                    adj.specificType = 'roughconductor';
                    adj = editAdjustmentValue(adj, 'eta', ...
                        'name', 'eta');
                    adj = editAdjustmentValue(adj, 'k', ...
                        'name', 'k');
                    adj = editAdjustmentValue(adj, 'roughness', ...
                        'name', 'alpha');
                case 'bumpmap'
                    adj.operator = 'bumpmap';
            end
            
        case 'light'
            adj.broadType = 'emitter';
            
            switch adj.specificType
                case {'point', 'spot'}
                    adj = editAdjustmentValue(adj, 'intensity', ...
                        'name', 'intensity');
                case 'directional'
                    adj = editAdjustmentValue(adj, 'intensity', ...
                        'name', 'irradiance');
                case 'area'
                    adj.operator = 'area-light';
                    adj = editAdjustmentValue(adj, 'intensity', ...
                        'name', 'radiance');
            end
            
        case {'floatTexture', 'spectrumTexture'}
            adj.broadType = 'texture';
            
            switch adj.specificType
                case 'bitmap'
                    adj = editAdjustmentValue(adj, 'filename', ...
                        'name', 'filename');
                    adj = editAdjustmentValue(adj, 'wrapMode', ...
                        'name', 'wrapMode');
                    adj = editAdjustmentValue(adj, 'gamma', ...
                        'name', 'gamma');
                    adj = editAdjustmentValue(adj, 'filterMode', ...
                        'name', 'filterType');
                    adj = editAdjustmentValue(adj, 'maxAnisotropy', ...
                        'name', 'maxAnisotropy');
                    adj = editAdjustmentValue(adj, 'offsetU', ...
                        'name', 'uoffset');
                    adj = editAdjustmentValue(adj, 'offsetV', ...
                        'name', 'voffset');
                    adj = editAdjustmentValue(adj, 'scaleU', ...
                        'name', 'uscale');
                    adj = editAdjustmentValue(adj, 'scaleV', ...
                        'name', 'vscale');
                    
                case 'checkerboard'
                    adj = editAdjustmentValue(adj, 'checksPerU', ...
                        'name', 'uscale');
                    adj = editAdjustmentValue(adj, 'checksPerV', ...
                        'name', 'vscale');
                    adj = editAdjustmentValue(adj, 'offsetU', ...
                        'name', 'uoffset');
                    adj = editAdjustmentValue(adj, 'offsetV', ...
                        'name', 'voffset');
                    adj = editAdjustmentValue(adj, 'oddColor', ...
                        'name', 'color1');
                    adj = editAdjustmentValue(adj, 'evenColor', ...
                        'name', 'color0');
                    
                    % Mitsuba needs UV scales cut in half
                    u = StringToVector(queryAdjustmentValue(adj, 'uscale', 'value', '1'));
                    v = StringToVector(queryAdjustmentValue(adj, 'vscale', 'value', '1'));
                    adj = editAdjustmentValue(adj, 'uscale', ...
                        'value', VectorToString(u ./ 2));
                    adj = editAdjustmentValue(adj, 'vscale', ...
                        'value', VectorToString(v ./ 2));
            end
    end
    
    % save the modified adjustment
    adjustments(aa) = adj;
    adj
end
