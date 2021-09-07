function CreateDataInSequence(IterationsAmnt)
if nargin<1, IterationsAmnt=1; end
%note1: maxOmega usually set to deg2rad([4 6 10]), now set to deg2rad([0 6
%0]). This is done in dictionary
%note2: maxrIC can be set to have 0 yaw and roll. This is done in this
%script, first row under loop
%Make sure the base driver is set to automatic (ball sim) in the model


%Static variables
modelName='DeepLearningDataCreator';
open_system(modelName,'loadonly');
DataFolder=fullfile(getProjRoot(),'DeepLearning','Data');

expiramentName='04 pitchAndYaw_10degPerSec';
ts_camera=getDictionaryDesignData('ts_camera');
simulationTime=50*ts_camera;
maxrIC=getDictionaryDesignData('maxAngles');
set_param('DeepLearningDataCreator/NoRecordTime','const',...
    num2str('10*ts_camera')); %no record time at start
setDictionaryDesignData('maxOmega',deg2rad([0 10 10])); %<-- set maxOmega in dictionary for "All"

%Make directories
expiramentPath=fullfile(DataFolder,expiramentName);
expiramentDataPath=fullfile(expiramentPath,'data');
expiramentMoviesPath=fullfile(expiramentPath,'movies');
if ~exist(expiramentPath, 'dir'), mkdir(expiramentPath); end
if ~exist(expiramentDataPath,'dir'), mkdir(expiramentDataPath); end
if ~exist(expiramentMoviesPath,'dir'), mkdir(expiramentMoviesPath); end

for kk=1:IterationsAmnt
    %Change initial condition
    rIC=maxrIC.*rand([1,3]).*randSign([1,3]) .* [0 1 1]; %multiplcation by zero here
    set_param('DeepLearningDataCreator/Base Dynamics and conversion to Scene coordiantes/RotationIntegrator',...
        'InitialCondition',sprintf('[%s]',num2str(rIC)));
    
    %simulate
    sim(modelName,'StartTime','0','StopTime',num2str(simulationTime));
    pause(1); %wait 1 sec so sim can wrap up
    
    %move movies
    simNumber=getSimNumber(expiramentDataPath);
    newNames.data=sprintf('data%g.mat',simNumber);
    newNames.eventMask=sprintf('eventMask%g.mp4',simNumber);
    newNames.logImage=sprintf('logImage%g.mp4',simNumber);
    newNames.RGB=sprintf('RGB%g.mp4',simNumber);
    movefile(fullfile(DataFolder,'data.mat'),...
        fullfile(expiramentDataPath,newNames.data));
    movefile(fullfile(DataFolder,'eventMask.mp4'),...
        fullfile(expiramentMoviesPath,newNames.eventMask));
    movefile(fullfile(DataFolder,'logImage.mp4'),...
        fullfile(expiramentMoviesPath,newNames.logImage));
    movefile(fullfile(DataFolder,'RGB.mp4'),...
        fullfile(expiramentMoviesPath,newNames.RGB));
    
    fprintf('Finished Simulation %g out of %g\n',kk,IterationsAmnt);
    fprintf('saved into %s\n',expiramentPath);
end

%reset to original
rIC=[0 0 0];
set_param('DeepLearningDataCreator/Base Dynamics and conversion to Scene coordiantes/RotationIntegrator',...
    'InitialCondition',sprintf('[%s]',num2str(rIC)));
save_system(modelName);
end
%% Functions
function simNumber=getSimNumber(expiramentDataPath)
listing=dir(expiramentDataPath);
simNumber=length(listing)-2;
end