classdef MexximpExrToolsTests < matlab.unittest.TestCase
    
    properties
        jpegFile;
        pngFile;
        ppmFile;
        exrFile;
        outputFolder;
        outputFile;
    end
    
    methods (TestMethodSetup)
        function setupFiles(obj)
            pathHere = fileparts(mfilename('fullpath'));
            obj.jpegFile = fullfile(pathHere, 'images', 'memorial.pp.s.jpg');
            obj.pngFile = fullfile(pathHere, 'images', 'memorial.pp.s.png');
            obj.ppmFile = fullfile(pathHere, 'images', 'memorial.pp.s.ppm');
            obj.exrFile = fullfile(pathHere, 'images', 'memorial.pp.s.exr');
            
            obj.outputFolder = fullfile(tempdir(), 'MexximpExrToolsTest');
            obj.outputFile = fullfile(obj.outputFolder, 'output.exr');
            if 7 == exist(obj.outputFolder, 'dir')
                rmdir(obj.outputFolder, 's');
            end
            mkdir(obj.outputFolder);
        end
    end
    
    methods (Test)
        function exrblurTest(obj)
            newFile = mexximpExrTools(obj.exrFile, ...
                'operation', 'exrblur', ...
                'args', '0.25', ...
                'outFile', obj.outputFile);
            obj.assertEqual(2, exist(newFile, 'file'));
        end
        
        function exrchrTest(obj)
            newFile = mexximpExrTools(obj.exrFile, ...
                'operation', 'exrchr', ...
                'blurFile', obj.exrFile, ...
                'args', '0.5', ...
                'outFile', obj.outputFile);
            obj.assertEqual(2, exist(newFile, 'file'));
        end
        
        function exricamtmTest(obj)
            newFile = mexximpExrTools(obj.exrFile, ...
                'operation', 'exricamtm', ...
                'blurFile', obj.exrFile, ...
                'outFile', obj.outputFile);
            obj.assertEqual(2, exist(newFile, 'file'));
        end
        
        function exrnlmTest(obj)
            newFile = mexximpExrTools(obj.exrFile, ...
                'operation', 'exrnlm', ...
                'blurFile', obj.exrFile, ...
                'outFile', obj.outputFile);
            obj.assertEqual(2, exist(newFile, 'file'));
        end
        
        function exrnormalizeTest(obj)
            newFile = mexximpExrTools(obj.exrFile, ...
                'operation', 'exrnormalize', ...
                'args', '10', ...
                'outFile', obj.outputFile);
            obj.assertEqual(2, exist(newFile, 'file'));
        end
        
        function exrpptmTest(obj)
            newFile = mexximpExrTools(obj.exrFile, ...
                'operation', 'exrpptm', ...
                'options', '-c 0.5 -a 0.5 -m 0.5 -f 5', ...
                'outFile', obj.outputFile);
            obj.assertEqual(2, exist(newFile, 'file'));
        end
        
        function exrstatsTest(obj)
            [~, result] = mexximpExrTools(obj.exrFile, ...
                'operation', 'exrstats');
            obj.assertNotEmpty(result);
        end
        
        function jpegtoexrTest(obj)
            newFile = mexximpExrTools(obj.jpegFile, ...
                'outFile', obj.outputFile);
            obj.assertEqual(2, exist(newFile, 'file'));
            
            [~, ~, newExt] = fileparts(newFile);
            obj.assertEqual(newExt, '.exr');
        end
        
        function pngtoexrTest(obj)
            newFile = mexximpExrTools(obj.pngFile, ...
                'outFile', obj.outputFile);
            obj.assertEqual(2, exist(newFile, 'file'));
            
            [~, ~, newExt] = fileparts(newFile);
            obj.assertEqual(newExt, '.exr');
        end
        
        function ppmtoexrTest(obj)
            % only works for 16 bit per channel PPM files.
            % not sure where to get one for testing
            % newFile = mexximpExrTools(obj.ppmFile, ...
            %     'outFile', obj.outputFile);
            % obj.assertEqual(2, exist(newFile, 'file'));
            %
            % [~, ~, newExt] = fileparts(newFile);
            % obj.assertEqual(newExt, '.exr');
        end
        
        function exrtopngTest(obj)
            newFile = mexximpExrTools(obj.exrFile, ...
                'outFile', obj.outputFile);
            obj.assertEqual(2, exist(newFile, 'file'));
            
            [~, ~, newExt] = fileparts(newFile);
            obj.assertEqual(newExt, '.png');
        end
    end
end
