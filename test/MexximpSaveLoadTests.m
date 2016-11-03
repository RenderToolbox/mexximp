classdef MexximpSaveLoadTests < matlab.unittest.TestCase
    
    properties (Constant)
        dragonFile = fullfile(fileparts(mfilename('fullpath')), 'Dragon.dae');
        flattenFile = fullfile(fileparts(mfilename('fullpath')), 'FlattenTest.blend');
    end
    
    methods (Test)
        function testSaveLoadDragon(testCase)
            originalScene = mexximpImport(testCase.dragonFile);
            
            tempFile = fullfile(tempdir(), 'testSaveLoadDragon');
            mexximpSave(originalScene, tempFile);
            reloadedScene = mexximpLoad(tempFile);
            
            testCase.assertEqual(reloadedScene, originalScene);
        end
        
        function testSaveLoadFlattenTest(testCase)
            originalScene = mexximpImport(testCase.flattenFile);
            
            tempFile = fullfile(tempdir(), 'testSaveLoadFlattenTest');
            mexximpSave(originalScene, tempFile);
            reloadedScene = mexximpLoad(tempFile);
            
            testCase.assertEqual(reloadedScene, originalScene);
        end
        
    end
end
