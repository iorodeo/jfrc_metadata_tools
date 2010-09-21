function treeToPropertyGrid(defaultsTree,mode,hierarchy)
% Creates a JIDE property grid from a metadata defaults tree.
%
% Arguments:
%   defaultsTree  = an xml defaults tree w/ nodes of class XMLDefaultsNode.
%   mode          = 'basic' or 'advanced'. The default is true.
%   hierarchy     = true or false, determines whether tree is shown as
%                   heirarchy or flat respectively. The default is true.
%
% -------------------------------------------------------------------------
if nargin < 2
    mode = 'basic';
end
if nargin < 3
    hierarchy = true;
end

% Ensure that we start with the root of the Tree.
defaultsTree = defaultsTree.root;

% Set value validators and defaults based on mode.
defaultsTree.setValueValidators(mode);
defaultsTree.setValuesToDefaults();

% Get properties for JIDE property grid and create hierarchy if requested
properties = getNodeProperties(defaultsTree,mode,hierarchy);
if hierarchy == true
    properties = properties.GetHierarchy();
end

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
function properties = getNodeProperties(node,mode,hierarchy)
% Gets the properties for JIDE Property Grid for given node and all its 
% children for the specified mode string = 'basic' or 'advanced'

%disp([node.indent, node.name])
if node.isLeaf() == true
    % Handle nodes which are leaves of the tree
    properties = getLeafProperties(node,mode,hierarchy);
else
    % Handle nodes which are not leaves of the tree
    properties = getNonLeafProperties(node,mode,hierarchy);
end
end

% -------------------------------------------------------------------------
function properties = getLeafProperties(node,mode,hierarchy)
% Gets the properties for JIDE property grid when the node is a leaf.
if node.isLeaf() == false
    error('node must be leaf');
end
if node.getValueAppear(mode,hierarchy) == true
    if hierarchy == true
        name = node.getNestedName('');
    else
        name = node.uniqueName;
    end
    %nestedName = node.getNestedName('');
    displayName = node.uniqueName;
    properties = getPropertiesByType(node,name,displayName,mode);
else
    properties = PropertyGridField.empty(); 
end
end

% -------------------------------------------------------------------------
function properties = getNonLeafProperties(node,mode,hierarchy)
% Get properties for JIDE grid when node is not a leaf.
if node.isLeaf() == true
    error('node cannot be leaf');
end
if node.isRoot() == true || node.getValueAppear(mode,hierarchy) == false
    properties = PropertyGridField.empty();
else
    % Set property name and display name
    if hierarchy == true
        name = node.getNestedName('');
    else
        name = node.uniqueName;
    end
    displayName = node.uniqueName;
    
    if node.isContentNode()
        % Special case for content nodes.
        childNode = node.children(1);
        properties = getPropertiesByType(childNode,name,displayName,mode);
    else
        % -----------------------------------------------------------------
        % Note, if is apparatus may want to display some type information
        %------------------------------------------------------------------
        properties = PropertyGridField( ...
            name, '', ...
            'Category', node.root.name, ...
            'DisplayName', displayName, ...
            'ReadOnly', true, ...
            'Description', node.getValueDescription() ...
            );
    end
end
% Loop over all children calling getNodeProperties
for i = 1:node.numChildren
    childNode = node.children(i);
    if strcmpi(childNode.name,'content')
        continue
    else
        childProperties = getNodeProperties(childNode,mode,hierarchy);
        if ~isempty(childProperties)
            properties = [properties, childProperties];
        end
    end
end
end

% -------------------------------------------------------------------------
function properties = getPropertiesByType(node,name,displayName,mode)
% Get JIDE grid properties based on leaf node datatype
% Node is set to appear
switch lower(node.getDataType())
    case 'string'
        properties = getStringProperties(node,name,displayName,mode);
    case 'float'
        properties = getFloatProperties(node,name,displayName,mode);
    case 'integer'
        properties = getIntegerProperties(node,name,displayName,mode);
    case 'time24'
        % -----------------------------------------------------------------
        % Note, this has not been implemented yet. I'm just using the
        % generic case as a place holder.
        % -----------------------------------------------------------------
        properties = getGenericProperties(node,name,displayName,mode);
    case 'datetime'
        properties = getDateTimeProperties(node,name,displayName,mode);
    otherwise
        % -----------------------------------------------------------------
        % Note, it might be best to throw an error here as there should be
        % anything that is not one of the above types. This leftover from
        % development.
        % -----------------------------------------------------------------
        properties = getGenericProperties(node,name,displayName,mode);
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
%allowedStrings = node.valueValidator.allowedStrings;

%if isempty(allowedStrings)
if node.valueValidator.isFiniteRange() == true
    valueArray = node.valueValidator.getValues();
    % If only one value set readonly to true.
    if length(valueArray) == 1
        readOnly = true;
    end
    propType = PropertyType('char','row',valueArray);
    properties = PropertyGridField( ...
        name, node.value, ...
        'Type', propType,...
        'Category', node.root.name, ...
        'DisplayName', displayName, ...
        'ReadOnly', readOnly, ...
        'Description', node.getValueDescription() ...
        );
else
    properties = PropertyGridField( ...
        name, {node.value,''}, ...
        'Category', node.root.name, ...
        'DisplayName', displayName, ...
        'ReadOnly', readOnly, ...
        'Description', node.getValueDescription() ...
        );
    
end
end

% -------------------------------------------------------------------------
function properties = getFloatProperties(node,name,displayName,mode)
% Get JIDE grid properties for float types

% Check validator type
validatorType = class(node.valueValidator);
if ~strcmp(validatorType,'NumericValidator')
    error('string datatype must have StringValidator');
end

propType = PropertyType('char','row');
properties = PropertyGridField( ...
    name, node.value, ...
    'Type', propType, ...
    'Category', node.root.name, ...
    'DisplayName', displayName, ...
    'ReadOnly', node.getReadOnly(mode), ...
    'Description', node.getValueDescription() ...
    );
% properties = PropertyGridField( ...
%     name, str2num(node.value), ...
%     'Category', node.root.name, ...
%     'DisplayName', displayName, ...
%     'ReadOnly', node.getReadOnly(mode), ...
%     'Description', node.getValueDescription() ...
%     );
end

% -------------------------------------------------------------------------
function properties = getIntegerProperties(node,name,displayName,mode)
% Get JIDE grid properties for integer types

% Check validator type
validatorType = class(node.valueValidator);
if ~strcmp(validatorType,'IntegerValidator')
    error('string datatype must have StringValidator');
end

if node.valueValidator.isFiniteRange() == true   
    % Range is finite show a drop down list. 
    % ---------------------------------------------------------------------
    % Note, if range is really large we might want to do something else.
    % ---------------------------------------------------------------------
    valueArray = node.valueValidator.getValues();
    propType = PropertyType('char', 'row', valueArray);
     properties = PropertyGridField( ...
        name, node.value, ...
        'Type', propType, ...
        'Category', node.root.name, ...
        'DisplayName', displayName, ...
        'ReadOnly', node.getReadOnly(mode), ...
        'Description', node.getValueDescription() ...
        ); 
%     valueCell = num2cell(int32(valueArray));
%     propType = PropertyType('int32', 'scalar', valueCell);
%      properties = PropertyGridField( ...
%         name, int32(str2num(node.value)), ...
%         'Type', propType, ...
%         'Category', node.root.name, ...
%         'DisplayName', displayName, ...
%         'ReadOnly', node.getReadOnly(mode), ...
%         'Description', node.getValueDescription() ...
%         ); 
else
    
    propType = PropertyType('char','row');
    properties = PropertyGridField( ...
        name, node.value, ...
        'Type', propType, ...
        'Category', node.root.name, ...
        'DisplayName', displayName, ...
        'ReadOnly', node.getReadOnly(mode), ...
        'Description', node.getValueDescription() ...
        );
%     properties = PropertyGridField( ...
%         name, str2num(node.value), ...
%         'Category', node.root.name, ...
%         'DisplayName', displayName, ...
%         'ReadOnly', node.getReadOnly(mode), ...
%         'Description', node.getValueDescription() ...
%         );
end
end

% -------------------------------------------------------------------------
function properties = getDateTimeProperties(node,name,displayName,mode)
% Get JIDE grid properties for datetime data type
% Check validator type
validatorType = class(node.valueValidator);
if ~strcmp(validatorType,'DateTimeValidator')
    error('string datatype must have StringValidator');
end

readOnly = node.getReadOnly(mode);

if node.valueValidator.isFiniteRange() == true
    % Range is finite - show drop down list
    % ---------------------------------------------------------------------
    % Note, if range is really large might want to do something else
    % ---------------------------------------------------------------------
    valueArray = node.valueValidator.getValues();
    if length(valueArray) == 1
        readOnly = true;
    end
    propType = PropertyType('char','row',valueArray);
    properties = PropertyGridField( ...
        name, node.value, ...
        'Type', propType,...
        'Category', node.root.name, ...
        'DisplayName', displayName, ...
        'ReadOnly', readOnly, ...
        'Description', node.getValueDescription() ...
        );
else
    properties = PropertyGridField( ...
        name, {node.value,''}, ...
        'Category', node.root.name, ...
        'DisplayName', displayName, ...
        'ReadOnly', readOnly, ...
        'Description', node.getValueDescription() ...
        ); 
end
end

% -------------------------------------------------------------------------
function properties = getGenericProperties(node,name,displayName,mode)
% Get JIDE grid properties for generic types
properties = PropertyGridField( ...
    name, node.value, ...
    'Category', node.root.name, ...
    'DisplayName', displayName, ...
    'ReadOnly', node.getReadOnly(mode), ...
    'Description', node.getValueDescription() ...
    );
end







