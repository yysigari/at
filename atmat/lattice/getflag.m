function [flag,arglist] = getflag(arglist,optname)
%  getflag - check the presence of a flag in an argument list
%
%  OPTION=GETFLAG(opts,optname)
%    Return a logical value indicating the presence of the flag name in the
%    argument list. Flag names are case insensitive.
%
% [OPTION,NEWARGS]=GETFLAG(ARGS,OPTNAME)
%           Returns the argument list after removing the processed flag
%
%  INPUTS
%  1. opts    - Argument list (cell array)
%  2. optname - Name of the desired option (string)
%
%  OUPUTS
%  1. flag - logical value indicating the presence of the flag name in the
%            argument list.
%  2. opts - argument list after removing the processed flag
%
%  EXAMPLES
%
%  function testfunc(varargin)
%
%   [optflag,args]=getflag(varargin,'option');  % Extract an optional flag
%   [range,args]=getoption(args,'Range', 1:10);	% Extract a keyword argument
%   [width, height]=getargs(args,{210,297});    % Extract positional arguments
%
% See also GETOPTION, GETARGS

%% Written by ESRF team 

ok      = strcmpi(optname,arglist);
flag    = any(ok);
arglist = arglist(~ok);

end

