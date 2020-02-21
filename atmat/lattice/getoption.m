function [optval,newargs] = getoption(args,optname,defval)
%getoption - Extract a keyword argument from the input arguments
%
%  optval=getoption(args,optname)
%    Extract a keyword argument, in the form of a pair "name,value" from
%    input arguments (typically from varargin).
%	 Return the value of the desired option from the argument list and
%	 send an exception if it is absent. Option names are case insensitive
%
%  optval=getoption(args,optname,optdefault)
%	return a default value if the option is absent
%
%  [optval,newargs]=getoption(...)
%    return the remaining arguments after removing the processed ones
%
%  INPUTS
%  1. args       - argument list (cell array or structure)
%  2. optname    - name of the desired option in the form of a pair
%                 "name,value" in argument input
%  3. optdefault - default value for the option
%
%  OUTPUTS
%  1. optval  - default value if the option is absent
%  2. newargs - Remaining arguments after removing the processed ones
%
%  EXAMPLES
%  1.
%   function testfunc(varargin)
%
%     [optflag,args]=getflag(varargin,'option');     % Extract an optional flag
%     [range,args]=getoption(args,'Range', 1:10);	% Extract a keyword argument
%     [width, height]=getargs(args,{210,297});       % Extract positional arguments
%
%See also getflag, getargs

if iscell(args)
    ok=[strcmpi(optname,args(1:end-1)) false];  %option name cannot be the last argument
    if any(ok)
        okval=circshift(ok,[0,1]);
        defval=args{find(okval,1,'last')};
        args(ok|okval)=[];        
    end
elseif isstruct(args)
    if isfield(args,optname)
        defval=args.(optname);
        args=rmfield(args,optname);
    end
end

newargs = args;

try
    optval=defval;
catch       % Dould be 'MATLAB:minrhs'
    error('getoption:missing','Option "%s" is missing',optname);
end
end
