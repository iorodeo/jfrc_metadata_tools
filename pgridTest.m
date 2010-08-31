function tree = pgridTest

sampleXMLDir = [pwd, filesep, 'sample_xml'];
tree = loadXMLDataTree([sampleXMLDir, filesep, 'flybowl.xml']);
% tree = loadXMLDataTree([sampleXMLDir, filesep, 'trikinetics.xml']);
%tree = loadXMLDataTree([sampleXMLDir, filesep, 'test0.xml']);
%tree = loadXMLDataTree([sampleXMLDir, filesep, 'MetaMetaData_v2.xml']);
%tree = loadXMLDataTree('flybowl_defaults.xml');

properties = tree.getJIDEGridProperties();
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
%g.Properties()
%delete(g);