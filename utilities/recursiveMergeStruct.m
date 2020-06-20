% Merges in a (partial) deltaStruct (list of changes) into a masterStruct. 
function masterStruct = recursiveMergeStruct(masterStruct,deltaStruct)
	
	% Most likely to happen on recursive call, not original one. In that
	% case, the masterStruct had a non-struct entry present (scalar entry,
	% for example) for a specific field, but the deltaStruct tried to
	% overwrite it to be a struct. Merging structs is compatible, but this
	% is merging a nonstruct with a struct. Throw a warning and proceed.
	if ~isstruct(masterStruct)
		warning('masterStruct is not actually a struct, and it''s contents will be lost.');
		masterStruct = struct();
	end
	
	% Loop over all the fields of deltaStruct
	deltaFields = fields(deltaStruct);
	for fieldInd = 1:numel(deltaFields)
		deltaField = deltaFields{fieldInd}; % Extract field as char vector
		
		% If the the field is not present in the master, it must be a new
		% field, so the full contents of deltaStruct corresponding to that
		% field should be copied over.
		if ~isfield(masterStruct,deltaField)
			masterStruct.(deltaField) = deltaStruct.(deltaField);
		% Alternatively, if the field exists in both, we need to merge them
		% intelligently. This is the case that is most likely to trigger
		% thet IF block at the top of the file.
		elseif isstruct(deltaStruct.(deltaField))
			masterStruct.(deltaField) = recursiveMergeStruct(...
				masterStruct.(deltaField),...
				deltaStruct.(deltaField));
		else % Merging in a single value, instead of a struct. Just do it.
			masterStruct.(deltaField) = deltaStruct.(deltaField);
		end
		
	end
end