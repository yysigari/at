cd 'home/yousefy/Documents/at'

%-- 2022-12-21, 12:58 --%
% find where mml director is in your drive...
addpath( 'MML/mml')
addpath('CLS_collab')
addpath('atmat')

cd mml
setpathmml % select CLS from gui, maybe can use setpathcls instead, no gui needed
%% 
order= 15;
XTUNE= [0.18,0.27];
YTUNE= [0.27,0.38];
% data from EPICS when beam is dumped due to change in tune
xnu = [  ];
%-- 2022-12-21, 16:58 --> FIX THE LIMITS ON X AND Y AXIS%

%% 
figure(101)
tunespaceplot(XTUNE,YTUNE, order)
hold on
% read data from EPICS and put it here.
plot(0.19997,0.27611,'kx')
plot(0.24255,0.29974,'kx')
plot(0.21705,0.28098,'kx')


%% % no beam
plot(0.18645,0.35357,'rx')
plot(0.26257,0.30517,'rx')
plot(0.18273,0.26343,'rx')
plot(0.21473,0.26637,'rx')

plot(0.18645,0.35357,'rx')
plot(0.26257,0.30517,'rx')
plot(0.18273,0.26343,'rx')
plot(0.21473,0.26637,'rx')

