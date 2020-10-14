close all; clear; clc;

% addpath('matgraph');
% javaaddpath('jgrapht/lib');

%% Parse tasks to form a forest of task graphs
taskFile = '../dax/Montage_100.xml';
maxTask = inf;
verbose = 0; % 0 or 1
stat = 0; % 0 or every %stat lines

[jobs, nTask, jobIDs, dagFlag] = parseTask(taskFile, maxTask, verbose, stat);

figs = getJobAttributes({jobs}, jobIDs, dagFlag);

figure;
G = jobs;
plot(G,'layout','layered');

traceFile = 'result4';
fig = parseTrace(traceFile);