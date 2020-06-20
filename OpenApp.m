function OpenApp()
	persistent app
	
	% Call the AddPaths scripts to make sure all the necessary files are
	% accessible to matlab.
	AddPaths;
	
	if isempty(app) || isa(app,'LocalMessage') && ~isValid(app) % using a custom isvalid function
		% Open app
		app = LocalMessage();
	end
end