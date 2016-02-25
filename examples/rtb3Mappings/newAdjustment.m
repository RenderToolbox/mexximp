function adjustment = newAdjustment(varargin)
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
% adjustment = NewAdjustment() creates a default adjustment struct.
%
% adjustment = NewAdjustment(... 'name', name) sets the name or id of the
% element to be adjusted.  The default is ''.
%
% adjustment = NewAdjustment(... 'broadType', broadType) sets the general
% category of the element to be adjusted.  For example, "mesh" or
% "parameter". The default is ''.
%
% adjustment = NewAdjustment(... 'specificType', specificType) sets a more
% specific type for the element to be adjusted.  For example,
% "trianglemesh" or "float". The default is ''.
%
% adjustment = NewAdjustment(... 'value', value) sets the value of the
% element to be adjusted.  The value may be a simple numeric or string
% type, or a struct array of nested adjustments.  This allows building up
% of complex scene elements.  The default is [].
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
parser.addParameter('name', '', @ischar);
parser.addParameter('broadType', '', @ischar);
parser.addParameter('specificType', '', @ischar);
parser.addParameter('value', []);
parser.addParameter('operator', '=', @ischar);
parser.addParameter('group', '', @ischar);
parser.addParameter('destination', '', @ischar);
parser.parse(varargin{:});

%% Let the input parser build us a struct.
adjustment = parser.Results;
