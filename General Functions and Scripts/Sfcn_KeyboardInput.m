function Sfcn_KeyboardInput(block)
setup(block);
end
function setup(block) %runs at t=0 i/o definitions
%dialog parameters
block.NumDialogPrms = 1;

%register number of ports
block.NumInputPorts = 1;
block.NumOutputPorts = 2;

%setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;

%Register the properties of the input ports
%Enable
block.InputPort(1).Complexity     ='Real';
block.InputPort(1).DataTypeId     =-1;
block.InputPort(1).Dimensions     =1;
block.InputPort(1).SamplingMode   ='Sample';

%Register the properties of the output ports
%keys pressed
block.OutputPort(1).Dimensions   = 7; %logical [space,w,s,d,a,space,e,q]
block.OutputPort(1).SamplingMode = 'Sample';
block.OutputPort(1).DatatypeID   = 0;
%trigger
block.OutputPort(2).Dimensions   = 1;
block.OutputPort(2).SamplingMode = 'Sample';
block.OutputPort(2).DatatypeID   = 0;

%Register sample time
dt=block.DialogPrm(1).Data;
block.SampleTimes = [dt 0]; %[discrete time, offset]

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
function Start(block) %runs on t=0
%Check for valid key inputs
NET.addAssembly('PresentationCore');
akey = System.Windows.Input.Key.A;  %use any key to get the enum type
keys = System.Enum.GetValues(akey.GetType);  %get all members of enumeration
% keynames = cell(System.Enum.GetNames(akey.GetType))';
iskeyvalid = true(keys.Length, 1);
iskeydown = false(keys.Length, 1);
for keyidx = 1:keys.Length
   try
       iskeydown(keyidx) = System.Windows.Input.Keyboard.IsKeyDown(keys(keyidx));
   catch
       iskeyvalid(keyidx) = false;
   end
end

%% Update User Data
UserData=get(gcbh,'UserData');

UserData.keys=keys;
UserData.iskeyvalid=iskeyvalid;
UserData.SteeringWheelGearRatio=3;

set(gcbh,'UserData',UserData);
end 
function ProcessPrms(block) %runs on every dt (Wasnt checked!)
  block.AutoUpdateRuntimePrms;
end
function InitializeConditions(block) %runs on t=0 and when susbystem is enabled
Enable=block.InputPort(1).Data(1);
if ~Enable, return, end
end
function Outputs(block) %runs on every dt
UserData=get(gcbh,'UserData'); %UserData is now a struct of handles and is NOT connected to BlockHandle
%check which keys are down
keys=UserData.keys;
iskeyvalid=UserData.iskeyvalid;
iskeydown(iskeyvalid) = arrayfun(@(keyidx) System.Windows.Input.Keyboard.IsKeyDown(keys(keyidx)), find(iskeyvalid));

%if escape is pressed - close simulation
% if iskeydown(18) %escape
%     set_param(bdroot(gcs),'SimulationCommand', 'stop');
% end

keyspressed=iskeydown([23,74,70,55,52,56,68]); %check keynames
%SOME KEYBOARDS OR OPERATOIN SYSTEMS MAY BE DIFFERNT
%23 - space
%74 - w
%70 - s
%55 - d
%52 - a
%56 - e
%68 - q

%outputs - keystrkes
if any(keyspressed)
    block.OutputPort(1).Data=double(keyspressed);
    block.OutputPort(2).Data=1;
else
    block.OutputPort(1).Data=[0,0,0,0,0,0,0];
    block.OutputPort(2).Data=0;
end
end
%% Unused fcns
function Terminate(block)
end
function CheckPrms(block)
  %can check validity of parameters here
end