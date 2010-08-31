classdef XMLDataNode < handle
    % XMLDataNode: Encapsultates a node (or element) of xml data and is 
    % designed to be used to represent an XML file as a tree.
    properties
        name = '';
        parent = XMLDataNode.empty();
        children = XMLDataNode.empty();
        attribute = struct;
        content =[];
        uniqueName;
    end
   
    properties (Dependent)
        numNodes;
        numChildren;
        childNames;
        uniqueChildNames;
        numAttribute;
        attributeNames;
        root;
        pathFromRoot;
        uniquePathFromRoot;
        depth;
    end
    
    properties (GetAccess=protected,Constant)
        printIndentNum = 3;
    end
    
    properties %(Access=private)
        mark = false;  
    end
     
    methods
        
        function self = XMLDataNode(name,parent,xmlStruct)
            % Node constructor function. 
            if nargin >= 1
                % Creates a root node with name=name.
                self.name = name;
            end
            if nargin >= 2
                % Creates a root node with parent=parent.
                self.parent = parent;
            end
            if nargin == 3
                % Creates a root node with name=name and parent=parent and
                % loads xml file tree from the xmlStruct returned by the 
                % xml_read function in the xml_io_tools library.
                self = nodeFromStruct(name,parent,xmlStruct);
                self.assignUniqueNames();
            end
        end
        
        function addChild(self,childNode,assignUnique)
            % Adds a child node to the current node of the tree. The
            % optional argment assignUnique specifies whether or not unique
            % names are assigned/reassigned to the children (and their
            % children) of the current node. In general when adding alot of
            % nodes, say when building the tree, users will want to use
            % assignUnique = false and then explicitly call the method
            % assignUniqueNames to give uniques names to the nodes at each
            % level of the tree. This reduced significantly the amount of 
            % computation done. The default value for assignUnique is
            % false.
            if nargin == 2
                assignUnique = false;
            end  
            % Adds a child node to the current node.
            self.children(self.numChildren+1) = childNode;
            childNode.parent = self;
            % Assign unique names to all child nodes.
            if assignUnique == true
                self.assignUniqueChildren();
            end 
        end
        
        function rmChild(self,index,assignUnique)
            % Removes a child node (and all nodes beneath it) from the
            % the current node. The optional argment assignUnique specifies 
            % whether or not the unique names are recalculated for the
            % current node after removal of the child node. The defualt
            % value for assignUnique is false.
            if nargin == 2
                assignUnique = false;
            end
            if self.numChildren >= index
                childNode = self.children(index);
                for i = childNode.numChildren:-1:1
                    childNode.rmChild(i);
                end
                delete(childNode);
                self.children = XMLDataNode.empty();
            end
            if assignUnique == true
                self.assignUniqueChildren();
            end
        end
        
        function children = getChildrenByName(self,name)
            % Returns an object array of all children of the current node 
            % with the given name.
            cnt = 0;
            children = XMLDataNode.empty();
            for i = 1:self.numChildren
                childname = self.children(i).name;
                if strcmp(childname,name)
                   cnt = cnt+1;
                   children(cnt) = self.children(i);
                end
            end
        end
        
        function addAttribute(self,name,value)
            % Adds an attribute to the current node.
            self.attribute.(name) = value;
        end
        
        function rmAttribute(self,name)
            % Removes an attribute from the current node
            self.attribute = rmfield(self.attribute,name);
        end
        
        function rmContent(self)
            % Deletes the nodes content.
            self.content = [];
        end
              
        function num = getNumNodesBelow(self)
            % Returns the number of nodes in the tree below this node
            num = self.numChildren;
            for i = 1:self.numChildren
                child = self.children(i);
                num = num + child.getNumNodesBelow();
            end
        end
        
        function test = isRoot(self)
            % Tests if the current node is the root node of the tree.
            test = isempty(self.parent);
        end
        
        function pathFromRoot = getPathFromRoot(self)
            % Returns a cell array containing the path, in element names,
            % from the root of the tree to the current node.
            if self.isRoot()
                pathFromRoot = {self.name};
            else
                parentPath = self.parent.getPathFromRoot();
                pathFromRoot = {parentPath{:},self.name};
            end
        end
        
        function uniquePath = getUniquePathFromRoot(self)
            % Returns a cell array containing the path, in unique element
            % name from the root of the tree to the current node.
           if self.isRoot()
               uniquePath = {self.uniqueName};
           else
               parentPath = self.parent.getUniquePathFromRoot();
               uniquePath = {parentPath{:},self.uniqueName};
           end
        end
      
        function print(self,uniqueName)
            % Prints all nodes below and including the current node.
            % uniqueName allows users to select whether or not unique
            % node names are used for printing the node. 
            if nargin == 1
                uniqueName = true;
            end 
            self.printNode(uniqueName);    
            for i = 1:self.numChildren
                child = self.children(i);
                child.print(uniqueName);
            end
        end
        
        function printAll(self)
            % Prints all nodes in the tree.
            self.root.print();
        end
        
        function printNode(self,uniqueName)
             % Prints the current node's data. The uniqueName options
             % allows users to select whether or not unique names are used 
             % when displaying the nodes name.
            if nargin == 1
                uniqueName = false;
            end
            if uniqueName
                name = self.uniqueName;
            else
                name = self.name;
            end
            msg = sprintf('%sNode(%d): %s',self.indent, self.depth, name);
            disp(msg);
            self.printAttribute();
            self.printContent();
        end
          
        function printAttribute(self)
            % Print the current nodes attributes
            %
            % Note, I added the isstruct test because when testing the
            % class an ramdom xml files downloaded from the web I
            % encountered some for which the attributes in the xmlStruct
            % returned by xml_read was not a strucuture. I don't think this
            % will be an issue for the metadata files.
            if isstruct(self.attribute)
                for i = 1:self.numAttribute
                    name = self.attributeNames{i};
                    value = self.attribute.(name);
                    disp([self.indent,'Attribute: ', name, ', ', value]);
                end
            else
                disp([self.indent,'Attribute: ']);
                disp(self.attribute);
            end
        end
        
        function printContent(self)
            % Print the content of a node
            if ~isempty(self.content)
                content = self.content;
                disp([self.indent,'Content: ', content]);
            end
        end
        
        function depth = getDepth(self)
            % Returns depth of the node in the tree. Note, the depth is the
            % distance of the node to the root node.
           if self.isRoot()
               depth = 0;
           else
               depth = self.parent.getDepth() + 1;
           end
        end
        
        function assignUniqueNames(self)
            % Assign names to nodes in the tree which are unique at each
            % level of the tree. Thus the names will be such that no two
            % nodes at the same level have the same name. Note, that nodes
            % at different levels in the tree may still have the same names.
            self.root.uniqueName = self.root.name;
            self.root.assignChildrenUniqueName();
        end
        
        function assignChildrenUniqueName(self)
            % Assign children of a node, and all its childrens' children, 
            % etc. Unique names for their level in the tree. The assigned 
            % names are such that no two nodes at the same level have the 
            % same name. Note, that nodes at different levels in the tree 
            % may still have the same names.
            childNames = self.childNames;
            for i = 1:length(childNames)
                name = self.childNames{i};
                childrenWithName = self.getChildrenByName(name);
                for j = 1:length(childrenWithName)
                    child = childrenWithName(j);
                    child.uniqueName = sprintf('%s_%d',child.name,j);  
                    child.assignChildrenUniqueName();
                end
            end
        end
        
        function setMarks(self,value)
            % Sets all marks on the tree given by the current node and all 
            % nodes below its to the logical (true/false) value.
            assert(islogical(value), 'value must be locigal (true/false)');
            self.mark = value;
            for i = 1:self.numChildren
               child = self.children(i);
               child.setMarks(value);
            end
        end
        
        function setMarksTrue(self)
            % Sets all marks on the tree given by the current node and all
            % marks below it to true.
            self.setMarks(true);
        end
        
        function setMarksFalse(self)
            % Sets all marks on the tree given by the current node and all 
            % nodes below it to false.
            self.setMarks(false);
        end
        
        function value = getValueByPath(self,path)
            % Returns the value of either node content or an attribute of a 
            % node using a path of unique node names. 
            if isempty(path)
                % We are at the last node in the list - return its content.
                value = self.content;
                return;
            end
            
            % This is not the last node - get next name in list.
            name = path{1};
            
            % Look for children with this name
            for i = 1:self.numChildren
                disp([name, ', ' self.uniqueChildNames{i}]);
                if strcmp(name,self.uniqueChildNames{i})
                    child = self.children(i);
                    childPath = {path{2:end}};
                    value = child.getValueByPath(childPath);
                    return;
                end
            end
            
            % Couldn't find a child with this name
            if length(path) > 1
                % If this isn't the last name it shouldn't be an
                % attribute - raise an error.
                error('unable to find child of node %s with name %s',self.uniqueName,name);
            else
                % This is the last item in the path - look for Attributes
                % with this name
                if isfield(self.attribute,name)
                    value = self.attribute.(name);
                    return;
                else
                    error('unable to find attribute of node %s with name %s',self.uniqueName,name);
                end
            end
        end
        
        function indent = indent(self)
            % Returns indentation string based on node depth for pretty
            % printing node information.
            indent = blanks(self.depth*self.printIndentNum);
        end
        
        function walk(self, fhandle)
            % Walks tree in depth first manner apply function fhandle to
            % each node in the tree below and including the current node.
            fhandle(self);
            for i=1:self.numChildren
                child = self.children(i);
                child.walk(fhandle);
            end
        end
        
        function [xmlStruct, name] = getXMLStruct(self)
            % Returns a structure (xmlStruct) which represents the tree
            % consisting of the current node and all nodes which are below 
            % it. The structure xmlStruct is designed to be consistent with
            % The representation of XML file used by the xml_io_tools 
            % library and specifically the xml_write and xml_read
            % functions. In addition to xmlStruct the name of the current
            % node is also returned.
            xmlStruct = struct;
            name = self.name;
            % Assign current node's data to xmlStruct
            if ~isempty(self.attribute)
                xmlStruct.ATTRIBUTE = self.attribute;
            end
            if ~isempty(self.content)
                xmlStruct.CONTENT = self.content;
            end     
            % Loop over the current node's children and get thier xml
            % structures. Note, this function recursively calls itself until 
            % the entire tree below this node has been covered.  
            for i = 1:length(self.childNames)             
                childName = self.childNames{i};
                nodesWithChildName = self.getChildrenByName(childName);               
                for j = 1:length(nodesWithChildName)
                    childNode = nodesWithChildName(j);
                    [child_xmlStruct, dummy] = childNode.getXMLStruct();
                    xmlStruct.(childName){j} = child_xmlStruct;
                end  
            end    
        end
        
        function write(self,filename)
            % Writes the data tree containing the current node and all
            % nodes below it to an xml file.
            [xmlStruct, name] = self.getXMLStruct();
            wPref.StructItem = false;
            wPref.CellItem = false;
            xml_write(filename, xmlStruct, name, wPref);
        end
        
        function properties = getJIDEGridProperties(self)
            % Creates a JIDE Property Grid contain the informatin in the XML
            % data tree tree starting from the current node.                  
            if self.isRoot()
                properties = PropertyGridField.empty();  
            else
                % If this isn't the root node create a entry in the
                % property grid field containing the nodes content.
                nestedName = getNestedName(self,'');
                properties = PropertyGridField( ...
                    nestedName, self.content, ...
                    'Category', self.root.name, ...
                    'DisplayName', self.uniqueName, ...
                    'ReadOnly', false ...
                    );
                %disp([self.indent, 'N(', num2str(self.depth), '): ', self.uniqueName, ', ', nestedName]);
            end
                   
            % Add entries for Node attributes.
            for i = 1:self.numAttribute
                attributeName = self.attributeNames{i};
                attributeValue = self.attribute.(attributeName);
                propertyName = getNestedName(self,attributeName);
                % DEBUGGING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if strcmp(attributeName, 'gender')
                    propType = PropertyType('char', 'row', {'m', 'f', 'b'});
                    attributeProps = PropertyGridField( ...
                        propertyName, attributeValue, ...
                        'Type', propType, ...
                        'Category', self.root.name, ...
                        'DisplayName', attributeName, ...
                        'ReadOnly', false ...
                        );
                else
                    attributeProps = PropertyGridField( ...
                        propertyName, attributeValue, ...
                        'Category', self.root.name, ...
                        'DisplayName', attributeName, ...
                        'ReadOnly', false ...
                        );
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 attributeProps = PropertyGridField( ...
%                     propertyName, attributeValue, ...
%                     'Category', self.root.name, ...
%                     'DisplayName', attributeName, ...
%                     'ReadOnly', false ...
%                     );
                properties = [properties, attributeProps];
                %disp([self.indent, 'A: ', propertyName]); 
            end
            
            % Created nested entries for all child nodes.
            for i = 1:self.numChildren
                child = self.children(i);
                childProperties = child.getJIDEGridProperties();
                properties = [properties, childProperties];
            end
        end
        

        
        % set/get methods -------------------------------------------------
        function depth = get.depth(self)
            % Returns the depth of the current node.
           depth = self.getDepth();
        end
        
        function num = get.numNodes(self)
            % Returns the total number of nodes in the tree.
            root = self.root;
            num = root.getNumNodesBelow() + 1;
        end
        
        function root = get.root(self)
            % Returns the root node of the tree.
            currentNode = self;
            parentNode = currentNode.parent;
            while ~isempty(parentNode)
                currentNode = parentNode;
                parentNode = currentNode.parent;
            end
            root = currentNode;    
        end
        
        function pathFromRoot = get.pathFromRoot(self)
            % Returns a cell array containing the path, in element names,
            % from the tree root to the current node.
           pathFromRoot = self.getPathFromRoot(); 
        end
        
        function uniquePath = get.uniquePathFromRoot(self)
            % Returns a cell array containing the path, in unique element
            % names from the root of the tree to the current node.
            uniquePath = self.getUniquePathFromRoot();
        end
        
        function num = get.numChildren(self)
            % Returns the number of children of the current node.
            num = length(self.children);
        end
        
        function names = get.childNames(self)
            % Returns a cell array containing the names of all the children
            % of the current node.
           names = cell(1,self.numChildren);
           for i=1:self.numChildren
               names{i} = self.children(i).name;
           end
           names = unique(names);
        end
        
        function names = get.uniqueChildNames(self)
           % Returns a cell array containing the unique names of all the 
           % children of the current node.
           names = cell(1,self.numChildren);
           for i=1:self.numChildren
               names{i} = self.children(i).uniqueName;
           end
        end
        
        function num = get.numAttribute(self)
            % Returns the number of attributes of the current node.
            %
            % Note, I added the isstruct test because when testing the
            % class an ramdom xml files downloaded from the web I
            % encountered some for which the attributes in the xmlStruct
            % returned by xml_read was not a strucuture. I don't think this
            % will be an issue for the metadata files.
            if isstruct(self.attribute)
                num = length(fieldnames(self.attribute));
            else
                num = 1;
            end
        end
        
        function names = get.attributeNames(self)
            % Returns a cell array containing the names of all the 
            % attributes of the current node.
            names = fieldnames(self.attribute);
        end
  
    end
end % classdef XMLDataNode

% Utility functions
% -------------------------------------------------------------------------
function node = nodeFromStruct(name, parent, xmlStruct)
% Creates nodes given the xml structure loaded using 
% xml_read functin from the xml_io_tools library.
%
% Arguments:
%  name      = the name of the node
%  parent    = the parent node, or XMLDataNode.empty() is this is the root
%              node of a tree.
%  xmlStruct = the nested data structure obtained from the xml file by
%              the xml_read function
% ------------------------------------------------------------------------

% Create top level node and set attribute, content, etc.
%
% Note, I'm ignoring CDATA and PROCESSING_INSTRUCTIONS fields. They
% shouldn't be present if the xml file was read with Pref.ReadSpec =
% false.
node = XMLDataNode(name,parent);
if isfield(xmlStruct,'ATTRIBUTE')
    node.attribute = xmlStruct.ATTRIBUTE;
end
if isfield(xmlStruct, 'CONTENT')
    node.content = xmlStruct.CONTENT;
end

% Use remaining fields (other than ATTRIBUTE, CONTENT, etc) to create child 
% nodes by recursively call nodeFromStruct to create entire tree.
fields = fieldnames(xmlStruct);
for i = 1:length(fields)
    fieldname = fields{i};
    if strcmp(fieldname,'ATTRIBUTE')
        continue;
    end
    if strcmp(fieldname,'CONTENT')
        continue;
    end
    if strcmp(fieldname,'CDATA_SECTION')
        continue;
    end
    if strcmp(fieldname,'PROCESSING_INSTRUCTIONS')
        continue;
    end
    
    data = xmlStruct.(fieldname);
    if isstruct(data) || iscell(data)
        % Data is struct array or cell array - loop over to get children. 
        for j = 1:length(data)
            if isstruct(data)
                child_xmlStruct = data(j);
            else
                child_xmlStruct = data{j};
            end
            childNode = nodeFromStruct(fieldname, node, child_xmlStruct); 
            node.addChild(childNode,false);
        end
    else
        % Data is not an array - create single child node.
        child_node = XMLDataNode(fieldname,node);
        child_node.content = data;
        node.addChild(child_node,false);
    end
end
end


function nestedName = getNestedName(node,name)
% Creates a nested name for use in JIDE Property Grids.
pathFromRoot = node.uniquePathFromRoot;
if isempty(name)
    nameCell = {pathFromRoot{2:end}};
else
    nameCell = {pathFromRoot{2:end}, name};
end
nestedName = nameCell{1};
for i=2:length(nameCell)
    nestedName = [nestedName, '.', nameCell{i}];
end
end
