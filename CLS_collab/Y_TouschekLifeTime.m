%Touschek Life time for clsat lattice design
%load the file Yclsat.m with an rf cavity

global GLOBVAL
Yclsat

%% define relevant positions for evaluation of momentum aperture and LT
% this positions are default selection in the TouschekPiwinskiLifeTime.m
% function
positions=findcells(THERING,'Length');
L=getcellstruct(THERING,'Length',positions);
positions=positions(L>0);
%% get energy sperad and bunch length
%switches RF and radiation on
RING=atradon(THERING);
[l,a]=atx(RING,0,1);
%a.espread;
%a.blength;

nturns=50; %% put 500! 5 is only for speed reason in the test

%% get momentum aperture 
%(this or any better function)
[dppM,dppP]=MomAperture_allRing(RING,positions,nturns);%

% current per bunch, can be get from Lightsource.ca website usually 190 mA
Ib=0.2; % mA

%% evaluate Life Time

% basic mode, constant momentum aperture
TL=TouschekPiwinskiLifeTime(RING,0.03,Ib)/3600;
disp(' basic mode, constant momentum aperture: ')
disp(TL)
% one sided momentum aperture.
TL=TouschekPiwinskiLifeTime(RING,dppM,Ib)/3600;
disp('one sided momentum aperture :')      
disp(TL)      
% two sided momentum aperture: 1/Ttot=1/2(1/Tup+1/Tdown)
TL=TouschekPiwinskiLifeTime(RING,[dppM dppP],Ib)/3600;
disp('two sided momentum aperture: 1/Ttot=1/2(1/Tup+1/Tdown) :')      
disp(TL)
% input positions
TL=TouschekPiwinskiLifeTime(RING,[dppM dppP],Ib,positions)/3600;
disp('input positions :')      
disp(TL)
% input positions and emittances
TL=TouschekPiwinskiLifeTime(RING,[dppM dppP],Ib,positions,10e-9,10e-12)/3600;
disp('input positions and emittances :')      
disp(TL)
% input positions and emittances and integration method
TL=TouschekPiwinskiLifeTime(RING,[dppM dppP],Ib,positions,10e-9,10e-12,'quad')/3600;
disp('input positions and emittances and integration method :')      
disp(TL)
% input positions and emittances and integration method and bumchelenght
% and energy spread
TL=TouschekPiwinskiLifeTime(RING,[dppM dppP],Ib,positions,10e-9,10e-12,'quad',a.espread,a.blength)/3600;
disp('input positions and emittances and integration method and bunch lenght and energy spread :')      
disp(TL)

