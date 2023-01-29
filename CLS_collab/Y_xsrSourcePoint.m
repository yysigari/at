%Load Yclsat
Yclsat
%
spos=findspos(THERING,1:length(THERING));

I_bends4x = findcells(THERING, 'FamName', 'BEND');
N_XSRbend = 14;


I_XSR_BPMs=findcells(THERING, 'FamName' , 'XSRbeam');
I_BPMs=findcells(THERING, 'FamName' , 'BPM');

s_XSR_BEND= findspos(THERING,I_bends4x(N_XSRbend));
s_XSRbpm= findspos(THERING,I_XSR_BPMs);

% get the indeces for all BPMs, bpms 7 and 8 are on either side of the
% dipole
I_bpms = findcells(THERING,'FamName','BPM');
% bpm index for upstream of SXR
N_BPM2_09 = 7; 
N_BPM2_10 = 8;
% bpm index for downstream of XSR
% find the spos of the bpms to plot later
S_BPM2_09 = findspos(THERING,I_bpms(N_BPM2_09)); 
S_BPM2_10 = findspos(THERING,I_bpms(N_BPM2_10));
%Find the M4 orbit of the ring
ROUT1=findorbit4(THERING, 0.01,1:length(THERING));
%plot it
figure(1)
hold on
plot(spos,ROUT1(3,:),'r')

xlabel('spos [m]')
ylabel('Y [m]')
title('closed orbit bumps')
grid on
plot(s_XSRbpm,ROUT1(3,120),'ok')
%plot(S_BPM2_09,ROUT1(3,I_bpms(N_BPM2_09)),'*r')
%plot(S_BPM2_10,ROUT1(3,I_bpms(N_BPM2_10)),'*r')
legend('XSR source point')%,'BPM2-09','BPM2-10')
%atplot % plots the magnets
hold off