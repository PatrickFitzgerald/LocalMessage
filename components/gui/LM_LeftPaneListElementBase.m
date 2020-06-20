classdef LM_LeftPaneListElementBase < LM_UnitBase
	
	properties (GetAccess = ?LM_UnitBase, Constant)
		
		listItemHeight = 25; % Also serves as icon width
		
		leftSpacer = 10;
		rightSpacer = 10;
		
	end
	
	properties (Access = private)
		
		displayName = '';
		isActive = false;
		
		gHBox;
		gIcon;
		
	end
	
	methods (Access = {?LM_FriendsList,?LM_ConvoList})
		
		% Constructor
		function this = LM_LeftPaneListElementBase(interface,gParent)
			
			% Inherited constructor
			this = this@LM_UnitBase(interface,gParent);
			
			% Populate graphics
			this.gHBox = uix.HBox(...
				'Parent',this.gParent,...
				'BackgroundColor',this.palette.primaryDark,...
				'Padding',0,...
				'Spacing',0);
			
			uix.Empty('Parent',this.gHBox); % left spacer
			iconAxes = axes(...
				'Parent',uix.gHBox,...
				'Units','Normalized',...
				'Position',[0,0,1,1],...
				'Visible','off');
			this.gIcon = image(rand(30,30,3),'Parent',iconAxes); % Icon
			this.gText = uicontrol(... % text
				'Style','text',...
				'String',this.displayName,...
				'Parent',this.gHBox,...% 				'FontName',this.fontInfo.leftPaneTitleFont,...
				'FontSize',this.fontInfo.leftPaneTitleSize,... % SCALE
				'BackgroundColor',this.palette.primaryDark,...
				'ForegroundColor',this.palette.fontNormal,...
				'HorizontalAlignment','left');
			% left-spacer, icon, text, update-count, right-spacer
			
			
			this.
			
			
			
			
			
			
			
			this.gVBox.Heights = this.titleHeight; % SCALE
			
		end
		
	end
	
end