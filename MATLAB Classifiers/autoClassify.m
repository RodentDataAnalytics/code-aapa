clear all
close all
clc

% Folders to be added to MATLAB's Path
addpath(fullfile(pwd,'objects'));
addpath(fullfile(pwd,'plotter'));

% Output folders
dirFeatures = fullfile(pwd,'results','feature_values_subsegments');
dirSubsegs = fullfile(pwd,'results','subsegmentation');
dirLabels = fullfile(pwd,'results','labels');
outF = fullfile(pwd,'results','autoClassification');

% Figure properties
visibility = 'off';
get_export_format = '.png';
get_export_properties = 'Low Quality';

% Subsegmentations to classify
subsegs = {'0.5_5'};
classes = {'01. Thigmotaxis','02. Incursion','03. Focus','04. Chaining','05. Avoid','Unknown'};


for S = 1:length(subsegs)
    % Load
    load(fullfile(dirFeatures,['subseg_',subsegs{S},'.mat']),'feature_values');
    load(fullfile(dirSubsegs,['subseg_',subsegs{S},'.mat']),'subsegments');
    tmpF = fullfile(outF,subsegs{S});
    if ~exist(tmpF,'dir')
        mkdir(tmpF);
    end
    for i = 1:length(classes)
        if ~exist(fullfile(tmpF,classes{i}),'dir')
            mkdir(fullfile(tmpF,classes{i}));
        end
    end
    
    % Classify
    [boosted, votes, undefined, y] = QuickBoost(feature_values);
    
    % Plot
    n = length(subsegments.items);
    for i = 1:n
        if boosted(i) == 0
            classF = classes{end};
        else
            classF = classes{boosted(i)};
        end
        f = plot_aapa(subsegments.items(i).points(:,2:3));
        name = sprintf('p%d_tr%d_id%d_gr%d',...
            i, subsegments.items(i).trial, subsegments.items(i).id, subsegments.items(i).group);
        export_figure(f, fullfile(tmpF,classF), name, get_export_format, get_export_properties);
        close(f);

        pts = subsegments.items(i).property('ARENA_COORDINATES');
        ii = find(pts(:,1) >= subsegments.items(i).points(1,1));
        jj = find(pts(:,1) <= subsegments.items(i).points(end,1));
        if isempty(ii) || isempty(jj) || pts(ii(1),1) > pts(jj(end),1)
            warning('Arena coordinates not found!')
            ii = 1;
            jj = size(pts,1);
        end
        f = plot_aapa(pts(ii(1):jj(end),2:3),'draw_shock');
        name = sprintf('p%d_tr%d_id%d_gr%d_arena',...
            i, subsegments.items(i).trial, subsegments.items(i).id, subsegments.items(i).group);
        export_figure(f, fullfile(tmpF,classF), name, get_export_format, get_export_properties);
        close(f);
    end
end