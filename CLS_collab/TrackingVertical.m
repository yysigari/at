%Particle Tracking by Yasaman
%clear all
%CLS2
global THERING
%% Initial condistions 

Nturns=500;
Z01=[0.0;0;0.001;0;0;0];
Z02=[0.0;0;0.0015;0;0;0];
Z03=[0.0;0.0;0.002;0;0;0];
Z04=[0.0;0;0.0;1.0e-4;0;0];
Z05=[0.0;0;0.0;2.0e-4;0.0;0];

%ringpass tracks particles through each element of the cell array RING
% ROUT=ringpass(RING,RIN,NTURNS)
ROUT1=ringpass(THERING,Z01,Nturns);
ROUT2=ringpass(THERING,Z02,Nturns);
ROUT3=ringpass(THERING,Z03,Nturns);
ROUT4=ringpass(THERING,Z04,Nturns);
ROUT5=ringpass(THERING,Z05,Nturns);
%% plot the routes
figure(1)
plot([ROUT1(3,:);ROUT2(3,:);ROUT3(3,:);ROUT4(3,:);ROUT5(3,:)]',[ROUT1(4,:);ROUT2(4,:);ROUT3(4,:);ROUT4(4,:);ROUT5(4,:)]','.')
hold on
xlabel('Particles tracking in Y [m]')
ylabel('dY [rad]')
title('vertical phase space for 500turns')
legend('deltay = 0.001','deltay = 0.0015','deltay=0.002','deltay"=0.0001','deltay"=0.0002')
grid on
hold off