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
if ischar(pNext)
    % descend into struct field
    dataRest = data.(pNext);
    
elseif isnumeric(pNext)
    % descend into array or cell array element
    if iscell(data)
        dataRest = data{pNext};
    else
        dataRest = data(pNext);
    end
    
elseif iscell(pNext)
    % resolve this query
    
else
    error('mPathGet:invalidPath', 'Invalid path element of type %s:\n%s', ...
        class(next), details(pNext));
end

pRest = p(2:end);
value = mPathGet(dataRest, pRest);
