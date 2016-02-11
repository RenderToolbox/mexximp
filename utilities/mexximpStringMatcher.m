function matcher = mexximpStringMatcher(string)
%% Make a function for comparing strings to the given string.
%
% matcher = mexximpStringMatcher(string) returns an anonymous function for
% comparing pther strings to the given string.  The function will expect a
% single "other string" argument and return a score of similarity between
% the other string and the string passed to this function.  The score will
% be 0 when the strings are equal, and decrease as the strings become less
% similar.
%
% matcher = mexximpStringMatcher(string)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('string', @ischar);
parser.parse(string);
string = parser.Results.string;

matcher = @(otherString) -1 * EditDistance(string, otherString);
