classdef LM_LeftPane < LM_UnitBase
	
	properties (Access = private)
		
		wConvoList;
		wFriendsList;
		wDebugInfo;
		
		gVBoxA;  % A super-container for all the elements herein
		gScroll; % A sub-container which holds gVBoxB
		gVBoxB;  % A sub-container responsible for holding the convoList and friendsList
		heightIndexA = struct(... % A helper to index gVBoxA.Heights
			'scroll',1,...
			'debugInfo',2);
		heightIndexB = struct(... % A helper to index gVBoxB.Heights
			'convoList',1,...
			'friendsList',2,...
			'spacer',3);
		
		% Sizes, not user customizable.
		minSpacerHeight = 30; % pixels.
		interListSpacing = 15; % pixels. 
		
	end
	
	methods (Access = ?LM_Interface)
		
		% Constructor
		function this = LM_LeftPane(interface,gParent)
			
			% Inherited constructor
			this = this@LM_UnitBase(interface,gParent);
			
			% Populate graphics
			this.gVBoxA = uix.VBox(...
				'BackgroundColor',this.palette.primaryDark,...
				'Padding',0,...
				'Spacing',0,...
				'Parent',this.gParent);
			this.gScroll = uix.ScrollingPanel(...
				'Parent',this.gVBoxA,...
				'BackgroundColor',this.palette.primaryDark,...
				'Padding',0);
uipanel('Parent',this.gVBoxA,'BackgroundColor',rand(1,3),'BorderType','none'); % debug
			this.gVBoxA.Heights = [-1,100]; % SCALE
			
			this.gVBoxB = uix.VBox(...
				'BackgroundColor',this.palette.primaryDark,...
				'Padding',0,...
				'Spacing',this.interListSpacing,... % SCALE
				'Parent',this.gScroll);
			
			this.wConvoList   = LM_ConvoList(  this.interface,this.gVBoxB);
			this.wFriendsList = LM_FriendsList(this.interface,this.gVBoxB);
			uix.Empty('Parent',this.gVBoxB);
			
			this.gVBoxB.Heights = [100,100,-1]; % SCALE
			this.gVBoxB.MinimumHeights = [0,0,this.minSpacerHeight-this.interListSpacing]; % SCALE
			
		end
		
	end
	
end