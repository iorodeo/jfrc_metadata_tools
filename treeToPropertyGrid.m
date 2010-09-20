function treeToPropertyGrid(defaultsTree,mode)
% Creates a JIDE property grid from a metadata defaults tree.
%
% Arguments:
%   defaultsTree  = an xml defaults tree w/ nodes of class XMLDefaultsNode.
%   mode          = 'basic' or 'advanced'
%
% -------------------------------------------------------------------------
if nargin == 1
    mode = 'basic';
end

% Ensure that we start with the root of the Tree.
defaultsTree = defaultsTree.root;

% Set value validators and defaults based on mode.
defaultsTree.setValueValidators(mode);
defaultsTree.setValuesToDefaults();

% Get properties for JIDE property grid and create hierarchy
properties = getNodeProperties(defaultsTree, mode);
properties = properties.GetHierarchy();

% Create figure and add property grid.
fig = figure( ...
    'MenuBar', 'none', ...
    'Name', 'pgridTest', ...
    'NumberTitle', 'off', ...
    'Toolbar', 'none');
pgrid = PropertyGrid(fig,'Position', [0 0 1 1]);
pgrid.Properties = properties;
uiwait(fig);
end

% -------------------------------------------------------------------------
function properties = getNodeProperties(node,mode)
% Gets the properties for JIDE Property Grid for given node and all its 
% children for the specified mode string = 'basic' or 'advanced'

%disp([node.indent, node.name])
if node.isLeaf() == true
    % Handle nodes which are leaves of the tree
    properties = getLeafProperties(node,mode);
else
    % Handle nodes which are not leaves of the tree
    properties = getNonLeafProperties(node,mode);
end
end

% -------------------------------------------------------------------------
function properties = getLeafProperties(node,mode)
% Gets the properties for JIDE property grid when the node is a leaf.
if node.isLeaf() == false
    error('node must be leaf');
end
if node.getValueAppear() == true
    nestedName = node.getNestedName('');
    displayName = node.uniqueName;
    properties = getPropertiesByType(node,nestedName,displayName,mode);
else
    properties = PropertyGridField.empty(); 
end
end

% -------------------------------------------------------------------------
function properties = getNonLeafProperties(node,mode)
% Get properties for JIDE grid when node is not a leaf.
if node.isLeaf() == true
    error('node cannot be leaf');
end
if node.isRoot() == true || node.getValueAppear() == false
    properties = PropertyGridField.empty();
else
    nestedName = node.getNestedName('');
    if node.isContentNode()
        % Special case for content nodes.
        childNode = node.children(1);
        displayName = node.uniqueName;
        properties = getPropertiesByType(childNode,nestedName,displayName,mode);
    else
        % -----------------------------------------------------------------
        % Note, if is apparatus may want to display some type information
        %------------------------------------------------------------------
        properties = PropertyGridField( ...
            nestedName, '', ...
            'Category', node.root.name, ...
            'DisplayName', node.uniqueName, ...
            'ReadOnly', true ...
            );
    end
end
% Loop over all children calling getNodeProperties
for i = 1:node.numChildren
    childNode = node.children(i);
    if strcmpi(childNode.name,'content')
        continue
    else
        childProperties = getNodeProperties(childNode,mode);
        if ~isempty(childProperties)
            properties = [properties, childProperties];
        end
    end
end
end

% -------------------------------------------------------------------------
function properties = getPropertiesByType(node,nestedName,displayName,mode)
% Get JIDE grid properties based on leaf node datatype
% Node is set to appear
switch lower(node.getDataType())
    case 'string'
        properties = getStringProperties(node,nestedName,displayName,mode);
    case 'float'
        properties = getFloatProperties(node,nestedName,displayName,mode);
    case 'integer'
        properties = getIntegerProperties(node,nestedName,displayName,mode);
    %case 'time24'   
    %case 'datetime'
    %    properties = getDatTimeProperties(node,nestedName,displayName,mode);
    otherwise
        properties = getGenericProperties(node,nestedName,displayName,mode);
end
end

% -------------------------------------------------------------------------
function properties = getStringProperties(node,name,displayName,mode)
% Get JIDE grid properties for string datatypes.

% Check validator type
validatorType = class(node.valueValidator);
if ~strcmp(validatorType,'StringValidator')
    error('string datatype must have StringValidator');
end

readOnly = node.getReadOnly(mode);
allowedStrings = node.valueValidator.allowedStrings;

if isempty(allowedStrings)
    properties = PropertyGridField( ...
        name, {node.value,''}, ...
        'Category', node.root.name, ...
        'DisplayName', displayName, ...
        'ReadOnly', readOnly ...
        );
else
    % If only one value set readonly to true.
    if length(allowedStrings) == 1
        readOnly = true;
    end
    propType = PropertyType('char','row',allowedStrings);
    properties = PropertyGridField( ...
        name, node.value, ...
        'Type', propType,...
        'Category', node.root.name, ...
        'DisplayName', displayName, ...
        'ReadOnly', readOnly ...
        );
end
end

% -------------------------------------------------------------------------
function properties = getFloatProperties(node,nestedName,displayName,mode)
% Get JIDE grid properties for float types

% Check validator type
validatorType = class(node.valueValidator);
if ~strcmp(validatorType,'NumericValidator')
    error('string datatype must have StringValidator');
end
properties = PropertyGridField( ...
    nestedName, str2num(node.value), ...
    'Category', node.root.name, ...
    'DisplayName', displayName, ...
    'ReadOnly', node.getReadOnly(mode) ...
    );
end

% -------------------------------------------------------------------------
function properties = getIntegerProperties(node,nestedName,displayName,mode)
% Get JIDE grid properties for integer types

% Check validator type
validatorType = class(node.valueValidator);
if ~strcmp(validatorType,'IntegerValidator')
    error('string datatype must have StringValidator');
end

if node.valueValidator.isFiniteRange() == true   
    % Range is finit show a drop down list. 
    % ---------------------------------------------------------------------
    % Note, might want to check if range is really really large and in that
    % case not show a drop down list.
    % ---------------------------------------------------------------------
    valueArray = node.valueValidator.getValues();
    valueCell = num2cell(int32(valueArray));
    propType = PropertyType('int32', 'scalar', valueCell);
     properties = PropertyGridField( ...
        nestedName, int32(str2num(node.value)), ...
        'Type', propType, ...
        'Category', node.root.name, ...
        'DisplayName', displayName, ...
        'ReadOnly', node.getReadOnly(mode) ...
        ); 
else
    properties = PropertyGridField( ...
        nestedName, str2num(node.value), ...
        'Category', node.root.name, ...
        'DisplayName', displayName, ...
        'ReadOnly', node.getReadOnly(mode) ...
        );
end
end

% -------------------------------------------------------------------------
% NOT DONE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getDateTimeProperties(node,nestedName,displayName,mode)
% Get JIDE grid properties for datetime data type
% Check validator type
validatorType = class(node.valueValidator);
if ~strcmp(validatorType,'DateTimeValidator')
    error('string datatype must have StringValidator');
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -------------------------------------------------------------------------
function properties = getGenericProperties(node,nestedName,displayName,mode)
% Get JIDE grid properties for generic types
properties = PropertyGridField( ...
    nestedName, node.value, ...
    'Category', node.root.name, ...
    'DisplayName', displayName, ...
    'ReadOnly', node.getReadOnly(mode) ...
    );
end







