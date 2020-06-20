classdef LM_UnitBase < handle
% This class serves as the backbone to all distinct GUI components, and
% provides a minimum framework for their interaction.
	
	properties (GetAccess = protected, SetAccess = private)
		
		interface; % The top level LM interface object (LM_Interface object)
		manager;   % The top level LM manager object (LocalMessage object)
		logger;    % The logger owned by the manager (LM_Logger object)
		gParent;   % The graphics object that all this content will be a child of
		
	end
	
	properties (GetAccess = protected, Dependent)
		
		% These redirect to LM_Interface's correspondingly named properties.
		% I define them as dependent so one can easily call e.g. this.scale
		% but only have one saved copy of that variable.
		scale;
		palette;
		fontInfo;
		sizes;
		
	end
	
	methods (Access = public)
		
		% Constructor
		function this = LM_UnitBase(interface,gParent)
			this.interface = interface;
			this.manager   = interface.manager;
			this.logger    = this.manager.logger;
			this.gParent   = gParent;
		end
		
		% Redirects to LM interface's implementation.
		function suggestSaveSettings(this)
			this.interface.suggestSaveSettings();
		end
		
	end
	
	methods % Getters
		function val = get.scale(this)
			val = this.interface.scale;
		end
		function val = get.palette(this)
			val = this.interface.palette;
		end
		function val = get.fontInfo(this)
			val = this.interface.fontInfo;
		end
		function val = get.sizes(this)
			val = this.interface.sizes;
		end
	end
	
% 	methods (Access = public, Abstract)
% 		
% 		% 
% 		announceUpdate(this,wasUpdated);
% 		
% 		% 
% 		applyUpdate(this,wasUpdated);
% 		
% 	end
	
end