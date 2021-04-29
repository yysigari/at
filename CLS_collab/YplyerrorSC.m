%% apply an error set based on the previolusly defined uncertainties.
%The misalignments are plotted.
SC = SCapplyErrors(SC);

SCplotSupport(SC);
%% Setup correction chain

SC.RING = SCcronoff(SC.RING,'cavityoff');

sextOrds = SCgetOrds(SC.RING,'SF|SD');
SC = SCsetMags2SetPoints(SC,sextOrds,2,3,0,...
	'method','abs');

RM1 = SCgetModelRM(SC,SC.ORD.BPM,SC.ORD.CM,'nTurns',1);
RM2 = SCgetModelRM(SC,SC.ORD.BPM,SC.ORD.CM,'nTurns',2);

Minv1 = SCgetPinv(RM1,'alpha',50);
Minv2 = SCgetPinv(RM2,'alpha',50);
%% we define the number of particles per bunch, shots for averaging the BPM 
%reading and number of turns and ensure turn-by-turn tracking mode. 
%The noise level eps defines a stopping criteria for the feedback. 
%Finally, we switch on the global plot falg and plot uncorrected 
%beam trajectory.
SC.INJ.nParticles = 1;
SC.INJ.nTurns     = 1;
SC.INJ.nShots     = 1;
SC.INJ.trackMode  = 'TBT';

eps   = 1E-4; % Noise level

plotFunctionFlag = 0;

SCgetBPMreading(SC);
%% 
