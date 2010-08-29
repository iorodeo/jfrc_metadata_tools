function g = pgridTest

sampleXMLDir = [pwd, filesep, 'sample_xml'];
tree = loadXMLDataTree([sampleXMLDir, filesep, 'flybowl.xml']);
% tree = loadXMLDataTree([sampleXMLDir, filesep, 'trikinetics.xml']);
% tree = loadXMLDataTree([sampleXMLDir, filesep, 'test0.xml']);
% tree = loadXMLDataTree([sampleXMLDir, filesep, 'MetaMetaData_v2.xml'])

properties = tree.getJIDEGridProperties();
properties = properties.GetHierarchy();

% create figure
f = figure( ...
    'MenuBar', 'none', ...
    'Name', 'Property grid demo - Copyright 2010 Levente Hunyadi', ...
    'NumberTitle', 'off', ...
    'Toolbar', 'none');

% procedural usage
%g = PropertyGrid(f,'Properties', properties,'Position', [0 0 0.5 1]);
g = PropertyGrid(f,'Position', [0 0 0.5 1]);
g.Properties = properties;

uiwait(f);
%g.Properties()
%delete(g);