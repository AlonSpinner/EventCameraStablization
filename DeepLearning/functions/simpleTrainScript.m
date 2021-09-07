%% get vars
params.dataFolder="02 pitchOnly_6degPerSec";
params.solver="sgdm";
params.maxEpochs=1;
params.netName="e2wNet1_1output";
params.ExecutionEnvironment="auto";
params.miniBatchSize=1;
params.frameAmount=31;
params.angles="all";
[ds,lgraph,options]=ExpiramentSetup(params);
%% Train
net=trainNetwork(ds,lgraph,options);
%% Save
project=matlab.project.rootProject;
projectRoot = project.RootFolder;
save(fullfile(projectRoot,'E2wNet.mat'),'net','-mat');