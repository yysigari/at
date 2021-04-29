%% Start correction chain

[CUR,ERROR] = SCfeedbackFirstTurn(SC,Minv1,'verbose',1);
if ~ERROR; SC=CUR; else; return; end
%% Switch in 2-turn mode and get full 2-turn transmission by correcting the 
%first three BPMs of the second turn to the corresponding readings in the
%first turn.
SC.INJ.nTurns = 2;

[CUR,ERROR] = SCfeedbackStitch(SC,Minv2,...
	'nBPMs',3,...
	'maxsteps',20,...
	'verbose',1);
if ~ERROR; SC=CUR; else; return; end
%% Run trajectory feedback on 2-turn readings. Then create a period 1 orbit 
%by matching the second turn BPM readings to the first turn.
[CUR,ERROR] = SCfeedbackRun(SC,Minv2,...
	'target',300E-6,...
	'maxsteps',30,...
	'eps',eps,...
	'verbose',1);
if ~ERROR; SC=CUR; else; return; end

[CUR,ERROR] = SCfeedbackBalance(SC,Minv2,...
	'maxsteps',32,...
	'eps',eps,...
	'verbose',1);
if ~ERROR; SC=CUR; else; return; end

%% In the following loop the sextupole magnets are ramped up in 5 steps and
% feedback is applied after each step.
for S = linspace(0.1,1,5)

	SC = SCsetMags2SetPoints(SC,sextOrds,2,3,S,...
		'method','rel');

	[CUR,ERROR] = SCfeedbackBalance(SC,Minv2,...
		'maxsteps',10,...
		'eps',eps,...
		'verbose',1);

	if ~ERROR; SC=CUR; end
end
%% Switch off plotting every beam, switch the cavity on and plot 
%initial phase space.
plotFunctionFlag = 0;

SC.RING = SCcronoff(SC.RING,'cavityon');

SCplotPhaseSpace(SC,...
	'nParticles',10,...
	'nTurns',100);
%% The following block performs an rf phase and frequency correction in a 
%loop and applies the corresponding correction step if no error occured.
for nIter=1:2
	% Perform RF phase correction.
	[deltaPhi,ERROR] = SCsynchPhaseCorrection(SC,...
		'nTurns',5,...      % Number of turns
		'nSteps',25,...     % Number of phase steps
		'plotResults',1,... % Final results are plotted
		'verbose',1);       % Print results
	if ERROR; error('Phase correction crashed');end

	% Apply phase correction
	SC = SCsetCavs2SetPoints(SC,SC.ORD.Cavity,...
			'TimeLag',deltaPhi,...
			'add');

	% Perform RF frequency correction.
	[deltaF,ERROR] = SCsynchEnergyCorrection(SC,...
		'range',40E3*[-1 1],... % Frequency range [kHz]
		'nTurns',20,...         % Number of turns
		'nSteps',15,...         % Number of frequency steps
		'plotResults',1,...     % Final results are plotted
		'verbose',1);           % Print results

	% Apply frequency correction
	if ~ERROR; SC = SCsetCavs2SetPoints(SC,SC.ORD.Cavity,...
			'Frequency',deltaF,...
			'add');
	else; return; end
end
%% Plot final phase space and check if beam capture is achieved.
SCplotPhaseSpace(SC,'nParticles',10,'nTurns',1000);

[maxTurns,lostCount,ERROR] = SCgetBeamTransmission(SC,...
	'nParticles',100,...
	'nTurns',10,...
	'verbose',true);
if ERROR;return;end
%% Beam capture achieved, switch to orbit mode for tracking. 
%Calculate the orbit response matrix and the dispersion. 
%Assume a beam based alignment procedure reduces the BPM offsets to 50um
% rms w.r.t. their neighbouring QF/QD magnets.
SC.INJ.trackMode = 'ORB';

MCO = SCgetModelRM(SC,SC.ORD.BPM,SC.ORD.CM,'trackMode','ORB');
eta = SCgetModelDispersion(SC,SC.ORD.BPM,SC.ORD.Cavity);

quadOrds = repmat(SCgetOrds(SC.RING,'QF|QD'),2,1);
SC       = SCpseudoBBA(SC,SC.ORD.BPM,quadOrds,50E-6);
%% Run orbit feedback in a loop with decreasing Tikhonov regularization 
%parameter alpha until no further improvment is achieved. 
%Dispersion [m/Hz] is included and scaled by a factor of 1E8 to get the 
%same magnitude as the orbit response [m/rad] matrix.
for	alpha = 10:-1:1
	% Get pseudo inverse
	MinvCO = SCgetPinv([MCO 1E8*eta],'alpha',alpha);

	% Run feedback
	[CUR,ERROR] = SCfeedbackRun(SC,MinvCO,...
		'target',0,...
		'maxsteps',50,...
		'scaleDisp',1E8,...
		'verbose',1);
	if ERROR;break;end

	% Calculate intial and final rms BPM reading.
	B0rms = sqrt(mean(SCgetBPMreading(SC ).^2,2));
	Brms  = sqrt(mean(SCgetBPMreading(CUR).^2,2));

	% Break if orbit feedback did not result in a smaller rms BPM reading
	if mean(B0rms)<mean(Brms);break;end

	% Accept new machine
	SC = CUR;
end



