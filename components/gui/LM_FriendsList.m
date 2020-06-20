classdef LM_FriendsList < LM_LeftPaneListBase
	
	methods (Access = ?LM_LeftPane)
		
		% Constructor
		function this = LM_FriendsList(interface,gParent)
			
			% Inherited constructor
			this = this@LM_LeftPaneListBase(interface,gParent,...
				'FRIENDS',true);
			
		end
		
	end
	
end