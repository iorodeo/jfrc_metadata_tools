function treeToPropertyGrid(defaultsTree,mode)
% Creates a JIDE property grid from a metadata defaults tree.
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

function properties = getNodeProperties(node,mode)
% Gets the properties for JIDE Property Grid containing the values in
% the metadata defaults tree.
if node.isLeaf()
    properties = getLeafProperties(node,mode);
else
    properties = getNonLeafProperties(node,mode);
end
end


function properties = getLeafProperties(node,mode)
% Gets the properties for JIDE property grid when the node is a leaf.
if ~node.isLeaf()
    error('node must be leaf');
end
if node.getValueAppear(mode)
    
    switch lower(node.getDataType())
        case 'string'
            properties = getStringProperties(node,mode);
        otherwise
            properties = getGenericProperties(node,mode);
    end
else
    properties = PropertyGridField.empty();
    return;
end
end

function properties = getNonLeafProperties(node,mode)
% Get properties for JIDE grid when node is not a leaf.
if node.isLeaf()
    error('node cannot be leaf');
end

nestedName = node.getNestedName('');
if node.isRoot()
    properties = PropertyGridField.empty();
else
    
    properties = PropertyGridField( ...
        nestedName, node.content, ...
        'Category', node.root.name, ...
        'DisplayName', node.uniqueName, ...
        'ReadOnly', false ...
        );
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

function properties = getStringProperties(node,mode)
% Get JIDE grid properties for string datatypes.
validatorType = class(node.valueValidator);
if ~strcmp(validatorType,'StringValidator')
    error('string datatype must have StringValidator');
end

allowedStrings = node.valueValidator.allowedStrings;
readOnly = node.getReadOnly(mode);
% If only one value set readonly to true.
if length(allowedStrings) == 1
    readOnly = true;
end

propType = PropertyType('char','row',allowedStrings);
nestedName = node.getNestedName('');
properties = PropertyGridField( ...
    nestedName, node.value, ...
    'Type', propType,...
    'Category', node.root.name, ...
    'DisplayName', node.uniqueName, ...
    'ReadOnly', readOnly ...
    );
end

function properties = getGenericProperties(node,mode)
% Get JIDE grid properties for generic types
nestedName = node.getNestedName('');
properties = PropertyGridField( ...
    nestedName, node.value, ...
    'Category', node.root.name, ...
    'DisplayName', node.uniqueName, ...
    'ReadOnly', node.getReadOnly(mode) ...
    );
end






