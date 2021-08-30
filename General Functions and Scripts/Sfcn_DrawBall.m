function Sfcn_DrawBall(block)
setup(block);
end
function setup(block) %runs at t=0 i/o definitions
block.SetSimViewingDevice(true);

%dialog parameters
block.NumDialogPrms = 1;

%register number of ports
block.NumInputPorts = 3;
block.NumOutputPorts = 0;

%setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;

%Register the properties of the input ports

%Enable
block.InputPort(1).Complexity     ='Real';
block.InputPort(1).DataTypeId     =-1;
block.InputPort(1).Dimensions     =1;
block.InputPort(1).SamplingMode   ='Sample';

%q
block.InputPort(2).Complexity     ='Real';
block.InputPort(2).DataTypeId     =-1;
block.InputPort(2).Dimensions     = 3;
block.InputPort(2).SamplingMode   ='Sample';

%Time
block.InputPort(3).Complexity     ='Real';
block.InputPort(3).DataTypeId     =-1;
block.InputPort(3).Dimensions     =1;
block.InputPort(3).SamplingMode   ='Sample';

dtDraw=1/100;
block.SampleTimes = [dtDraw 0]; %[discrete time, offset]

%specify block simStateCompliace
block.SimStateCompliance = 'HasNoSimState';

%register functions
block.RegBlockMethod('InitializeConditions',    @InitializeConditions);
block.RegBlockMethod('Start',                   @Start);
block.RegBlockMethod('Terminate',               @Terminate);
block.RegBlockMethod('Outputs',                 @Outputs);
block.RegBlockMethod('CheckParameters',         @CheckPrms);
block.RegBlockMethod('ProcessParameters',       @ProcessPrms);
end
function ProcessPrms(block) %runs on every dt (Wasnt checked!)
  block.AutoUpdateRuntimePrms;
end
function InitializeConditions(block) %runs on t=0 and when susbystem is enabled
Enable=block.InputPort(1).Data(1);
if ~Enable, return, end

%check if figute exists and valid. if not - reset it
UserData=get(gcbh,'UserData');
if isempty(UserData) %first time simulation is activated
     SetupFigAndUserData(block);
elseif ~ishghandle(UserData.Figure) %figure was deleted
    SetupFigAndUserData(block);
else %figure exists, just clear it and start a new
    SetupFigAndUserData(block,UserData.Figure); %reset figure
end
end
function Outputs(block) %runs on every dt
UserData=get(gcbh,'UserData');
if ~ishghandle(UserData.Figure)
     UserData=SetupFigAndUserData(block); %set figure to a new start
end

%------Draw Measured Data
%Beam
x=block.InputPort(2).Data;
UserData.hBall.XData=x(1);
UserData.hBall.YData=x(2);
UserData.hBall.ZData=x(3);

%Update time text
Time=block.InputPort(3).Data(1);
UserData.hTime.String=sprintf('Time %g[s]',Time);

drawnow limitrate
end
%% Auxiliary functions
function UserData=SetupFigAndUserData(block,varargin)
bounds=block.DialogPrm(1).Data;

if nargin<2 %figure was not provided in input
    %Create figure
    FigureName='OnlyPhysics';
    Fig = figure(...
        'Name',              FigureName,...
        'NumberTitle',        'off',...
        'IntegerHandle',     'off',...
        'Color',             [1,1,1],...
        'MenuBar',           'figure',...
        'ToolBar',           'auto',...
        'HandleVisibility',   'callback',...
        'Resize',            'on',...
        'visible',           'on');
    
    %Create Axes
    Ax=axes(Fig);
    axis(Ax,'manual');
    hold(Ax,'on'); grid(Ax,'on');
    axis(Ax,'equal'); view(Ax,3);
    xlabel(Ax,'x'); ylabel(Ax,'y'); zlabel(Ax,'z');
    xlim(Ax,bounds(1,:)*1.2);
    ylim(Ax,bounds(2,:)*1.2);
    zlim(Ax,bounds(3,:)*1.2);
else %figure was provided in input
    Fig=varargin{1};
    Ax=findobj(Fig,'type','axes');
    cla(Ax);
end

hBall=scatter3(Ax,0,0,0,20,[0,0.5,0.5],'filled'); 

%Initalize text for time
xtext=0.9*Ax.XLim(1)+0.1*Ax.XLim(2);
ytext=0.1*Ax.YLim(1)+0.9*Ax.YLim(2);
hTime=text(Ax,xtext,ytext,'');
%% Storing handles to "figure" and block "UserData"
UserData.Figure = Fig;
UserData.Axes = Ax;
UserData.hBall=hBall;
UserData.hTime = hTime;

%Store in both figure and block
set(gcbh,'UserData',UserData);
end
%% Unused fcns
function Terminate(block)
end
function Start(block)
Enable=block.InputPort(1).Data(1);
if ~Enable, return, end

end
function CheckPrms(block)
  %can check validity of parameters here
end