%% Motor Plant
%Jm*dot(omega)=Kt*I
%L*dot(I)=V-R*I-Kb*omega
s=tf('s');
Kb=1;
Kt=Kb;
J=0.01;
L=0.0025;
R=0.5;

wmid=sqrt(Kb*Kt/(J*L))/(2*pi);
disp(wmid);

GV2I=J*s/(J*L*s^2+R*J*s+Kb*Kt);
opt = bodeoptions;  
opt.FreqUnits='Hz';
opt.Grid='on';
h=bodeplot(GV2I,opt);

PI=(s+2*pi*wmid)/s;
opt = bodeoptions;  
opt.FreqUnits='Hz';
opt.Grid='on';
h=bodeplot(GV2I*PI*PI,opt);


%% Velocity Loop Equations
syms kk kv N Jm Jl s
Jls=Jl/N^2;
Jeq=Jm*Jls/(Jm+Jls);
g1=1/((Jm+Jls)*s);
g2=1+(kv/kk)*s+(Jls/kk)*s^2;
g3=1/(1+kv/kk*s+Jeq/kk*s^2);
GT2w=g1*g2*g3;
%% Velocity Loop Transfer Function
s=tf('s');
N=2;
kk=1e2/(N^2);
kv=0.14/(N^2);
Jm=0.01;
Jl=0.01;
Jls=Jl/N^2;
Jeq=(Jm*Jls)/(Jm+Jls);

g1=1/((Jm+Jls)*s);
g2=1+(kv/kk)*s+(Jls/kk)*s^2;
g3=1/(1+kv/kk*s+Jeq/kk*s^2);
GT2w=g1*g2*g3;

opt = bodeoptions;  
opt.FreqUnits='Hz';
opt.Grid='on';
bodeplot(GT2w,opt);