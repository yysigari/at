%% 
%print('starting..')
zerocorrectors % might be best to zero correctors before each bump?

yoffset1 = -40e-6;
yoffset2 = -40e-6;
OCS6 = setorbitbump('BPMy',[2 3;2 4],[yoffset1;yoffset2],'VCM',[-2 -1 1 2]);
ROUT6 = findorbit4(THERING,0,1:length(THERING));
% check vertical position and angle at XSR source point
fprintf('y = %5.3e, y'' = %5.3e\n', ROUT6(3, I_XSRbend),ROUT6(4, I_XSRbend))

[x_bend, ATI_bend, LostBeam_bend] = getturns([1e-6, 0 , 10e-6, 0, 1e-5, 0.0]', 1024, 'BEND');



%% 
zerocorrectors % might be best to zero correctors before each bump?

yoffset1 = -20e-6;
yoffset2 = -20e-6;
OCS6 = setorbitbump('BPMy',[2 3;2 4],[yoffset1;yoffset2],'VCM',[-2 -1 1 2]);
ROUT6 = findorbit4(THERING,0,1:length(THERING));
% check vertical position and angle at XSR source point
fprintf('y = %5.3e, y'' = %5.3e\n', ROUT6(3, I_XSRbend),ROUT6(4, I_XSRbend))

[x_bend1, ATI_bend1, LostBeam_bend1] = getturns([1e-6, 0 , 10e-6, 0, 1e-5, 0.0]', 1024, 'BEND');


%% 
zerocorrectors % might be best to zero correctors before each bump?

yoffset1 = 0e-6;
yoffset2 = 0e-6;
OCS6 = setorbitbump('BPMy',[2 3;2 4],[yoffset1;yoffset2],'VCM',[-2 -1 1 2]);
ROUT6 = findorbit4(THERING,0,1:length(THERING));
% check vertical position and angle at XSR source point
fprintf('y = %5.3e, y'' = %5.3e\n', ROUT6(3, I_XSRbend),ROUT6(4, I_XSRbend))

[x_bend2, ATI_bend2, LostBeam_bend2] = getturns([1e-6, 0 , 10e-6, 0, 1e-5, 0.0]', 1024, 'BEND');
%% 
zerocorrectors % might be best to zero correctors before each bump?

yoffset1 = 20e-6;
yoffset2 = 20e-6;
OCS6 = setorbitbump('BPMy',[2 3;2 4],[yoffset1;yoffset2],'VCM',[-2 -1 1 2]);
ROUT6 = findorbit4(THERING,0,1:length(THERING));
% check vertical position and angle at XSR source point
fprintf('y = %5.3e, y'' = %5.3e\n', ROUT6(3, I_XSRbend),ROUT6(4, I_XSRbend))

[x_bend21, ATI_bend21, LostBeam_bend21] = getturns([1e-6, 0 , 10e-6, 0, 1e-5, 0.0]', 1024, 'BEND');

%% 
zerocorrectors % might be best to zero correctors before each bump?

yoffset1 = 40e-6;
yoffset2 = 40e-6;
OCS6 = setorbitbump('BPMy',[2 3;2 4],[yoffset1;yoffset2],'VCM',[-2 -1 1 2]);
ROUT6 = findorbit4(THERING,0,1:length(THERING));
% check vertical position and angle at XSR source point
fprintf('y = %5.3e, y'' = %5.3e\n', ROUT6(3, I_XSRbend),ROUT6(4, I_XSRbend))

[x_bend3, ATI_bend3, LostBeam_bend3] = getturns([1e-6, 0 , 10e-6, 0, 1e-5, 0.0]', 1024, 'BEND');


%% 

figure(4)
plot(x_bend(4,:,3), x_bend(4,:,4),'.'); %mu
hold on
plot(x_bend1(4,:,3), x_bend1(4,:,4),'.'); % 0mu
plot(x_bend2(4,:,3), x_bend2(4,:,4),'.'); %0 mu 
plot(x_bend21(4,:,3), x_bend21(4,:,4),'.'); %

plot(x_bend3(4,:,3), x_bend3(4,:,4),'.'); %0
hold off
title('Phase Space at XSR source point after vertical bumps');
xlabel('X, Y [m]');
ylabel("X' , Y' [rad]")
legend('-100 \mu m','-50 \mu m','0','50 \mu m', '100 \mu m')