function [jobs, nTask, jobPool, dagFlag] = parseTask(taskPath, maxTask, verbose, stat)
%PARSETASK Parse tasks to form a forest of task graphs
%   Detailed explanation goes here

jobs = digraph;
jobPool = 1;
dagFlag = 1;
nJob = 1;

%% Add nodes
fid = fopen(taskPath, 'r');
if fid ~= -1
    nTask = 0;
    while ~feof(fid) && nTask < maxTask
        % Read a line
        lineText = fgetl(fid);
        if ischar(lineText) && strcmp(lineText(1:5), '  <ch')
            while ~strcmp(lineText, '  </child>')
                textDetail = textscan(lineText, '%s', 'delimiter', '=');
                taskID = str2num(textDetail{1}{2}(4:8));
                try
                    jobs = addnode(jobs, int2str(taskID));
                catch ME
                end
                lineText = fgetl(fid);
                if ischar(lineText) && strcmp(lineText(1:7), '    <pa')
                    textDetail = textscan(lineText, '%s', 'delimiter', '=');
                    taskID = str2num(textDetail{1}{2}(4:8));
                    try
                        jobs = addnode(jobs, int2str(taskID));
                    catch ME
                    end
                end
            end
        end
    end
    fclose(fid);
end

fid = fopen(taskPath, 'r');
if fid ~= -1
    nTask = 0;
    while ~feof(fid) && nTask < maxTask
        % Read a line
        lineText = fgetl(fid);
        if ischar(lineText) && strcmp(lineText(1:5), '  <ch')
            if ~strcmp(lineText, '  </child>')
                textDetail = textscan(lineText, '%s', 'delimiter', '=');
                childID = str2num(textDetail{1}{2}(4:8));
            end
            while ~strcmp(lineText, '  </child>')
                lineText = fgetl(fid);
                if ischar(lineText) && strcmp(lineText(1:7), '    <pa')
                    textDetail = textscan(lineText, '%s', 'delimiter', '=');
                    parentID = str2num(textDetail{1}{2}(4:8));
                    try
                        jobs = addedge(jobs, int2str(parentID), int2str(childID));
                    catch ME
                    end
                end
            end
        end
    end
    fclose(fid)
end
%         if ischar(lineText) && strcmp(lineText(1:3), '<ch')
%             if ~strcmp(lineText, '</child>')
%             taskDetail = textscan(lineText, '%s', 'delimiter', ',');
%
%             % Identify job
%             jobName = textscan(taskDetail{1}{3}, '%s', 'delimiter', '_');
%             jobID = str2double(jobName{1}{2});
%             if ~ismember(jobID, jobPool)
%                 jobPool = [jobPool, jobID];
%                 dagFlag = [dagFlag, 0];
%                 jobs{numel(jobs)+1} = digraph;
%                 nJob = nJob + 1;
%             end
%             jobIdx = find(jobPool == jobID);
%
%             % Add task
%             taskName = textscan(taskDetail{1}{1}, '%s', 'delimiter', '_');
%             if isnan(str2double(taskName{1}{1}(2))) % Non DAG task
%                 try
%                     jobs{jobIdx} = addnode(jobs{jobIdx},...
%                         table(taskName{1}(1),...
%                         str2double(taskDetail{1}{2}),...
%                         str2double(taskDetail{1}{7})-str2double(taskDetail{1}{6}),...
%                         str2double(taskDetail{1}{6}),...
%                         str2double(taskDetail{1}{7}),...
%                         'VariableNames', {'Name', 'numInstance', 'exeTime', 'startTime', 'endTime'}));
%                 catch ME
%                     if verbose && strcmp(ME.message, 'Node names must be unique.')
%                         fprintf('Task %s already exists in job j_%d\n', taskName{1}{1}, jobID);
%                     end
%                 end
%             else % DAG task
%                 dagFlag(jobIdx) = 1;
%                 taskName{1}{1} = taskName{1}{1}(2:end);
%                 try
%                     jobs{jobIdx} = addnode(jobs{jobIdx},...
%                         table(taskName{1}(1),...
%                         str2double(taskDetail{1}{2}),...
%                         str2double(taskDetail{1}{7})-str2double(taskDetail{1}{6}),...
%                         str2double(taskDetail{1}{6}),...
%                         str2double(taskDetail{1}{7}),...
%                         'VariableNames', {'Name', 'numInstance', 'exeTime', 'startTime', 'endTime'}));
%                 catch ME
%                     if verbose && strcmp(ME.message, 'Node names must be unique.')
%                         fprintf('Task %s already exists in job j_%d\n', taskName{1}{taskIdx}, jobID);
%                     end
%                 end
%             end
%         end
%         nTask = nTask + 1;
%     end
%     fclose(fid);
% end
%
% %% Add edges
% fid = fopen(taskPath, 'r');
% if fid ~= -1
%     nTask = 0;
%     while ~feof(fid) && nTask < maxTask
%         % Read a line
%         lineText = fgetl(fid);
%         if ischar(lineText)
%             taskDetail = textscan(lineText, '%s', 'delimiter', ',');
%
%             % Identify job
%             jobName = textscan(taskDetail{1}{3}, '%s', 'delimiter', '_');
%             jobID = str2double(jobName{1}{2});
%             if ~ismember(jobID, jobPool)
%                 jobPool = [jobPool, jobID];
%                 dagFlag = [dagFlag, 0];
%                 jobs{numel(jobs)+1} = digraph;
%                 nJob = nJob + 1;
%             end
%             jobIdx = find(jobPool == jobID);
%
%             % Add dependency
%             taskName = textscan(taskDetail{1}{1}, '%s', 'delimiter', '_');
%             if ~isnan(str2double(taskName{1}{1}(2))) % DAG task
%                 taskName{1}{1} = taskName{1}{1}(2:end);
%                 for taskIdx = 1:numel(taskName{1})
%                     if taskIdx > 1
%                         try
%                             if ~findedge(jobs{jobIdx},...
%                                     jobs{jobIdx}.Nodes(findnode(jobs{jobIdx},taskName{1}{taskIdx}),:).Name{1},...
%                                     jobs{jobIdx}.Nodes(findnode(jobs{jobIdx},taskName{1}{1}),:).Name{1})
%                                 jobs{jobIdx} = addedge(jobs{jobIdx},...
%                                     jobs{jobIdx}.Nodes(findnode(jobs{jobIdx},taskName{1}{taskIdx}),:).Name{1},...
%                                     jobs{jobIdx}.Nodes(findnode(jobs{jobIdx},taskName{1}{1}),:).Name{1},...
%                                     jobs{jobIdx}.Nodes(findnode(jobs{jobIdx},taskName{1}{1}),:).endTime...
%                                     -jobs{jobIdx}.Nodes(findnode(jobs{jobIdx},taskName{1}{taskIdx}),:).endTime);
%                             else
%                                 if verbose
%                                     fprintf('Dependency %s -> %s already exists in job j_%d\n',...
%                                         jobs{jobIdx}.Nodes(findnode(jobs{jobIdx},taskName{1}{taskIdx}),1).Name{1},...
%                                         jobs{jobIdx}.Nodes(findnode(jobs{jobIdx},taskName{1}{1}),1).Name{1},...
%                                         jobID);
%                                 end
%                             end
%                         catch ME
%                         end
%                     end
%                 end
%             end
%         end
%
%         nTask = nTask + 1;
%         if stat > 0 && mod(nTask, stat) == 0
%             fprintf('stat\n');
%         end
%     end
%     fclose(fid);
% end
%
% %% Mark jobs recorded before trace start
% for i = 1:size(jobPool,2)
%     if min(jobs{i}.Nodes.startTime) <= 0
%         jobPool(i) = -1;
%     end
% end
% end
%
