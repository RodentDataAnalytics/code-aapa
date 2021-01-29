close all
clear all
clc

classes = {'01. Thigmotaxis','02. Incursion','03. Focus','04. Chaining','05. Avoid','bad'};
format = '*.png';

folderManualClass = dir(fullfile(pwd,'results','myClassification'));
subsegs = dir(fullfile(pwd,'results','feature_values_subsegments','*.mat'));
outF = fullfile(pwd,'results','labels');

for I = 3:length(folderManualClass)
    name = strsplit(folderManualClass(I).name, '_');
    if length(name) ~= 3
        continue
    end
    load(fullfile(subsegs(1).folder,['subseg_',name{2},'_',name{3},'.mat']),'feature_values');
    labels = -1*ones(size(feature_values,1),1);
    
    for i = 1:length(classes)
        files = dir(fullfile(folderManualClass(I).folder,['subseg_',name{2},'_',name{3}],classes{i},format));
        for j = 1:length(files)
            s = strsplit(files(j).name,{'_'});
            if isequal(s{end},['arena',format(2:end)])
                continue
            end
            a = str2double(s{1}(2:end));
            if isnan(a)
                error('NaN')
            else
                if isequal(classes{i},'bad')
                    labels(a) = 0;
                else
                    labels(a) = i;
                end
            end
        end
    end
    
    save(fullfile(outF,['labels_',name{2},'_',name{3},'.mat']),'labels');
end

%Add bad to 3. Focus
%labels(labels==0)=3; --> for the 0.6-5 only


