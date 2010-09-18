function [tree, xmlStruct] = loadXMLDataTree(filename)
% Creates an xml data tree based on the XMLDataNode class from the given 
% xml file.
% 
% Arguments:
%  filename: the name of the xml file to read
%
wPref.NoCells = false;
wPref.ReadSpec = false;
wPref.Str2Num = 'never';
[xmlStruct, name_cell] = xml_read(filename,wPref);
name = name_cell{1};

% tree = XMLDataNode();
% tree.name = name;
% tree.nodeFromStruct(xmlStruct);
% tree.assignUniqueNames();

tree = XMLDefaultsNode();
tree.name = name;
tree.nodeFromStruct(xmlStruct);
tree.assignUniqueNames();
%tree.setValueValidator('basic');
tree.setValueValidator('advanced');
tree.setValuesToDefaults();