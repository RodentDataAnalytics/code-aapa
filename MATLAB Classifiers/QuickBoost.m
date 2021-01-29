function [boosted, votes, undefined, y] = QuickBoost(feature_values)

    load(fullfile(pwd,'results','classifiers.mat'));
    
    % Classifiers
    y1 = trainedModelEnsembleBag.predictFcn(feature_values(:,1:11));
    y2 = trainedModelEnsembleBoo.predictFcn(feature_values(:,1:11));
    y3 = trainedModelSVMCub.predictFcn(feature_values(:,1:11));
    y4 = trainedModelSVMMed.predictFcn(feature_values(:,1:11));
    y5 = trainedModelSVQua.predictFcn(feature_values(:,1:11));
    y6 = trainedModelTreeFine.predictFcn(feature_values(:,1:11));

    y = [y1,y2,y3,y4,y5,y6];

    % Test similarity    
    similarity = zeros(size(y,2),size(y,2));
    for i = 1:size(y,2)
        for j = i+1:size(y,2)
            a1 = y(:,i);
            a2 = y(:,j);
            vals = length(find(a1==a2));
            similarity(i,j) = 100*vals/length(a1);
            similarity(j,i) = similarity(i,j);
        end
    end

    % Voting matrix
    un = unique(y(:));
    votes = zeros(size(y,1),length(un));
    for i = 1:size(y,1)
        for j = 1:length(un)
            votes(i,j) = length(find(y(i,:)==un(j)));
        end
    end

    % Majority voting
    boosted = zeros(size(y,1),1);
    for i = 1:size(votes,1)
        a = find(votes(i,:)==max(votes(i,:)));
        if length(a) > 1
            boosted(i) = 0;
        else
            boosted(i) = a;
        end
    end

    % Undefined
    undefined = find(boosted==0);
end