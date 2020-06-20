classdef LM_Interface < handle
	
	properties (Access = private)
		
		logger;  % Logger used for reporting and debug
		
		gMainFigure; % Matlab figure handle for main GUI
		gMainHBox;   % Holds the left and right panes
		wLeftPane;   % Lists out chats/users, settings
		wRightPane;  % Shows a single chat
		
	end
	
	% These are the full definitions of the properties expected by
	% LM_UnitBase inheritors. These must be updated whenever their
	% respective equivalents in visualSettings are updated.
	properties (GetAccess = ?LM_UnitBase, SetAccess = private)
		
		manager;  % The LocalMessage instance which manages everything
		
		scale;    % This will match visualSettings.scale
		palette;  % This is derived from visualSettings.palette but has more color entries
		fontInfo; % This will match visualSettings.fontInfo
		sizes;    % This will match visualSettings.sizes
		
	end
	
	properties (GetAccess = ?LocalMessage, Constant)
		
		visualSettingsDefault = struct(...
			'scale',1.0,... % scaling for whole GUI
			'palette',struct(... % color palette for whole figure, RGB in [0,1]
				'primary',   [ 76, 76, 76]/255,...
				'secondary', [ 94, 80,139]/255,...
				'font',      [255,255,255]/255),...
			'fontInfo',struct(...
				'leftPaneTitleFont','Tahoma',...
				'leftPaneTitleSize',14,...
				'fontName','Tahoma'),...
			'sizes',struct(... % UNSCALED customizable sizes and positions in pixels
				'figurePosition',[767,225,740,741],...
				'leftPaneWidth', 200)...
			);
		
	end
	
	methods (Access = ?LocalMessage)
		
		% Constructor
		function this = LM_Interface(manager)
			
			this.manager = manager;
			this.logger = manager.logger;
			
			this.refreshVisualSettings();
			
			this.createGUI();
			
		end
		
	end
	
	methods (Access = public)
		
		% Destructor
		function delete(this)
			% Close the figure
			if ~isempty(this.gMainFigure) && isvalid(this.gMainFigure)
				delete(this.gMainFigure);
			end
		end
		
		% This is a slightly more useful version of the built-on isvalid()
		% for handle objects.
		function isValid_ = isValid(this)
			isValid_ = isvalid(this) && isvalid(this.gMainFigure);
		end
		
		% Will save settings occasionally, but not every time this function
		% is called. This can be attached to callbacks which can trigger
		% arbitrarily frequently.
		function suggestSaveSettings(this)
			
		end
		
	end
	
	methods (Access = private)
		
		% Refreshes the LM_UnitBase accessible properties. wasChanged is a
		% struct with fields corresponding to the main LM_UnitBase
		% properties. The corresponding values will be booleans describing
		% whether that property has been updated.
		% If visualSettings is not provided (most common usage), the
		% settings will be pulled in from the manager.
		function wasChanged = refreshVisualSettings(this,visualSettings)
			
			if ~exist('visualSettings','var')
				% Extract the visual settings from the LM manager
				visualSettings = this.manager.userSettings.visualSettings;
			end
			
			% Detect what changed
			wasChanged.scale    = ~isequal(this.scale,   visualSettings.scale   );
			wasChanged.palette  = ~isequal(this.palette, visualSettings.palette );
			wasChanged.fontInfo = ~isequal(this.fontInfo,visualSettings.fontInfo);
			wasChanged.sizes    = ~isequal(this.sizes,   visualSettings.sizes   );
			
			% These are like mini setter functions:
			if wasChanged.scale
				this.scale = visualSettings.scale;
			end
			if wasChanged.palette
				this.palette = this.derivePalette(visualSettings.palette);
			end
			if wasChanged.fontInfo
				this.fontInfo = visualSettings.fontInfo;
			end
			if wasChanged.sizes
				this.sizes = visualSettings.sizes;
			end
			
		end
		
		% Derives the full palette from the condensed version saved inside
		% the visualSettings.
		function fullPalette = derivePalette(this,rawPalette)
			
			% Define all the base colors
			fullPalette.primaryNormal   = rawPalette.primary;
			fullPalette.secondaryNormal = rawPalette.secondary;
			fullPalette.fontNormal      = rawPalette.font;
			
			% This will be useful for linearly mixing colors in RGB space
			mixColors = @(color1,color2,color1alpha) color1*color1alpha + color2*(1-color1alpha);
			
			% Create derivative colors
			
			% Derivative primary colors
			alphaDark = 0.3;
			colorDark = [0,0,0]; % black
			alphaLight = 0.3;
			colorLight = [1,1,1]; % white
			fullPalette.primaryDark  = mixColors(colorDark, rawPalette.primary,alphaDark );
			fullPalette.primaryLight = mixColors(colorLight,rawPalette.primary,alphaLight);
			
			% Derivative font color
			fullPalette.fontMuted = mixColors(colorDark,rawPalette.primary,alphaDark);
			
		end
		
		function pushSettingsUp(this)
			
% Finish this
			this.logger.warning('visualSetings would have been pushed up.');
			
		end
		
		% Responsible for creating the full GUI. Assumes the visualSettings
		% struct is properly filled.
		function createGUI(this)
			
% 			dummyPanel = @(parent,other) uipanel('Parent',parent,'BackgroundColor',bgColor,'BorderType','none',other{:});
% 			dummyPanelBorder = @(parent,other) uipanel('Parent',parent,'BackgroundColor',bgColor,other{:});
% 			simpleText = @(parent,text) uicontrol('Parent',parent,'Style','text','String',text);
			
			
			% Create main figure
			this.gMainFigure = figure(...
				'Position',this.sizes.figurePosition,... % SCALE
				'Color',this.palette.primaryDark,...
				'DockControls','off',...
				'MenuBar','none',...
				'Name','Local Message App',...
				'NumberTitle','off',...
				'ToolBar','none',...
				'CloseRequestFcn',@(object,event) this.manager.requestDelete(object,event));
			% Split the figure
			this.gMainHBox = uix.HBoxFlex(...
				'BackgroundColor',this.palette.primaryDark,... % Only visible on strip between left and right panes
				'DividerMarkings','off',...
				'Padding',0,...
				'Spacing',3,...
				'Parent',this.gMainFigure);
			
			% Outsource the populating of the left and right panes.
			this.wLeftPane  = LM_LeftPane( this,this.gMainHBox);
			this.wRightPane = LM_RightPane(this,this.gMainHBox);
			% Set the widths of those inside the 
			this.gMainHBox.Widths = [this.sizes.leftPaneWidth,-1]; % SCALE
			
			
			
			return
			% Define mainHBox children
			leftScroll = uix.ScrollingPanel(...
				'BackgroundColor',bgColor,...
				'Parent',this.mainHBox);
			this.leftPane = uix.VBox(...
				'Parent',leftScroll,...
				'BackgroundColor',bgColor,...
				'Padding',0,...
				'Spacing',0);
			dummyPanel(this.mainHBox,{});
			
		entryHeight_pix = 30;
			% Populating the left pane
			% Populate the convoContainer
			this.convoContainer = uix.VBox(...
				'BackgroundColor',bgColor,...
				'Parent',this.leftPane,...
				'Spacing',0,...
				'Padding',0);
			simpleText(this.convoContainer,'Conversations:');
			this.convoList = uix.VBox(...
				'BackgroundColor',bgColor,...
				'Padding',0,...
				'Parent',this.convoContainer,...
				'Spacing',0);
			dummyPanel(this.convoContainer,{}); % make new
			this.convoContainer.Heights = [20,4*entryHeight_pix,entryHeight_pix];
			% Populating the convoList
			dummyPanelBorder(this.convoList,{});
			dummyPanelBorder(this.convoList,{});
			dummyPanelBorder(this.convoList,{});
			dummyPanelBorder(this.convoList,{});
			this.convoList.Heights = ones(1,4) * entryHeight_pix;
			% Populate the friendList
			this.friendContainer = uix.VBox(...
				'BackgroundColor',bgColor,...
				'Parent',this.leftPane,...
				'Spacing',0,...
				'Padding',0);
			simpleText(this.friendContainer,'Friends:');
			this.friendList = uix.VBox(...
				'BackgroundColor',bgColor,...
				'Padding',0,...
				'Parent',this.friendContainer,...
				'Spacing',0);
			dummyPanel(this.friendContainer,{}); % make new
			this.friendContainer.Heights = [20,4*entryHeight_pix,entryHeight_pix];
			% Populating the convoList
			dummyPanelBorder(this.friendList,{});
			dummyPanelBorder(this.friendList,{});
			dummyPanelBorder(this.friendList,{});
			dummyPanelBorder(this.friendList,{});
			this.friendList.Heights = ones(1,4) * entryHeight_pix;
			
			
			this.leftPane.Heights = [sum(this.convoContainer.Heights),sum(this.friendContainer.Heights)];
			
			
		end
		
		% Callback for more direct user control. If they've interacted with
		% the GUI, they can store those settings here. This is to avoid
		% repeatedly sending updates to the manager, or complicated smart
		% alternatives to that.
% 		function saveVisualSettings_Manual(this)
% 			
% 			% Gather all user settings into the visualSettings
% 			this.visualSettings.position_pix = this.mainFigure.Position;
% 			this.visualSettings.leftPaneWidth_pix = this.mainHBox.Widths(1);
% 			% Assumes colors were already assigned (user cannot easily
% 			% change these themselves without an additional GUI).
% 			% Same for font sizes.
% 			
% 			% Save visualSettings
% 			this.saveVisualSettings();
% 			
% 		end
		
	end
	
end