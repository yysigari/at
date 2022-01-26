%Touschek Life time for clsat lattice design
%load the file Yclsat.m with an rf cavity
Yclsat

%% define relevant positions for evaluation of momentum aperture and LT
% this positions are default selection in the TouschekPiwinskiLifeTime.m
% function
positions=findcells(THERING,'Length');
L=getcellstruct(THERING,'Length',positions);
positions=positions(L>0);
