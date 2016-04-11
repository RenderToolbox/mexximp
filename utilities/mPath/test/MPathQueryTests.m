classdef MPathQueryTests < matlab.unittest.TestCase
    
    properties
        s = MPathQueryTests.sampleStruct();
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
        function testEmptyData(testCase)
            testCase.assertEmpty(mPathQuery([], {}));
            testCase.assertEmpty(mPathQuery({}, {}));
            testCase.assertEmpty(mPathQuery(struct([]), {}));
        end
        
        function testEmptyPath(testCase)
            % numeric elements
            testCase.assertEqual(mPathQuery(10:20, {}), 11);
            testCase.assertEqual(mPathQuery(num2cell(10:20), {}), 11);
            
            % struct elements with special scoring function
            data = struct('foo', num2cell(10:20));
            scoringFun = @(d)d.foo;
            testCase.assertEqual(mPathQuery(data, {scoringFun}), 11);
        end
        
        function testSingleElement(testCase)
            testCase.assertEqual(mPathQuery(testCase.s, {'foo'}), 1);
        end
        
        function testDigIn(testCase)
            % the nested quack with the greatest magnitude
            q = {'baz', {'quack', @abs}, 'quack'};
            testCase.assertEqual(mPathGet(testCase.s, q), -999999999);
            
            % the nested quack with the least magnitude
            q = {'baz', {'quack', @(d)1/abs(d)}, 'quack'};
            testCase.assertEqual(mPathGet(testCase.s, q), 0);
            
            % the nested zoom corresponding to the greatest quack
            q = {'baz', {'quack', @abs}, 'zoom'};
            testCase.assertEqual(mPathGet(testCase.s, q), 'negative ninety-ninety-ninety...');
            
            % the baz with the greatest quack
            q = {'baz', {'quack', @abs}};
            testCase.assertEqual(mPathGet(testCase.s, q), testCase.s.baz(3));
        end
        
        function testDigInUpdate(testCase)
            % zero-out the quack with the greatest magnitude
            q = {'baz', {'quack', @abs}, 'quack'};
            t = mPathSet(testCase.s, q, 0);
            testCase.assertEqual(t.baz(3).quack, 0);
            
            % increase the quack with the least magnitude
            q = {'baz', {'quack', @(d)1/abs(d)}, 'quack'};
            t = mPathSet(testCase.s, q, 99999);
            testCase.assertEqual(t.baz(4).quack, 99999);
            
            % rewrite the zoom corresponding to the greatest quack
            q = {'baz', {'quack', @abs}, 'zoom'};
            t = mPathSet(testCase.s, q, 'one minus a billion');
            testCase.assertEqual(t.baz(3).zoom, 'one minus a billion');
        end
    end
end
