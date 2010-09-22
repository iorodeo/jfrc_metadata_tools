function treeToPropertyGrid(defaultsTree,mode,hierarchy)
% Creates a JIDE property grid from a metadata defaults tree.
%
% Arguments:
%   defaultsTree  = an xml defaults tree w/ nodes of class XMLDefaultsNode.
%   mode          = 'basic' or 'advanced'. The default is true.
%   hierarchy     = true or false, determines whether tree is shown as
%                   heirarchy or flat respectively. The default is true.
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








