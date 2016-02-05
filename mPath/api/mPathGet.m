function value = mPathGet(data, p)
%% Get a value nested in the given data at the given path.
%
% value = mPathGet(data, p) digs out a value nested within the given
% data variable.  p must be a cell array path specifying which fields
% and array elements to dig into.
%
% See also mPathSyntax mPathSet
%
% value = mPathGet(data, p)
%
% Copyright (c) 2016 mPath Team

parser = inputParser();
parser.addRequired('data');
parser.addRequired('p', @iscell);
parser.parse(data, p);
data = parser.Results.data;
p = parser.Results.p;

%% Base case: empty path is the identity path.
if isempty(p)
    value = data;
    return;
end

%% Recursive case: dig in one step.
pNext = p{1};
pRest = p(2:end);
if ischar(pNext)
    % descend into struct field
    dataRest = data.(pNext);
    value = mPathGet(dataRest, pRest);
    return;
end

if isnumeric(pNext)
    % descend into array or cell array element
    if iscell(data)
        dataRest = data{pNext};
    else
        dataRest = data(pNext);
    end
    value = mPathGet(dataRest, pRest);
    return;
end

if iscell(pNext)
    % resolve this query and try again
    p{1} = mPathQuery(data, pNext);
    value = mPathGet(data, p);
    return;
end

% expect to return before we get here
error('mPathGet:invalidPath', 'Invalid path element of type %s:\n%s', ...
    class(next), details(pNext));
