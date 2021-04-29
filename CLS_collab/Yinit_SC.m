%Initialize toolbox
SC = SCinit(RING);
%% Register lattice in SC
%Identify all BPMs in lattice structure and register them including 
% uncertainties of the calibration factor, offset, roll, turn-by-turn
% noise and stored beam noise.

ords = SCgetOrds(SC.RING,'BPM');
SC = SCregisterBPMs(SC,ords,...
	'CalError',5E-2 * [1 1],... % relative
	'Offset',500E-6 * [1 1],... % [m]
	'Noise',10E-6 * [1 1],...   % [m]
	'NoiseCO',1E-6 * [1 1],...  % [m]
	'Roll',1E-3);               % [rad]
%% Identify the QFs in the lattice structure and register them as 
%horizontal  corrector magnets with a limit of 1mrad and include 
%uncertainties of the CM calibration factor,quadrupole strength error, 
%magnet offset and magnet roll.
ords = SCgetOrds(SC.RING,'QF');
SC = SCregisterMagnets(SC,ords,...
	'HCM',1E-3,...                    % [rad]
	'CalErrorB',[5E-2 1E-3],...       % relative
	'MagnetOffset',200E-6 * [1 1],... % x and y, [m]
	'MagnetRoll',200E-6);             % [rad]
%% Identify the QDs in the lattice structure and register them as 
%vertical corrector magnet
ords = SCgetOrds(SC.RING,'QD');
SC = SCregisterMagnets(SC,ords,...
	'VCM',1E-3,...                    % [rad]
	'CalErrorA',[5E-2 0],...          % relative
	'CalErrorB',[0 1E-3],...          % relative
	'MagnetOffset',200E-6 * [1 1],... % x and y, [m]
	'MagnetRoll',200E-6);             % [rad]
%% Identify the BENDs in the lattice structure 
ords = SCgetOrds(SC.RING,'BEND');
SC = SCregisterMagnets(SC,ords,...
	'BendingAngle',1E-3,...           % relative
	'MagnetOffset',200E-6 * [1 1],... % x and y, [m]
	'MagnetRoll',200E-6);             % [rad]
%% Identify the SF&SD in the lattice structure and register them as skew 
%  quadrupole
ords = SCgetOrds(SC.RING,'SF|SD');
SC = SCregisterMagnets(SC,ords,...
	'SkewQuad',0.1,...                 % [1/m]
	'CalErrorA',[0 1E-3 0],...         % relative
	'CalErrorB',[0 0 1E-3],...         % relative
	'MagnetOffset',200E-6 * [1 1],...  % x and y, [m]
	'MagnetRoll',200E-6);              % [rad]
%% %Identify the cavity in the lattice structure 
ords = findcells(SC.RING,'Frequency');
SC = SCregisterCAVs(SC,ords,...
	'FrequencyOffset',5E3,... % [Hz]
	'VoltageOffset',5E3,...   % [V]
	'TimeLagOffset',0.5);     % [m]
%% Identify girder start and end ordinates in lattice structure 
ords = [SCgetOrds(SC.RING,'GirderStart');SCgetOrds(SC.RING,'GirderEnd')];
SC = SCregisterSupport(SC,...
	'Girder',ords,...
	'Offset',100E-6 * [1 1],... % x and y, [m]
	'Roll',200E-6);             % [rad]
%% Identify section start and end ordinates in lattice structure
ords = [SCgetOrds(SC.RING,'SectionStart');SCgetOrds(SC.RING,'SectionEnd')];
SC = SCregisterSupport(SC,...
	'Section',ords,...
	'Offset',100E-6 * [1 1]); % x and y, [m]
%% 6x6 beam sigma matrix, random shot-to-shot injection variation 
%and the uncertainty of the systematic injection errors
SC.INJ.beamSize = diag([200E-6, 100E-6, 100E-6, 50E-6, 1E-3, 1E-4].^2);

SC.SIG.randomInjectionZ = [1E-4; 1E-5; 1E-4; 1E-5; 1E-4; 1E-4]; % [m; rad; m; rad; rel.; m]
SC.SIG.staticInjectionZ = [1E-3; 1E-4; 1E-3; 1E-4; 1E-3; 1E-3]; % [m; rad; m; rad; rel.; m]

SC.SIG.Circumference = 2E-4; % relative
SC.BPM.beamLostAt    = 0.6;  % relative
%% Define lattice apertures


for ord=SCgetOrds(SC.RING,'Drift')
	SC.RING{ord}.EApertures = 13E-3 * [1 1]; % [m]
end

for ord=SCgetOrds(SC.RING,'QF|QD|BEND|SF|SD')
	SC.RING{ord}.EApertures = 10E-3 * [1 1]; % [m]
end

SC.RING{SC.ORD.Magnet(50)}.EApertures = [6E-3 3E-3]; % [m]
%% Check registration
SCsanityCheck(SC);

SCplotLattice(SC,'nSectors',10);