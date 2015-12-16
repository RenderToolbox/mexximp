classdef MexximpSceneTests < matlab.unittest.TestCase
    
    properties (Constant)
        emptyScene = struct( ...
            'cameras', [], ...
            'lights', [], ...
            'materials', [], ...
            'meshes', [], ...
            'embeddedTextures', [], ...
            'rootNode', []);
        lightTypes = {'undefined', 'directional', 'point', 'spot'};
        dataTypes = {'float', 'string', 'integer', 'buffer'};
        textureSemantics = {'none', 'diffuse', 'specular', 'ambient', ...
            'emissive', 'height', 'normals', 'shininess', 'opacity', ...
            'displacement', 'light_map', 'reflection', 'unknown'};
        floatTolerance = 1e-6;
        itemSize = 1:10;
    end
    
    methods (Test)
        
        function testEmptySceneRoundTrip(testCase)
            testCase.doSceneRoundTrip(testCase.emptyScene);
        end
        
        function testCamerasRoundTrip(testCase)
            scene = testCase.emptyScene;
            for s = testCase.itemSize
                scene.cameras = struct( ...
                    'name', MexximpSceneTests.randomString(s), ...
                    'position', rand(3, 1), ...
                    'lookAtDirection', rand(3, 1), ...
                    'upDirection', rand(3, 1), ...
                    'aspectRatio', num2cell(rand(1, s)), ...
                    'horizontalFov', num2cell(rand(1, s)), ...
                    'clipPlaneFar', num2cell(rand(1, s)), ...
                    'clipPlaneNear', num2cell(rand(1, s)));
                testCase.doSceneRoundTrip(scene);
            end
        end
        
        function testLightsRoundTrip(testCase)
            scene = testCase.emptyScene;
            for s = testCase.itemSize
                scene.lights = struct( ...
                    'name', MexximpSceneTests.randomString(s), ...
                    'position', rand(3, 1), ...
                    'type', MexximpSceneTests.randomElements(s, testCase.lightTypes), ...
                    'lookAtDirection', rand(3, 1), ...
                    'innerConeAngle', num2cell(rand(1, s)), ...
                    'outerConeAngle', num2cell(rand(1, s)), ...
                    'constantAttenuation', num2cell(rand(1, s)), ...
                    'linearAttenuation', num2cell(rand(1, s)), ...
                    'quadraticAttenuation', num2cell(rand(1, s)), ...
                    'ambientColor', rand(3, 1), ...
                    'diffuseColor', rand(3, 1), ...
                    'specularColor', rand(3, 1));
                testCase.doSceneRoundTrip(scene);
            end
        end
        
        function testMaterialsRoundTrip(testCase)
            scene = testCase.emptyScene;
            for s = testCase.itemSize
                
                keys = cell(1, s);
                for ii = 1:s
                    keys{ii} = MexximpSceneTests.randomString(s);
                end
                
                dataTypes = MexximpSceneTests.randomElements(s, testCase.dataTypes);
                datas = MexximpSceneTests.randomDatas(s, dataTypes);
                properties = struct( ...
                    'key', keys, ...
                    'dataType',  dataTypes, ...
                    'data', datas, ...
                    'textureSemantic', MexximpSceneTests.randomElements(s, testCase.textureSemantics), ...
                    'textureIndex', num2cell(randi([0 s], [1 s])));
                
                scene.materials = struct( ...
                    'properties', properties);
                testCase.doSceneRoundTrip(scene);
            end
        end
        
    end
    
    methods (Access = private)
        function doSceneRoundTrip(testCase, scene)
            scenePrime = mexximpTest('scene', scene);
            testCase.assertEqual(scenePrime, scene, ...
                'AbsTol', testCase.floatTolerance);
        end
    end
    
    methods (Static)
        function string = randomString(stringSize)
            alphabet = '0':'z';
            string = alphabet(randi(numel(alphabet), [1, stringSize]));
        end
        
        function types = randomElements(nElements, allElements)
            types = allElements(randi(numel(allElements), [1, nElements]));
        end
        
        function datas = randomDatas(nElements, types)
            datas = cell(1, nElements);
            for ii = 1:nElements
                switch(types{ii})
                    case 'float'
                        datas{ii} = rand(1, nElements);
                    case 'string'
                        datas{ii} = MexximpSceneTests.randomString(nElements);
                    case 'integer'
                        datas{ii} = randi([-nElements nElements], 1, nElements, 'int32');
                    case 'buffer'
                        datas{ii} = randi(255, 1, nElements, 'uint8');
                    otherwise
                        datas{ii} = [];
                end
            end
        end
    end
end