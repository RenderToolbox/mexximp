classdef MexximpSceneTests < matlab.unittest.TestCase
    
    properties (Constant)
        emptyScene = struct( ...
            'cameras', [], ...
            'lights', [], ...
            'materials', [], ...
            'meshes', [], ...
            'embeddedTextures', [], ...
            'rootNode', []);
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
    end
end