classdef MexximpExportTests < matlab.unittest.TestCase
    
    properties (Constant)
        sampleFile = fullfile(fileparts(mfilename('fullpath')), 'Dragon.dae');
        postprocessorSteps = mexximpConstants('postprocessStep');
        floatTolerance = 1e-5;
        maxMeshCompareSize = 1000;
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
        
        function testRoundTripOK(testCase)
            scene = mexximpImport(testCase.sampleFile);
            testCase.assertNotEmpty(scene);
            testCase.assertInstanceOf(scene, 'struct');
            
            exportTemp = fullfile(tempdir(), 'roundTrip.dae');
            status = mexximpExport(scene, 'collada', exportTemp);
            testCase.assertNotEmpty(status);
        end
        
        function testImportExportImportEqual(testCase)
            scene = mexximpImport(testCase.sampleFile);
            testCase.assertNotEmpty(scene);
            testCase.assertInstanceOf(scene, 'struct');
            
            exportTemp = fullfile(tempdir(), 'roundTrip.dae');
            status = mexximpExport(scene, 'collada', exportTemp);
            testCase.assertNotEmpty(status);
            
            scenePrime = mexximpImport(exportTemp);
            testCase.assertNotEmpty(scenePrime);
            testCase.assertInstanceOf(scenePrime, 'struct');
            
            % can't compare whole scenes exporter may change things
            % harmlessly, so compare part by part
            
            testCase.assertEqual(scenePrime.cameras, scene.cameras, ...
                'AbsTol', testCase.floatTolerance);
            testCase.assertEqual(scenePrime.lights, scene.lights, ...
                'AbsTol', testCase.floatTolerance);
            testCase.assertEqual(scenePrime.embeddedTextures, scene.embeddedTextures, ...
                'AbsTol', testCase.floatTolerance);
            testCase.assertEqual(scenePrime.rootNode, scene.rootNode, ...
                'AbsTol', testCase.floatTolerance);
            
            testCase.assertMeshesAboutEqual(scenePrime.meshes, scene.meshes);
            testCase.assertMaterialsAboutEqual(scenePrime.materials, scene.materials);
        end
    end
    
    methods
        function assertMeshesAboutEqual(testCase, meshesPrime, meshesOriginal)
            nMeshes = numel(meshesOriginal);
            testCase.assertNumElements(meshesPrime, nMeshes);
            
            for ii = 1:nMeshes
                % truncate large arrays because comparisons take forever!
                meshPrime = testCase.truncateLargeArrays(meshesPrime(ii));
                meshOriginal = testCase.truncateLargeArrays(meshesOriginal(ii));
                
                % ignore names because exporter changes them harmlessly
                meshPrime.name = '';
                meshOriginal.name = '';
                
                testCase.assertEqual(meshPrime, meshOriginal, ...
                    'AbsTol', testCase.floatTolerance);
            end
        end
        
        function assertMaterialsAboutEqual(testCase, materialsPrime, materialsOriginal)
            nMaterials = numel(materialsOriginal);
            testCase.assertNumElements(materialsPrime, nMaterials);
            
            for ii = 1:nMaterials
                % ignore property data because exporter may change it harmlessly
                materialPrime = testCase.clearPropertyData(materialsPrime(ii));
                materialOriginal = testCase.clearPropertyData(materialsOriginal(ii));

                % ignore names because exporter changes them harmlessly
                materialPrime.name = '';
                materialOriginal.name = '';
                
                testCase.assertEqual(materialPrime, materialOriginal, ...
                    'AbsTol', testCase.floatTolerance);
            end
        end
        
        function truncated = truncateLargeArrays(testCase, original)
            truncated = original;
            fieldNames = fieldnames(truncated);
            nFields = numel(fieldNames);
            for ii = 1:nFields
                fieldName = fieldNames{ii};
                field = truncated.(fieldName);
                
                if size(field, 2) > testCase.maxMeshCompareSize
                    truncated.(fieldName) = field(:, 1:testCase.maxMeshCompareSize);
                end
            end
        end
        
        function noStrings = clearPropertyData(testCase, original)
            noStrings = original;
            nProperties = numel(noStrings.properties);
            for ii = 1:nProperties
                noStrings.properties(ii).data = [];
            end
        end
    end
end
