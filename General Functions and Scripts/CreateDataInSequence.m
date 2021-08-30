function CreateDataInSequence(IterationsAmnt)
modelName='DeepLearningDataCreator';
open_system(modelName,'loadonly');

if nargin<1
    IterationsAmnt=1;
end

%Static variables
DataFolder=fullfile(getProjRoot(),'DeepLearning','Data');
fileNames={'RGB.mp4',...
    'Orientation.mat',...
    'logImage.mp4',...
    'eventMask.mp4',...
    'eventMask.mat'};
maxrIC=getDictionaryDesignData('maxAngles');
ts_camera=getDictionaryDesignData('ts_camera');
simTimeRange=[8,12]*ts_camera;
set_param('DeepLearningDataCreator/NoRecordTime','const',num2str('5*ts_camera')); %no record time at start

for kk=1:IterationsAmnt
    %Change initial condition
    rIC=maxrIC.*rand([1,3]).*randSign([1,3]);
    set_param('DeepLearningDataCreator/Base Dynamics and conversion to Scene coordiantes/RotationIntegrator',...
        'InitialCondition',sprintf('[%s]',num2str(rIC)));
    simulationTime=simTimeRange(1)+diff(simTimeRange)*rand;
    
    %simulate
    sim(modelName,'StartTime','0','StopTime',num2str(simulationTime));
    pause(1); %wait 1 sec so sim can wrap up
    
    %Make directory with simulation number and move files to new directory
    newDirPath=GetNewDirPath(DataFolder);
    if ~exist(newDirPath, 'dir') %folder sim73 got stuck, I just overwrite onto it
        mkdir(newDirPath);
    end

    for ii=1:length(fileNames)
        movefile(fullfile(DataFolder,fileNames{ii}),fullfile(newDirPath,fileNames{ii}),'f');
    end
    
    fprintf('Finished Simulation %g out of %g\n',kk,IterationsAmnt);
    fprintf('saved into %s\n',newDirPath);
end

%reset to original
rIC=[0 0 0];
set_param('DeepLearningDataCreator/Base Dynamics and conversion to Scene coordiantes/RotationIntegrator',...
    'InitialCondition',sprintf('[%s]',num2str(rIC)));
save_system(modelName);
end
%% Functions
function newDirPath=GetNewDirPath(DataFolder)
listing=dir(DataFolder);
listing=listing(3:end); %remove first two entries that are not relevant
dirAmnt=sum([listing.isdir]);
newDirPath=fullfile(DataFolder,sprintf('sim%g',dirAmnt));
end