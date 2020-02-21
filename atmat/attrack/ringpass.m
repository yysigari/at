function [ROUT, varargout] = ringpass(ring, RIN, NTURNS, varargin)
%ringpass - tracks particles through each element of the cell array ring
%  calling the element-specific tracking function specified in the
%  ring{i}.PassMethod field.
%
%  ROUT=ringpass(ring,RIN,NTURNS) tracks particle(s) with initial
%    condition(s) RIN for NTURNS turns
%
%  [ROUT, LOST]=ringpass(...)
%    Returns additionally an information on lost particles
%
%  [ROUT, LOST, LASTTURN]=ringpass(...)
%
%  [ROUT, LOSS, NTURNS, LOSSINFO]=ringpass(...,'nhist',NHIST,...)
%
%  ROUT = ringpass(...,'KeepLattice') Tracking with the 'KeepLattice' flag is
%     more efficient because it reuses persistent data structures stored in
%     memory in previous calls to ringpass.
%
%  ROUT=ringpass(...,'reuse') is kept for compatibilty with previous
%      versions. It has no effect.
%  
%  ROUT=ringpass(...,PREFUNC)
%  ROUT=ringpass(...,PREFUNC,POSTFUNC)
%  ROUT=ringpass(...,function_handle.empty,POSTFUNC)
%     PREFUNC and POSTFUNC are function handles, PREFUNC is called
%     immediately before tracking each element, POSTFUNC is called
%     immediately after each element. Functions are called as:
%       ROUT=FUNC(ELEMENT, RIN, NTURN, NELEMENT) 
%       and are allowed to modify the particle coordinates
%  
%  ROUT=ringpass(...,'Silent') does not output the particle coordinates at
%    each turn but only at the end of the tracking

%
%  INPUTS
%  1. ring     - AT lattice
%  2. RIN      - 6xN matrix: input coordinates of N particles
%  3. NTURNS   - Number of turns to perform (default: 1)
%
%  OPTIONAL
%  NHIST       - number elements before the loss to be traced (default: 1)
%  KeepLattice - Tracking with the 'KeepLattice' flag is more efficient because it reuses persistent data structures stored in
%                memory in previous calls to ringpass.
%
%	!!! In order to use this option, ringpass must first be called
%	without the 'KeepLattice' flag. It then assumes that the elements in ring
%	DO NOT CHANGE between calls. Otherwise, ringpass  must be called again
%   without 'KeepLattice'.
%
%   'reuse'    - no effect, kept for backwards compatibility
%   'Silent'   - not output the particle coordinates at
%                each turn but only at the end of the tracking
%
%  OUTPUTS
%  1. ROUT     - 6x(N*NTURNS) matrix: output coordinates of N particles at
%               the exit of each turn
%  2. LOST     - 1xN logical vector, indicating lost particles
%                If only one output is given, loss information is saved in
%                global variable LOSSFLAG
%  3. LASTTURN  - 1xN vector, last turn when loss occured
%  4. LOSSINFO	- 1x1 structure with the following fields:
%                 lost                 1xN logical vector, indicating lost particles
%                 turn                 1xN vector, turn number where the particle is lost
%                 element              1xN vector, element number where the particle is lost
%                 coordinates_at_loss  6xN array, coordinates at the exit of
%                                      the element where the particle is lost
%                                      (sixth coordinate is inf if particle is lost in a physical aperture)
%                 coordinates          6xNxNHIST array, coordinates at the entrance of the
%                                      NHIST elements before the loss
%
% See Also linepass, atpass

%%

% Check input arguments
if size(RIN,1)~=6
    error('Matrix of initial conditions, the second argument, must have 6 rows');
end

if nargin < 3
    NTURNS = 1;
end

% parsing input argument (flags)
[KEEPLATTICEFLAG,args] = getflag(varargin, 'KeepLattice');
[~,args]               = getflag(args,'reuse');	%#ok<ASGLU> % Kept for compatibility and ignored
[SILENTFLAG,args]      = getflag(args, 'silent');
funcargs               = cellfun(@(arg) isa(arg,'function_handle'), args);
nhist                  = getoption(struct(args{~funcargs}), 'nhist',1);

% Boolean
NEWLATTICE = double(~KEEPLATTICEFLAG);

if SILENTFLAG
    refpts=[]; % Not output the particle coordinates
else
    refpts = length(ring)+1; %otherwise output after each turn
end

%parsing input arguments
[prefunc,postfunc] = parseargs({function_handle.empty,function_handle.empty},...
    args(funcargs));

try
    [ROUT,lossinfo] = atpass(ring, RIN, NEWLATTICE, NTURNS, refpts, prefunc, postfunc, nhist);    
    if nargout>1
        if nargout>3, varargout{3} = lossinfo; end
        if nargout>2, varargout{2} = lossinfo.turn; end
        varargout{1} = lossinfo.lost;
    else % if no output arguments - create LOSSFLAG, for backward compatibility with AT 1.2
        evalin('base','clear LOSSFLAG');
        evalin('base','global LOSSFLAG');
        assignin('base','LOSSFLAG',lossinfo.lost);
    end
catch err
    if strcmp(err.identifier,'MATLAB:unassignedOutputs')
        error('Atpass:obsolete',['ringpass is now expecting 2 output arguments from atpass.\n',...
        'You may need to call "atmexall" to install the new version']);
    else
        rethrow(err)
    end
end
end
