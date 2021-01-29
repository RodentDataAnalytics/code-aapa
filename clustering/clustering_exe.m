function results = clustering_exe(data,nc,ss,constrs,optionInit,optionCluster,labels,varargin)

    aML = 1;
    aCL = 1;
    for i = 1:length(varargin)
        if isequal(varargin{i},'MLweight')    
            aML = varargin{i+1};  
        elseif isequal(varargin{i},'CLweight')    
            aCL = varargin{i+1};  
        end
    end
    

    results = struct('idx',[],'centroids',[],'w',[],'niter',[],...
        'Silh2',[],'Silhcl',[],'Si',[],'external',[],...
        'Silh2w',[],'Silhclw',[],'Siw',[],'initCentroids',[],'flag',[]);
    
    %% Run clustering initialisation
    switch optionInit
        case 'DK-Means++'
            results.initCentroids = data(dkmpp_init(data,nc),:);
        case 'Seeding'
            [~,~,~,~,~,results.initCentroids,~] = mpckmeans(data,nc,constrs,'init_only',1);
        case 'Manual'
            i = find(cellfun(@(x) isequal(x,'Manual'),varargin)==1);
            results.initCentroids = varargin{i+1};
        case 'NONE'
            return
        otherwise
            error('Clustering exe: Initialisation not found')
    end
    
    
    %% Run clustering algorithm
    switch optionCluster
        case 'Lloyds'
            [results.idx,results.centroids,results.iterations] = kmeans_lloyd(data,nc,results.initCentroids,10000);
            results.w = ones(1,size(data,2));
            
        case 'MPCK-Means'
            try
                writematrix(results.initCentroids,'mycentroids.txt','Delimiter',',');
            catch
                %MATLAB 2017
                dlmwrite('mycentroids.txt',results.initCentroids,'Delimiter',',');
            end
            %Run WEKA; results are generated inside txt files
            [idx,results.centroids] = Jmpckmeans(data, constrs, nc);
            %Get indexes
            results.idx = double(idx')+1;
            %Get weights
            fileID1 = fopen('WeightsFinal.txt');
            tline = fgetl(fileID1);
            w = nan(1,size(data,2));
            kk = 1;
            while ischar(tline)
                w(1,kk) = str2double(tline);
                tline = fgetl(fileID1);
                kk = kk+1;
            end            
            fclose(fileID1);
            results.w = w;
            %Delete the txt files
            %pause(1);
            %delete(fullfile(pwd,'*.txt'));
        
        case {'SK-Means','PCSK-Means'}
            results = repmat(results,1,length(ss));
            for i = 1:length(ss)
                [results(i).idx, results(i).centroids, results(i).w, results(i).niter, ~, results(i).flag] = ...
                    pcskmeans(data,nc,ss(i),constrs,results(i).initCentroids,'MLweight',aML,'CLweight',aCL);
            end
            
        otherwise
            error('Clustering exe: Algorithm not found')
    end
    
    
    %% Run clustering performance
    for s = 1:length(results)
        % Silhouette
        [results(s).Silh2, ~, results(s).Silhcl, results(s).Si] = cl_SilhouetteIndex_par(data,results(s).idx);
        % Try also weighted silhouette
        [results(s).Silh2w, ~, results(s).Silhclw, results(s).Siw] = cl_SilhouetteIndex_par(data.*repmat(results(s).w,size(data,1),1), results(s).idx);
        if length(unique(labels(:,2)))==nc
            x = results(s).idx;
            x = x(labels(:,1));
            % F-score
            [fscorek,accuracyk,recallk,specificityk,precisionk] = cl_FmeasureCL(labels(:,2), x);
            % Purity
            purityk = cl_purity(labels(:,2), x);
            results(s).external = [purityk,fscorek,accuracyk,recallk,specificityk,precisionk];
        end
    end

end

