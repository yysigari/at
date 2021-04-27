function SC = register_CLS(SC)
	
	% Factors for switching off entire error types % % % % % % % % % % % % % % % % % %
	injErrorFactor  = 1;
	injJitterFactor = 1;
	magErrorFactor  = 1;
	diagErrorFactor = 1;
	RFerrorFactor   = 1;
	
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Define magnet errors 
	magOffset     = 1* 50E-6 * [1 1]  * magErrorFactor; % Offsets of magnets in x and y [m]
	magRoll       = 1* 200E-6         * magErrorFactor; % Tilts of magnets around z axis [rad]
	magCal        = 1* 1E-3           * magErrorFactor; % Relative magnet strength error
		
	GirderOffset  = 1* 100E-6  * [1 1] * magErrorFactor; % Girders-to-plinth offset in x and y [m]
	girderRoll    = 1* 100E-6             * magErrorFactor; % Roll of girders [rad]
	
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Define errors to diagnostic devices
	BPMcal          = 1* 5E-2   * [1 1] * diagErrorFactor; % BPM calibration error 
	BPMoffset       = 1* 500E-6 * [1 1] * diagErrorFactor; % BPM offset [m]
	BPMnoise        = 1* 3E-6   * [1 1] * diagErrorFactor; % BPM noise [m]
	BPMnoiseCO      = 1* 1E-7   * [1 1] * diagErrorFactor; % BPM noise for stored beam [m]
	BPMroll         = 1* 400E-6         * diagErrorFactor; % BPM roll [rad]
	CMcal           = 1* 5E-2           * diagErrorFactor; % CM calibration error
	
	CMlimit         = 1* 0.4E-3;

	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Circumfernece error 	
	circError       = 1* 1E-6; % Circumeference error [rel]
	
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Add errors to RF cavity 
	RFfrequency     = 1* 1E2  * RFerrorFactor; % RF frequency error [Hz]
	RFvoltage       = 1* 1E-3 * RFerrorFactor * SC.IDEALRING{findcells(SC.RING,'Frequency')}.Voltage; % RF voltage error [V]
	RftimeLag       = 1* 1/4  * RFerrorFactor * 299792458/SC.IDEALRING{findcells(SC.RING,'Frequency')}.Frequency; % RF phase [m]
	
	

	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Register q1-q5: Quadrupoles and HCMs and VCMs
	ords = SCgetOrds(SC.RING,'^q1|^q2|^q3|^q4|^q5');
	SC = SCregisterMagnets(SC,ords,...
		'HCM',CMlimit,...
		'VCM',CMlimit,...
		'CalErrorB',[CMcal magCal],...
		'CalErrorA',[CMcal 0     ],...
		'MagnetOffset',magOffset,...
		'MagnetRoll',magRoll);

	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Register s1-s5: Sextupoles and Skew-Quad Correctors
	ords = SCgetOrds(SC.RING,'^s1|^s2|^s3|^s4|^s5');
	SC = SCregisterMagnets(SC,ords,...
		'SkewQuad',Inf,...
		'CalErrorB',[0 0      magCal],...
		'CalErrorA',[0 magCal 0     ],...
		'MagnetOffset',magOffset,...
		'MagnetRoll',magRoll);

	% Register all 'rb' as combined function magnets with HCM and VCM
	ords = SCgetOrds(SC.RING,'^rb');
	SC = SCregisterMagnets(SC,ords,...
		'HCM',CMlimit,...
		'VCM',CMlimit,...
		'CF',1,...
		'CalErrorB',[CMcal magCal],...
		'CalErrorA',[CMcal 0     ],...
		'MagnetOffset',magOffset,...
		'MagnetRoll',magRoll); 

	% Register all other BENDs as combined function magnets
	ords = SCgetOrds(SC.RING,'^bq|^bc|^bmat');
	SC = SCregisterMagnets(SC,ords,...
		'CF',1,...
		'CalErrorB',[0 magCal],...
		'MagnetOffset',magOffset,...
		'MagnetRoll',magRoll); 


	
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Register BPMs 
	ords = SCgetOrds(SC.RING,'BPM');	
	SC = SCregisterBPMs(SC,ords,...
		'CalError',BPMcal,...
		'Offset',BPMoffset,...
		'Roll',BPMroll,...
		'Noise',BPMnoise,...
		'NoiseCO',BPMnoiseCO);
		
	
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Register cavities (not included in your lattice file!)
	CAVords = findcells(SC.RING,'Frequency');
	SC = SCregisterCAVs(SC,CAVords,...
		'Frequency',RFfrequency,...
		'Voltage',RFvoltage,...
		'TimeLag',RftimeLag);


	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Register girders
	girderOrds = reshape(SCgetOrds(SC.RING,'GIRDER'),2,[]);
	SC = SCregisterSupport(SC,...
		'Girder',girderOrds,...
		'Offset',GirderOffset,...
		'Roll',girderRoll);


	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Switch on cavity and radiation
	SC.RING = SCcronoff(SC.RING,'cavityon','radiationon');

	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Define initial bunch emittance
	% => The idea is to define an injected beam emittance and assume a matched beam
	emit0 = 2E-9*[1 0.01]; % [m*rad] -> 1% coupling
	% Define longitudinal size of initial bunch
	beamSize5 = 1E-3;				% Relative energy error
	beamSize6 = 15E-12 * 299792458; % Relative phase error [m]
	% Calculate Courant-Snyder parameters at beginning of ring
	TD = twissring(SC.IDEALRING,0,1);
	alpha = [TD.alpha(1) TD.alpha(2)];
	beta  = [TD.beta(1)  TD.beta(2)];
	% Define sigma matrices of injected beam
	sigx = emit0(1) * [beta(1) -alpha(1) ; -alpha(1) (1+alpha(1).^2)./beta(1)];
	sigy = emit0(2) * [beta(2) -alpha(2) ; -alpha(2) (1+alpha(2).^2)./beta(2)];
	sigz = [beamSize5 0 ; 0 beamSize6].^2;
	% Define 6x6 beam size matrix
	SC.INJ.beamSize = blkdiag(sigx,sigy,sigz);
	
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Define random injection errors
	SC.SIG.randomInjectionZ(1) = injJitterFactor * 10E-6;
	SC.SIG.randomInjectionZ(2) = injJitterFactor * 6E-6; 
	SC.SIG.randomInjectionZ(3) = injJitterFactor * 1E-6;
	SC.SIG.randomInjectionZ(4) = injJitterFactor * 0.5E-6;
	SC.SIG.randomInjectionZ(5) = injJitterFactor * 1E-4;
	SC.SIG.randomInjectionZ(6) = injJitterFactor * deg2rad(0.1) * 299792458/SC.IDEALRING{SC.ORD.Cavity(1)}.Frequency;
	
	% Define systematic injection errors
	SC.SIG.staticInjectionZ(1) = injErrorFactor * 500E-6;
	SC.SIG.staticInjectionZ(2) = injErrorFactor * 200E-6;
	SC.SIG.staticInjectionZ(3) = injErrorFactor * 500E-6;
	SC.SIG.staticInjectionZ(4) = injErrorFactor * 200E-6;
	SC.SIG.staticInjectionZ(5) = injErrorFactor * 1E-3;
	SC.SIG.staticInjectionZ(6) = injErrorFactor * 0;
	
	
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Circumference uncertainty
	SC.SIG.Circumference = circError;
	
	
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Percentage of partcles which can be lost while still getting BPM reading
	SC.BPM.beamLostAt    = 0.6;

end
