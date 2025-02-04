% clear
%% 

lim=[-0.01,+0.01,-0.05,+0.05];
aper = ataperture('ap01', lim, 'AperturePass');
L1 = 0.5;  % Drift length
L2 = 1.0;  % Quadrupole length
K1 = 1.95;  % Quadrupole strength
theta = pi/12;  % Bending angle

% Define elements
D1 = atdrift('D1', L1);
QF = atquadrupole('QF', L2/10, K1);
QD = atquadrupole('QD', L2/5, -1*K1);
BEND = atsbend('BEND', L2/5, theta/5, 'PassMethod', 'BendLinearPass');
BEND2 = atsbend('BEND', L2/5, 1*theta, 'PassMethod', 'BendLinearPass');

RFC = atrfcavity('RFC', 0, 3e6, 500e6, 328);

% Define beamline
%ring = {aper, D1,  BEND,BEND,BEND,BEND,BEND,QF,QF,QF,QF,QF, ...
%        BEND2,BEND2,BEND2,QD,QD,QD,QD,QD, BEND,BEND,BEND,BEND,BEND,...
%        RFC, aper};
 % ring = {aper, D1, ...
 % BEND,BEND,BEND,BEND,BEND,D1,aper,BEND,BEND,BEND,BEND,BEND,aper, RFC};
 ring = {aper, QF,QF,QF,QF,QF,  BEND,BEND,BEND,BEND,BEND,aper,QF,QF,QF,QF,QF,...
     aper,BEND,BEND,BEND,BEND,BEND, aper, RFC};

%% 

% Initial particle coordinates
init_cond = [1e-3; 0; 1e-3; 0; 0; 0];  % (x, x', y, y', δ, z)
[rout, lossinfo] = linepass(ring, init_cond);
%% 100 particles with random initial conditions
N = 100;
init_conditions = 1e-3 * randn(6, N);

final_states = linepass(ring, init_conditions);
%% Track for Multiple Turns
num_turns = 100;
tracked_states = ringpass(ring, init_conditions, num_turns);

%% 
[twiss, tune, chrom] = atlinopt(ring, 0);
twiss;
%% 
init_coords = [-1e-3; 1e-3; 0; 0; 0; 0];  % (x = 1mm, all else 0)
init_coords = [1e-3,  0,  -1e-3;  
               0,     0,      0;  
               0,     0,      0;  
               0,     0,      0;  
               0,     0,      0;  
             0.10,  -0.1,     -0.10]; % 6D phase space for each particle

num_particles = 100;

% Generate random initial conditions (Gaussian distribution)
% x0  = 5e-3 * randn(1, num_particles);  % x (horizontal position)
% xp0 = 5e-3 * randn(1, num_particles);  % x' (horizontal angle)
% y0  = 1e-6 * randn(1, num_particles);  % y (vertical position)
% yp0 = 1e-6 * randn(1, num_particles);  % y' (vertical angle)
% dp0 = 1e-4 * randn(1, num_particles);  % δ (energy deviation)
% ct0 = 1e-6 * randn(1, num_particles);  % ct (path length deviation)

% Create initial 6D coordinates matrix
init_coords = [x0; xp0; y0; yp0; dp0; ct0];

[num_vars, num_particles] = size(init_coords);
num_elements = length(ring);

% Store trajectory for each element
trajectory = zeros(num_vars, num_elements, num_particles);

% Track element by element
for i = 1:num_elements
    [trajectory(:, i, :) ,lost]= linepass(ring(1:i), init_coords);
end
%% 
spos = findspos(ring, 1:length(ring));
figure;
hold on;
for j = 1:num_particles
    plot(spos , squeeze(trajectory(1, :, j)), '-ko', 'DisplayName', ['Particle ' num2str(j)]);
end
%legend;
% Loop through elements and plot by type
for i = 1:num_elements
    element = ring{i};
    
    % Plot Dipoles
    if isfield(element, 'BendingAngle') && element.BendingAngle ~= 0
        plot([spos(i), spos(i+1)], [0, 0], 'b', 'LineWidth', 5); % Blue for Dipoles
    end
    
    % Plot Quadrupoles
    if isfield(element, 'K') && element.K ~= 0
        plot([spos(i), spos(i+1)], [0, 0], 'r', 'LineWidth', 6); % Red for Quadrupoles
    end
    
    % Plot Sextupoles
    if isfield(element, 'PolynomB') && length(element.PolynomB) > 2
        plot([spos(i), spos(i+1)], [0, 0], 'k', 'LineWidth', 2); % Green for Sextupoles
    end
end

xlabel('Element position');
ylim([-0.03 0.03]);
xlim([0 3]);
ylabel('x [m]');
title('Particle Trajectories');
sum(lost)
grid on;
hold off;
%% 
