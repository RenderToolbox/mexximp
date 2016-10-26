classdef MexximpFlattenNodesTests < matlab.unittest.TestCase
    
    properties (Constant)
        testScene = which('FlattenTest.blend');
    end
    
    methods
        function scene = loadFlatScene(testCase)
            scene = mexximpImport(testCase.testScene);
        end
        
        function scene = loadNestedScene(testCase)
            scene = mexximpImport(testCase.testScene);
            
            % find a node to duplicate
            cubeSelector = strcmp('Cube', {scene.rootNode.children.name});
            cubeNode = scene.rootNode.children(cubeSelector);
            
            % create a node to contain the nested duplicate
            containerNode = mexximpConstants('node');
            containerNode.name = 'Container';
            containerNode.transformation = mexximpRotate([0 0 1], pi()/6);
            containerNode.children = cubeNode;
            
            % add the container and duplicate to the scene
            scene.rootNode.children(end+1) = containerNode;
        end
        
    end
    
    methods (Test)
        
        function testFlatNodeCount(testCase)
            % flat scene has root plus 6 children
            scene = testCase.loadFlatScene();
            testCase.assertEqual(numel(scene.rootNode.children), 6);
            
            % flattening the nodes should not change their number
            flattened = mexximpFlattenNodes(scene);
            testCase.assertEqual(numel(flattened.children), 6);
            
            % re-flattening the nodes should not change their number
            scene.rootNode = flattened;
            reflattened = mexximpFlattenNodes(scene);
            testCase.assertEqual(numel(reflattened.children), 6);
        end
        
        function testNestedNodeCount(testCase)
            % nested scene has root plus 7 children plus 1 grandchild
            scene = testCase.loadNestedScene();
            testCase.assertEqual(numel(scene.rootNode.children), 7);
            
            % flattening the nodes should make them all peers
            flattened = mexximpFlattenNodes(scene);
            testCase.assertEqual(numel(flattened.children), 8);
            
            % re-flattening the nodes should not change their number
            scene.rootNode = flattened;
            reflattened = mexximpFlattenNodes(scene);
            testCase.assertEqual(numel(reflattened.children), 8);
        end
        
        function testFlatNodePaths(testCase)
            scene = testCase.loadFlatScene();
            
            % nodes should exist at all reported paths
            nodeInfo = mexximpNodePaths(scene);
            for nn = 1:numel(nodeInfo)
                info = nodeInfo(nn);
                node = mPathGet(scene, info.path);
                testCase.assertEqual(node.name, info.name);
            end
            
            % and should still exist after flattening
            scene.rootNode = mexximpFlattenNodes(scene);
            nodeInfo = mexximpNodePaths(scene);
            for nn = 1:numel(nodeInfo)
                info = nodeInfo(nn);
                node = mPathGet(scene, info.path);
                testCase.assertEqual(node.name, info.name);
            end
            
        end
        
        function testNestedNodePaths(testCase)
            scene = testCase.loadNestedScene();
            
            % nodes should exist at all reported paths
            nodeInfo = mexximpNodePaths(scene);
            for nn = 1:numel(nodeInfo)
                info = nodeInfo(nn);
                node = mPathGet(scene, info.path);
                testCase.assertEqual(node.name, info.name);
            end
            
            % the last, nested element should have a long path like
            %   {'rootNode', 'children', nn, 'children', mm};
            info = nodeInfo(end);
            testCase.assertEqual(numel(info.path), 5);
            
            % and should still exist after flattening
            scene.rootNode = mexximpFlattenNodes(scene);
            nodeInfo = mexximpNodePaths(scene);
            for nn = 1:numel(nodeInfo)
                info = nodeInfo(nn);
                node = mPathGet(scene, info.path);
                testCase.assertEqual(node.name, info.name);
            end
            
            % the last, nested element should now have a short path like
            %   {'rootNode', 'children', nn};
            info = nodeInfo(end);
            testCase.assertEqual(numel(info.path), 3);
        end
        
        function testFlatNoChildren(testCase)
            scene = testCase.loadFlatScene();
            
            % flattened nodes should be exactly one level deep
            flattened = mexximpFlattenNodes(scene);
            for cc = 1:numel(flattened.children)
                child = flattened.children(cc);
                testCase.assertEmpty(child.children);
            end
        end
        
        function testNestedNoChildren(testCase)
            scene = testCase.loadNestedScene();
            
            % flattened nodes should be exactly one level deep
            flattened = mexximpFlattenNodes(scene);
            for cc = 1:numel(flattened.children)
                child = flattened.children(cc);
                testCase.assertEmpty(child.children);
            end
        end
    end
end
