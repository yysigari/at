function atpath(varargin)
%ATPATH Adds the AT directories to the MATLAB search path
    
ATROOT = fileparts(mfilename('fullpath'));
ATINTEGRATORS = fullfile(fileparts(ATROOT),'atintegrators');
MACHINEDATA = fullfile(fileparts(ATROOT),'machine_data');
M2HTML = fullfile(fileparts(ATROOT),'docs', 'm2html');
disp(ATROOT)
addpath(genpath(ATROOT));
disp(ATINTEGRATORS)
addpath(genpath(ATINTEGRATORS));
disp(MACHINEDATA)
addpath(genpath(MACHINEDATA));
disp(M2HTML)
addpath(genpath(M2HTML));