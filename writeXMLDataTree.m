function writeXMLDataTree(filename,tree)
% Writes data in XMLDataNode based tree to an xml file with given filename
%
% Arguments:
%  filename   = name of output file
%  tree       = the XMLDataTree to write
tree.write(filename);
