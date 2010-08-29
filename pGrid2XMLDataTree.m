function pGrid2XMLDataTree(name, pgrid)
% Gets the values from a JIDE Property grid and places them into an XML 
% Data tree.
tree = nodeFromProperties('experiment',XMLDataNode.empty(),pgrid);
end

function nodeFromProperties(name,parent,pgrid)
% Creates a XMLDataNode with parent node = parent, based on the given 
% JIDEProperty grid.

end
