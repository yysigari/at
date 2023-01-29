addpath('CLS_collab')
addpath('atmat')
atpath()


clsat
%% number 48 in this bend array:
bend_in=findcells(THERING, 'Class','Bend');
quad_in = findcells(THERING,'Class', 'Quadrupole');
bpm_in = findcells(THERING,'FamName','BPM');
%% initial
RIN = [0; 0; 0; 0 ;1e-4; 0];

RIN0 = [1e-5; 0; 1e-6; 1e-6 ;1e-4; 1e-5];
RIN1 = [0; 1e-5; 1e-6; 1e-6 ;1e-4; 1e-5];
RIN2 = [0; 0; 10e-6; 1e-6 ;1e-4; 1e-5];
RIN3 = [5e-5; 0; 1e-6; 1e-6 ;1e-4; 1e-5];
RIN4 = [0; 0; 5e-6; 1e-6 ;1e-4; 1e-5];
RIN5 = [0; 5e-5; 1e-6; 1e-6 ;1e-4; 1e-5];
RIN6 = [10e-5; 0; 1e-6; 1e-6 ;1e-4; 1e-5];
RIN7 = [0; 10e-5; 1e-6; 1e-6 ;1e-4; 1e-5];
RIN8 = [1e-5; 1e-5; 1e-6; 1e-6 ;1e-4; 1e-5];

%% routs setting
[ROUT,~] = atpass(THERING, RIN,0, 1024,bend_in(48));

[ROUT0,~] = atpass(THERING, RIN0,1, 1024,bend_in(48));
[ROUT1,~] = atpass(THERING, RIN1,1, 1024,bend_in(48));
[ROUT2,~] = atpass(THERING, RIN2,1, 1024,bend_in(48));
[ROUT3,~] = atpass(THERING, RIN3,1, 1024,bend_in(48));
[ROUT4,~] = atpass(THERING, RIN4,1, 1024,bend_in(48));
[ROUT5,~] = atpass(THERING, RIN5,1, 1024,bend_in(48));
[ROUT6,~] = atpass(THERING, RIN6,1, 1024,bend_in(48));
[ROUT7,~] = atpass(THERING, RIN7,1, 1024,bend_in(48));
[ROUT8,~] = atpass(THERING, RIN8,1, 1024,bend_in(48));
%% plt them
figure(14)

scatter(ROUT0(3,:)*1e6,ROUT0(4,:)*1e6,25,"b",'o','filled')
hold on
%scatter(ROUT1(3,:)*1e6,ROUT1(4,:)*1e6,25,'b','o','filled')
%scatter(ROUT2(3,:)*1e6,ROUT2(4,:)*1e6,25,'b','o','filled')
%scatter(ROUT3(3,:)*1e6,ROUT3(4,:)*1e6,25,'b','o','filled')
%scatter(ROUT4(3,:)*1e6,ROUT4(4,:)*1e6,25,'b','o','filled')
%scatter(ROUT5(3,:)*1e6,ROUT5(4,:)*1e6,25,'b','o','filled')
%scatter(ROUT6(3,:)*1e6,ROUT6(4,:)*1e6,25,'b','o','filled')
%scatter(ROUT(3,:)*1e6,ROUT(4,:)*1e6,25,'b','o','filled')
%scatter(ROUT7(3,:)*1e6,ROUT7(4,:)*1e6,25,'b','o','filled')


title('Vertical Phase Space in XSR source Point')
xlabel('Y [\mu m]')
ylabel("Y' [\mu rad]")
grid()




%% 
el = fit_ellipse(ROUT5(3,:), ROUT5(4,:));
major = el.long_axis;
minor = el.short_axis;
minor*major*pi
