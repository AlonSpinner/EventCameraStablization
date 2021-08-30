%% General
mdl = 'Simulation';
%% Define Agent
maxOmega=getDictionaryDesignData('maxOmega');

actionInfo = rlNumericSpec([3 1],...
    'LowerLimit',-maxOmega',...
    'UpperLimit',maxOmega');
actionInfo.Name = 'observations';
actionInfo.Description = 'integrated error, error, and measured height';

observationInfo = rlNumericSpec([144 256],...
    'LowerLimit',0,...
    'UpperLimit',1);
observationInfo.Name = 'EventMask';
observationInfo.Description = 'values of 0,0.5,1 where 0.5 indicates low or no rate of change';

initOpts = rlAgentInitializationOptions('NumHiddenUnit',128,'UseRNN',false);
rng(0); %repeatable randomness
rlAgent = rlDDPGAgent(observationInfo,actionInfo,initOpts);
rlAgent.AgentOptions.SampleTime=getDictionaryDesignData('ts_camera');
actorNet = getModel(getActor(rlAgent));
criticNet = getModel(getCritic(rlAgent));

%assign agent to dictionary
mWS = get_param('Simulation','modelworkspace');
mWS.assignin('rlAgent',rlAgent);
save_system(mdl);
disp("Agent built and uploaded to model. Model was saved");
%%  Train Agent
rlAgentBlocks=[mdl,'/Estimator/RL/RL Agent'];
env = rlSimulinkEnv(mdl,rlAgentBlocks,observationInfo,actionInfo);
maxrIC=getDictionaryDesignData('maxAngles');
env.ResetFcn = @(in)setVariable(in,'A0',maxrIC.*rand([1,3]).*randSign([1,3]),'Workspace',mdl);

trainOpts = rlTrainingOptions(...
    'MaxEpisodes',10000,...
    'MaxStepsPerEpisode',20,...
    'ScoreAveragingWindowLength',10,...
    'Plots','training-progress');

stats = train(rlAgent,env,trainOpts);