%% Set paths 
%mainDir = 'V:\at\at-master\sc';
%addpath(mainDir);
%addpath(fullfile(mainDir,'applications\CLS'));
%addpath('V:\at\at-master')
%atpath()

%% Initialize
clear
global plotFunctionFlag
global THERING
% Load lattice
RING = CLS;

% Initialize toolbox
SC = SCinit(RING);

% Register CLS
SC = register_CLS(SC);

% Define apertures
SC.RING = defineApertures_CLS(SC.RING);

% Get model response matrices
[RM1,RM2,MidealCO,Bref1,Bref2] = SCloadSaveMideal(SC,'CLS','overwrite',1);

% Apply errors
SC = SCapplyErrors(SC);


%% Look at lattice

% Plot lattice
SCplotLattice(SC,'sRange',[0 38])

% Plot support structure errors
SCplotSupport(SC)

%% Start the correction chain

% Enable plotting
plotFunctionFlag = 1;

% Ensure turn-by-turn tracking
SC.INJ.trackMode  = 'TBT';
SC.INJ.nParticles = 1; % Particles per shot
SC.INJ.nShots     = 1; % Shots for averaging BPM readings
SC.INJ.nTurns     = 1; % Number of turns

% Switch off cavity but ensure radiation is included
SC.RING = SCcronoff(SC.RING,'cavityoff','radiationon');

% Switch off sextupoles
sextOrds = SCgetOrds(SC.RING,'SF|SD|SHH$|SHH2');
SC = SCsetMags2SetPoints(SC,sextOrds,2,3,0,'method','abs');


% Define noise level
eps = 1E-4;
		
% Get pseudo inverse
Minv1 = SCgetPinv(RM1,'alpha',100);

for FOO=0 % FAKE Loop. Just something to ``break'' out of if there is a fatal error.

	% First turn threading
	[CUR,ERROR] = SCfeedbackFirstTurn(SC,Minv1,'wiggleAfter',10,'verbose',1);
	if ~ERROR; SC=CUR; else; break; end
	
	% First turn feedback
	[CUR,ERROR] = SCfeedbackRun(SC,Minv1,'target',300E-6,'maxsteps',30,'eps',eps,'verbose',1);
	if ~ERROR; SC=CUR; else; break; end

	SC.INJ.nTurns = 2;
	
	% Get pseudo inverse
	Minv2 = SCgetPinv(RM2,'alpha',100);
	
	% Stitch second turn
	for nBPM=[15 10 5 3]
		[CUR,ERROR] = SCfeedbackStitch( SC,Minv2,'nBPMs',nBPM,'maxsteps',200,'verbose',1);
		if ~ERROR; break; end
	end
	if ~ERROR; SC=CUR; else; break; end
	
	% 2-turn feedback
	[CUR,ERROR] = SCfeedbackRun(SC,Minv2,'target',300E-6,'maxsteps',100,'eps',eps,'verbose',1);
	if ~ERROR; SC=CUR; else; break; end
	
	% Periodicity 2 orbit
	[CUR,ERROR] = SCfeedbackBalance(SC,Minv2,'maxsteps',32,'eps',eps,'verbose',1);
	if ~ERROR; SC=CUR; else; break; end
	
	

end
%%
