function [map_l,map_h]=MomAperture_allRing(THERING, points, varargin)
% MomAperture_allRing - Computes the Longitudinal Momentum Acceptance (LMA)
% of a storage ring around the 6D closed orbit is radiation is ON
%
%  INPUTS
%  1. THERING - Ring structure
%  2. points  - Location where to compute the LMA
%  Optional
%  3. nturns  - Number of turns for tracking (Default value: 100)
%  4. MinAmplitudeAtRingEntrance - Minimum transverse Amplitude at the ring entrance 
%     (default: 10 microns in both transverse planes)
%
%  OUPUTS
%  1. map_l - Lower value momentum acceptance
%  2. map_h - Higher momentum acceptance
%
%  EXAMPLES
%  1. MomAperture_allRing(ring,1:10, 100)
%  2. MomAperture_allRing(ring,1:10, 100, 'MinAmplitudeAtRingEntrance', [10e-6; 30e-6])
%     for setting 10 microns in h-plane et 30 micron in V-plane 
%
%% See Also momentum_aperture_at

% all Ring momentum aperture

try
    initcoord =getoption(varargin,'MinAmplitudeAtRingEntrance');
catch
    initcoord  = 10*[1e-6, 1e-6]; % initial coordinates for horizontal and vertical amplitude at the entrance of the ring
end

% Extra arguments
if numel(varargin)>0
    nturns=varargin{1};
else
    nturns=100;
end

% init variable
map_h = zeros(length(points),1);
map_l = zeros(length(points),1);

deltalim   = +0.1; % maximum energy for search
deltastart = 0; %starting energy offset for search
precdelta  = 0;
deltastepsize = +0.01; % crude energy step for 1st part of the search
splits     = 1; %split number
split_step_divisor =  10;% reduced factor in energy offset for each split

for ik=1:length(points)
   % disp([i length(points) i/length(points)*100])
    %occurs
    % Transport the inititial amplitude
    
    CAVi = findcells(THERING,'Class','RFCavity');
    if any(CAVi) && any(strcmpi(atgetfieldvalues(THERING, CAVi, 'PassMethod'), 'CavityPass'))
        cod = findorbit6(THERING);
    else
        cod = [findorbit4(THERING,0);0;0];
    end
    
    % Propagate initial coordinate till the entrance of points(i) around
    % closed orbit. cod(6) is the synchronous phase if radiation is
    % activated
    % This condition enables to be an amplitude with is coherent along the
    % ring structure.
    Xinit = linepass(THERING(1:points(ik)-1), [initcoord(1); 0; initcoord(2); 0; 0; cod(6)]); 
    
    %cycle ring: starting point at the location where the Touschek event
    THERING_cycl = [THERING(points(ik):end); THERING(1:points(ik)-1)]';
        try             
            map_h(ik)=momentum_aperture_at(THERING_cycl,deltalim, Xinit, ...
                deltastart, precdelta, deltastepsize, splits, split_step_divisor,nturns);
        catch
            map_h(ik)=0;
        end
        
        try
            map_l(ik)=momentum_aperture_at(THERING_cycl,-deltalim, Xinit ...
                ,deltastart,precdelta,-deltastepsize, splits, split_step_divisor ,nturns);
        catch
            map_l(ik)=0;
        end     
end

return