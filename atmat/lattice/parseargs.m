function varargout = parseargs(default_values,args)
%  parseargs - Check and expands optional argument lists
%
%  INPUTS
%  1. default_values - Default value is not put in input argument
%  2. args           - optional argument
%
%  OUTPUTS
%  1. ARGOUT - PARSEARGS(DEFAULT_VALUES,ARGIN)
%  2. [ARG1,ARG2,...]=PARSEARGS(DEFAULT_VALUES,ARSIN)

na=min(length(default_values),length(args));
ok=~cellfun(@(arg) isempty(arg)&&isnumeric(arg),args(1:na));
default_values(ok)=args(ok);
if nargout==length(default_values)
    varargout=default_values;
else
    varargout{1}=default_values;
end
end
