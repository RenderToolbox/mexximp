function matcher = mexximpStringMatcher(string, varargin)
%% Make a function for comparing strings to the given string.
%
% matcher = mexximpStringMatcher(string) returns an anonymous function for
% comparing other strings to the given string.  The function will expect a
% single "other string" argument and return a score of similarity between
% the other string and the string passed to this function.
%
% The similarity score will be 1 when the strings are equal, and decrease
% towards 0 as the strings become less similar.  A score of 0 indicates
% that the two strings have no characters in common.
%
% matcher = mexximpStringMatcher( ... 'caseSensitive', caseSensitive)
% choose whether to do case-sensitive matching (true) or to ignore case
% when matching (false).  The default is true, do case-sensitive matching.
%
% matcher = mexximpStringMatcher(string, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('string', @ischar);
parser.addParameter('caseSensitive', true, @islogical);
parser.parse(string, varargin{:});
string = parser.Results.string;
caseSensitive = parser.Results.caseSensitive;

if caseSensitive
    matcher = @(otherString) normalSimilarity(string, otherString);
else
    matcher = @(otherString) normalSimilarity(lower(string), lower(otherString));
end

%% String edit distance, normalized by length, one minus all that.
function similarity = normalSimilarity(a, b)
maxLength = max(numel(a), numel(b));
similarity = 1 - (EditDistance(a, b) ./ maxLength);
