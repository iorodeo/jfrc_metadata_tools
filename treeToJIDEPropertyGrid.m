function treeToJIDEPropertyGrid(defaultsTree,mode)
% Creates a JIDE property grid from a metadata defaults tree.
if nargin == 1
    mode = 'basic';
end
% Ensure that we start with the root of the Tree.
defaultsTree = defaultsTree.root;

% Set value validators and defaults based on mode.
defaultsTree.setValueValidators(mode);
defaultsTree.setValuesToDefaults();

properties = getJIDEGridProperties(defaultsTree, mode)
properties = properties.GetHierarchy();

% create figure
f = figure( ...
    'MenuBar', 'none', ...
    'Name', 'pgridTest', ...
    'NumberTitle', 'off', ...
    'Toolbar', 'none');

% procedural usage
%g = PropertyGrid(f,'Properties', properties,'Position', [0 0 0.5 1]);
g = PropertyGrid(f,'Position', [0 0 0.5 1]);
g.Properties = properties;

uiwait(f);

function properties = getJIDEGridProperties(node,mode)
% Creates the properties for JIDE Property Grid containing the values in
% the metadata defaults tree.


if node.isLeaf()
    properties = leafJIDEGridProperties(node,mode);
else
    properties = nonLeafJIDEGridProperties(node,mode);
end

function properties = leafJIDEGridProperties(node,mode)
nestedName = node.getNestedName('');
if ~node.getValueAppear(mode)
    properties = [];
    return;
end

readOnly = node.getReadOnly(mode);
dataType = node.getDataType();
validatorType = class(node.valueValidator);

switch lower(dataType)
    
    case 'string'
        
        switch validatorType
            
            case 'StringValidator'
                allowedStrings = node.valueValidator.allowedStrings;
                % If only one value set readonly to true.
                if length(allowedStrings) == 1
                    readOnly = true;
                end
                
                propType = PropertyType('char','row',allowedStrings);
                properties = PropertyGridField( ...
                    nestedName, node.value, ...
                    'Type', propType,...
                    'Category', node.root.name, ...
                    'DisplayName', node.uniqueName, ...
                    'ReadOnly', readOnly ...
                    );
                
            case 'BaseValidator'
                
                properties = PropertyGridField( ...
                    nestedName, {node.value;''}, ...
                    'Category', node.root.name, ...
                    'DisplayName', node.uniqueName, ...
                    'ReadOnly', readOnly ...
                    );
                
                
            otherwise
                error('incorrect validator for string data type');
        end
        
    otherwise
        properties = PropertyGridField( ...
            nestedName, node.value, ...
            'Category', node.root.name, ...
            'DisplayName', node.uniqueName, ...
            'ReadOnly', readOnly ...
            );
end
   


function properties = nonLeafJIDEGridProperties(node,mode)
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

% Loop over all children calling getJIDEGridProperties recursively.
for i = 1:node.numChildren
    childNode = node.children(i);
    childProperties = getJIDEGridProperties(childNode,mode);
    if ~isempty(childProperties)
        properties = [properties, childProperties];
    end
end

 
 
