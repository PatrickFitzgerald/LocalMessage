% Detects whenever two structs are different. The result will be a struct
% of all unique fields they possess (present in either new or old), and
% the VALUE for each respective field will be TRUE if they differ.
% A field present in one but not the other is assumed to be a change.
function isDiffStruct = compareStructValues(oldStruct,newStruct)
	
	% Extract existing fields
	oldFields = fields(oldStruct);
	newFields = fields(newStruct);
	
	% Condense field list to total unique fields to compare.
	totFields = unique([oldFields;newFields]);
	numTotFields = numel(totFields);
	
	% Initialize the output struct, default to false.
	temp = [ totFields(:)'; repmat({false},1,numTotFields) ]; % Designed to unwrap to be the
	isDiffStruct = struct( temp{:} );                         % correct inputs to struct()
	
	% Loop over each field and compare the values.
	for totFieldInd = 1:numTotFields
		field = totFields{totFieldInd};
		
		% Only overwrite the false saved in boolList if the field is common
		% to both structs, and their corresponding values are equal.
		if ismember(field,oldFields) && ismember(field,newFields);
			isDiffStruct.(field) = isequal( oldStruct.(field), newStruct.(field) );
		end
		
	end
	
end