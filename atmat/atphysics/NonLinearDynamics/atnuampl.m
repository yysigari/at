function varargout=atnuampl(ring,ampl,xz,varargin)
% atnuampl - computes/plots tune shift with transvserse amplitudes
%
% [NUX,NUZ]=ATNUAMPL(RING,AMPLITUDE)
% Computes tunes for the specified horizontal amplitudes
% [NUX,NUZ]=ATNUAMPL(RING,AMPLITUDE,1)
%	Computes tunes for the specified vertical amplitudes
% [NUX,NUZ]=ATNUAMPL(RING,AMPLITUDE,3)
%
%ATNUAMPL(...)
%   Plots the computed tunes in the current axes
%
%  INPUTS
%  1. ring - Ring Structure
%  2. ampl - Scalar amplitude
%  3. xz   - plotting vs x^2, px^2, z^2, pz^2
%  4. vararin - Closed orbit
%
%  OPTIONAL INPUTS  ATNUAMPL(...,Name,Value)
%   Uses additional options specified by one or more Name,Value pairs.
%   Possible values are:
%       nturns: specify the number of turns for tracking (default 256)
%       linear: horizontal axis in plot
%               1: linear
%               2: quadratic
%       method: specify the method for tune determination
%               1: Highest peak in fft
%               2: Interpolation on fft results
%               3: Windowing + interpolation (default)
%               4: NAFF
%   Other options are transmitted to the plot function

amplitude_minimal = 10e-6; % 30 microns in both transverse plane

if nargin < 3, xz=1; end % horizontal amplitude

if ~isempty(varargin) && isnumeric(varargin{1})
    % closed orbit
    orbit=varargin{1};
    varargin(1)=[];
else % find close orbit
    warning off MATLAB:singularMatrix
    orbit=findorbit6(ring);
    warning on MATLAB:singularMatrix
    if ~all(isfinite(orbit))
        orbit=zeros(6,1);
        orbit(1:5)=findsyncorbit(ring,0);
    end
end

% optional values
[nturns,varargin] = getoption(varargin,'nturns',256); % turn number for tracking
[method,varargin] = getoption(varargin,'method',3);   % interpolation method 
[linear,varargin] = getoption(varargin,'linear',1);   % interpolation method 

[~,nbper]=atenergy(ring); % get number of periods
[lindata,fractune0]=atlinopt(ring,0,1:length(ring)+1); % get linear optics and linear tunes
tune0=nbper*lindata(end).mu/2/pi; % get full linera tune with integer part
offs=[nbper -nbper];

siza=size(ampl); % amplitude size
nampl=prod(siza); % total number of points to track

p0=repmat(amplitude_minimal*[1;0;1;0;0;0], 1,nampl); % add minimum amplitude

% avoid tracking particles with too small amplitudes
if linear
    ik = find(abs(ampl(:)')<amplitude_minimal); 
    p0(xz,:) = ampl;
    p0(xz,ik)= amplitude_minimal*sign(p0(xz,ik));
    p0(xz, find(p0(xz,:) == 0)) = amplitude_minimal; 
else
    p0(xz,:)=max(p0(xz,:),ampl(:)');
end

p0=p0+orbit(:,ones(1,nampl));

% tracks particle over nturns
[p1, LOSS] = ringpass(ring,p0,nturns);
p1 = p1 -orbit(:,ones(1,nampl*nturns)); % retreive closed orbit to avoid 0 detection

Hamplitude = reshape(p1(1,:),nampl,nturns)';
Vamplitude = reshape(p1(3,:),nampl,nturns)';

% nan all data if particle is lost
Hamplitude(:, LOSS == 1) = nan;
Vamplitude(:, LOSS == 1) = nan;

%get the tune
tunetrack=[findtune(Hamplitude,method); findtune(Vamplitude,method)]';

% if not tune in a plane (look for particle with minimum amplitude)
[~, kmin] = min(abs(p0(xz,:)));
[~,k]=min([fractune0-tunetrack(kmin,:); 1-fractune0-tunetrack(kmin,:)]);

np=offs(k);

offset = round(tune0-np.*tunetrack(kmin,:));
tunetrack = np(ones(nampl,1),:).*tunetrack + offset(ones(nampl,1),:);

if nargout > 0
    varargout={reshape(tunetrack(:,1),siza),reshape(tunetrack(:,2),siza)};
else % plotting
    %% linear plotting
    inttunes=floor(tune0); % get integer part
    if ~linear % nonlinear amplitude
        lab={'x^2','p_x^2','z^2','p_z^2'};
        plot((ampl.*ampl)',tunetrack-inttunes(ones(nampl,1),:),'o',varargin{:});
        xlabel(lab{xz});
    else % linear amplitude
        lab={'x','p_x','z','p_z'};
        plot(ampl,tunetrack-inttunes(ones(nampl,1),:),'o',varargin{:});
        xlabel(lab{xz});
    end
    legend('\nu_x','\nu_z');
    ylabel('\nu');
    grid on
end
