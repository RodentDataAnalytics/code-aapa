function part2_shockSegmentation(output,output_figs,...
    SEGMENTATION_SHOCK_SECTOR,SEGMENTATION_SHOCK_SECTOR_PLOT,SEGMENTATION_SHOCK_SECTOR_FEATURES)

    %SEGMENTATION_SHOCK_SECTOR = 0;          %Do the segmentation
    %SEGMENTATION_SHOCK_SECTOR_PLOT = 0;     %Plot the segments
    %SEGMENTATION_SHOCK_SECTOR_FEATURES = 0; %Compute features for the segments

    get_export_format = '.png';
    get_export_properties = 'Low Quality';
    
    arena_coordinates = 1; %use the given arena coordinates
    %arena_coordinates_missing = [9,1,19,1]; %track,group,id,trial
    arena_coordinates_missing = []; %we now have everything


    %% Segmentation: shock sector
    if SEGMENTATION_SHOCK_SECTOR
        if ~exist(fullfile(output,'full_paths.mat'),'file')
            error('Full paths do not exist.');
        else
            load(fullfile(output,'full_paths.mat'),'paths');
        end
        [segments,partition,cum_partitions] = segmentation_shock(paths);
        save(fullfile(output,'segmentation_shock.mat'),'segments','partition','cum_partitions');
    end
    
    %% PLOT: segmentation shock sector
    if SEGMENTATION_SHOCK_SECTOR_PLOT
        if ~exist(fullfile(output_figs,'segments_shock'),'dir')
            mkdir(fullfile(output_figs,'segments_shock'))
        end
        if ~exist(fullfile(output,'segmentation_shock.mat'),'file')
            error('Segmentation shock sector paths not exist.');
        else
            load(fullfile(output,'segmentation_shock.mat'),'segments');
        end
        n = length(segments.items);
        for i = 1:n
            f = plot_aapa(segments.items(i).points(:,2:3));
            name = sprintf('p%d_tr%d_id%d_gr%d_seg%d',...
                i, segments.items(i).trial, segments.items(i).id, segments.items(i).group, segments.items(i).segment);
            export_figure(f, fullfile(output_figs,'segments_shock'), name, get_export_format, get_export_properties);
            close(f);

            pts = segments.items(i).property('ARENA_COORDINATES');
            ii = find(pts(:,1) >= segments.items(i).points(1,1));
            jj = find(pts(:,1) <= segments.items(i).points(end,1));
            if isempty(ii) || isempty(jj) || pts(ii(1),1) > pts(jj(end),1)
                warning('Arena coordinates not found!')
                ii = 1;
                jj = size(pts,1);
            end
            f = plot_aapa(pts(ii(1):jj(end),2:3),'draw_shock');
            name = sprintf('p%d_tr%d_id%d_gr%d_seg%d_arena',...
                i, segments.items(i).trial, segments.items(i).id, segments.items(i).group, segments.items(i).segment);
            export_figure(f, fullfile(output_figs,'segments_shock'), name, get_export_format, get_export_properties);
            close(f);
        end
    end

    %% Features: segmentation shock sector
    if SEGMENTATION_SHOCK_SECTOR_FEATURES
        paths = [];
        if ~exist(fullfile(output,'segmentation_shock.mat'),'file')
            error('Segmentation shock sector paths not exist.');
        else
            load(fullfile(output,'segmentation_shock.mat'),'segments');
            if arena_coordinates
                load(fullfile(output,'full_paths.mat'),'paths');
            end
        end
        feature_values = compute_features_values(segments,paths);
        save(fullfile(output,'feature_values_shock.mat'),'feature_values');
    end
    
    
    
end