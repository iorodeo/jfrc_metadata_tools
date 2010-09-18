function tree = loadXMLDefaultsTree(filename, mode)
% Loads a defaults xml metadata tree based on the XMLDefaultsNode class 
% from the given xml file.
% 
% Arguments:
%  filename  = the name of the xml file to read
%  mode      = the mode used to set the validators for the tree.
%
% -------------------------------------------------------------------------
if nargin == 1
    mode = 'basic';
else 
    mode = 'advanced';
end
% Read xml file into xmlStruct using xml_io_tools
wPref.NoCells = false;
wPref.ReadSpec = false;
wPref.Str2Num = 'never';
[xmlStruct, name_cell] = xml_read(filename,wPref);

% Create xml metadata tree
name = name_cell{1};
tree = XMLDefaultsNode();
tree.name = name;
tree.nodeFromStruct(xmlStruct);
tree.assignUniqueNames();
tree.setValueValidators(mode);
tree.setValuesToDefaults();
end