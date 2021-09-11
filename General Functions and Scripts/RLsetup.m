%% General
mdl = 'Simulation';
%% Define Agent
maxOmega=getDictionaryDesignData('maxOmega');

actionInfo = rlNumericSpec([3 1],...
    'LowerLimit',-maxOmega',...
    'UpperLimit',maxOmega');
actionInfo.Name = 'observations';
actionInfo.Description = 'integrated error, error, and measured height';

observationInfo = rlNumericSpec([144 256 6],...
    'LowerLimit',0,...
    'UpperLimit',1);
observationInfo.Name = 'EventMask';
observationInfo.Description = 'values of 0,0.5,1 where 0.5 indicates low or no rate of change';

initOpts = rlAgentInitializationOptions('NumHiddenUnit',128);
rng(0); %repeatable randomness
agent = rlDDPGAgent(observationInfo,actionInfo,initOpts); %not rlDDPGAgent
agent.AgentOptions.SampleTime=getDictionaryDesignData('ts_camera');

actor=getActor(agent);
actorNet = getModel(actor);
actor.Options.LearnRate=1e-3;
actor.Options.UseDevice="gpu";
agent = setActor(agent,actor);

critic=getCritic(agent);
criticNet = getModel(critic);
critic.Options.LearnRate=1e-3;
critic.Options.UseDevice="gpu";
agent = setCritic(agent,critic);

%assign agent to dictionary
mWS = get_param('Simulation','modelworkspace');
mWS.assignin('agent',agent);
save_system(mdl);
disp("Agent built and uploaded to model. Model was saved");
%%  Train Agent
rlAgentBlocks=[mdl,'/Estimator/RL/RL Agent'];
env = rlSimulinkEnv(mdl,rlAgentBlocks,observationInfo,actionInfo);
maxrIC=getDictionaryDesignData('maxAngles');
env.ResetFcn = @(in)setVariable(in,'A0',0.7*maxrIC.*rand([1,3]).*randSign([1,3]),'Workspace',mdl);

trainOpts = rlTrainingOptions(...
    'MaxEpisodes',10000,...
    'MaxStepsPerEpisode',40,...
    'ScoreAveragingWindowLength',5,...
    'Plots','training-progress');

stats = train(agent,env,trainOpts);