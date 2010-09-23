classdef XMLDefaultsNode < XMLDataNode
    % Encapsulates a node or element of an defaults data XML file. The
    % nodes can be used to create a tree based on the structure of the
    % defaults file. 
    %
    % More ...
    
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
        % Allowed values for leaf attributes.
        allowedDataTypes = { ...
            'string', ...
            'float', ...
            'integer', ...
            'time24', ...
            'datetime', ...
            'integerlist' ...
            };
        allowedEntryTypes = {'manual','acquire'}; 
        allowedRequiedValues = {'true','false'};
        allowedModes = {'basic', 'advanced'};
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
        
        function treeFromStruct(self,xmlStruct,mode)
           % Create a defaults data xml tree from an xml structure read 
           % using xml_io_tools. Children are assigned unique names during
           % the call the treeFromStruct@XMLDataNOde
           if nargin < 3
               mode = 'basic';
           end
           treeFromStruct@XMLDataNode(self,xmlStruct);
           self.checkNodes();
           self.setValueValidators(mode);
           self.setValuesToDefaults();
        end
        
        function checkNodes(self)
            % Apply routines which check the structure and values in the
            % tree consiting of the current node and all nodes below it in
            % the tree.
            self.walk(@checkNode);
        end
        
        function write(self,filename,savelast)
            % Writes the tree containing the current node and all nodes below 
            % it to an xml file. The optional argument savelast determines
            % if the last value attributes of the leaf nodes are set to the
            % leaf's current value.
            if nargin < 3
                savelast = true;
            end
            if savelast == true
                self.setLastToValue();
            end
            write@XMLDataNode(self,filename);
        end
        
        function setLastToValue(self)
            % For all leaves in the tree below the node self, set the last 
            % value attribute to the current value.
            leaves = self.getLeaves();
            for i = 1:length(leaves)
                leaf = leaves(i);
                leaf.attribute.last = leaf.value;
            end
        end
       
        function dataType = getDataType(self,pathString)
            % Return dataType string for node from the node attributes. If
            % the path string argument is not given the data type for the
            % node self is returned. Otherwise the data type for the node
            % below self specified by the path string of unique names is
            % returned.
            % 
            % Note, if the node is not a leaf the data type returned is
            % always the empty string.
            if nargin == 1
                if self.isLeaf()
                    dataType = strtrim(self.attribute.datatype);
                else
                    dataType = '';
                end
            else
                node = self.getNodeByPathString(pathString);
                dataType = node.getDataType();
            end
        end
        
        function range = getRangeString(self, mode)
            % Get the range string from the node attributes based on the 
            % operating mode.
            if nargin == 1
                mode = 'basic';
            end
            if self.isLeaf()
                if strcmpi(mode,'basic')
                    range = strtrim(self.attribute.range_basic);
                elseif strcmpi(mode, 'advanced')
                    range = strtrim(self.attribute.range_advanced);
                else
                    error('unknown mode string %s', mode);
                end
            else
                % If node is not a leaf there is no range string.
                range = [];
            end
        end
        
        function default = getDefaultValue(self)
            % Get default value for node from the nodes' attributes.
           if self.isLeaf()
               default = strtrim(self.attribute.default);
           else
               % If node is not a leaf there is no default value.
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
               entryType = '';
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
        
        function descr = getValueDescription(self)
           % Get the description string for the value
           if self.isLeaf()
               descr = strtrim(self.attribute.description);
           else
               descr = '';
           end
        end
        
        function appearString = getAppearString(self,mode)
           % Returns the appear string for the node self
           if self.isLeaf()
               switch lower(mode)
                   case 'basic'
                       appearString = strtrim(self.attribute.appear_basic);
                   case 'advanced'
                       appearString = strtrim(self.attribute.appear_advanced);
                   otherwise
                       error('unkown mode string %s', mode);
               end
           else
               appearString = '';
           end
        end
        
        function flag = getValueAppear(self, mode, hierarchy)
            % Returns flag indicating whether or not value should appear
            % in the GUI for the given mode string. Hierarchy can be set to
            % true or false. The default is true. If hierachy is true all
            % nodes on branches with leaves that have appear=true will 
            % themselves return true, i.e., the appear value is propogates 
            % up branches of the tree in order to create the hierarchy. If 
            % heirarchy = false only leaves with appear=true will return 
            % true with the exception of nodes with content that has appear
            % true.
            %
            % This is unfortunately a little convoluted.
            if nargin < 2
                mode = 'basic';
            end
            if nargin < 3
                hierarchy = true;
            end
            if self.isLeaf() == true    
                % Node is a leaf, set the value of appear flag based upon 
                % the mode and attribute settings.
                appearString = self.getAppearString(mode);
                [flag, ~] = parseAppearString(appearString);
            else
                % Deterimine if non-leaf node should appear
                flag = false;
                
                if self.isContentNode() == true
                    % Node is content node. Check if only child node (named
                    % content) is set to appear if so node should also appear.
                    childNode = self.children(1);
                    if childNode.getValueAppear() == true
                        flag = true;
                    end
                end
                
                if hierarchy == true
                    % If hierarachy is set to true propogate appear setting
                    % up branches so that all nodes on branches containing 
                    % leaves which appear will also appear.
                    for i = 1:self.numChildren
                        childNode = self.children(i);
                        flag = flag | childNode.getValueAppear();
                    end
                end
            end
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
            % Check if all value that are require are present for the tree 
            % consisting of the current node and all nodes below it. 
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
            % For the tree consisting of the current node and all nodes
            % below returns a cell array containing the unique path string, 
            % from the root node, of all nodes with values that that have
            % entry type acquire.
            leaves = self.getLeaves();
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
        
        function num = getNumValuesToAcquire(self)
            % Returns the number of values that have entry type set to
            % acquire.
            valuesToAcquire = self.getValuesToAcquire();
            num = length(valuesToAcquire);
        end
        
        function printValuesToAcquire(self)
            % Print the unique path string from the root node for all
            % values that need to be acquired.
            valuesToAcquire = self.getValuesToAcquire();
            for i = 1:length(valuesToAcquire)
                disp(valuesToAcquire{i});
            end
        end
        
        function test = isContentNode(self)
           % Test if node represents an element with content. For this to 
           % be the case the node must have only a single child which is a
           % leaf whose name is 'content'
           if self.numChildren == 1 && strcmpi(self.children(1).name, 'content')
               test = true;
           else
               test = false;
           end
        end
        
        function setValueByPathString(self,pathString,value)
            % Set value in defaults tree using the path string which 
            % specifies the unique path from the root node. 
            uniquePath = pathStringToUniquePath(self.root.name, pathString);
            self.setValueByUniquePath(uniquePath,value);
        end
        
        
        function setValueByUniquePath(self,uniquePath,value)
           % Set value of node using a cell array containing the unique 
           % path from the root node.   
           rootNode = self.root;
           node = rootNode.getNodeByUniquePath(uniquePath);
           node.value = value;
        end
       
        function node = getNodeByPathString(self,pathString)
           % Get a node using the using the path string which specifies the
           % unique path from the root node.
            uniquePath = pathStringToUniquePath(self.root.name, pathString);
            node = self.getNodeByUniquePath(uniquePath);
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
                %disp(['* called ', self.name, ' validator']);
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

% -------------------------------------------------------------------------
function setNodeValueToDefault(node)
% Set a node value to the default specified by the defaults attribute.
if node.isLeaf() && (~strcmpi(node.getValueEntryType(),'acquire'))  
    % Get default value
    switch node.getDefaultValue()
        case '$LAST'
            setNodeValueToLast(node);
        otherwise
            setDefaultValueGeneric(node);     
    end
end
end
   
% -------------------------------------------------------------------------
function setNodeValueToLast(node)
% Set node to value to the last value used.
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
end

% -------------------------------------------------------------------------
function setDefaultValueGeneric(node)
% Generic node to default value - generic case, i.e., not a special case
% such as $LAST. 
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

% -------------------------------------------------------------------------
function checkNode(node)
% Applies basic tests to check that node conforms to the requied format for 
% a xml defaults tree.
checkAttribute(node);
checkDataType(node);
checkValueAppear(node);
checkEntryType(node);
checkValueRequired(node);
checkRanges(node);
checkContent(node);
checkManualEntry(node);
end

% -------------------------------------------------------------------------
function checkAttribute(node)
% Check that a node has the required attributes. Only leaves are required
% to have attributes.
if node.isLeaf()
    for i = 1:length(node.requiredAttributes)
        attributeName = node.requiredAttributes{i};
        if ~isfield(node.attribute,attributeName)
            error( ...
                'attribute %s missing from node %s', ...
                attributeName, ...
                node.getPathString() ...
                );
        end
    end
end
end

% -------------------------------------------------------------------------
function checkDataType(node)
% Checks that the nodes datatype is in the list of allowed data types.
% Note, this only applies to leaf nodes.
if node.isLeaf() == true
   dataType = node.getDataType();
   try
       validatestring(dataType,node.allowedDataTypes);
   catch ME
       error( ...
           'unkown data type %s for node %s: %s', ...
           dataType, ...
           node.getPathString(), ...
           ME.message ...
           );
   end
end
end

% -------------------------------------------------------------------------
function checkValueAppear(node)
% Check that the appear values can be parsed
if node.isLeaf()
    for i = 1:length(node.allowedModes)
        mode = node.allowedModes{i};
        try
            appearString = node.getAppearString(mode);
            [~, ~] = parseAppearString(appearString);
        catch ME
            error( ...
                'unable to parse appear string for node %s: %s', ...
                node.getPathString(), ...
                ME.message ...
                );
        end
    end
end
end

% -------------------------------------------------------------------------
function checkEntryType(node)
% Checks that the entry value for the node is in the list of allowed
% values.
entryType = node.getValueEntryType();
if node.isLeaf() == true
    try
        validatestring(entryType,node.allowedEntryTypes);
    catch ME
        error( ...
            'unknown entry type, %s, for node %s: %s', ...
            entryType, ...
            node.getPathString(), ...
            ME.message ...
            );
    end
else
    if isempty(entryType) == false
        error( ...
            'entry type for non leaf node %s should be empty', ...
            node.getPathString() ...
            );
    end
end
end

% -------------------------------------------------------------------------
function checkValueRequired(node)
% Check that the value required attribtue can be parsed correctly
try
    node.getValueRequired();
catch ME
    error( ...
        'unable to parse value required for node %s: %s', ...
        node.getPathString(), ...
        ME.message ...
        );
end
end

% -------------------------------------------------------------------------
function checkRanges(node)
% Check that Ranges for all modes can be parsed by the value validators.
if node.isLeaf() == true
    for i = 1:length(node.allowedModes)
       mode = node.allowedModes{i};
       try
           setNodeValueValidator(node,mode);
       catch ME
           error( ... 
               'unable to parse range of node %s for mode=%s: %s', ...
               node.getPathString(), ...
               mode, ...
               ME.message ...
               );
       end
    end
end
end

% -------------------------------------------------------------------------
function checkContent(node)
% Check a content node to see if it has the correct format.
if node.isContentNode()
    if node.numChildren ~= 1
        error( ...
            'content nodes must only have a single child: node %s', ...
            node.getPathString() ...
            );
    end
    childNode = node.children(1);
    if ~strcmpi(childNode.name,'content')
        error( ...
            'child element of content node must be named content: node %s', ...
            node.getPathString() ...
            );
    end
end
end

% -------------------------------------------------------------------------
function checkManualEntry(node)
% Checkes nodes whose value entry type is set to manual. Makes sure that
% they are either set to appear or have a default set for both basic and
% advanceed modes. Note, this only applies to leaf elements.
entryType = node.getValueEntryType();
if (node.isLeaf() == true) && (strcmpi(entryType,'manual')==true)
    for i = 1:length(node.allowedModes)
        mode = node.allowedModes{i};
        appearValue = node.getValueAppear(mode);
        defaultValue = node.getDefaultValue();
        if (appearValue == false) && (isempty(defaultValue) == true)
           error( ...
               'node: %s, does not appear for mode %s and has no default value', ...
               node.getPathString(), ...
               mode ...
               );
        end
    end
end
end

% -------------------------------------------------------------------------
function printNodeValue(node)
disp([node.indent,node.name, ', ', var2str(node.value)]);
end

% -------------------------------------------------------------------------
function setNodeValueValidator(node, mode)
% Creates the validation function for a node based on the mode string - 
% 'basic' or 'advanced'.
if node.isLeaf()
    %disp(node.name);
    rangeString = node.getRangeString(mode);
    dataType = node.getDataType();
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
else
    node.valueValidator = BaseValidator();
end
end

% -------------------------------------------------------------------------
function [appearFlag, readOnlyFlag] = parseAppearString(appearString)
% Parses the appearString of leaf attributes and returns the appearFlag
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
    readOnlyFlagString = lower(strtrim(appearString(commaPos+1:end)));
end

% Set value of appear flag based on String
switch appearFlagString
    case 'true'
        appearFlag = true;
    case 'false'
        appearFlag = false;
    otherwise
        error('unrecognised value for appear string: %s', appearFlagString);
end

% Set value of readOnly flag based on String
switch readOnlyFlagString
    case 'readonly'
        readOnlyFlag = true;
    case ''
        readOnlyFlag = false;
    otherwise
        error('recognised value for read only string: %s', readOnlyFlagString);
end

end

% -------------------------------------------------------------------------
function  uniquePath = pathStringToUniquePath(rootName,pathString)
% Converts a path String to a Cell Array of the unique path from the root
% node.
uniquePath = {rootName};
pathString = ['.',pathString,'.'];
dotPos = findstr(pathString,'.');
for i = 2:length(dotPos)
    n1 = dotPos(i-1)+1;
    n2 = dotPos(i)-1;
    uniquePath{i} = pathString(n1:n2);
end
end

