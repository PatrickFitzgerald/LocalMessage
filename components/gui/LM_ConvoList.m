classdef LM_ConvoList < LM_LeftPaneListBase
	
	methods (Access = ?LM_LeftPane)
		
		% Constructor
		function this = LM_ConvoList(interface,gParent)
			
			% Inherited constructor
			this = this@LM_LeftPaneListBase(interface,gParent,...
				'CONVERSATIONS',true);
			
		end
		
	end
	
end