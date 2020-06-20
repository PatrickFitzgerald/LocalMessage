classdef DelayedCallback < handle
% Manages a callback which may get triggered very frequently in a small
% window of time, but the countdown timer gets reset each time. Thus, the
% callback is only called once that rapid trigger sequence is finished.
	
	properties (Access = private)
		
		% User provided variables, how and when to callback.
		minDelay_s; % The minimum delay between being triggered and invoking the callback function 'func'
		maxDelay_s; % The maximum delay between a trigger and the last time the callback function 'func' was invoked
		func; % The callback function
		
		% Hard coded settings
		pollingFreq_Hz = 20; % The frequency of testing if enough time has passed
		
		% State memory
		isRunning; % Records whether a timer has been started
		triggerTime_s; % The most recent trigger time
		lastInvokeTime_s; % The last time the callback was invoked
		timerObject; % Handles the repeated time checking at the pollingFreq_hz
		
	end
	
	methods (Access = public)
		
		% Constructor
		function this = DelayedCallback(minDelay_s,maxDelay_s,func)
			
			% Validate the user provided settings
			assert(...
				isscalar(minDelay_s) && ~isnan(minDelay_s) && isreal(minDelay_s) && ~isinf(minDelay_s) && minDelay_s > 0,...
				'Minimum delay must be a valid duration.');
			assert(...
				isscalar(maxDelay_s) && ~isnan(maxDelay_s) && isreal(maxDelay_s) && ~isinf(maxDelay_s) && maxDelay_s > 0,...
				'Maximum delay must be a valid duration.');
			assert(...
				maxDelay_s > minDelay_s,...
				'Maximum delay must be greater than minimum delay.');
			assert(...
				isscalar(func) && isa(func,'function_handle'),...
				'func needs to be a valid function handle.');
			
			% Store the user provided settings
			this.minDelay_s = minDelay_s;
			this.maxDelay_s = maxDelay_s;
			this.func = func;
			
			% Initialize to not running.
			this.isRunning = false;
			
		end
		
		% Start the timer countdown, or resets if called again soon enough.
		function trigger(this)
			
			% Record that this was triggered
			this.isRunning = true;
			
			% Record the current time
			this.triggerTime_s = this.now_s();
			
			% If the timerObject hasn't been created yet, make it now.
			if isempty(this.timerObject) || ~isvalid(this.timerObject)
				
				% Determine the duration between checking. Must be at least
				% one millisecond. To prevent a warning, make it an integer
				% number of milliseconds too.
				interPollTime_s = max(round(1/this.pollingFreq_Hz,3),0.001);
				
				% Create the periodic timer object, and start it.
				this.timerObject = timer(...
					'TimerFcn', @(~,~) this.callback(),... 
					'Period', interPollTime_s,...
					'BusyMode', 'drop',...
					'ExecutionMode', 'fixedRate',...
					'StartDelay', interPollTime_s); % Don't attempt callback right away
				start(this.timerObject);
				
				% Since we'll be waiting a most maxDelay_s before invoking
				% the callback, let's record now as the most recent
				% invocation.
				this.lastInvokeTime_s = this.now_s();
				
			end
			
		end
		
		% Cancels any previous triggers.
		function cancel(this)
			this.doCleanup();
		end
		
		% Cancels any previous triggers and destroys object
		function delete(this)
			this.doCleanup();
		end
		
	end
	
	methods (Access = private)
		
		% Handles conditionally calling the user provided 'func'
		function callback(this)
			
			% Make sure we're actually still running
			if this.isRunning
				% Check whether enough time has passed
				reachedMinimumTime = this.now_s() - this.triggerTime_s    > this.minDelay_s;
				reachedMaximumTime = this.now_s() - this.lastInvokeTime_s > this.maxDelay_s;
				if reachedMinimumTime || reachedMaximumTime % yes, enough time has passed
					
					% Perform the cleanup and invoke the user provided
					% callback.
					this.doCleanup();
					this.func();
					
				else % No, not enough time has passed.
					
					% Do nothing, just keep waiting.
					return
					
				end
				
			else % Not running. Do cleanup just to be safe
				this.doCleanup();
			end
			
		end
		
		% Handles shutting down the timer
		function doCleanup(this)
			
			% Set to not running.
			this.isRunning = false;
			
			% Remove memory of when this was last triggered.
			this.triggerTime_s = -inf;
			this.lastInvokeTime_s = -inf;
			
			% Clean up the timer object, carefully.
			if ~isempty(this.timerObject)
				if isvalid(this.timerObject)
					if strcmp(this.timerObject.Running,'on')
						stop(this.timerObject);
					end
					delete(this.timerObject);
				end
				this.timerObject = [];
			end
			
		end
		
	end
	
	methods (Access = private, Static)
		
		% Converts now() to seconds.
		function time_s = now_s()
			time_s = now() * 24 * 3600;
		end
		
	end
	
end