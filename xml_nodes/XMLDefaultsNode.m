classdef XMLDefaultsNode < XMLDataNode
    
    properties
       value = '';
       valueValidator = BaseValidator();
       validation = true;
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
        
        function self = XMLDefaultsNode()
            % DefaultsNode constructor
            self.parent = self.createEmptyNode();
            self.children = self.createEmptyNode();
        end
        
        function child = createChild(self)
            % Creates an child node. Required when inherting form
            % XMLDataNode.
            child = XMLDefaultsNode();
        end
        
        function node = createEmptyNode(self)
            % Creates an empty node. Rrequired when inheriting from
            % XMLDataNode.
            node = XMLDefaultsNode.empty();
        end
        
        function checkAttributes(self)
            % Check that all leaves of tree have the required attributes
            self.walk(@checkNodeAttributes);
        end
        
        function dataType = getDataType(self)
            % Return dataType string for node from the node attributes
            if self.isLeaf()
                dataType = strtrim(self.attribute.datatype);
            else
                dataType = '';
            end
        end
        
        function range = getRangeString(self, mode)
            % Get the range string from the node attributes based on the 
            % operating mode.
            if self.isLeaf()
                if strcmpi(mode,'basic')
                    range = strtrim(self.attribute.range_basic);
                elseif strcmpi(mode, 'advanced')
                    range = strtrim(self.attribute.range_advanced);
                else
                    error('unknown mode string %s', mode);
                end
            else
                range = [];
            end
        end
        
        function default = getDefaultValue(self)
            % Get default value for node.
           if self.isLeaf()
               default = strtrim(self.attribute.default);
           else
               default = '';
           end
        end
        
        function last = getLastValue(self)
            % Get last value for node.
            if self.isLeaf()
                last = strtrim(self.attribute.last);
            else
                last = '';
            end
        end
        
        function entryType = getValueEntryType(self)
            % Get entry type for node value.
           if self.isLeaf()
               entryType = strtrim(self.attribute.entry);
           else
               entryType = 'none';
           end
        end
        
        function flag = getValueRequired(self)
            % Returns true is the node contains a required value and false
            % otherwise.
            if self.isLeaf()
                requiredString = strtrim(self.attribute.required);
                switch lower(requiredString)
                    case 'true'
                        flag = true;
                    case 'false'
                        flag = false;
                    otherwise
                        error('unrecognised required string');
                end            
            else
                flag = false;
            end
        end
        
        function units = getValueUnits(self)
           % Returns values units
           if self.isLeaf()
               units = strtrim(self.attribute.units);
           else
               units = '';
           end
        end
        
        function flag = getValueAppear(self, mode)
            % Returns flag indicating whether or not value should appear
            % in the GUI for the given mode string.
            switch lower(mode)
                case 'basic'
                    appearString = strtrim(self.attribute.appear_basic);
                case 'advanced'
                    appearString = strtrim(self.attribute.appear_advanced);
                otherwise
                    error('unrecognised mode string %s', mode);
            end
            [flag, ~] = parseAppearString(appearString);
        end
        
        function flag = getReadOnly(self, mode)
            % Returns flag indicating whether or not value should be read
            % only in GUI for the given mode string.
            switch lower(mode)
                case 'basic'
                    appearString = strtrim(self.attribute.appear_basic);
                case 'advanced'
                    appearString = strtrim(self.attribute.appear_advanced);
                otherwise
                    error('unrecognised mode string %s', mode);
            end
            [~, flag] = parseAppearString(appearString);
        end
        
        function test = hasRequiredValues(self)
            % Check if all required values of all tree leaves have a value.
            test = true;
            leaves = self.getLeaves();
            for i = 1:length(leaves)
                leaf = leaves(i);
                requiredFlag = leaf.getValueRequired();
                if (requiredFlag == true) && isempty(leaf.value)
                    %disp(['required value for node, ', leaf.getPathString(), ', not present']);
                    test = false;
                end
            end
        end
        
        function valuesToAcquire = getValuesToAcquire(self)
            % Get cell array containing the unique path string, from the root 
            % node, of all values that need to be acquired.
            leaves = self.root.getLeaves();
            valuesToAcquire = {};
            cnt = 0;
            for i = 1:length(leaves)
                node = leaves(i);
                if strcmpi(node.getValueEntryType(), 'acquire')
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
            % get node value
           value = self.value;
        end
        
        function set.value(self, value)
            % Set node value.
           [value,flag, msg] = self.validateValue(value);
           if flag == true
                self.value = value;
           else
               error('validation error: %s', msg);
           end
        end
        
        function [value, flag, msg] = validateValue(self, value)
            % Call value validation function on given value.
            if self.validation == true
                [value,flag,msg] = self.valueValidator.validationFunc(value);
            else
                flag = true;
                msg = '';
            end
        end
        
        function value = getValidValue(self)
            % Get valid value from value validator.
            value = self.valueValidator.getValidValue();
        end
        
        function setValueValidators(self, mode)
            % Sets the value validation function for this node and all nodes 
            % below it in the tree based on the mode string which can be equal
            % 'basic' or 'advanced'
            self.walk(@setNodeValueValidator,mode);
        end
        
        function setValuesToDefaults(self)
            % Set the values of this node and all nodes below it on the tree
            % to the defualt value. 
            self.walk(@setNodeValueToDefault);
        end
        
        function printValues(self)
            % Prints the current values for all of the nodes.
            self.walk(@printNodeValue);
        end
        
    end
end % classdef XMLDefaultsNode

function setNodeValueToDefault(node)
% Set a nodes value to the specified default value
if node.isLeaf() && (~strcmpi(node.getValueEntryType(),'acquire'))  
    % Get default value
    if strcmp(node.getDefaultValue(),'$LAST')
        value = node.getLastValue();
        if isempty(value)
            % If last value is empty - set to known valid value.
            value = node.getValidValue();
            node.value = value;
        else
            % Check to see if last value validates
            [value, flag, msg] = node.validateValue(value);
            if flag == false
                % Last value does not validate - set to known valid value 
                % and issue warning.
                value = node.getValidValue();
                warning( ...
                    'XMLDefaultsNode:defaultvalidation', ...
                    'last value does not validate, for node %s, %s, setting to valid value %s', ...
                    node.getPathString(), ...
                    msg, ...
                    var2str(value) ...
                    );
            end
            node.value = value;    
        end
    else
        value = node.getDefaultValue();
        if isempty(value)
            % There is no default specified. Turn validation off and set 
            % value to empty string. Turn validation back on when done.
            node.validation = false;
            node.value = '';
            node.validation = true;
        else
            % There is a default value. Check to see if it validates
            [value, flag, msg] = node.validateValue(value);
            if flag == false
                % Default value does not validate - set to known valid
                % value and issue warning.
                value = node.getValidValue();
                warning( ...
                    'XMLDefaultsNode:defaultvalidation', ...
                    'default does not validate, for node %s, %s, setting to valid value %s', ...
                    node.getPathString(), ...
                    msg, ...
                    var2str(value) ...
                    );
            end
            node.value = value;
        end   
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
    %disp(node.name);
    rangeString = node.getRangeString(mode);
    dataType = node.getDataType();
    if isempty(rangeString)
        node.valueValidator = BaseValidator();
    else
        switch lower(dataType)
            case 'integer'
                %disp('integer datatype');
                node.valueValidator = IntegerValidator(rangeString);
            case 'float'
                %disp('float datatype');
                node.valueValidator = NumericValidator(rangeString);
            case 'string'
                %disp('string datatype');
                node.valueValidator = StringValidator(rangeString);
            case 'datetime'
                %disp('datetime datatype')
                node.valueValidator = DateTimeValidator(rangeString);
            case 'time24'
                %disp('time24 datatype')
                node.valueValidator = Time24Validator(rangeString);
            case 'integer_list'
                %disp('integer_list datatype');
            otherwise
                error('unkown datatype %s', dataType);
        end
    end
else
    node.valueValidator = BaseValidator();
end
end

function [appearFlag, readOnlyFlag] = parseAppearString(appearString)
% Parses the appearString of leaf attributes and return the appearFlag
% (true or false) and the readOnlyFlag (true or false).
appearString = strtrim(appearString);
if isempty(appearString)
    error('appear string is empty should be false, true or true, readonly');
end
commaPos = findstr(appearString,',');
if length(commaPos) > 1
    error('too many commas in appear string');
end
if isempty(commaPos) 
    appearFlagString = lower(strtrim(appearString));
    readOnlyFlagString = '';
else
    appearFlagString = lower(strtrim(appearString(1:commaPos-1)));
    readOnlyFlagString = lower(strtrim(appearString(commasPos+1,end)));
end

switch (appearFlagString)
    case 'true'
        appearFlag = true;
    case 'false'
        appearFlag = false;
    otherwise
        error('unrecognised value for appear string: %s', appearString);
end

switch (readOnlyFlagString)
    case 'readonly'
        reasOnlyFlag = true;
    case ''
        readOnlyFlag = false;
    otherwise
end

end

