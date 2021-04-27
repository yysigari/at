function CLS2
%CLS2 Simplified example lattice definition file
% Created 02/16/2020 
% Last modification : 6/30/2020
% Simplified Canadian Light Source 2.0 lattice
% no BPMs, no correctors
% (V:\at\at-master)

global FAMLIST THERING GLOBVAL

GLOBVAL.E0 = 3e9;
GLOBVAL.LatticeFile = 'CLS2';
FAMLIST = cell(0);

disp(' ');
disp('** Loading Canadian Light Source 2.0 lattice in machine_data/CLS2.m **');

% %Aperature physical limits be inserted
% AP = aperture('AP', [-0.05, 0.05, -0.05, 0.05],'AperturePass');

% Drifts in the cell
long   =    drift('long' ,2.52220,'DriftPass');
db     =    drift('db' ,0.120000,'DriftPass');
d1     =    drift('d1' ,0.130000,'DriftPass');
d2     =    drift('d2' ,0.110000,'DriftPass');
d3     =    drift('d3',0.110000,'DriftPass');
d4     =    drift('d4' ,0.100000,'DriftPass');
d5     =    drift('d5',0.351402,'DriftPass');
d6     =    drift('d6',0.150000,'DriftPass');
d7     =    drift('d7',0.150000,'DriftPass');
d8     =    drift('d8',0.150000,'DriftPass');
d9     =    drift('d9',0.150000,'DriftPass');
d10    =    drift('d10',0.120000,'DriftPass');

% Quadrupoles
q1     =    quadrupole('q1'  , 0.120000,  6.498710,'StrMPoleSymplectic4Pass');
q2     =    quadrupole('q2'  , 0.120000, -8.097841,'StrMPoleSymplectic4Pass');
q3     =    quadrupole('q3'  , 0.120000,  5.344311,'StrMPoleSymplectic4Pass');
q4     =    quadrupole('q4' , 0.150000, 10.000000,'StrMPoleSymplectic4Pass');
q5     =    quadrupole('q5' , 0.120000, -6.590778,'StrMPoleSymplectic4Pass');

% Sextupoles
s1     =    sextupole('s1' , 0.120000 , 193.070008,'StrMPoleSymplectic4Pass');
s2     =    sextupole('s2' , 0.150000 ,-202.3659913,'StrMPoleSymplectic4Pass');
s3     =    sextupole('s3' , 0.120000 ,18.333333,'StrMPoleSymplectic4Pass');
s4     =    sextupole('s4' , 0.150000 ,-29.333333,'StrMPoleSymplectic4Pass');
s5     =    sextupole('s5' , 0.150000 ,0.000000 ,'StrMPoleSymplectic4Pass');
%why S5 has k=0?
%
% => Good question! It currently is nothing but a drift. Maybe it's needed later as a corrector during operation
%


% Bending magnets
rb     =    rbend('rb'  , 0.200000, deg2rad(-0.15000) , deg2rad(0.00000)/2, deg2rad(0.00000)/2, 4.850000,'BendLinearPass');
bq     =    rbend('bq'  , 0.200000, deg2rad(0.200000) , deg2rad(0.000000)/2, deg2rad(0.000000)/2,-4.850000,'BndMPoleSymplectic4Pass');      

bc     =    rbend('bc'  , 1.200000, deg2rad(2.612000) , deg2rad(2.612000)/2, deg2rad(2.612000)/2, 0.421000,'BendLinearPass'); 
%bmat   =    rbend('bmat', 0.800000, deg2rad(1.758000) , deg2rad(1.758000)/2, deg2rad(1.758000)/2,-0.522199,'BendLinearPass');         %
bmat   =    rbend('bmat', 0.800000, deg2rad(1.758000) , deg2rad(0.0000)/2, deg2rad(0.0000)/2 ,-0.522199,'BendLinearPass');         %

       

% Begin Lattice
bend   =   [ bq db bc db bq];
Lcell   =   [ s1 d1 rb d2 ...
             s2 d3 bend d3 ...
             s2 d2 rb d1 s1];
imatch =   [ bmat d5 s4 d5 q1 d4 s3];
rimatch=   [ s3 d4 q1 d5 s4 d5 bmat];
fmatch =   [ long s5 d10 q5 d9 q4 d8 q3 d7 q2 d6];
rfmatch=   [ d6 q2 d7 q3 d8 q4 d9 q5 d10 s5 long];
match  =   [ fmatch imatch];
rmatch =   [ rimatch rfmatch];
seven  =   [Lcell Lcell Lcell ...
            Lcell Lcell Lcell Lcell ];
mba    =   [ match seven rmatch ];
%delete later
%this is for 
%x = [match rmatch]
%Ring is made of 16 mba cells 
Ring   =   [mba mba mba mba ... 
            mba mba mba mba ... 
            mba mba mba mba ... 
            mba mba mba mba ];
     
      
%modification put Lcell instead of CLSRing    
CLSRing = [Ring]; 
%CLSRing= [mba];

CLSRing = reverse(CLSRing);

buildlat(CLSRing);
THERING = setcellstruct(THERING,'Energy',1:length(THERING),GLOBVAL.E0);


evalin('caller','global THERING FAMLIST GLOBVAL');
disp('** Done **');

% {V:\at\at-master}
% Aknowledgment: Les Dallin , Thorsrten Hillert helped setting up this
% lattice.





