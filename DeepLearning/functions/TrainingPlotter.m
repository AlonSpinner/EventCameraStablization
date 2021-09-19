fig=figure('color',[1 1 1]);
ax=axes(fig);
hold(ax,'on'); grid(ax,'on'); xlabel(ax,'iteration'); ylabel(ax,'RMSE')


plot(LPF(trainingInfo_pitch.TrainingRMSE),'linewidth',2);
plot(LPF(trainingInfo_roll.TrainingRMSE),'linewidth',2);
plot(LPF(trainingInfo_pitchYaw.TrainingRMSE),'linewidth',2);
plot(LPF(trainingInfo_all.TrainingRMSE),'linewidth',2);


legend({...
    'pitchOnly 6degPerSec',...
    'rollOnly 10degPerSec',...
    'pitchAndYaw 10degPerSec',...
    'all 10degPerSec'});

xlim([0,2*10^4]);

function y=LPF(x)
windowSize = 100; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
y = filter(b,a,x);
end
