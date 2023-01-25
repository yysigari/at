cd './MATLAB'
addpath('./at')
addpath('./at/atmat')
addpath('./at/CLS_collab')
addpath('./sc')
atpath()
analyzeCLS
[DA,RMAXs,thetas]=SCdynamicAperture(RING,0.01,'nturns',1024,'thetas',linspace(0,2*pi,32),'plot',1);
