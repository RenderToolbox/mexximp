classdef MPathReadWriteTests < matlab.unittest.TestCase
    
    properties
        s = MPathReadWriteTests.sampleStruct();
        a = [MPathReadWriteTests.sampleStruct() MPathReadWriteTests.sampleStruct()];
        c = {MPathReadWriteTests.sampleStruct(), [MPathReadWriteTests.sampleStruct() MPathReadWriteTests.sampleStruct()]};
    end
    
    methods (Static)
        % sample data definition we can re-use in property definitions
        function s = sampleStruct()
            s = struct( ...
                'foo', 'bar', ...
                'baz', struct( ...
                'quack', {42, ...
                exp(1i*pi), ...
                -999999999, ...
                0}, ...
                'zoom', {'forty-two', ...
                'Half of Euler''s identity?', ...
                'negative ninety-ninety-ninety...', ...
                'zero'}));
        end
    end
    
    methods (Test)
        function testGetIdentity(testCase)
            testCase.assertEqual(mPathGet(1, {}), 1);
            testCase.assertEqual(mPathGet('one', {}), 'one');
            testCase.assertEqual(mPathGet(testCase.s, {}), testCase.s);
            testCase.assertEqual(mPathGet(testCase.a, {}), testCase.a);
            testCase.assertEqual(mPathGet(testCase.c, {}), testCase.c);
        end
        
        function testGetAtTheMiddle(testCase)
            testCase.assertInstanceOf(mPathGet(testCase.s, {'baz'}), 'struct');
            testCase.assertNumElements(mPathGet(testCase.s, {'baz'}), 4);
            testCase.assertInstanceOf(mPathGet(testCase.a, {1, 'baz'}), 'struct');
            testCase.assertNumElements(mPathGet(testCase.a, {1, 'baz'}), 4);
            testCase.assertInstanceOf(mPathGet(testCase.a, {2, 'baz'}), 'struct');
            testCase.assertNumElements(mPathGet(testCase.a, {2, 'baz'}), 4);
            testCase.assertInstanceOf(mPathGet(testCase.c, {2, 2, 'baz'}), 'struct');
            testCase.assertNumElements(mPathGet(testCase.c, {2, 2, 'baz'}), 4);
            testCase.assertInstanceOf(mPathGet(testCase.c, {1, 'baz'}), 'struct');
            testCase.assertNumElements(mPathGet(testCase.c, {1, 'baz'}), 4);
        end
        
        function testGetAtTheEnd(testCase)
            testCase.assertEqual(mPathGet(testCase.s, {'foo'}), 'bar');
            testCase.assertEqual(mPathGet(testCase.a, {1, 'foo'}), 'bar');
            testCase.assertEqual(mPathGet(testCase.a, {2, 'foo'}), 'bar');
            testCase.assertEqual(mPathGet(testCase.c, {1, 1, 'foo'}), 'bar');
            testCase.assertEqual(mPathGet(testCase.c, {2, 'foo'}), 'bar');
            
            testCase.assertEqual(mPathGet(testCase.s, {'baz', 4, 'quack'}), 0);
            testCase.assertEqual(mPathGet(testCase.a, {1, 'baz', 4, 'quack'}), 0);
            testCase.assertEqual(mPathGet(testCase.a, {2, 'baz', 4, 'quack'}), 0);
            testCase.assertEqual(mPathGet(testCase.c, {2, 2, 'baz', 4, 'quack'}), 0);
            testCase.assertEqual(mPathGet(testCase.c, {1, 'baz', 4, 'quack'}), 0);
            
            testCase.assertEqual(mPathGet(testCase.s, {'baz', 1, 'zoom'}), 'forty-two');
            testCase.assertEqual(mPathGet(testCase.a, {1, 'baz', 1, 'zoom'}), 'forty-two');
            testCase.assertEqual(mPathGet(testCase.a, {2, 'baz', 1, 'zoom'}), 'forty-two');
            testCase.assertEqual(mPathGet(testCase.c, {2, 2, 'baz', 1, 'zoom'}), 'forty-two');
            testCase.assertEqual(mPathGet(testCase.c, {1, 'baz', 1, 'zoom'}), 'forty-two');
        end
    end
end
