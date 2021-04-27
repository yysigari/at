%% Code for simulating a vertical bump orbi at the XSR source point
%-- 2021-02-02, 13:35 --%
% find where mml director is in your drive...
cd mml
setpathmml % select CLS from gui, maybe can use setpathcls instead, no gui needed

%%
switch2sim
%setorbitbumpgui % see below, can use setorbitbump with command not GUI
global THERING % loads the lattice into stored memory, so you can tack particles through the lattice changes made in setorbitbumpgui - should find how to so this on command line with setorbitbump
% get the values of the element positions in [m]

spos = findspos(THERING,[1:length(THERING)]);

% where is the source point? 4 deg into dipole 3, but lattice splits each
% dipole into 4 slices, source point is at the end of slice 1, but for some
% functions you need to input the next slice as it calculates the position
% relative to the start of the element.
360/24 % deg bending per magnet in the 24 bend magnets in CLS = 15
4/15 % 4deg into the bend is the XSR source point, in bend number 4, second bend in sector 2 

%%
% get all the bends, i.e. all the indes elements of the 4 slices per dipole.
I_bends4x = findcells(THERING,'FamName','BEND');
N_XSRbend = 14; % bend slice 2 in the XSR dipole bend, so we get the value at the start of this element where XSR is
I_XSRbend = I_bends4x(N_XSRbend); % need the index of the cell after the source point, since findspos returns the position at the start of the element
% THERING{I_XSRbend}
S_XSRbend = findspos(THERING,I_XSRbend);

% get the indeces for all BPMs, bpms 7 and 8 are on either side of the
% dipole
I_bpms = findcells(THERING,'FamName','BPM');
N_BPM2_09 = 7; % bpm index for upstream of SXR
N_BPM2_10 = 8; % bpm index for downstream of XSR
S_BPM2_09 = findspos(THERING,I_bpms(N_BPM2_09)); % find the spos of the bpms to plot later
S_BPM2_10 = findspos(THERING,I_bpms(N_BPM2_10));

%% See Cell below, managed to get command line orbitbump code working
% used the setorbitbumpgui to put in a bump of 10,-10 um in BPM9 and BPM10 in
% the vertical
% track particles through the ring and find a closed orbit.
%ROUT2 = findorbit4(THERING,0,1:length(THERING));

% used the setorbitbumpgui to put in a bump of 20,-20 um in BPM9 and BPM10 in
% the vertical
% track particles through the ring and find a closed orbit.
%ROUT3 = findorbit4(THERING,0,1:length(THERING));

%% set the orbit on the command line
% use BPMy [2 3] = sector 3, BPM 3, see clsinit.m for PV name from EPICS
% control system.
zerocorrectors % might be best to zero correctors before each bump?
yoffset1 = 100e-6;
yoffset2 = 100e-6;
OCS4 = setorbitbump('BPMy',[2 3;2 4],[yoffset1;yoffset2],'VCM',[-2 -1 1 2]); % can play with vector [-2 -1 1 2] to select other corrector magnets to try to improve the bump
ROUT4 = findorbit4(THERING,0,1:length(THERING));
% ROUT is a vector of [x, x', y, y']'
% check vertical position and angle at XSR source point
fprintf('y = %5.3e, y'' = %5.3e\n', ROUT4(3, I_XSRbend),ROUT4(4, I_XSRbend))

yoffset1 = 200e-6;
yoffset2 = 200e-6;
OCS5 = setorbitbump('BPMy',[2 3;2 4],[yoffset1;yoffset2],'VCM',[-2 -1 1 2]);
ROUT5 = findorbit4(THERING,0,1:length(THERING));
% check vertical position and angle at XSR source point
fprintf('y = %5.3e, y'' = %5.3e\n', ROUT5(3, I_XSRbend),ROUT5(4, I_XSRbend))

yoffset1 = 300e-6;
yoffset2 = 300e-6;
OCS6 = setorbitbump('BPMy',[2 3;2 4],[yoffset1;yoffset2],'VCM',[-2 -1 1 2]);
ROUT6 = findorbit4(THERING,0,1:length(THERING));
% check vertical position and angle at XSR source point
fprintf('y = %5.3e, y'' = %5.3e\n', ROUT6(3, I_XSRbend),ROUT6(4, I_XSRbend))

%%
figure(31)
plot(spos,ROUT4(3,:))
hold on
plot(spos,ROUT5(3,:),'r')
plot(spos,ROUT6(3,:),'k')
xlabel('spos [m]')
ylabel('Y [m]')
title('closed orbit bumps')
grid on
plot(findspos(THERING,I_bends4x(14)),ROUT6(3,106),'ok')
plot(S_BPM2_09,ROUT6(3,I_bpms(N_BPM2_09)),'*r')
plot(S_BPM2_10,ROUT6(3,I_bpms(N_BPM2_10)),'*r')
legend('100 um bump','200 um bump','300 um bump','XSR source point','BPM2-09','BPM2-10')
%atplot % plots the magnets
hold off

figure(32)
plot(spos,ROUT4(3,:))
hold on
plot(spos,ROUT5(3,:),'r')
plot(spos,ROUT6(3,:),'k')
xlabel('spos [m]')
ylabel('Y [m]')
title('closed orbit bumps')
grid on
plot(findspos(THERING,I_bends4x(14)),ROUT6(3,106),'ok')
plot(S_BPM2_09,ROUT6(3,I_bpms(N_BPM2_09)),'*r')
plot(S_BPM2_10,ROUT6(3,I_bpms(N_BPM2_10)),'*r')
legend('100 um bump','200 um bump','300 um bump','XSR source point','BPM2-09','BPM2-10')
%atplot
xlim([20,27])
hold off