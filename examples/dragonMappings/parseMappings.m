function mappings = parseMappings(mappingsFile)
%% Read mappings syntax from a text file.
%
% mappings = parseMappings(mappingsFile) parses RenderToolbox3 mappings
% syntax from the given mappingsFile text.  Each mappings line from the
% file will be parsed into an element of a mappings struct array with text
% data and metadata.
%
% Returns a 1xn struct array with mapping data.  The struct array will have
% one element per mappings line, and the following fields:
%   - text - raw text before parsing
%   - blockType - block type eg 'Collada', 'Generic', 'Mitsuba', 'PBRT'
%   - blockNumber - the order of the block in the mappings file
%   - group - name of a set of related blocks
%   - left - a struct of info about the left-hand string
%   - operator - the operator string
%   - right - a struct of info about the right-hand string
%
% @details
% Each 'left' or 'right' field will contain a struct with data about a
% string, with the following fields
%   - text - the raw text before parsing
%   - enclosing - the enclosing brackets, if any, '[]', '<>', or ''
%   - value - the text found within enclosing brackets
%
% mappings = parseMappings(mappingsFile)
%
% Copyright (c) 2016 mexximp Team

% implementation taken from RenderToolbox3 ParseMappings().

parser = rdtInputParser();
parser.addRequired('mappingsFile', @ischar);
parser.parse(mappingsFile);
mappingsFile = parser.Results.mappingsFile;

%% Make a default mappints struct.
mappings = struct( ...
    'text', {}, ...
    'blockType', {}, ...
    'blockNumber', {}, ...
    'group', {}, ...
    'left', {}, ...
    'operator', {}, ...
    'right', {});

%% Prepare to read the mappings file.
if nargin < 1 || ~exist(mappingsFile, 'file')
    return;
end

fid = fopen(mappingsFile, 'r');
if -1 == fid
    error('parseMappings:failedToOpenFile', ...
        'Cannot open mappings file "%s"', mappingsFile);
end

%% Define regular expressions to parse mapping syntax.
% comments have % as the first non-whitespace
commentPattern = '^\s*\%';

% blocks start with one word followed by {
blockStartPattern = '([^{\s]+)\s+([^{\s]+)\s*{|([^{\s]+)\s*{';

% blocks end with }
blockEndPattern = '}';

% "operators" might start with +-*\, and must end with =
%   and must be flanked with spaces
opPattern = ' ([\+\-\*/]?=) ';

% "values" must start with a non-space
valuePattern = '(\S.+)';

%% Read one line at a time, look for blocks and mappings.
blockType = '';
blockNumber = 0;
groupName = '';
nextLine = '';
while ischar(nextLine)
    % read a line of the mappings file
    nextLine = fgetl(fid);
    if ~ischar(nextLine)
        break;
    end
    
    % skip comment lines
    if regexp(nextLine, commentPattern, 'once')
        continue;
    end
    
    % enter a new block?
    tokens = regexp(nextLine, blockStartPattern, 'tokens');
    if ~isempty(tokens)
        blockNumber = blockNumber + 1;
        
        if 1 == numel(tokens{1})
            % start a block with no group name
            blockType = tokens{1}{1};
            groupName = '';
            continue;
            
        elseif 2 == numel(tokens{1})
            % start a block with a group name
            blockType = tokens{1}{1};
            groupName = tokens{1}{2};
            continue;
        end
    end
    
    % close the current block?
    if regexp(nextLine, blockEndPattern, 'once')
        blockType = '';
        groupName = '';
        continue;
    end
    
    % read a mapping?
    %   mappings must contain at least one value
    if regexp(nextLine, valuePattern, 'once')
        % append a new mapping struct
        n = numel(mappings) + 1;
        mappings(n).text = nextLine;
        mappings(n).blockType = blockType;
        mappings(n).blockNumber = blockNumber;
        mappings(n).group = groupName;
        
        % look for an operator
        [opStart, opEnd] = regexp(nextLine, opPattern, 'start', 'end');
        if isempty(opStart)
            % no operator, just lone value
            mappings(n).left = unwrapString(nextLine);
            mappings(n).operator = '';
            mappings(n).right = unwrapString('');
            
        else
            % left-hand value, operator, right-hand value
            mappings(n).left = unwrapString(nextLine(1:(opStart-1)));
            mappings(n).operator = nextLine((opStart+1):(opEnd-1));
            mappings(n).right = unwrapString(nextLine((opEnd+1):end));
        end
        
        continue;
    end
end

%% Done with file
fclose(fid);


%% Dig out a string from its enclosing braces, if any.
function info = unwrapString(string)
% fill in default info
info.enclosing = '';
info.text = string;
info.value = '';

if isempty(string)
    return;
end

% check for enclosing brackets
if ~isempty(strfind(string, '<'))
    % angle brackets
    info.enclosing = '<>';
    valuePattern = '<(.+)>';
    
elseif ~isempty(strfind(string, '['))
    % square brackets
    info.enclosing = '[]';
    valuePattern = '\[(.+)\]';
    
else
    % plain string, strip some whitespace
    info.enclosing = '';
    valuePattern = '(\S.*\S)|(\S?)';
end

% dig out the value
valueToken = regexp(string, valuePattern, 'tokens');
info.value = valueToken{1}{1};
