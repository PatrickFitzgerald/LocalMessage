classdef LocalMessage < handle
% Top level manager object for the Local Message application.
	
	properties (Access = private)
		
		udpAgents;     % Handles communicating between users.
		userInterface; % UI handle
		
		installDir;    % Populated upon startup
		settingsPath;  % Populated upon startup
		
	end
	
	properties (GetAccess = {?LM_Interface,?LM_UnitBase}, SetAccess = private)
		
		logger; % Orchestrates logging and debug messages
		
	end
	
	properties (GetAccess = ?LM_Interface, SetAccess = private)
		
		userName;
		userSettings; % Will be populated with struct
		
	end
	
	% Hard coded saved quantities
	properties (Access = private, Constant)
		
		settingsFile = '/workingfiles/user_settings.mat'; % Will be relative to installDir
		
		% These will be used to fill missing info for the userSettings
		defaultUserSettings = struct(... 
			... % 'userName' field always exists
			'displayName','Unnamed',...
			'displayInitials','?',...
			'avatarColor',hsv2rgb([rand,1,1]),... % Randomly assigned color (full saturation)
			'friendsList',{{}},... % Empty friends list
			'visualSettings',LM_Interface.visualSettingsDefault... % Refer to LM_Interface for these defaults
		);
		
	end
	
	methods (Access = public)
		
		% Constructor
		function this = LocalMessage()
			
			% Create the logger.
			this.logger = LM_Logger(this);
			this.logger.info('Starting LM manager.');
			
			this.determineUserName();
			
			% Determine the install directory and important sub-paths
			this.logger.info('Configuring paths.');
			[this.installDir,~,~] = fileparts(mfilename('fullpath'));
			this.settingsPath = fullfile(this.installDir,this.settingsFile);
			
			% Perform startup sequence.
			this.loadUserSettings();
			this.initializeUDPAgents();
			this.openUserInterface();
			
		end
		
		% Destructor
		function delete(this)
			
			this.logger.info('Initiating shut-down sequence.');
			
% Delete UDP agents
			
			% Delete user interface
			if ~isempty(this.userInterface) && isvalid(this.userInterface)
				delete(this.userInterface);
			end
			
			this.logger.info('Closing LM manager.');
			
		end
		
		% This is a slightly more useful version of the built-on isvalid()
		% for handle objects.
		function isValid_ = isValid(this)
			isValid_ = isvalid(this) && isValid(this.userInterface);
		end
		
	end
	
	methods (Access = private)
		
		% Stores username info inside this.userName
		function determineUserName(this)
			
			% Execute commandline call to request username.
			timeout_s = 3.0;
			[status,userNameRaw,~] = cmd('whoami',timeout_s);
			% If something goes wrong, or if the timeout triggers before
			% the command returns, status will be nonzero. Otherwise,
			% userNameRaw contains the string that was returned.
			
			if status == 0 % If successful
				% Clean up some extra spaces around the part we want.
				this.userName = userNameRaw(1:end-2);
				this.logger.info('Client username: "%s".',this.userName);
			else % Something went wrong.
				this.logger.severe('The client username could not be extracted.');
			end
			
		end
		
		% Safely loads full userSettings map
		function userSettingsList = readUserSettings(this)
			
			% If the file doesn't exist, make it, populate it with an empty
			% list.
			if ~exist(this.settingsPath,'file')
				this.logger.info('User settings file not found. Saving empty map to file.');
				this.saveUserSettings('empty');
			end
			
			% Cautiously read in the file
			try % If the file is valid, load in the desired variable.
				
				this.logger.info('Reading saved settings from file.');
				loadedSettings = load(this.settingsPath,'userSettingsList');
				userSettingsList = loadedSettings.userSettingsList;
				
				% Confirm the variable is setup correctly.
				if isa(userSettingsList,'containers.Map') && strcmp(userSettingsList.KeyType,'char') && strcmp(userSettingsList.ValueType,'any')
					this.logger.info('Settings read successfully.');
				else % Was not the right format map.
					this.logger.info('Read data from file, but variable is in the wrong format. Creating from scratch.');
					userSettingsList = this.saveUserSettings('empty');
				end
				
			catch % Some error happened, almost certainly in the load() call.
				
				this.logger.info('Reading the file failed. Creating from scratch.');
				userSettingsList = this.saveUserSettings('empty');
				
			end
			
		end
		
		% Safely saves user settings to file. The mode input defaults to
		% 'property' if omitted.
		% When mode is 'property' the settings to write come from
		% this.userSettings; when mode is 'empty', a new empty map
		% container is made and written to file. A backup is made of
		% pre-existing saved files.
		% The output is a copy of what was written to file.
		function userSettingsList = saveUserSettings(this,mode)
			
			% If the mode was unspecified, assign it to its default.
			if ~exist('mode','var')
				mode = 'property';
			end
			
			% Sanitize inputs. Kinda overkill.
			if ~any(strcmp(mode,{'property','empty'}))
				this.logger.error('The mode specified was invalid. Defaulting to ''property''.');
				mode = 'property';
			end
			
			% Assemble the file which will be written to file.
			switch mode
				case 'property'
					% Read existing from file
					userSettingsList = this.readUserSettings();
					% Update this users settings
					userSettingsList(this.userName) = this.userSettings;
				case 'empty'
					% Create empty map container
					userSettingsList = this.makeEmptyMap();
					
					% Check for pre-existing file
					if exist(this.settingsPath,'file')
						% Update the existing name with a (nearly) unique
						% string appended to the end. 
						appendName = datestr(now,' yyyymmdd_HHMMSSFFF.bak');
						try % This could fail if there are any read/write permission issues.
							movefile(this.settingsPath,[this.settingsPath,appendName]);
							this.info('Backup of user settings created: "%s%s".',this.settingsFile,appendName);
						catch
							this.logger.error('Creating the user settings backup failed.');
						end
					end
			end % No need for otherwise.
			
			% Now try to save the assembled settings to file.
			try
				save(this.settingsPath,'userSettingsList');
			catch
				this.logger.severe('Failed in writing user settings to file.');
			end
			
		end
		
		% Extract the user's saved settings, if any.
		function loadUserSettings(this)
			
			this.logger.info('Importing user settings.');
			
			% Look up the locally stored settings file to get the user
			% settings.
			userSettingsList = this.readUserSettings();
			
			% Detect whether this is a new user.
			if ~userSettingsList.isKey(this.userName) % is new user
				userSettingsList(this.userName) = struct(... % Mostly empty struct
					'userName',this.userName); 
			end
			
			% Now that the entry necessarily exists, extract it, and pass
			% it off to be applied and propagated.
			this.applyUserSettings( userSettingsList(this.userName) ); % containers.Map lookup
			
		end
		
		% Check for changes to the user settings, apply them, and propagate
		% those changes to the necessary components. newUserSettings may be
		% a partial struct, containing only changes to userSettings.
		% Manages assigning defaults to unspecified properties.
		% The outputs report whether certain sections of the settings were
		% changed.
		% Performs saving internally, as necessary.
		function [visChanged] = applyUserSettings(this,newUserSettings)
			
			% We need a base for this merging process. If the user settings
			% are already defined, use those. Otherwise, use the defaults.
			% If the defaults are used, we definitely need to treat all
			% settings as changed, since they were effectively undefined
			% previously.
			if isempty(this.userSettings)
				userSettingsBase = this.defaultUserSettings;
				allChangedOverride = true;
			else
				userSettingsBase = this.userSettings;
				allChangedOverride = false;
			end
			
			% Merge the structs. The new struct overwrites matching fields
			% from the base.
			this.userSettings = recursiveMergeStruct(userSettingsBase,newUserSettings);
			
			% Compare the base and merged versions, and detect what
			% changed.
			comparisonStruct = compareStructValues( userSettingsBase, this.userSettings );
			visChanged = comparisonStruct.visualSettings || allChangedOverride;
			
			% Call internal updating functions depending on what changed.
			if visChanged
				this.refreshVisualSettings();
			end
			
		end
		
		function initializeUDPAgents(this)
			this.logger.info('Initializing connections.');
% Create UDP stuff
			this.logger.warning('NOT IMPLEMENTED.');
		end
		
		% Makes user interface
		function openUserInterface(this)
			this.logger.info('Opening GUI.');
			this.userInterface = LM_Interface(this);
		end
		
		% Makes sure the visual settings are self-consistent.
		function refreshVisualSettings(this)
			
			
			
		end
		
	end
	
	methods (Access = ?LM_Interface)
		
		% Prompts user about shutting down the application
		function requestDelete(this,obj,~)
			% If already deleted, just delete caller source
			if ~isvalid(this)
				delete(obj);
				return
			end
			
			this.logger.info('LM object requested to shut down. Prompting user.');
			
			% Ask the user about shutting down
			response = questdlg('Exit the Local Message app?', ...
				'Close Prompt', ...
				'Exit','Cancel','Cancel');
			if strcmp(response,'Exit')
				% Call the hard delete function.
				this.delete();
			else
				this.logger.info('Shut down request rescinded.');
			end
		end
		
		% Saves the provided settings to the userSettings, and saves it to
		% file.
		function wrapper_applyUserSettings(this,partialUserSettings)
			
			% Pass on changes to user settings
			this.logger.info('Transferring user settings update.');
			[visualSettingsChanged] = this.applyUserSettings(partialUserSettings);
			
			% If the visual settings changed, kick off a GUI refresh.
			if visualSettingsChanged
				this.logger.info('Triggering GUI refresh.');
% GUI REFRESH
			end
			
		end
		
	end
	
	methods (Access = private, Static)
		
		% Creates an empty map container with KeyType 'char' and ValueType
		% 'any'.
		function emptyMap = makeEmptyMap()
			emptyMap = containers.Map({'empty'},{'empty'},'UniformValues',false); % Doesn't support being empty from construction.
			emptyMap = emptyMap.remove('empty'); % but apparently is okay with this.
		end
		
	end
	
end