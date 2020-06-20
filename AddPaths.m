% Path setup for LocalMessage app

[installDir,~,~] = fileparts(mfilename('fullpath'));
deepAddPaths = {'components','dependencies','utilities'};
liteAddPaths = {};

for deepInd = 1:numel(deepAddPaths)
	path = fullfile(installDir,deepAddPaths{deepInd});
	addpath(genpath(path));
end

for liteInd = 1:numel(liteAddPaths)
	path = fullfile(installDir,liteAddPaths{liteInd});
	addpath(path);
end