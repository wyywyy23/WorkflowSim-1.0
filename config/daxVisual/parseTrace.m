function [fig] = parseTrace(file)
%PARSETRACE Summary of this function goes here
%   Detailed explanation goes here
c = parula(100);
fid = fopen(file, 'r');
if fid ~= -1
    fig = figure;
    hold on;
    while ~feof(fid)
        lineText = fgetl(fid);
        if ischar(lineText)
            textDetail = textscan(lineText, '%s', 'delimiter', ' ', 'MultipleDelimsAsOne',1);
            plot([str2double(textDetail{1}{7}), str2double(textDetail{1}{8})],...
                [str2double(textDetail{1}{5}), str2double(textDetail{1}{5})],...
                '-', 'Color', c(str2double(textDetail{1}{1})+1,:));
            text((str2double(textDetail{1}{7})+str2double(textDetail{1}{8}))/2,str2double(textDetail{1}{5}),textDetail{1}{1});
        end
    end
    fclose(fid);
end
end

