function data = mPathSet(data, p, value)
%% Set a value nested in the given data at the given path.
%
% data = mPathSet(data, p, value) digs into the given data variable,
% following fields and array indices specified in the given mPath p.  Sets
% the given value at the end of the path.
%
% Returns the given data, updated with the new value set and the given
% mPath p.
%
% See also mPathSyntax mPathGet
%
% data = mPathSet(data, p, value)
%
% Copyright (c) 2016 mPath Team

parser = inputParser();
parser.addRequired('data');
parser.addRequired('p', @iscell);
parser.addRequired('value');
parser.parse(data, p, value);
data = parser.Results.data;
p = parser.Results.p;
value = parser.Results.value;

%% Base case: empty path is identity.
if isempty(p)
    data = value;
    return;
end

%% Base and recursive cases:
pNext = p{1};
pRest = p(2:end);
if ischar(pNext)
    if isempty(pRest)
        % base case: assign value at the end
        data.(pNext) = value;
    else
        % recursive case: descend into struct field and save the result
        if isfield(data, pNext)
            dataRest = data.(pNext);
        else
            dataRest = [];
        end

        % let empty data to take on any type
        if isempty(data)
            clear data;
        end
        data.(pNext) = mPathSet(dataRest, pRest, value);
    end
elseif isnumeric(pNext)
    if isempty(pRest)
        % base case: assign value at the end
        if iscell(data)
            data{pNext} = value;
        else
            data(pNext) = value;
        end
    else
        % descend into array or cell array element
        if iscell(data)
            if numel(data) < pNext
                dataRest = {};
            else
                dataRest = data{pNext};
            end
            data{pNext} = mPathSet(dataRest, pRest, value);
        else
            if numel(data) < pNext
                dataRest = [];
            else
                dataRest = data(pNext);
            end
            
            % let empty data to take on any type
            if isempty(data)
                clear data;
            end
            data(pNext) = mPathSet(dataRest, pRest, value);
        end
    end
elseif iscell(pNext)
    % resolve this query
    
else
    error('mPathSet:invalidPath', 'Invalid path element of type %s:\n%s', ...
        class(next), details(pNext));
end
