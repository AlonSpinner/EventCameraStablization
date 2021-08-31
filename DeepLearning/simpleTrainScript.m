%% Train
[sequences,responses,lgraph,options]=ExpiramentSetup();
net=trainNetwork(sequences,responses,lgraph,options);

%% Save
project     = simulinkproject();
projectRoot = project.RootFolder;
save(fullfile(projectRoot,'E2wNet.mat'),'net','-mat');