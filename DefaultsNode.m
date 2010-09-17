classdef DefaultsNode < XMLDataNode
    
    properties
       value = [];
       valueValidator = BaseValidator();
    end
    
    properties (Constant, Hidden)
        % Attributes required for leaf nodes of the tree.
        requiredAttributes = { ...
            'datatype', ...
            'range_basic', ...
            'range_advanced', ...
            'units', ...
            'appear_basic', ...
            'appear_advanced', ...
            'entry', ...
            'description', ...
            'required', ...
            'default', ...
            'last'
            };
    end
      
    methods
        
        function self = DefaultsNode()
            % DefaultsNode constructor
            self.parent = self.createEmptyNode();
            self.children = self.createEmptyNode();
        end
        
        function child = createChild(self)
            % Creates an child node. Required when inherting form
            % XMLDataNode.
            child = DefaultsNode();
        end
        
        function node = createEmptyNode(self)
            % Creates an empty node. Rrequired when inheriting from
            % XMLDataNode.
            node = DefaultsNode.empty();
        end
        
        function checkAttributes(self)
            % Check that all leaves of tree have the required attributes
            self.walk(@checkNodeAttributes);
        end
        
        function range = getRangeString(self, mode)
            % Get the range string from the node attributes based on the 
            % operating mode.
            if self.isLeaf()
                if strcmpi(mode,'basic')
                    range = self.attribute.range_basic;
                elseif strcmpi(mode, 'advanced')
                    range = self.attribute.range_advanced;
                else
                    error('unknown mode string %s', mode);
                end
            else
                range = [];
            end
        end
        
        function dataType = getDataType(self)
            % Return dataType string for node from the node attributes
            if self.isLeaf()
                dataType = self.attribute.datatype;
            else
                dataType = '';
            end
        end
        
        function setValueValidator(self, mode)
            % Sets the value validation function for the node based on the
            % mode string = 'basic' or 'advanced'
            self.walk(@setNodeValueValidator,mode);
        end
        
        function setValuesToDefaults(self)
            % Set all node values to there default values
            self.walk(@setNodeValueToDefault);
        end
        
        function printValues(self)
            % Prints the current values for all of the nodes.
            self.walk(@printNodeValue);
        end
        
        function valuesToAcquire = getValuesToAcquire(self)
            % Get cell array containing the unique path string, from the root 
            % node, of all values that need to be acquired.
            leaves = self.getLeaves();
            valuesToAcquire = {};
            cnt = 0;
            for i = 1:length(leaves)
                node = leaves(i);
                if strcmpi(node.attribute.entry, 'acquire')
                    cnt = cnt+1;
                    valuesToAcquire{cnt} = node.getPathString();
                end
            end
        end
        
        function printValuesToAcquire(self)
            % Print the unique path string from the root node for all
            % values that need to be acquired.
            valuesToAcquire = self.getValuesToAcquire();
            for i = 1:length(valuesToAcquire)
                disp(valuesToAcquire{i});
            end
        end
        
    
        
        function value = get.value(self)
           %disp(['getting: ', self.uniqueName,'.value']); 
           value = self.value;
        end
        
        function set.value(self, value)
           %disp(['setting: ', self.uniqueName,'.value']);
           [value,flag, msg] = self.validateValue(value);
           if flag == true
                self.value = value;
           else
               error('validation error: %s', msg);
           end
        end
        
        function [value, flag, msg] = validateValue(self, value)
            % Call value validation function.
            [value,flag,msg] = self.valueValidator.validationFunc(value);
        end
     
    end
end 


function setNodeValueToDefault(node)
% Set a nodes value to the specified default value
if node.isLeaf()
    if strcmp(node.attribute.default,'$LAST')
        node.value = node.attribute.last;
    else
        node.value = node.attribute.default;
    end
end
end

function checkNodeAttributes(node)
% Check that a node has the required attributes
if node.isLeaf()
    for i = 1:length(node.requiredAttributes)
        attributeName = node.requiredAttributes{i};
        if ~isfield(node.attribute,attributeName)
            error('attribute %s missing from node %s',attributeName,node.getPathString());
        end
    end
    
else
    for i = 1:node.numChildren
        child = node.children(i);
        child.checkAttribute();
    end
end
end

function printNodeValue(node)
disp([node.indent,node.name, ', ', var2str(node.value)]);
end

function setNodeValueValidator(node, mode)
% Creates the validation function for a node based on the mode string - 
% 'basic' or 'advanced'.
if node.isLeaf()
    rangeString = node.getRangeString(mode);
    dataType = node.getDataType();
    if isempty(rangeString)
        node.valueValidator = BaseValidator();
    else
        switch lower(dataType)
            case 'integer'
                disp(['integer datatype',', ', rangeString])
                node.valueValidator = IntegerValidator(rangeString);
            case 'float'
                disp('float datatype')
                node.valueValidator = NumericValidator(rangeString);
            case 'string'
                %disp('string datatype')
            case 'datetime'
                %disp('datetime datatype')
            case 'time24'
                %disp('time24 datatype')
            otherwise
                %error('unkown datatype %s', dataType);
        end
    end
else
    node.valueValidator = BaseValidator();
end
end

