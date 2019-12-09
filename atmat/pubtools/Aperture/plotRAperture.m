function plotdata=plotRAperture(~,ring,~,varargin) 
%PLOTRAPERTURE Plots Rectangular aperture
%function plotdata=plotAperture(lindata,ring,dpp,varargin) %#ok<INUSD>
%
% Plots x and y aperture.
% 
% use with atplot(atlattice,@plotRAperture);
%
%  See Also plotAperture, PlotERAperture, SetPhysicalAperture

apind=findcells(ring,'RApertures');

xm=getcellstruct(ring,'RApertures',apind,1);
ym=getcellstruct(ring,'RApertures',apind,3);
xp=getcellstruct(ring,'RApertures',apind,2);
yp=getcellstruct(ring,'RApertures',apind,4);

Xp=[nan(size(ring)); nan];
Xm=Xp;
Yp=Xp;
Ym=Xp;

Xp(apind)=xp;
Xm(apind)=xm;
Yp(apind)=yp;
Ym(apind)=ym;

% look for thin elements and tak minimum for nice plots
spos = findspos(ring, 1:length(ring)+1);

plotdata(1).values=[Xp Xm Yp Ym]*1e3;%
plotdata(1).labels={'x aperture','x aperture','y aperture','y aperture'};
plotdata(1).axislabel='x or y aperture [mm]';
% 
% plotdata(2).values=[Yp Ym]*1e2;%
% plotdata(2).labels={'y aperture','y aperture'};
% plotdata(2).axislabel='y aperture [cm]';
% 

end 