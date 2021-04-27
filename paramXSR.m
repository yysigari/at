%calculate beam data in yclsat
clear all
Yclsat

BeamData=atx(THERING,0,1:length(THERING));
Nxsr=findcells(THERING,'FamName','XSRbeam');
BeamData(Nxsr)