function [status, result, advice] = mexximpCheckNativeDependencies()
% Check whether required native dependencies are installed.
%
% [status, result, advice] = mexximpCheckNativeDependencies() checks the
% local required shared libraries. Returns a status code which is non-zero
% if some dependency was missing. Also returns a result, such as an error
% code about the missing Finally, returns a string with advice about how to
% obtain a missing dependency, if any.
%
% [status, result, advice] = mexximpCheckNativeDependencies()
%
% Copyright (c) 2017 mexximp Team


%% Check for Assimp library.
if ismac()
    % assume homebrew
    findLibCommand = 'brew list | grep assimp';
else
    findLibCommand = 'ldconfig -p | grep assimp.so.3';
end
assimp = checkSystem('Assimp', ...
    findLibCommand, ...
    'It looks like Assimp is not installed.  Please use these instructions to install Assimp: https://github.com/RenderToolbox/RenderToolbox4#assimp.');


%% Assimp is required.
if 0 ~= assimp.status
    status = assimp.status;
    result = assimp.result;
    advice = assimp.advice;
    return;
end


%% Check for Docker.
docker = checkSystem('Docker', ...
    'docker ps', ...
    'It looks like Docker is not installed.  Please visit https://github.com/RenderToolbox/RenderToolbox4/wiki/Docker.');


%% Docker can cover other tools.
if 0 == docker.status
    status = 0;
    result = 'Local dependencies were found.';
    advice = '';
    return;
end


%% Check for a local installation of ExrTools.
exrTools = checkSystem('ExrTools', ...
    'which exrblur', ...
    'It looks like ExrTools is not installed.  Please visit http://scanline.ca/exrtools/.  Or, consider installing Docker so that mexximp can get ExrTools for you.');


%% Check for other tools.
if 0 ~= exrTools.status
    status = exrTools.status;
    result = exrTools.result;
    advice = exrTools.advice;
    return;
end

%% Looks good from here.
status = 0;
result = 'Local dependencies were found.';
advice = '';


%% Check whether something exists and print messages.
function info = checkSystem(name, command, advice)
fprintf('Checking for %s:\n', name);
fprintf('  %s\n', command);
info.name = name;
info.advice = advice;
[info.status, result] = system(command);
info.result = strtrim(result);
if 0 == info.status
    fprintf('  OK.\n');
else
    fprintf('  Not found.  Status %d, result <%s>.\n', info.status, info.result);
end
