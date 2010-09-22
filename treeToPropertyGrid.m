function treeToPropertyGrid(defaultsTree,mode,hierarchy)
% Creates a JIDE property grid from a metadata defaults tree.
%
% Arguments:
%   defaultsTree  = an xml defaults tree w/ nodes of class XMLDefaultsNode.
%   mode          = 'basic' or 'advanced'. The default is true.
%   hierarchy     = true or false, determines whether tree is shown as
%                   heirarchy or flat respectively. The default is true.
%
% Note, currently the option with hierarchy=false is broken. Or at least I
% think that it is - I missed some subtlies here. I think I need to
% generate unique leaf names for this to work.
%
% -------------------------------------------------------------------------
if nargin < 2
    mode = 'basic';
end
if nargin < 3
    hierarchy = true;
end
propBuilder = PropertiesBuilder(defaultsTree,mode,hierarchy);
propBuilder.showTestFigure();

% Test creating metadata and writing to file
metaData = createXMLMetaData(defaultsTree);
metaData.write('metadata_test_write.xml');
defaultsTree.write('defaults_test_write.xml');








