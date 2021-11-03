%Some statistics on the full animal paths (measurements of performance)
%This script generates Figure 1 of the manuscript.

%Requires Part1_rawData

close all
clear all
clc

start_folder = pwd;

format = '.png';
quality = 'High Quality';

addpath(fullfile(pwd,'objects'));
addpath(fullfile(pwd,'plotter'));

feats_str = {'Ang. distance shock signed';...%1
    'Log avg. radius';'Log var radius';...%2,3
    'Time centre';...%4
    'IQR speed arena';...%5
    'Average speed (arena)';...%6
    'Mode angular velocity (arena)';...%7
    'Average angular velocity (arena)';...%8
    'Angular dispersion';...%9
    'Angular dispersion (arena)';...%10
    'Frequency speed change (arena)';...%11
    'Angular distance shock';...%12
    'Variance angular velocity (arena)';...%13
    'Shock radius';...%14
    'Number of entrances';...%15
    'Maximum time between shocks';...%16
    'Time for first shock';...%17
    'Variance speed arena';...%18
    'Total path length (arena)';...%19
    'Number of shocks';...%20
    'IQR radius (arena)';...%21
    'Total path length';...%22
    'Latency'};%23

todo = {[15,17,20,16,6,19], {'','[s]','','[s]','[cm/s]','[m]'}};

group1_start_id = -10; %group1 starts from id 11 --> make it 1

%Load paths and features
load(fullfile(start_folder,'results','full_paths.mat'))
load(fullfile(start_folder,'results','feature_values_paths.mat'))
%Set output
outPath = fullfile(start_folder,'results','path_plots');
if ~exist(outPath,'dir')
    mkdir(outPath)
end

n = length(paths.items);
nt = max([paths.items.trial]);
ngroup1 = length(find([paths.items.group]==1)) / nt; %number of animals g1
ngroup2 = length(find([paths.items.group]==2)) / nt; %number of animals g2

mat1 = nan(ngroup1, nt);
mat2 = nan(ngroup2, nt);
feats_mats = {mat1,mat2};
feats_mats = repmat(feats_mats,size(feature_values,2),1);

ids = unique([paths.items.id]);
for i = 1:length(ids)
    tmp = find([paths.items.id]==ids(i));
    tmpf = feature_values(tmp,:);
    for j = 1:length(tmp)
        tr = paths.items(tmp(j)).trial;
        gr = paths.items(tmp(j)).group;
        id = paths.items(tmp(j)).id;
        for F = 1:size(feature_values, 2)
            if gr == 1
                feats_mats{F,gr}(id+group1_start_id,tr) = feature_values(tmp(j),F);
            elseif gr == 2
                feats_mats{F,gr}(id,tr) = feature_values(tmp(j),F);
            else
                error('Unknown group')
            end
        end
    end
end

[haxes, fig6] = tight_subplot_cm(2, 3, ...
                    [2 2], [3 3], [3 2], 20, 35);
set(fig6, 'Visible', 'off');
idx = 1;
for i = todo{1}  % 1:size(feats_mats,1)
    if ~isempty(todo)
        if ~ismember(i,todo{1})
            continue
        end
        ylab = find(todo{1}==i);
        ylab = todo{2}{ylab};
    else
        ylab = -1;
    end
    switch ylab
        case '[m]'
            tmp1 = feats_mats{i,1}./100;
            tmp2 = feats_mats{i,2}./100;
        otherwise
            tmp1 = feats_mats{i,1};
            tmp2 = feats_mats{i,2};
    end

    % 6 trials
    ax = haxes(idx);
    axes(ax);
    make_boxplot(tmp1, tmp2, 6, ax);
    ylim( [min([tmp1,tmp2],[],'all'), max([tmp1,tmp2],[],'all')] );
    mfried = [];
    for j = 1:size(feats_mats{i,1}, 1)
        % Friedman (and p-values) only over the 5 training sessions:
        mfried = [mfried; [feats_mats{i, 1}(j, 1:5)', feats_mats{i, 2}(j, 1:5)']];
    end
    if isempty(find(isnan(mfried),1))
        [p, tbl, stats] = friedman(mfried, size(feats_mats{i,1},1), 'off');
    else
        error('missing values')
        % p = mackskill(mfried, size(feats_mats{i,1},1));
    end
    p_rounded = round(p, 4);
    if p_rounded == 0
        p_formated = regexprep(sprintf('%g', round(p, 2, 'significant')), ...
            '(e[+-])0(\d)', '$1$2');
    else
        p_formated = p_rounded;
    end
    title(['p-value: ', num2str(p_formated)], 'FontSize', 10);
    if ~isequal(ylab,-1)
        ylabel([feats_str{i},' ',ylab]);
    else
        ylabel(feats_str{i});
    end

    % 5 trials
    %{
    f = make_boxplot(tmp1(:,1:5), tmp2(:,1:5), 5);
    ylim( [min([tmp1(:,1:5),tmp2(:,1:5)],[],'all'), max([tmp1(:,1:5),tmp2(:,1:5)],[],'all')] );
    mfried = [];
    for j = 1:size(feats_mats{i,1},1)
        mfried = [mfried; [feats_mats{i,1}(j,1:5)',feats_mats{i,2}(j,1:5)']];
    end
    if isempty(find(isnan(mfried),1))
        p = friedman(mfried, size(feats_mats{i,1},1),'off');
    else
        p = mackskill(mfried, size(feats_mats{i,1},1));
    end
    title(['p-value: ',num2str(p)]);
    if ~isequal(ylab,-1)
        ylabel([feats_str{i},' ',ylab]);
    else
        ylabel(feats_str{i});
    end
    if ~exist(fullfile(outPath,'trials5'),'dir')
        mkdir(fullfile(outPath,'trials5'));
    end
    export_figure(f, fullfile(outPath,'trials5'), ['feat_',num2str(i)], format, quality);
    export_figure(f, fullfile(outPath,'trials5'), ['feat_',num2str(i)], '.eps', quality);
    close(f)
    %}
    
    idx = idx + 1;
end

if ~exist(fullfile(outPath,'trials6'), 'dir')
    mkdir(fullfile(outPath,'trials6'));
end
export_figure(fig6, fullfile(outPath,'trials6'), 'performance_new', format, quality);
export_figure(fig6, fullfile(outPath,'trials6'), 'performance_new', '.eps', quality);
close(fig6)
