% this example of calculating linear optics at e reference point

M =linopt(THERING, 0, findcells(THERING, 'FamName' , 'SMbeam'));

%LinData = 
%
%  struct with fields:

 %     ElemIndex: 633
  %         SPos: 128.1600
   % ClosedOrbit: [4×1 double]
    % Dispersion: [4×1 double]
    %       M44: [4×4 double]
     %     gamma: 0.9999
     %        C: [2×2 double]
      %        A: [2×2 double]
       %       B: [2×2 double]
       %    beta: [9.1314 2.6227]
        %  alpha: [0.0013 -0.0036]
         %    mu: [4.1853 1.3330]
