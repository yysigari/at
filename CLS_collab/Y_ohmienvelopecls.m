%OHMIENVELOPEDEMO illustrates the use of OHMIENVELOPE function
clear all
%spear2rad
clsat

% for i=1:272 THERING{i}.Energy = 3e9; end
atsetenergy(THERING, 2.9e9);

BENDINDEX = findcells(THERING,'PassMethod','BndMPoleSymplectic4RadPass');
QUADSEXTINDEX = findcells(THERING,'PassMethod','StrMPoleSymplectic4RadPass');
% BENDINDEX = findcells(THERING,'PassMethod','BendLinearPass');
% SEXTINDEX = findcells(THERING,'PassMethod','StrMPoleSymplectic4Pass');
% QUADINDEX = findcells(THERING,'PassMethod','QuadLinearPass');

RADELEMINDEX = sort([BENDINDEX QUADSEXTINDEX]);
XSRINDEX = findcells(THERING,'FamName','XSR');

% Find  indexes of elements in different families 
QFI = findcells(THERING,'FamName','QFA');
% Select some of them to randomly tilt
TILTI = QFI([3:7 10:12]);

% NOTE: How to introduce random coupling and misalignment errors:
% s-rotations(tilts) and transverse displacements (shifts)

% 1.generate random  rotations 
tilterr = 0.1*pi/180;			% RMS tilt error [radians]
qftilts = tilterr*randn(1,length(TILTI));

% 2. rotate elements
settilt(TILTI,qftilts);

[ENV, DP, DL] = ohmienvelope(THERING(:),RADELEMINDEX, 1:length(THERING)+1);
sigmas = cat(2,ENV.Sigma);
tilt = cat(2,ENV.Tilt);
spos = findspos(THERING,1:length(THERING)+1);

figure(1)
plot(spos,tilt*180/pi,'.-')
set(gca,'XLim',[0 spos(end)])
title('Rotation angle of the beam ellipse [degrees]');
xlabel('s - position [m]');

figure(2)
[A, H1, H2] = plotyy(spos,sigmas(1,:),spos,sigmas(2,:));

set(H1,'Marker','.')
set(A(1),'XLim',[0 spos(end)])
set(H2,'Marker','.')
set(A(2),'XLim',[0 spos(end)])
title('Principal axis of the beam ellipse [m]');
xlabel('s - position [m]');
% plots the magnets
ax = gca;
atplotsyn(ax, THERING);

%- beam sizes at XSR
fprintf('spos %f m, sigmax %f um, sigmay %f um\n',spos(XSRINDEX),sigmas(1,XSRINDEX)/1e-6,sigmas(2,XSRINDEX)/1e-6)
fprintf('spos %f m, FWHMx %f um, sigmay %f um\n',spos(XSRINDEX),2.355*sigmas(1,XSRINDEX)/1e-6,2.355*sigmas(2,XSRINDEX)/1e-6)
fprintf('spos %f m, betax %f m, betay %f m\n',spos(XSRINDEX),betx(THERING,XSRINDEX),bety(THERING,XSRINDEX))
