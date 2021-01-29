close all
clear all
clc


addpath(fullfile(pwd,'objects'));
addpath(fullfile(pwd,'plotter'));

dirFeatures = fullfile(pwd,'results','feature_values_subsegments');
dirSubsegs = fullfile(pwd,'results','subsegmentation');
dirLabels = fullfile(pwd,'results','labels');
outF = fullfile(pwd,'results','paperFigs','subseg');

subsegs = {'0.5_5'};

visibility = 'off';
get_export_format = '.svg';
get_export_properties = 'High Quality';
strClasses = {'thigmotaxis','incursion','focused','chaining','avoidance'};
strFeats = {'angular distance to shock sector',...
    'median log-radius', 'iqr log-radius', 'centrality',...
    'median speed', 'iqr speed',...
    'median angular speed', 'iqr angular speed',...
    'angular dispersion (room)','angular dispersion (arena)',...
    'speed change frequency'};


for S = 1:length(subsegs)
    % Load
    load(fullfile(dirFeatures,['subseg_',subsegs{S},'.mat']),'feature_values');
    load(fullfile(dirSubsegs,['subseg_',subsegs{S},'.mat']),'subsegments');
    load(fullfile(dirLabels,['labels_',subsegs{S},'.mat']),'labels');
    %labels = y(:,6);
    tmpF = fullfile(outF,subsegs{S});
    if ~exist(tmpF,'dir')
        mkdir(tmpF);
    end
    
    % Animals
    na = unique([subsegments.items.id]);
    nt = unique([subsegments.items.trial]);
    animals = cell(length(na),length(nt)+1);
    for i = 1:length(subsegments.items)   
        id = subsegments.items(i).id;
        tr = subsegments.items(i).trial;
        gr = subsegments.items(i).group;
        animals{id,tr} = [animals{id,tr},labels(i)];
        animals{id,end} = gr;
    end
    
    % Classes
    nc =  unique([animals{:}]);
    mfried = zeros((length(na)/2)*length(nt),2);
    ps = nan(1,length(nc)); 
    for i = 1:length(nc)
        k = 1;
        for j1 = 1:length(na)
            for j2 = 1:length(nt)
                %Number of subsegments of this class
                ns = length(find(animals{j1,j2}==nc(i)));
                mfried(k,animals{j1,7}) = ns;
                k = k+1;
            end
            if j1==length(na)/2
                k = 1;
            end
        end
        %Friedman test
        [ps(i),tbl] = friedman(mfried, length(na)/2, 'off');
        writetable(cell2table(tbl),fullfile(tmpF,['class',num2str(i),'.csv']),'WriteVariableNames',0);
        %Sums
        pdata = zeros(length(nt),2);
        for j = 1:length(nt)
            v = sum(mfried(j:length(nt):end,:), 1);
            pdata(j,:) = v;
        end
        %Plots
        f = figure('Visible',visibility);
        ax = axes(f);
        b = bar(pdata,'LineWidth',1.5,'parent',ax);
        b(1).FaceColor = [0,0,0];
        b(2).FaceColor = [1,1,1];
        title(strClasses{i});
        xlabel(ax,'trials');
        ylabel(ax,'subsegments');
        export_figure(f, tmpF, ['class',num2str(i)], get_export_format, get_export_properties)
        close(f)
        f = figure('Visible',visibility);
        ax = axes(f);
        b = bar(100*pdata/size(feature_values,1),'LineWidth',1.5,'parent',ax);
        b(1).FaceColor = [0,0,0];
        b(2).FaceColor = [1,1,1];
        title(strClasses{i});
        xlabel(ax,'trials');
        ylabel(ax,'percentage');
        export_figure(f, tmpF, ['class%',num2str(i)], get_export_format, get_export_properties)
        close(f)
    end

    % Features
    feats = feature_values(:,1:11);
    classes = unique(labels);
    [labs,idx] = sort(labels);
    feats = feats(idx,:);
    for i = 1:size(feats,2)
        f = figure('Visible',visibility);
        ax = axes(f);
        title(strFeats{i})
        boxplot(feats(:,i),labs,'parent',ax);
        xlabel(ax,'classes');
        ylabel(ax,'values');
        export_figure(f, tmpF, ['feat',num2str(i)], get_export_format, get_export_properties)
        close(f)
    end
end