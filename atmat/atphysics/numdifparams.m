%NUMDIFPARAMS Global variable in AT (all caps)
% Fields in this structure are step sizes for numerical differentiation 
% used by AT functions. Functions that use numerical differentiation
% (such as FINDM44, FINDM66) first check if the global 
% structure NUMDIFPARAMS exists. Then they check if NUMDIFPARAMS
% has the field that defines the numerical differentiation step size.
% If the field is not defined in NUMDIFPARAMS the function uses
% its internal default value
% 
% EXAMPLE:
%
% >> global NUMDIFPARAMS
% >> NUMDIFPARAMS.XYStep = 1e-8;
% >> NUMDIFPARAMS.DPStep = 1e-6;
%
% Functions that use numdifparams are:
%   findm44, findm66, findelemm66, linopt, twissring, twissline,
%   tunechrom
