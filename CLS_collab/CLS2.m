function RING = CLS2
	%CLS2 Simplified example lattice definition file
	% Last edit 04/29/2021
	disp(['   Loading CLS2 magnet lattice ', mfilename]);
	global FAMLIST
	FAMLIST = cell(0);
	
	E0 = 3e9;          % Beam energy [eV]
	L0 = 5.78400128E2; % Circumference [m]
	C0 = 299792458;    % Speed of light [m/s]
	HarmNumber = 328;  % Cavity harmonic number => Has to be defined by you!
	
	% Cavity
	% Name        L       U[V]       f(Hz)        h    method
	CAV = rfcavity('CAV', 0, 6.500000e+05, HarmNumber*C0/L0, HarmNumber, 'CavityPass');
	% => The numbers here are just a random guess from me, you have to get them from your guys
	
	% Markers
	BPM     = marker('BPM', 'IdentityPass');
	GIRDER  = marker('GIRDER',  'IdentityPass');
	
	
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
	
	
	% Bending magnets
	rb     =    rbend('rb'  , 0.200000, deg2rad(-0.15000) , deg2rad(-0.15000)/2, deg2rad(-0.15000)/2, 4.850000,'BndMPoleSymplectic4Pass');
	bq     =    rbend('bq'  , 0.200000, deg2rad(0.200000) , deg2rad(0.200000)/2, deg2rad(0.200000)/2,-4.850000,'BndMPoleSymplectic4Pass');
	bc     =    rbend('bc'  , 1.200000, deg2rad(2.612000) , deg2rad(2.612000)/2, deg2rad(2.612000)/2, 0.421000,'BndMPoleSymplectic4Pass');
	bmat   =    rbend('bmat', 0.800000, deg2rad(1.758000) , deg2rad(1.758000)/2, deg2rad(1.758000)/2,-0.522199,'BndMPoleSymplectic4Pass');         %
	
	
	
	% Define lattice sub-structures
	bend   =   [ bq db bc db bq];
	Lcell   =   [ s1 d1 rb d2 BPM...
		s2 d3 bend d3 ...
		s2 BPM d2 rb d1 s1];
	imatch =   [ bmat d5 s4 d5 q1 d4 s3];
	rimatch=   [ s3 d4 q1 d5 s4 d5 bmat];
	fmatch =   [ long BPM s5 d10 q5 d9 q4 d8 q3 d7 q2 d6];
	rfmatch=   [ d6 q2 d7 q3 d8 q4 d9 q5 d10 s5 BPM long];
	match  =   [ fmatch imatch];
	rmatch =   [ rimatch rfmatch];
	seven  =   [Lcell Lcell Lcell ...
		Lcell Lcell Lcell Lcell ];
	mba    =   [ GIRDER match GIRDER GIRDER seven GIRDER GIRDER rmatch GIRDER];
	
	% Ring is made of 16 mba cells
	ELIST   =   [mba mba mba mba ...
		CAV ...
		mba mba mba mba ...
		mba mba mba mba ...
		mba mba mba mba ];
		
	ELIST = reverse([ELIST]);
		
	
	% Locate function output
	RING=cell(size(ELIST));
	for i=1:length(RING)
		RING{i}        = FAMLIST{ELIST(i)}.ElemData;
		RING{i}.Energy = E0;
	end
	
end
