function adjustment = newAdjustment(name, broadType, specificType, value, varargin)
%% Pack up a scene element adjustment.
%
% The idea here is to make a consistent struct representation of an
% "adjustment" to a scene.  For example, an adjustment could be "add an
% integrator", "set the number of samples per pixel", "set the spectrum of
% a light", "increment the camera position", etc.  Adjustments structs are
% deliberately generic.  The same structure should be usable for
% RenderToolbox3 "Generic" adjustments as well as renderer-specific
% adjustments.
%
% adjustment = NewAdjustment(name, broadType, specificType, value) packs
% up a new adjustment.  The name must be a unique idenifier for a scene
% element.  The broadType must be the name of a broad class of scene
% elements, like "mesh" or "parameter".  The specificType must be a
% concrete type within the broadType, like "trianglemesh" or "float".  The
% value may have many forms, but must agree with the specificType.  Values
% may be an array, scalar, string, or even a struct array of nested
% adjustments.
%
% adjustment = NewAdjustment(... 'operator', operator) sets the operator to
% use with the value.  The default is '=', assign the value to the scene
% element.  Other valid operators include '+=', '-=', '*=', '/=',
% 'declare'.
%
% adjustment = NewAdjustment(... 'group', group) sets the group name of the
% adjustment, allowing adjustments to be "switched on and off" according to
% named groups.  The default is '', no particular group.
%
% adjustment = NewAdjustment(... 'destination', destination) sets the
% destination where the adjustment should be applied, for example the
% renderer name like "PBRT" or "Mitusba".  The default is "", no particular
% destination.
%
% adjustment = NewAdjustment(name, broadType, specificType, value, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = rdtInputParser();
parser.addRequired('name', @ischar);
parser.addRequired('broadType', @ischar);
parser.addRequired('specificType', @ischar);
parser.addRequired('value');
parser.addParameter('operator', '=', @ischar);
parser.addParameter('group', '', @ischar);
parser.addParameter('destination', '', @ischar);
parser.parse(name, broadType, specificType, value, varargin{:});

%% Let the input parser build us a struct.
adjustment = parser.Results;
