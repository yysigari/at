%% 
addpath mml
setpathmml
%choose cls

%% 


[x_bend2, ATI_bend2, LostBeam_bend2] = getturns([1e-6, 0 , 10e-6, 0, 1e-5, 0.0]', 1024, 'BEND');
%% 

figure(312)
plot(x_bend2(4,:,3), x_bend2(4,:,4),'r.');
hold on
plot(x_bend2(4,:,1), x_bend2(4,:,2),'b.');
%hold off
title('Phase Space at XSR');
xlabel('X, Y [m]');
ylabel("X' , Y' [rad]")
%legend('vertical','horizontal')

%% 

[x_d6, ATI_d6, LostBeam_d6] = getturns([-1e-6,0 , -1.e-5, 0, 0, 0.0]', 1024, 'D6');


figure(122)
plot(x_d6(8,:,3), x_d6(8,:,4),'r.');
hold on
plot(x_d6(8,:,1), x_d6(8,:,2),'b.');
hold off
title('Phase Space at Drift');
xlabel('X, Y [m]');
ylabel("X' , Y' [rad]")
legend('vertical','horizontal')

%% 
[x_bpm, ATI_bpm, LostBeam_bpm] = getturns([-1e-6,0, -1.e-5, 0, 0, 0.0]', 1024, 'BPM');

figure(222)
plot(x_bpm(16,:,3), x_bpm(16,:,4),'r.');
hold on
plot(x_bpm(16,:,1), x_bpm(16,:,2),'b.');
hold off
title('Phase Space at BPM1404-04');
xlabel('X, Y [m]');
ylabel("X' , Y' [rad]")
legend('vertical','horizontal')
%% 
%% 
