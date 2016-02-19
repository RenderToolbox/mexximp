function matcher = mexximpStringMatcher(string, varargin)
%% Make a function for comparing strings to the given string.
%
% matcher = mexximpStringMatcher(string) returns an anonymous function for
% comparing pther strings to the given string.  The function will expect a
% single "other string" argument and return a score of similarity between
% the other string and the string passed to this function.  The score will
% be 0 when the strings are equal, and decrease as the strings become less
% similar.
%
% matcher = mexximpStringMatcher( ... 'caseSensitive', caseSensitive)
% choose whether to do case-sensitive matching (true) or to ignore case
% when matching (false).  The default is true, do case-sensitive matching.
%
% matcher = mexximpStringMatcher(string, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('string', @ischar);
parser.addParameter('caseSensitive', true, @islogical);
parser.parse(string, varargin{:});
string = parser.Results.string;
caseSensitive = parser.Results.caseSensitive;

if caseSensitive
    matcher = @(otherString) -1 * EditDistance(string, otherString);
else
    matcher = @(otherString) -1 * EditDistance(lower(string), lower(otherString));
end
