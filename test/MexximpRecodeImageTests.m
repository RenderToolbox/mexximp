classdef MexximpRecodeImageTests < matlab.unittest.TestCase
    
    properties
        scratchFolder = fullfile(tempdir(), 'MexximpRecodeImageTests');
    end
    
    methods (TestMethodSetup)
        function cleanScratchFolder(testCase)
            if 7 == exist(testCase.scratchFolder, 'dir')
                rmdir(testCase.scratchFolder, 's');
            end
            mkdir(testCase.scratchFolder);
        end
    end
    
    methods
        % copy images to scratch folder for recoding
        function populateScratchFolder(testCase, formats)
            sourceFolder = fileparts(mfilename('fullpath'));
            imagesFolder = fullfile(sourceFolder, 'images');
            imageFiles = mexximpCollectFiles(imagesFolder);
            nImages = numel(imageFiles);
            for ii = 1:nImages
                imageFile = fullfile(imagesFolder, imageFiles{ii});
                [~, ~, imageExt] = fileparts(imageFile);
                if any(strcmp(formats, imageExt(2:end)))
                    copyfile(imageFile, testCase.scratchFolder, 'f');
                end
            end
        end
    end
    
    methods (Test)
        
        function testImagesToExrRelativePath(testCase)
            toReplace = {'jpg', 'png', 'ppm'};
            testCase.populateScratchFolder(toReplace);
            
            imageFiles = mexximpCollectFiles(testCase.scratchFolder);
            nImages = numel(imageFiles);
            for ii = 1:nImages
                [outputFile, isRecoded] = mexximpRecodeImage(imageFiles{ii}, ...
                    'toReplace', toReplace, ...
                    'targetFormat', 'exr', ...
                    'skipExisting', false, ...
                    'sceneFolder', testCase.scratchFolder);
                testCase.assertEqual(fileparts(outputFile), testCase.scratchFolder);
                testCase.assertEqual(exist(outputFile, 'file'), 2);
                testCase.assertTrue(isRecoded);
            end
        end
        
        function testImagesToPngRelativePath(testCase)
            toReplace = {'jpg', 'exr', 'ppm'};
            testCase.populateScratchFolder(toReplace);
            
            imageFiles = mexximpCollectFiles(testCase.scratchFolder);
            nImages = numel(imageFiles);
            for ii = 1:nImages
                [outputFile, isRecoded] = mexximpRecodeImage(imageFiles{ii}, ...
                    'toReplace', toReplace, ...
                    'targetFormat', 'png', ...
                    'skipExisting', false, ...
                    'sceneFolder', testCase.scratchFolder);
                testCase.assertEqual(fileparts(outputFile), testCase.scratchFolder);
                testCase.assertEqual(exist(outputFile, 'file'), 2);
                testCase.assertTrue(isRecoded);
            end
        end
        
        function testImagesToExrAbsolutePath(testCase)
            toReplace = {'jpg', 'png', 'ppm'};
            testCase.populateScratchFolder(toReplace);
            
            imageFiles = mexximpCollectFiles(testCase.scratchFolder);
            nImages = numel(imageFiles);
            for ii = 1:nImages
                imageFile = fullfile(testCase.scratchFolder, imageFiles{ii});
                [outputFile, isRecoded] = mexximpRecodeImage(imageFile, ...
                    'toReplace', toReplace, ...
                    'targetFormat', 'exr', ...
                    'skipExisting', false);
                testCase.assertEqual(fileparts(outputFile), testCase.scratchFolder);
                testCase.assertEqual(exist(outputFile, 'file'), 2);
                testCase.assertTrue(isRecoded);
            end
        end
        
        function testImagesToPngAbsolutePath(testCase)
            toReplace = {'jpg', 'exr', 'ppm'};
            testCase.populateScratchFolder(toReplace);
            
            imageFiles = mexximpCollectFiles(testCase.scratchFolder);
            nImages = numel(imageFiles);
            for ii = 1:nImages
                imageFile = fullfile(testCase.scratchFolder, imageFiles{ii});
                [outputFile, isRecoded] = mexximpRecodeImage(imageFile, ...
                    'toReplace', toReplace, ...
                    'targetFormat', 'png', ...
                    'skipExisting', false);
                testCase.assertEqual(fileparts(outputFile), testCase.scratchFolder);
                testCase.assertEqual(exist(outputFile, 'file'), 2);
                testCase.assertTrue(isRecoded);
            end
        end
        
    end
end