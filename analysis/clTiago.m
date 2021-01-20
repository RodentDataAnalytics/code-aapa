function clTiago(output,output_figs)

    todo = {'subseg_0.5_5.mat','subseg_0.5_6.mat','subseg_0.6_5.mat','subseg_0.6_6.mat'};

    weka_init;
    files = dir(fullfile(output,'feature_values_subsegments','*.mat'));
    clustering_feats = 1:11; %features to use in clustering
    pcs = [0,2:length(clustering_feats)]; %pca to use in clustering (loop)
    ks = 2:10; %number of clusters to use in clustering (loop)
    for i = length(files):-1:1
        if ~isempty(todo)
            if ~ismember(files(i).name,todo)
                continue
            end
        end
        %Load segmentation and make clustering folder
        load(fullfile(files(i).folder,files(i).name));
        [~,tmp] = fileparts(files(i).name);
        str = fullfile(output,'clustering_subsegments',tmp);
        if ~exist(str,'dir')
            mkdir(str)
        end
        if isempty(dir(fullfile(str,'*.mat')))
            %Make results structure
            cl_results = struct('x',[],'initC',[],'pcs',[],'idx',[],'centroids',[],'w',[],...
                'wcd',[],'bcd',[],'Silh2',[],'Si',[],'Silh2w',[],'Siw',[]);
            cl_results = repmat(cl_results,length(ks),length(pcs));
            %Exe clustering loops
            for ii = 1:length(pcs)
                x = feature_values(:,clustering_feats);
                x(isnan(x)|isinf(x)) = 0;
                %PCA
                if pcs(ii) > 0
                    [coeff, score, latent] = pca(x,'Centered','on');
                    x = x*coeff(:, 1:pcs(ii));   
                end
                for jj = 1:length(ks)
                    %Clustering algorithm
                    [idx,centroids,w,initC] = run_mpckmeans(x,ks(jj),[]);
                    %Clustering metrics
                    [~,~,wcd,~,bcd,~] = clustering_metrics(x,idx);
                    [Silh2,~,~,Si] = cl_SilhouetteIndex_par(x,idx);
                    [Silh2w,~,~,Siw] = cl_SilhouetteIndex_par(x.*repmat(w,size(x,1),1),idx);
                    cm = clustering_correlation_matrix(x,idx,centroids'); 
                    %Store
                    cl_results(jj,ii).initC = initC;
                    cl_results(jj,ii).x = x;
                    cl_results(jj,ii).pcs = pcs(ii);
                    cl_results(jj,ii).idx = idx;
                    cl_results(jj,ii).centroids = centroids;
                    cl_results(jj,ii).w = w;
                    cl_results(jj,ii).wcd = wcd;
                    cl_results(jj,ii).bcd = bcd;
                    cl_results(jj,ii).Silh2 = Silh2;
                    cl_results(jj,ii).Silh2w = Silh2w;
                    cl_results(jj,ii).Si = Si;
                    cl_results(jj,ii).Siw = Siw;
                    cl_results(jj,ii).cm = cm;
                end
            end
            %Save
            save(fullfile(str,'cl_results.mat'),'cl_results','-v7.3');
        else
            load(fullfile(str,'cl_results.mat'),'cl_results');
            continue
        end

        %Maximum correlation and minimum clustering size
        [n,m] = size(cl_results);
        max_corr = zeros(size(cl_results));
        min_size = inf(size(cl_results));
        for I = 1:n
            for j = 1:m
                tmp = cl_results(I,j).cm(:);
                tmp(tmp==1) = [];
                max_corr(I,j) = 100*max(tmp);
                tmp = cl_results(I,j).idx;
                for ii = 1:length(unique(tmp))
                    if 100*length(find(tmp==ii))/size(cl_results(I,j).x,1) < min_size(I,j)
                        min_size(I,j) = 100*length(find(tmp==ii))/size(cl_results(I,j).x,1);
                    end
                end
            end
        end
        for j = 1:m
            f = figure('Visible',0);
            ax = axes(f);
            hold on
            plot(ks,max_corr(:,j),'k-','LineWidth',1.5);
            plot(ks,min_size(:,j),'k--','LineWidth',1.5);
            ylim([0,100]);
            xlabel('Number of clusters');
            ylabel('%');
            title([num2str(pcs(j)),' Principal Components']);
            grid on
            if ~exist(fullfile(str,'plot_param_selection'),'dir')
                mkdir(fullfile(str,'plot_param_selection'))
            end
            export_figure(f, fullfile(str,'plot_param_selection'), ['pc_',num2str(pcs(j))], '.png', 'Low Quality');
            close(f)
        end
    end
end