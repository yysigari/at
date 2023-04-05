addpath('CLS_collab')
addpath('atmat')
addpath('MML')
atpath()
atmexall()
%% add errors to the model cls lattice
clear all
Yclsat;
%YCLS2

qfa_ind = atgetcells(THERING, 'FamName', 'QFA');
qf_ind = atgetcells(THERING, 'Class', 'Quadrupole');

Kvals = atgetfieldvalues(THERING, qf_ind, 'PolynomB',{1,2});
Kvals_quaderr = atgetfieldvalues(THERING, qf_ind, 'PolynomB',{1,1});
Kvalserr = Kvals + 0.05*(rand(length(Kvals),1)-0.1);
THERing_quaderr = atsetfieldvalues(THERING, qf_ind, 'PolynomB',{1,2},Kvalserr);
atplot(THERing_quaderr);

quadspos = findspos(THERING, qf_ind);
plot(quadspos,Kvals,'*r',quadspos,Kvalserr,'*b');
%% add 
ringdata=atlinopt6(THERING);
ringdata_quaderr = atlinopt6(THERing_quaderr);
%ringdata.tune
%% new ring by fitting the tune with quads
FT_THERing_quaderr=atfittune(THERing_quaderr,[0.22,0.29],'QFA','QFB');
atplot(FT_THERing_quaderr);
Kvals_quaderr = atgetfieldvalues(FT_THERing_quaderr, qf_ind, 'PolynomB',{1,2});
plot(quadspos,Kvals,'*r',quadspos,Kvals_quaderr,'^b',quadspos,Kvalserr,'+k');
%% Phase space in tracking 
%nturns=200;
nturns=104;
Z01=[.0001;0;1e-5;0;0;1e-6];
Z02=[.00002;0;1e-6;0;0;1e-6];
Z03=[.00003;0;1e-6;0;0;1e-6];

% Z1=ringpass(FT_THERing_quaderr,Z01,nturns);
% Z2=ringpass(FT_THERing_quaderr,Z02,nturns);
% Z3=ringpass(FT_THERing_quaderr,Z03,nturns);

Z1=ringpass(THERING,Z01,nturns);
Z2=ringpass(THERING,Z02,nturns);
Z3=ringpass(THERING,Z03,nturns);

plot([Z1(1,:); Z2(1,:); Z3(1,:)]',[Z1(2,:); Z2(2,:); Z3(2,:)]','.');
%% phase space ellipse fit
figure(6)
%plot([Z1(3,:); Z2(3,:); Z3(3,:)]',[Z1(4,:); Z2(4,:); Z3(4,:)]','.');
plot(Z1(3,:),Z1(4,:), 'b.');
ellipse_t = fit_ellipse( Z1(3,:),Z1(4,:) )
2*ellipse_t.a *2*ellipse_t.b 
theta_r         = linspace(0,2*pi);
ellipse_x_r     = ellipse_t.X0 + ellipse_t.a*cos( theta_r );
ellipse_y_r     = ellipse_t.Y0 + ellipse_t.b*sin( theta_r );R = [ cos(ellipse_t.phi) sin(ellipse_t.phi); -sin(ellipse_t.phi) cos(ellipse_t.phi) ];
rotated_ellipse = R * [ellipse_x_r;ellipse_y_r];
hold on
plot( rotated_ellipse(1,:),rotated_ellipse(2,:),'r' );
hold off
%% Define aperture
Xapert=0.06*ones(size(THERING));
Yapert=0.04*ones(size(THERING));

Ap_THERing_quaderr=SetPhysicalAperture(FT_THERing_quaderr,Xapert/2,Yapert/2);


FT_Ap_THERing_quaderr=atfittune(Ap_THERing_quaderr,[0.22,0.29],'QFA','QFB'); %fit the tune after the PA
%% add another phase space for above
Z1=ringpass(FT_Ap_THERing_quaderr,Z01,nturns);
Z2=ringpass(FT_Ap_THERing_quaderr,Z02,nturns);
Z3=ringpass(FT_Ap_THERing_quaderr,Z03,nturns);
%print('FT_Ap_THERing_quaderr')
%% sextupoles added
sx_ind=findcells(Ap_THERing_quaderr,'FamName','SF');
sx_spos = findspos(Ap_THERing_quaderr, sx_ind);

cor_ind=findcells(Ap_THERing_quaderr,'FamName','cor');
Kvals_sx = atgetfieldvalues(Ap_THERing_quaderr, sx_ind, 'PolynomB',{1,2});
Kvalserr_sx = Kvals_sx + 0.05*(rand(length(Kvals_sx),1)-0.1);
Ring_sx = atsetfieldvalues(Ap_THERing_quaderr, sx_ind, 'PolynomB',{1,2},Kvalserr_sx);
atplot(Ring_sx)
plot(sx_spos,Kvals_sx,'*r',sx_spos,Kvalserr_sx,'*b');
%% Ringpass for sextupole

Z1=ringpass(Ring_sx,Z01,nturns);
Z2=ringpass(Ring_sx,Z02,nturns);
Z3=ringpass(Ring_sx,Z03,nturns);


%% DA
[XX,ZZ]=atdynap(THERING, nturns, 0, 0.02); %nominal ring
[XX_2,ZZ_2]=atdynap(THERing_quaderr  , nturns, 0, 0.02); %quads error
%[XX_err,ZZ_err]=atdynap(FT_THERing_quaderr , nturns, 0, 0.02); %fitted tune
%% 

[XX_3,ZZ_3]=atdynap(Ap_THERing_quaderr , nturns, 0, 0.02); % physical aperture to FODO2
%% 

[XX_5, ZZ_5]=atdynap(FT_Ap_THERing_quaderr , nturns, 0, 0.02);%Phy.Aper.+fitting tune
%% 

[XX_6,ZZ_6]=atdynap(Ring_sx , nturns, 0, 0.02); %Sextupole ring

plot(XX_6,ZZ_6)
hold on
plot(XX_5,ZZ_5)
plot(XX_3,ZZ_3)
plot(XX_2,ZZ_2)
plot(XX_err,ZZ_err)
plot(XX,ZZ)
legend('sextupole+quad+apertur', 'fit tune+apreture+quad errors','apreture+quad errors', ...
       'quad. strength error', 'tune fit+quad errors', 'nominal lattice');

%% 

sx_ind=findcells(Ap_THERing_quaderr,'FamName','SF');
Kvals_sx = atgetfieldvalues(Ap_THERing_quaderr, sx_ind, 'PolynomB',{1,2});
Kvalserr_sx = Kvals_sx + 0.05*(rand(length(Kvals_sx),1)-0.1);
Ring_sx = atsetfieldvalues(Ap_THERing_quaderr, sx_ind, 'PolynomB',{1,2},Kvalserr_sx);
atplot(Ring_sx);
sx_spos = findspos(Ap_THERing_quaderr, sx_ind);
plot(sx_spos,Kvals_sx,'*r',sx_spos,Kvalserr_sx,'*b');
%Dynamic Aperture
[XX_6,ZZ_6]=atdynap(Ring_sx , nturns, 0, 0.02)
