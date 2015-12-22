classdef MexximpExportTests < matlab.unittest.TestCase
    
    properties (Constant)
        sampleFile = fullfile(fileparts(mfilename('fullpath')), 'Dragon.dae');
        postprocessorSteps = mexximpConstants('postprocessStep');
    end
    
    methods (Test)
        
        function testNoArgsOK(testCase)
            status = mexximpExport();
        end
        
        function testMinimalExport(testCase)
            scene = mexximpConstants('scene');
            scene.rootNode = mexximpConstants('node');
            scene.rootNode.name = 'minimal';
            scene.rootNode.transformation = eye(4);
            
            exportTemp = fullfile(tempdir(), 'minimal.dae');
            status = mexximpExport(scene, 'collada', exportTemp);
            testCase.assertNotEmpty(status);
        end
        
%         function testRoundTripOK(testCase)
%             scene = mexximpImport(testCase.sampleFile);
%             testCase.assertNotEmpty(scene);
%             testCase.assertInstanceOf(scene, 'struct');
%             
%             exportTemp = fullfile(tempdir(), 'roundTrip.dae');
%             status = mexximpExport(scene, 'collada', exportTemp);
%             testCase.assertNotEmpty(status);
%         end
    end
end
