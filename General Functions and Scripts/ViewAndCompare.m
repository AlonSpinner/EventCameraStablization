%Extratct Data
project     = simulinkproject();
projectRoot = project.RootFolder;
orientationMat=load(fullfile(projectRoot,'DeepLearning','Data','Orientation.mat'));
gt_orientation=orientationMat.Orientation.Data;

time=orientationMat.Orientation.time;
gt.roll=gt_orientation(:,1);
gt.pitch=gt_orientation(:,2);
gt.yaw=gt_orientation(:,3);
gt.rollRate=gt_orientation(:,4);
gt.pitchRate=gt_orientation(:,5);
gt.yawRate=gt_orientation(:,6);
%% Plot
fig=figure('color',[0,0,0]);
hTitledLayout=tiledlayout(fig,2,1);
hTitledLayout.Title.String='Ground Truth vs Estimation - time';
hTitledLayout.Title.Color=[1,1,1];
% Tile 1
ax=nexttile([1,1]);
plot(ax,time,[gt.roll,gt.pitch,gt.yaw],'linewidth',2);
set(ax,'color',[0,0,0],'XColor',[1,1,1],'YColor',[1,1,1]);
grid(ax,'on'); xlabel('time [sec]'); ylabel('Euler Angles [rad]');
legend(ax,{'roll','pitch','yaw'},'TextColor',[1,1,1]);

% Tile 2
ax=nexttile([1,1]);
plot(ax,time,[gt.rollRate,gt.pitchRate,gt.yawRate],'linewidth',2);
set(ax,'color',[0,0,0],'XColor',[1,1,1],'YColor',[1,1,1]);
grid(ax,'on'); xlabel('time [sec]'); ylabel('Euler Angles Rates [rad/s]');
