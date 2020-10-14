function [figs] = jobAttributes(jobs, jobIDs, dagFlag)
%JOBATTRIBUTES Summary of this function goes here
%   Detailed explanation goes here

%% nJobs vs. time
% minTime = inf;
% maxTime = -1;
% for i = 1:size(jobIDs,2)
%     if jobIDs(i) ~= -1
%         minTime = min(minTime, min(jobs{i}.Nodes.startTime));
%         maxTime = max(maxTime, max(jobs{i}.Nodes.endTime));
%     end
% end
% x = floor(minTime/3600):floor(maxTime/3600);
% y = zeros(size(x));
% yDag = zeros(size(x));
% for i = 1:size(jobIDs,2)
%     if jobIDs(i) ~= -1
%         y((floor(min(jobs{i}.Nodes.startTime)/3600)-floor(minTime/3600)+1):(floor(max(jobs{i}.Nodes.endTime)/3600)-floor(minTime/3600)+1)) = ...
%             y((floor(min(jobs{i}.Nodes.startTime)/3600)-floor(minTime/3600)+1):(floor(max(jobs{i}.Nodes.endTime)/3600)-floor(minTime/3600)+1)) + 1;
%         if dagFlag(i) == 1 && size(jobs{i}.Nodes,1) > 1
%             yDag((floor(min(jobs{i}.Nodes.startTime)/3600)-floor(minTime/3600)+1):(floor(max(jobs{i}.Nodes.endTime)/3600)-floor(minTime/3600)+1)) = ...
%             yDag((floor(min(jobs{i}.Nodes.startTime)/3600)-floor(minTime/3600)+1):(floor(max(jobs{i}.Nodes.endTime)/3600)-floor(minTime/3600)+1)) + 1;
%         end
%     end
% end
% fig1 = figure(1); hold on;
% plot(x,y);
% plot(x,yDag);

%% Tall/fat vs. nTask
toPlot = [];
for i = 1:size(jobIDs,2)
    if jobIDs(i) ~= -1 && dagFlag(i) == 1 && size(jobs{i}.Nodes,1) > 1
        dist = distances(jobs{i},'Method','unweighted');
        dist = dist(:);
        tall = max(dist(~isinf(dist)));
        toPlot = [toPlot,[size(jobs{i}.Nodes,1);tall]];
    end
end
fig2 = figure(2);
plot(toPlot(1,:), toPlot(2,:), '.')

% toPlot = [];
% for i = 1:size(jobIDs,2)
%     if jobIDs(i) ~= -1 && dagFlag(i) == 1 && size(jobs{i}.Nodes,1) > 1
%         H = transreduction(jobs{i});
%         inDeg = indegree(H, H.Nodes.Name);
%         toPlot = [toPlot,[size(jobs{i}.Nodes,1);max(inDeg)]];
%     end
% end
% fig3 = figure(3);
% plot(toPlot(1,:), toPlot(2,:), '.')

toPlot = [];
for i = 1:size(jobIDs,2)
    if jobIDs(i) ~= -1 && dagFlag(i) == 1 && size(jobs{i}.Nodes,1) > 1
        H = transclosure(jobs{i});
        A = adjacency(H);
        A = A + A';
        A = ones(size(A))-eye(size(A))-A;
        M = ELSclique(A);
        toPlot = [toPlot, [size(jobs{i}.Nodes,1);full(max(sum(A)))]];
    end
end
fig3 = figure(3);
plot(toPlot(1,:), toPlot(2,:), '.')


figs = {fig2, fig3};
end

