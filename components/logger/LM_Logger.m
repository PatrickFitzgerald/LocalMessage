classdef LM_Logger < handle
% Handles logging for all LocalMessage needs.

	properties (Access = private)
		
		manager; % The LM manager
		
		commandWindow; % pointer to matlab command prompt
		pixelsPerChar = 8.0366; % Just an estimate I made on my screen, not sure how this needs to scale...
		
	end
	
	methods (Access = public) % Constuctor
		
		% Constructor
		function this = LM_Logger(manager)
			this.manager = manager;
			
			% Copied this code from lines 195-206 of dependencies/cprintf/cprintf.m
			mde = com.mathworks.mde.desk.MLDesktop.getInstance;
			cw = mde.getClient('Command Window');
			this.commandWindow = cw.getComponent(0).getViewport.getComponent(0);
			% Calling this.commandWindow.getVisibleRect().width returns the
			% width of the command prompt in pixels.
			
			this.info('Starting Logger');
		end
		
	end
	
	methods (Access = public) % External interaction. These are ordered in increasing severity
		
		function info(this,message,varargin)
			color = 'Text';
			this.printFormatted('Info',color,message,varargin{:})
		end
		
		function warning(this,message,varargin)
			color = [1,0.5,0];
			this.printFormatted('Warning',color,message,varargin{:})
		end
		
		function error(this,message,varargin)
			color = 'Error';
			this.printFormatted('Error',color,message,varargin{:})
		end
		
		function severe(this,message,varargin)
			color = [1,0,0];
			this.printFormatted('Severe Error',color,message,varargin{:})
		end
		
	end
	
	methods (Access = private)
		
		function printFormatted(this,type,color,message,varargin)
			
			datrStr = datestr(now(),'HH:MM:SS');
			
			cprintf(color,[datrStr,' ',type,': ',message,'\n'],varargin{:});
% TODO add word wrap, use getCommandWindowWidth()
			
		end
		
		function width_chars = getCommandWindowWidth(this)
			width_chars = floor( this.commandWindow.getVisibleRect().width / this.pixelsPerChar );
		end
		
	end
	
end