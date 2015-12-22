classdef MexximpImportTests < matlab.unittest.TestCase
    
    properties (Constant)
        sampleFile = fullfile(fileparts(mfilename('fullpath')), 'Dragon.dae');
        postprocessorSteps = mexximpConstants('postprocessStep');
    end
    
    methods (Test)
        
        function testNoArgsOK(testCase)
            scene = mexximpImport();
        end
        
        function testBasicImport(testCase)
            scene = mexximpImport(testCase.sampleFile);
            testCase.assertNotEmpty(scene);
            testCase.assertInstanceOf(scene, 'struct');
            testCase.assertNumElements(scene.cameras, 1);
            testCase.assertNumElements(scene.lights, 0);
            testCase.assertNumElements(scene.materials, 4);
            testCase.assertNumElements(scene.meshes, 7);
            testCase.assertNumElements(scene.embeddedTextures, 0);
            testCase.assertNumElements(scene.rootNode, 1);
            testCase.assertNumElements(scene.rootNode.children, 8);
        end
        
        function testImportPostProcess(testCase)
            options = testCase.postprocessorSteps;
            
            rightHandedRootTransform = [ ...
                1     0     0     0;
                0     0    -1     0;
                0     1     0     0;
                0     0     0     1];
            
            options.convertToLeftHanded = false;
            rightyScene = mexximpImport(testCase.sampleFile, options);
            testCase.assertNotEmpty(rightyScene);
            testCase.assertEqual(rightyScene.rootNode.transformation, rightHandedRootTransform);

            options.convertToLeftHanded = true;
            leftyScene = mexximpImport(testCase.sampleFile, options);
            testCase.assertNotEmpty(leftyScene);
            testCase.assertEqual(leftyScene.rootNode.transformation, rightHandedRootTransform');

        end
        
    end
end
