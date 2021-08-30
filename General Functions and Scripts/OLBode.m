function OLBode()
BaseWorkspace=evalin('base','whos');
VarNames={BaseWorkspace.name};

if any(contains(VarNames,'out'))
    out=evalin('base','out');
    BodeOL=out.BodeOL;
else
    BodeVarNames=VarNames(contains(VarNames,'BodeOL'));
    if length(BodeVarNames)>1 %user needs to select...
        [idx,tf]=listdlg('PromptString','Please Select Bode to show',...
            'ListString',BodeVarNames,...
            'SelectionMode','single',...
            'ListSize',[200,200]);
        if ~tf, return, end %user chose to exit
        BodeOL=evalin('base',BodeVarNames{idx});
    elseif length(BodeVarNames)==1
        BodeOL=evalin('base',BodeVarNames{:});
    else
        disp('Error: No base workspace variable has "OLBode" as part of its name')
        return
    end
end

w = BodeOL.signals(1,3).values';
Gain=BodeOL.signals(1,1).values';
Phase=BodeOL.signals(1,2).values';
BodeAmnt=min(size(w));

figure('Name','OL Bode from spectrum scope');
subplot(2,1,1);

semilogx(w,Gain);
grid on;
ylabel('Gain [dB]');
xlim([w(1) w(end)]);

legendCell=cell(1,BodeAmnt);
for ii=1:BodeAmnt
    legendCell{ii}=sprintf('OL_%g',ii);
end
legend(legendCell);

subplot(2,1,2);
semilogx(w,Phase);
grid on;
ylabel('Phase [Deg]');
xlim([w(1) w(end)]);

xlabel('Frequency [Hz]');