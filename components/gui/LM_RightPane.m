classdef LM_RightPane < LM_UnitBase
	
	methods (Access = ?LM_Interface)
		
		% Constructor
		function this = LM_RightPane(interface,gParent)
			
			% Inherited constructor
			this = this@LM_UnitBase(interface,gParent);
			
			% Populate graphics
			uipanel('Parent',this.gParent,'BackgroundColor',rand(1,3),'BorderType','none');
			
		end
		
	end
	
end