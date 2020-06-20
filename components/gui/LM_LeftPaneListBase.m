classdef LM_LeftPaneListBase < LM_UnitBase
	
	properties (GetAccess = ?LM_UnitBase, Constant)
		
		titleHeight = 25;
		
	end
	
	properties (Access = private)
		
		numElements = 0;
		
		gVBox;
		
		heightIndex = struct(...
			'title',1,...
			'elements',@(this) 1+(1:this.numElements));
		
	end
	
	methods (Access = {?LM_FriendsList,?LM_ConvoList})
		
		% Constructor
		function this = LM_LeftPaneListBase(interface,gParent,arg1,arg2)
			
			% Inherited constructor
			this = this@LM_UnitBase(interface,gParent);
			
			% Populate graphics
			this.gVBox = uix.VBox(...
				'Parent',this.gParent,...
				'BackgroundColor',this.palette.primaryDark,...
				'Padding',0,...
				'Spacing',0);
			
			uicontrol(... % title
				'Style','text',...
				'String',arg1,...
				'Parent',this.gVBox,...
				'FontName',this.fontInfo.leftPaneTitleFont,...
				'FontSize',this.fontInfo.leftPaneTitleSize,... % SCALE
				'BackgroundColor',this.palette.primaryDark,...
				'ForegroundColor',this.palette.fontNormal,...
				'HorizontalAlignment','left');
			
			this.gVBox.Heights = this.titleHeight; % SCALE
			
		end
		
	end
	
end