% Find handle graphics object with user data check.
% Retrieves those handle graphics objects (HGOs) that have the specified
% Tag property and whose UserData property satisfies the given predicate.
%
% Input arguments:
% fcn:
%    a predicate (a function that returns a logical value) to test against
%    the HGO's UserData property
% tag (optional):
%    a string tag to restrict the set of controls to investigate
%
% See also: findobj

% Copyright 2010 Levente Hunyadi
function h = findobjuser(fcn, tag)

validateattributes(fcn, {'function_handle'}, {'scalar'});
if nargin < 2 || isempty(tag)
    tag = '';
else
    validateattributes(tag, {'char'}, {'row'});
end

if ~isempty(tag)
    h = findobj('-property', 'UserData', '-and', 'Tag', tag);  % more results if multiple matching HGOs exist
else
    h = findobj('-property', 'UserData');
end
f = arrayfun(@(handle) fcn(get(handle, 'UserData')), h);
h = h(f);