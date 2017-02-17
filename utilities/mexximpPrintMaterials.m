function mexximpPrintMaterials( scene, varargin )

%% Print scene material properties to terminal
%
% mexximpPrintMaterials(mexximpScene) prints all the scene materials, and
% their properties to the terminal for easy visual inspection of material
% properties. 
%
% mexximpPrintMaterials(mexximpScene,'MaterialIndex',3) prints all 
% properties of the specific material only. In this case it is the third
% material in the scene.materials array.
% 
% mexximpPrintMaterials(mexximpScene,'MaterialName','someMaterial') prints 
% all properties of a material with the 'someMaterial' name.
%
% mexximpPrintMaterials(mexximpScene, varargin)
%
% Copyright (c) 2016 mexximp Team


p = inputParser;
p.addRequired('scene',@isstruct)
p.addOptional('MaterialIndex',0);
p.addOptional('MaterialName','');
p.parse(scene,varargin{:});

materialIndex = p.Results.MaterialIndex;
materialName = p.Results.MaterialName;

if materialIndex > 0
    % Print material by index
    
    if materialIndex < length(scene.materials),
        fprintf('Material %3i:\n', materialIndex);
        printMaterial(scene.materials(materialIndex));
    end
    
elseif ~isempty(materialName)
    % Print material by name
    selector = mexximpFindElement(scene,materialName);
    if ~isempty(selector)
        fprintf('Material %3i:\n', selector.path{2});
        printMaterial(scene.materials(selector.path{2}));
    end
else
    
    nMaterials = length(scene.materials);
    for i=1:nMaterials
        fprintf('Material %3i:\n', i);
        printMaterial(scene.materials(i));
    end
    
    
end

end


function printMaterial(material)

    nProperties = length(material.properties);
    for p=1:nProperties
        
        key = material.properties(p).key;
        
        if strcmp(key,'texture')
            semantic = material.properties(p).textureSemantic;
            fprintf('   %s-%s : %s\n', key, semantic, mat2str(material.properties(p).data));
        else
            fprintf('   %s : %s\n', key, mat2str(material.properties(p).data));
        end
    end
    
    fprintf('\n');

end
