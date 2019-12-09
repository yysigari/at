function [map_l,map_h]=MomAperture_allRing(THERING, points, varargin)
% MomAperture_allRing - Computes the Longitudinal Momentum Acceptance (LMA)
% of a storage ring
%
%  INPUTS
%  1. THERING - Ring structure
%  2. points  - location where to compute the LMA
%  Optional
%  3. nturns  - number of turn for tracking Default value: 100
%
%  OUPUTS
%  1. map_l - lower momentum acceptance
%  2. map_h - upper momentum acceptance
%
%% See Also momentum_aperture_at

% all Ring momentum aperture
%points=1:10:length(THERING);

% Extra arguments
if numel(varargin)>0
    nturns=varargin{1};
else
    nturns=100;
end

% init variable
map_h=zeros(length(points),1);
map_l=zeros(length(points),1);

deltalim   = +0.1; % maximum energy for search
initcoord  = [1e-6 1e-6]; % initial coordinates for horizontal and vertical amplitude
deltastart = 0; %starting energy offset for search
precdelta  = 0;
deltastepsize = +0.01; % crude energy step for 1st part of the search
splits     = 1; %split number
split_step_divisor =  10;% reduced factor in energy offset for each split

for i=1:length(points)
   % disp([i length(points) i/length(points)*100])
    %cycle ring: starting point at the location where the Touschek event
    %occurs
     THERING_cycl = [THERING(points(i):end); THERING(1:points(i)-1)]';
        try             
            map_h(i)=momentum_aperture_at(THERING_cycl,deltalim, initcoord, ...
                deltastart, precdelta, deltastepsize, splits, split_step_divisor,nturns);
        catch
            map_h(i)=0;
        end
        
        try
            map_l(i)=momentum_aperture_at(THERING_cycl,-deltalim, initcoord ...
                ,deltastart,precdelta,-deltastepsize, splits, split_step_divisor ,nturns);
        catch
            map_l(i)=0;
        end     
end

return