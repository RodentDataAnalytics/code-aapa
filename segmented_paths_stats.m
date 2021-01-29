format = '.png';
quality = 'Low Quality';
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
    'Variance angular velocity (arena)(*e)';...%13
    'Shock radius(*c)';...%14
    'Number of entrances(*a)';...%15
    'Maximum time between shocks(*d)';...%16
    'Time for first shock(*b)';...%17
    'Variance speed arena(*e)';...%18
    'Length (arena)(*f1)';...%19
    'Number of shocks(*)';...%20
    'IQR radius (arena)';...%21
    'Length(*f2)';...%22
    'Latency(*)'};%23
    
outPath = fullfile(pwd,'results','path_plots');
if ~exist(outPath,'dir')
    mkdir(outPath)
end

%load paths and features
n = length(paths.items);
nt = max([paths.items.trial]);

mat1 = nan(10, nt);
mat2 = nan(length(find([paths.items.group]==2)) / nt, nt);
feats_mats = {mat1,mat2};
feats_mats = repmat(feats_mats,size(feature_values,2),1);

ids = unique([paths.items.id]);
flag = 1;
for i = 1:length(ids)
    tmp = find([paths.items.id]==ids(i));
    tmpf = feature_values(tmp,:);
    for j = 1:length(tmp)
        tr = paths.items(tmp(j)).trial;
        gr = paths.items(tmp(j)).group;
        id = paths.items(tmp(j)).id;
        for F = 1:size(feature_values,2)
            if gr == 1
                feats_mats{F,gr}(id-10,tr) = feature_values(tmp(j),F);
            elseif gr == 2
                feats_mats{F,gr}(id,tr) = feature_values(tmp(j),F);
            else
                error('Unknown group')
            end
        end
    end
end

if ~exist(fullfile(outPath,'trials6'),'dir')
    mkdir(fullfile(outPath,'trials6'));
end
for i = 1:size(feats_mats,1)
    f = make_boxplot(feats_mats{i,1}, feats_mats{i,2}, 6);
    mfried = [];
    for j = 1:size(feats_mats{i,1},1)
        mfried = [mfried; [feats_mats{i,1}(j,:)',feats_mats{i,2}(j,:)']];
    end
    if isempty(find(isnan(mfried),1))
        p = friedman(mfried, size(feats_mats{i,1},1),'off');
    else
        p = mackskill(mfried, size(feats_mats{i,1},1));
    end
    title(['p-value: ',num2str(p)]);
    ylabel(feats_str{i});
    export_figure(f, fullfile(outPath,'trials6'), ['feat_',num2str(i)], format, quality);
    close(f)
end

if ~exist(fullfile(outPath,'trials5'),'dir')
    mkdir(fullfile(outPath,'trials5'));
end
for i = 1:size(feats_mats,1)
    f = make_boxplot(feats_mats{i,1}(:,1:5), feats_mats{i,2}(:,1:5), 5);
    mfried = [];
    for j = 1:size(feats_mats{i,1},1)
        mfried = [mfried; [feats_mats{i,1}(j,:)',feats_mats{i,2}(j,:)']];
    end
    if isempty(find(isnan(mfried),1))
        p = friedman(mfried, size(feats_mats{i,1},1),'off');
    else
        p = mackskill(mfried, size(feats_mats{i,1},1));
    end
    title(['p-value: ',num2str(p)]);
    ylabel(feats_str{i});
    export_figure(f, fullfile(outPath,'trials5'), ['feat_',num2str(i)], format, quality);
    export_figure(f, fullfile(outPath,'trials5'), ['feat_',num2str(i)], '.svg', quality);
    close(f)
end