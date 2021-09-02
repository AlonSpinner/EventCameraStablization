%% get vars
params.pitchOnly=true;
[sequences,responses,lgraph,options]=ExpiramentSetup(params);
%% Train
net=trainNetwork(sequences,responses,lgraph,options);
%% Save
project=matlab.project.rootProject;
projectRoot = project.RootFolder;
save(fullfile(projectRoot,'E2wNet.mat'),'net','-mat');