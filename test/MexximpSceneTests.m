classdef MexximpSceneTests < matlab.unittest.TestCase
    
    properties (Constant)
        emptyScene = mexximpConstants('scene');
        lightTypes = mexximpConstants('lightType');
        dataTypes = mexximpConstants('materialPropertyType');
        textureSemantics = mexximpConstants('textureType');
        materialPropertyKeys = mexximpConstants('materialPropertyKey');
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
                keys = MexximpSceneTests.randomElements(s, testCase.materialPropertyKeys);
                types = MexximpSceneTests.randomElements(s, testCase.dataTypes);
                datas = MexximpSceneTests.randomDatas(s, types);
                semantics = MexximpSceneTests.randomElements(s, testCase.textureSemantics);
                properties = struct( ...
                    'key', keys, ...
                    'dataType',  types, ...
                    'data', datas, ...
                    'textureSemantic', semantics, ...
                    'textureIndex', num2cell(randi([0 s], [1 s])));
                
                scene.materials = struct( ...
                    'properties', properties);
                testCase.doSceneRoundTrip(scene);
            end
        end
        
        function testMeshesRoundTrip(testCase)
            scene = testCase.emptyScene;
            for s = testCase.itemSize
                
                indicies = cell(1, s);
                for ii = 1:s
                    indicies{ii} = randi(s, 1, s, 'uint32');
                end
                faces = struct( ...
                    'nIndices', s, ...
                    'indices', indicies);
                
                primitives = struct( ...
                    'point', rand() > .5, ...
                    'line', rand() > .5, ...
                    'triangle', rand() > .5, ...
                    'polygon', rand() > .5);
                
                scene.meshes = struct( ...
                    'name', MexximpSceneTests.randomString(s), ...
                    'materialIndex', num2cell(randi(s, 1, s)), ...
                    'primitiveTypes', primitives, ...
                    'vertices', rand(3, s), ...
                    'faces', faces, ...
                    'colors0', rand(4, s), ...
                    'colors1', rand(4, s), ...
                    'colors2', rand(4, s), ...
                    'colors3', rand(4, s), ...
                    'colors4', rand(4, s), ...
                    'colors5', rand(4, s), ...
                    'colors6', rand(4, s), ...
                    'colors7', rand(4, s), ...
                    'normals', rand(3, s), ...
                    'tangents', rand(3, s), ...
                    'bitangents', rand(3, s), ...
                    'textureCoordinates0', rand(3, s), ...
                    'textureCoordinates1', rand(3, s), ...
                    'textureCoordinates2', rand(3, s), ...
                    'textureCoordinates3', rand(3, s), ...
                    'textureCoordinates4', rand(3, s), ...
                    'textureCoordinates5', rand(3, s), ...
                    'textureCoordinates6', rand(3, s), ...
                    'textureCoordinates7', rand(3, s));
                scenePrime = testCase.doSceneRoundTrip(scene);
            end
        end
        
        function testNodeRoundTrip(testCase)
            scene = testCase.emptyScene;
            for s = testCase.itemSize
                
                % arbitrary node hierarchy 3 levels deep
                children = cell(1, s);
                for ii = 1:s
                    children{ii} = MexximpSceneTests.randomNode(s);
                    
                    % vary the number of grandchildren as we go
                    children{ii}.children = [children{2:ii}];
                end
                
                scene.rootNode = MexximpSceneTests.randomNode(s);
                scene.rootNode.children = [children{:}];
                testCase.doSceneRoundTrip(scene);
            end
        end
        
        function testCompressedTextureRoundTrip(testCase)
            scene = testCase.emptyScene;
            for s = testCase.itemSize
                
                images = cell(1, s);
                formats = cell(1, s);
                for ii = 1:s
                    images{ii} = randi(255, 1, s, 'uint8');
                    formats{ii} = MexximpSceneTests.randomString(3);
                end
                
                embeddedTextures = struct( ...
                    'image', images, ...
                    'format', formats);
                
                scene.embeddedTextures = embeddedTextures;
                testCase.doSceneRoundTrip(scene);
            end
        end
        
        function testRawTextureRoundTrip(testCase)
            scene = testCase.emptyScene;
            for s = testCase.itemSize
                
                images = cell(1, s);
                for ii = 1:s
                    images{ii} = randi(255, 4, 2*s, s, 'uint8');
                end
                
                embeddedTextures = struct( ...
                    'image', images, ...
                    'format', '');
                
                scene.embeddedTextures = embeddedTextures;
                testCase.doSceneRoundTrip(scene);
            end
        end
        
    end
    
    methods (Access = private)
        function scenePrime = doSceneRoundTrip(testCase, scene)
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
        
        function node = randomNode(nElements)
            node = struct( ...
                'name', MexximpSceneTests.randomString(nElements), ...
                'meshIndices', randi(nElements, 1, nElements, 'uint32'), ...
                'transformation', rand(4, 4), ...
                'children', []);
        end
    end
end