function [xx,zz]=atdynap(ring,nt,dpp,rfrac, nangle)
%ATDYNAP Compute the dynamic aperture along several angles
%
%[XX,ZZ] = ATDYNAP(RING,NTURNS,DPP,RFRAC)
%
%  INPUTS
%  1. XX,ZZ  - limit of the dynamic aperture (betatron amplitudes in m)
%  2. RING   - Structure for tracking
%  3. NTURNS - Number of turns
%  4. DPP    - Off-momentum value (default: 0)
%  5. RFRAC  - Resolution of the grid for checking the stability
%	     	   as a fraction of the maximum stable amplitude (default: 0.02)
%  6. nangle - Number of angles to probe. The code will use 2*nangle+1 
%              (default: 5)
%
%  OUTPUTS
%  1. xx - dynamic aperture [xx zz]
%  2. zz - dynamic aperture [xx zz]
%
%  EXAMPLE
%  1. [xx zz]= atdynap(ring,NT,0,0.02);

% search is made along 2nangle+1 angles of radius rlist
rlist=0:0.001:0.1;

% default number of angle to probe
if nargin < 5, nangle=5; end
% default radius fractional part
if nargin < 4, rfrac=0.02; end
%Default energy offset
if nargin < 3, dpp=0.0; end


% looks for closed orbit
if isnumeric(dpp)
    clorb=[findorbit4(ring,dpp);dpp;0];
else
    clorb=findorbit6(ring);
end

% generates a search grid in theta
theta = linspace(0,pi,2*nangle+3);
fprintf('***** DA estimation\n');
% Look for main axis limits
% look for maximum amplitude in positive amplitude (xp)
xpmax = ascan(ring,nt,clorb,0,rlist);
% look for maximum amplitude in vertical amplitude
zmax  = ascan(ring,nt,clorb,0.5*pi,rlist);
% look for maximum amplitude in negative amplitude (xm)
xmmax = ascan(ring,nt,clorb,pi,rlist);

% refine grid for the search for DA
% 0.5*max_amplitude to 2*max_amplitude by step of rfract*max_amplitude
slist=0.5:rfrac:2;

% intialize data
xx = nan(2*nangle+3,1);
zz = xx;

for i=1:nangle+3
    [xx(i),zz(i)]=bscan(ring,nt,clorb,...
        xpmax*cos(theta(i))*slist,zmax*sin(theta(i))*slist);
end
for i=nangle+4:2*nangle+3
    [xx(i),zz(i)]=bscan(ring,nt,clorb,...
        xmmax*cos(theta(i))*slist,zmax*sin(theta(i))*slist);
end

%subfunction sections
function rmax=ascan(ring,nt,clorb,theta,rlist)
% ascan - searches for maximum radius value along a radius line of angle theta
%
%  INPUTS
%  1. ring  - Ring structure
%  2. nt    - number of turns for tracking 
%  3. clorb - Closed orbit
%  4. theta - Angle line to make the search
%  5. rlist - Vector of radius
%
%  OUTPUTS
%  1. rmax  - maximum amplitude

for radius=rlist
    rin=clorb+[radius*cos(theta);0;radius*sin(theta);0;0;0];
    [dummy,lost]=ringpass(ring,rin,nt,'KeepLattice'); %#ok<ASGLU>
    if lost, break; end
    rmax=radius;
end
fprintf('theta: %8.3f rad, rmax: %8.3f mm\n',theta, rmax*1e3);

function [xmax,zmax]=bscan(ring,nt,clorb,xlist,zlist)
% bscan - searches for maximum amplitudes along a radius line of angle theta
%
%  INPUTS
%  1. ring  - Ring structure
%  2. nt    - number of turns for tracking 
%  3. clorb - Closed orbit
%  4. xlist - Angle line to make the search
%  5. zlist - Vector of radius
%
%  OUTPUTS
%  1. xmax  - maximum horizontal amplitude
%  2. zmax  - maximum vertical amplitude
%
%  NOTES
%  1. A 10 um transveres amplitude is forced for tracking to get the full
%  4D/6D dynamics

% initialize data
xmax = 0.0;
zmax = 0.0;

%minimum tranverse amplitudes
rin0 = 10*[1e-6; 0; 1e-6; 0; 0; 0];

fprintf('***** DA computation\n');

% loop over the DA grid
for i=1:length(xlist)
    rin=clorb+[xlist(i);0;zlist(i);0;0;0]+rin0;
    [dummy,lost]=ringpass(ring,rin,nt,'KeepLattice'); %#ok<ASGLU>
    if lost, break; end
    xmax=xlist(i);
    zmax=zlist(i);
end
fprintf('xmax: %8.3f mm, zmax: %8.3f mm\n\n',xmax*1e3,zmax*1e3);
