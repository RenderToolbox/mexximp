function [index, score] = mPathQuery(data, q)
%% Run a query over a data array and return the index of the winner.
%
% index = mPathQuery(data, q) iterates elements of the given data
% array and uses the given query q to select a "winning" element.
%
% The given q must be an mPath path cell array.  This will be used to
% mPathGet() a value from each element of the data array.  Each value will
% be scored.  The element with the highest score is the winner.  In the
% case of a tie, the first winner is chosen.
%
% By default, numeric and char values will be scored by sum, and other
% values scored by number of elements.
%
% Optionally, q may contain an a function_handle as an extra last
% element.  This "score function" must have the form:
%   score = myFunction(value)
% This function will be used instead of the default scoring function.
%
% Returns the index into data of the element where the highest score
% occurred, or the first such index if there is a tie.  Also returns the
% actual score of the winner.
%
% See also mPathSyntax mPathGet mPathSet
%
% [index, score] = mPathQuery(data, q)
%
% Copyright (c) 2016 mPath Team

parser = inputParser();
parser.addRequired('data');
parser.addRequired('q', @iscell);
parser.parse(data, q);
data = parser.Results.data;
q = parser.Results.q;

%% Separate sub-path and scoring function.
if isempty(q)
    p = {};
    scoreFunction = @sumOrNumel;
elseif isa(q{end}, 'function_handle')
    p = q(1:end-1);
    scoreFunction = q{end};
else
    p = q;
    scoreFunction = @sumOrNumel;
end

%% Get a score from each element of data.
nElements = numel(data);
scores = zeros(1, nElements);
for ii = 1:nElements
    if iscell(data)
        element = data{ii};
    else
        element = data(ii);
    end
    value = mPathGet(element, p);
    scores(ii) = feval(scoreFunction, value);
end

%% Choose the winner.
[score, index] = max(scores);

%% Score by sum where possible, else number of elements.
function score = sumOrNumel(value)
if isnumeric(value) || ischar(value)
    score = sum(value(:));
else
    score = numel(value);
end
