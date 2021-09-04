%% get vars
params.dataFolder="pitchOnly";
params.pitchOnly=true;
params.solver="sgdm";
params.imageSize="imageNet";
params.maxEpochs=50;
params.pitchOnlyNet="Simple";
[ds,lgraph,options]=ExpiramentSetup(params);
%% Train
net=trainNetwork(ds,lgraph,options);
%% Save
project=matlab.project.rootProject;
projectRoot = project.RootFolder;
save(fullfile(projectRoot,'E2wNet.mat'),'net','-mat');