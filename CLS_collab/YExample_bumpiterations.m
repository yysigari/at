%% ALL VCM and zero to generate an array for the Closed orbit bumps when we iterate BPM 9 and 10 
zerocorrectors;
%t=-500e-6;
x=zeros(11,1);
y= zeros(11,1);
dy= zeros(11,1);
i=0;
for t = -500e-6: 100e-6:500e-6
    i = i+1;
    zerocorrectors;
    x(i)=t;
    
    OCS = setorbitbump('BPMy',[2 3;2 4],[t;t],'VCM',[-24 -23 -22 -21 -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]);
    ROUT = findorbit4(THERING,0,1:length(THERING));
    y(i)= ROUT(3, I_XSRbend);
    dy(i)= ROUT(4, I_XSRbend);
    
    figure(45)
    plot(spos,ROUT(3,:))
    hold on
    
end
xlabel('spos [m]')
ylabel('Y [m]')
title('closed orbit bumps')
grid on
plot(findspos(THERING,I_bends4x(14)),ROUT(3,106),'ok')
plot(S_BPM2_09,ROUT(3,I_bpms(N_BPM2_09)),'*r')
plot(S_BPM2_10,ROUT(3,I_bpms(N_BPM2_10)),'*r')
%atplot % plots the magnets
%newcolors = [230 9 42;230 9 145;230 9 200;222 9 230; 134 9 230; 61 9 230; 13 9 230; 9 79 230 ;9 130 230;9 182 230;20 230 9 ];
%colororder(newcolors)

legend('-500 um bump','-400 um bump','-300 um bump','-200 um bump','-100 um bump','0 um bump','100 um bump','200 um bump','300 um bump','400 um bump','500 um bump','XSR source point','BPM2-09','BPM2-10')

hold off
%% Plot them
%% 
figure(30)
%plot(y1(1:20))
hold on
plot(y,'*r')
plot(y,'k')

xlabel('50 mum bumps at BPM 9 and 10 ')
ylabel("XSR source point's vertical position [m]")
title('XSR Source Point position orbit bumps-All VCM')
%legend('VCM [0]', 'VCM All')
grid on
hold off