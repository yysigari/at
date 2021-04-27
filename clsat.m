function clsat
% ----------------------------------------------------------------------------------------------
% $Header$
% ----------------------------------------------------------------------------------------------
% Canadian Light Source
% ----------------------------------------------------------------------------------------------

disp(['   Loading CLS magnet lattice ', mfilename]);

global FAMLIST THERING
Energy = 2.9e9;
FAMLIST = cell(0);

L0    = 170.88;
C0    = 299792458; 
HarmNumber = 285;
CAV	  = rfcavity('RF', 0, 2.4e+6, HarmNumber*C0/L0, HarmNumber, 'CavityPass');
COR   = corrector('COR',0.15,[0 0],'CorrectorPass');  
CORSD = corrector('COR',0.0,[0 0],'CorrectorPass');
AP    = aperture('AP',  [-0.1, 0.1, -0.1, 0.1], 'AperturePass');
BPM   = marker('BPM', 'IdentityPass');
XSR   = marker('XSRbeam', 'IdentityPass');
BMIT   = marker('BMITbeam', 'IdentityPass');
SM   = marker('SMbeam', 'IdentityPass');
BRKHS   = marker('BRKbeam', 'IdentityPass');

% Drifts should match the DIMAD model
D1  = drift('D1' , 2.2500, 'DriftPass');   
D1A = drift('D1A', 0.2910, 'DriftPass');
D1B = drift('D1B', 0.0660, 'DriftPass');
D2A = drift('D2A', 0.3390-.15/2, 'DriftPass');  % Was 0.264
D2B = drift('D2B', 0.1950-.15/2, 'DriftPass');  % Was 0.120
D3  = drift('D3',  0.3120, 'DriftPass');  % Was 0.534
D4A = drift('D4A', 0.3095, 'DriftPass'); 
D4B = drift('D4B', 0.0975, 'DriftPass');  % Was 0.0375
D5  = drift('D5',  0.3125, 'DriftPass');  % Was 0.3335
D6  = drift('D6',  0.1695, 'DriftPass');
D7  = drift('D7',  0.3975, 'DriftPass');  % Was 0.4185
D8A = drift('D8A', 0.0920, 'DriftPass');  % Was 0.1130
D8B = drift('D8B', 0.2300, 'DriftPass');
D9A = drift('D9A', 0.2100-.15/2, 'DriftPass');  % Was 0.135
D9B = drift('D9B', 0.3240-.15/2, 'DriftPass');  % Was 0.249
D10A = drift('D10A', 0.0700, 'DriftPass');
D10B = drift('D10B', 0.2870, 'DriftPass');

%Calculated using DIMAD: first order agrees with 'LinearPass' functions
QFAK = 1.95812072442795; 
QFBK = 1.43332618210432;
QFCK = 2.04529679068196;
SDK = 0; 
SFK = 0;

%Build a bending magnet out of peices
%We must take care to ensure that we get the correct edge focusing
%BEND   = rbend2('BEND', 1.87, 0.2617994, 0.105, 0.105, -0.3972, 0.05,'BendLinearPass');
BEND1 = rbend2('BEND', 1.87/15, 0.2617994/15, 0.105, 0, -0.3972, 0.05,'BendLinearPass');
FAMLIST{BEND1}.ElemData.FringeInt2 = 0;
BEND2 = rbend2('BEND', 1.87/15, 0.2617994/15, 0, 0, -0.3972, 0.0,'BendLinearPass');
BEND3 = rbend2('BEND', 1.87/15, 0.2617994/15, 0, 0.105, -0.3972, 0.05,'BendLinearPass');
FAMLIST{BEND3}.ElemData.FringeInt1 = 0;
BEND = [BEND1, BEND2, BEND2, BEND2, BEND2, BEND2, BEND2, BEND2, BEND2, BEND2, BEND2, BEND2, BEND2, BEND2, BEND3];

%Lattice elements
QFA = quadrupole('QFA', 0.18, QFAK, 'QuadLinearPass');
QFB = quadrupole('QFB', 0.18, QFBK, 'QuadLinearPass');
QFC = quadrupole('QFC', 0.26, QFCK, 'QuadLinearPass');
SF = sextupole('SF', 0.192  , SFK/2, 'StrMPoleSymplectic4Pass'); %Convention: divide K2 by two

% %Defocusing sextupoles have windings for corrector and skew quad
% SQK = 0.0; %Skew quad strength
 %SD = sextcorr('COR', 0.192, SDK/2, 0.0 ,'StrMPoleSymplectic4Pass');
% SD = sextcorr('SD', 0.0, SDK/2, 0.0 ,'StrMPoleSymplectic4Pass');
% FAMLIST{1,SD}.ElemData.PolynomA(2) = SQK; %skew quad component

%imbed the corrector inside the sextupole (split sextupole)
SEXTSD = sextupole('SD', 0.192/2, SDK/2, 'StrMPoleSymplectic4Pass');
SD = [SEXTSD, CORSD, SEXTSD];

% Build the lattice
HCELL =	[D1 D1A BPM D1B QFA D2A COR D2B QFB D3 BEND D4A BPM D4B SD D5 QFC D6 SF];
HCELR =	[D6 QFC D7 SD D8A BPM D8B BEND D3 QFB D9A COR D9B QFA D10A BPM D10B D1];
CEL   = [AP HCELL HCELR];
ELIST = [CEL CEL CEL CEL CEL CEL CEL CEL CEL CEL CEL CEL CAV]; 
buildlat(ELIST);

% Compute total length and RF frequency
L0_tot = findspos(THERING, length(THERING)+1);
%fprintf('   L0 = %.6f     (design length is 170.8800 m)\n', L0_tot)
%fprintf('   RF = %.6f MHz  \n', HarmNumber*C0/L0_tot/1e6)

% Newer AT versions require 'Energy' to be an AT field
THERING = setcellstruct(THERING, 'Energy', 1:length(THERING), Energy);
%setcavity off;
%setradiation off;

%clear global FAMLIST
% LOSSFLAG is not global in AT1.3
evalin('base','clear LOSSFLAG');
evalin('base','global THERING FAMLIST GLOBVAL'); 
