LABELLING = 0;
MPCK_MEANS = 1;
PCSK_MEANS = 0;

subsegs = {'subseg_0.6_5'};
norms = {0,'scale','z-score'};
Ks = 5:10;

addpath(fullfile(pwd,'input'));
addpath(fullfile(pwd,'objects'));
addpath(fullfile(pwd,'plotter'));
addpath(fullfile(pwd,'segmentation'));
addpath(fullfile(pwd,'weka'));
addpath(fullfile(pwd,'clustering'));
addpath(genpath(fullfile(pwd,'features')));
weka_init;


if LABELLING
    mpath = fullfile(pwd,'esults','myClassification');
    folders = {'01. Thigmotaxis','02. Incursion','03. Focus','04. Chaining','05. Avoid'};

    labels = [];
    nlabels = zeros(length(folders),1);
    for i = 1:length(folders)
        files = dir(fullfile(mpath,folders{i},'*.png'));
        l = [];
        for j = 1:length(files)
            tmp = strsplit(files(j).name,{'_','.png'});
            tmp(end) = [];
            if isequal(tmp{end},'arena')
                continue
            else
                tmp = str2double(tmp{1}(2:end));
                if isnan(tmp)
                    error('NaN number')
                else
                    l = [l;[tmp,i]];
                end
            end
        end
        nlabels(i) = size(l,1);
        labels = [labels;l];
    end

    n = size(labels,1);
    ML = [];
    CL = [];
    for i = 1:n
        for j = i+1:n
            if labels(i,2) == labels(j,2)
                if labels(i,1) < labels(j,1)
                    ML = [ML; [labels(i,1),labels(j,1)] ];
                elseif labels(i,1) > labels(j,1)
                    ML = [ML; [labels(j,1),labels(i,1)] ];
                else
                    error('Wrong label')
                end
            else
                if labels(i,1) < labels(j,1)
                    CL = [CL; [labels(j,1),labels(i,1)] ];
                elseif labels(i,1) > labels(j,1)
                    CL = [CL; [labels(i,1),labels(j,1)] ];
                else
                    error('Wrong label')
                end
            end
        end
    end

    save(fullfile(pwd,['constrs_',strjoin(arrayfun(@(x) num2str(x),nlabels,'UniformOutput',0),'-')]),...
        'ML','CL','labels','nlabels');
end


%% MPCK-MEANS
if MPCK_MEANS
    load('constrs_382-39-721-127-45.mat','ML','CL','labels','nlabels');
    clFeats = 1:11;
    for I = 1:length(subsegs)
        load(fullfile(pwd,'results','feature_values_subsegments',[subsegs{I},'.mat']),'feature_values');
        Ss = 1.1:0.2:sqrt(length(clFeats));
        results = cell(length(Ks),length(norms));
        for j = 1:length(norms) %for each normalization   
            %Normalize
            if ~isequal(norms{j},0)
                x = normalizations(feature_values(:,clFeats),norms{j});
            else
                x = feature_values(:,clFeats);
            end
            x(isnan(x)) = 0;
            %Initialize
            %[~,~,~,~,~,init_centers,~] = mpckmeans(x,Ks(end),[ML;CL],'init_only',1);
            switch j
                case 1
                    load('nonormCenters.mat')
                case 2
                    load('scalenormCenters.mat')
                case 3
                    load('zscorenormCenters.mat')
                otherwise
                    error('init not found')
            end
            for i = 1:1 %for each number of clusters
                %Exe clustering/classification
                centers = init_centers(1:Ks(i),:);
                results{i,j} = clustering_exe(x,Ks(i),Ss,[ML;CL],'Manual','MPCK-Means',labels,'Manual',centers);
            end
        end
        if ~exist(fullfile(pwd,'results','class_mpckm'),'dir')
            mkdir(fullfile(pwd,'results','class_mpckm'));
        end
        save(fullfile(pwd,'results','class_mpckm',['res_',subsegs{I},'.mat']),results);
    end
end
       

%% PCSK-MEANS
if PCSK_MEANS
    load('constrs_382-39-721-127-45.mat','ML','CL','labels','nlabels');
    clFeats = 1:11;
    for I = 1:length(subsegs)
        load(fullfile(pwd,'results','feature_values_subsegments',[subsegs{I},'.mat']),'feature_values');
        Ss = 1.1:0.2:sqrt(length(clFeats));
        results = cell(length(Ks),length(norms));
        for j = 1:length(norms) %for each normalization   
            %Normalize
            if ~isequal(norms{j},0)
                x = normalizations(feature_values(:,clFeats),norms{j});
            else
                x = feature_values(:,clFeats);
            end
            x(isnan(x)) = 0;
            %Initialize
            %[~,~,~,~,~,init_centers,~] = mpckmeans(x,Ks(end),[ML;CL],'init_only',1);
            switch j
                case 1
                    load('nonormCenters.mat')
                case 2
                    load('scalenormCenters.mat')
                case 3
                    load('zscorenormCenters.mat')
                otherwise
                    error('init not found')
            end
            for i = 1:1 %for each number of clusters
                %Exe clustering/classification
                centers = init_centers(1:Ks(i),:);
                results{i,j} = clustering_exe(x,Ks(i),Ss,[ML;CL],'Manual','PCSK-Means',labels,'Manual',centers);
            end
        end
        if ~exist(fullfile(pwd,'results','class_pcskm'),'dir')
            mkdir(fullfile(pwd,'results','class_pcskm'));
        end
        save(fullfile(pwd,'results','class_pcskm',['res_',subsegs{I},'.mat']),results);
    end
end


