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
            testCase.assertEqual(mPathGet(testCase.c, {2, 2, 'foo'}), 'bar');
            testCase.assertEqual(mPathGet(testCase.c, {1, 'foo'}), 'bar');
            
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
        
        function testSetIdentity(testCase)
            testCase.assertEqual(mPathSet(1, {}, 2), 2);
            testCase.assertEqual(mPathSet('one', {}, 'two'), 'two');
            testCase.assertEqual(mPathSet('blah', {}, testCase.s), testCase.s);
            testCase.assertEqual(mPathSet('blah', {}, testCase.a), testCase.a);
            testCase.assertEqual(mPathSet('blah', {}, testCase.c), testCase.c);
        end
        
        function testSetAtTheMiddle(testCase)
            t = mPathSet(testCase.s, {'baz'}, 5);
            testCase.assertEqual(t.baz, 5);
            t = mPathSet(testCase.a, {1, 'baz'}, 5);
            testCase.assertEqual(t(1).baz, 5);
            t = mPathSet(testCase.a, {2, 'baz'}, 5);
            testCase.assertEqual(t(2).baz, 5);
            t = mPathSet(testCase.c, {2, 2, 'baz'}, 5);
            testCase.assertEqual(t{2}(2).baz, 5);
            t = mPathSet(testCase.c, {1, 'baz'}, 5);
            testCase.assertEqual(t{1}.baz, 5);
        end
        
        function testSetAtTheEnd(testCase)
            t = mPathSet(testCase.s, {'foo'}, 42);
            testCase.assertEqual(t.foo, 42);
            t = mPathSet(testCase.a, {1, 'foo'}, 42);
            testCase.assertEqual(t(1).foo, 42);
            t = mPathSet(testCase.a, {2, 'foo'}, 42);
            testCase.assertEqual(t(2).foo, 42);
            t = mPathSet(testCase.c, {2, 2, 'foo'}, 42);
            testCase.assertEqual(t{2}(2).foo, 42);
            t = mPathSet(testCase.c, {1, 'foo'}, 42);
            testCase.assertEqual(t{1}.foo, 42);
            
            t = mPathSet(testCase.s, {'baz', 4, 'quack'}, 'hello');
            testCase.assertEqual(t.baz(4).quack, 'hello');
            t = mPathSet(testCase.a, {1, 'baz', 4, 'quack'}, 'hello');
            testCase.assertEqual(t(1).baz(4).quack, 'hello');
            t = mPathSet(testCase.a, {2, 'baz', 4, 'quack'}, 'hello');
            testCase.assertEqual(t(2).baz(4).quack, 'hello');
            t = mPathSet(testCase.c, {2, 2, 'baz', 4, 'quack'}, 'hello');
            testCase.assertEqual(t{2}(2).baz(4).quack, 'hello');
            t = mPathSet(testCase.c, {1, 'baz', 4, 'quack'}, 'hello');
            testCase.assertEqual(t{1}.baz(4).quack, 'hello');
            
            t = mPathSet(testCase.s, {'baz', 1, 'zoom'}, {0});
            testCase.assertEqual(t.baz(1).zoom, {0});
            t = mPathSet(testCase.a, {1, 'baz', 1, 'zoom'}, {0});
            testCase.assertEqual(t(1).baz(1).zoom, {0});
            t = mPathSet(testCase.a, {2, 'baz', 1, 'zoom'}, {0});
            testCase.assertEqual(t(2).baz(1).zoom, {0});
            t = mPathSet(testCase.c, {2, 2, 'baz', 1, 'zoom'}, {0});
            testCase.assertEqual(t{2}(2).baz(1).zoom, {0});
            t = mPathSet(testCase.c, {1, 'baz', 1, 'zoom'}, {0});
            testCase.assertEqual(t{1}.baz(1).zoom, {0});
        end
        
        function testSetNewPath(testCase)
            % add a struct field
            t = mPathSet(struct(), {'new'}, 'yo!');
            testCase.assertEqual(t.new, 'yo!');
            
            % add array element
            t = mPathSet([], {10}, 6);
            testCase.assertEqual(t(10), 6);
            
            % add struct array element
            t = mPathSet(struct('new', {}), {5, 'new'}, 'yo!');
            testCase.assertEqual(t(5).new, 'yo!');
            
            % add cell array element
            t = mPathSet({}, {42}, 'thing');
            testCase.assertEqual(t{42}, 'thing');
            
            % add complex path without any cell arrays
            t = mPathSet(struct, {'foo', 'bar', 'baz'}, 'quack');
            testCase.assertEqual(t.foo.bar.baz, 'quack');
            
            % add complex path with cell array in the middle
            t = mPathSet(struct(), {'foo', 'bar'}, {});
            testCase.assertInstanceOf(t.foo.bar, 'cell');
            t = mPathSet(t, {'foo', 'bar', 42, 'baz'}, 'quack');
            testCase.assertEqual(t.foo.bar{42}.baz, 'quack');
            
            % add complex path with struct array in the middle
            t = mPathSet(struct(), {'foo', 'bar'}, struct('baz', {}));
            testCase.assertInstanceOf(t.foo.bar, 'struct');
            t = mPathSet(t, {'foo', 'bar', 42, 'baz'}, 'quack');
            testCase.assertEqual(t.foo.bar(42).baz, 'quack');
        end
    end
end
