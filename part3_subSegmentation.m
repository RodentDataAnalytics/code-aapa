function part3_subSegmentation(output,output_figs,...
    SUBSEGMENTATION_SHOCK_SECTOR,SUBSEGMENTATION_SHOCK_SECTOR_PLOT,SUBSEGMENTATION_SHOCK_SECTOR_FEATURES)

    %SUBSEGMENTATION_SHOCK_SECTOR = 0;          %Do the subsegmentation
    %SUBSEGMENTATION_SHOCK_SECTOR_PLOT = 0;     %Plot the subsegments
    %SUBSEGMENTATION_SHOCK_SECTOR_FEATURES = 0; %Compute features for the subsegments

    get_export_format = '.png';
    get_export_properties = 'Low Quality';
    
    arena_coordinates = 1; %use the given arena coordinates
    %arena_coordinates_missing = [9,1,19,1]; %track,group,id,trial
    arena_coordinates_missing = []; %we now have everything
    
    todo = {'subseg_0.5_5.mat','subseg_0.6_5.mat'}; %for the plot


    %% SubSegmentation: speed change
    if SUBSEGMENTATION_SHOCK_SECTOR
        dt_mins = 2:7;%2:10;
        speed_thresholds = 0.3:0.1:0.8;%0.1:0.1:1;
        first_seg = 1;
        other_seg = 1;

        paths = [];
        if ~exist(fullfile(output,'segmentation_shock.mat'),'file')
            error('Segmentation shock sector paths not exist.');
        else
            load(fullfile(output,'segmentation_shock.mat'),'segments');
            if arena_coordinates
                load(fullfile(output,'full_paths.mat'),'paths');
            end
        end

        n = length(segments.items);

        for I = 1:length(dt_mins)
            for J = 1:length(speed_thresholds)
                str = ['subseg_',num2str(speed_thresholds(J)),'_',num2str(dt_mins(I)),'.mat'];
                if exist(fullfile(output,'subsegmentation',str),'file')
                    continue
                end
                subsegments = trajectories;

                fprintf('Segmenting %d trajectories... ',n);
                fprintf('0.0%% ');

                for i = 1:n
                    if mod(i,floor(n/1000)) == 0                        
                        val = 100*i/n;
                        if val < 10
                            %fprintf('\b\b\b\b\b%02.1f%% ', val);
                        else
                            fprintf('\b\b\b\b\b%03.1f%%', val);
                        end   
                    end
                    if i == n
                        fprintf('\n');
                    end
                    %Get the segments points
                    pts = segments.items(i).points;
                    %Check to see if we have the arena coordinates 
                    iflag = 0;
                    for j = 1:size(arena_coordinates_missing,1)
                        if segments.items(i).track == arena_coordinates_missing(j,1) &&...
                                segments.items(i).group == arena_coordinates_missing(j,2) &&...
                                segments.items(i).id == arena_coordinates_missing(j,3) &&...
                                segments.items(i).trial == arena_coordinates_missing(j,4)
                            iflag = 1;
                            break;
                        end
                    end

                    if isempty(paths) || iflag
                        pts = path_arena_coord(pts, center_x, center_y, rotation_freq); 
                    else
                        %We have/want arena coordinates: find them
                        iflag = 0;
                        for j = 1:length(paths.items)
                            if segments.items(i).track == paths.items(j).track &&...
                                    segments.items(i).group == paths.items(j).group &&...
                                    segments.items(i).id == paths.items(j).id &&...
                                    segments.items(i).trial == paths.items(j).trial
                                this_traj = paths.items(j);
                                iflag = 1;
                                break;
                            end
                        end
                        if ~iflag
                            error('Arena coordinates not found!')
                        end
                        pts = path_arena_coord(segments.items(i), center_x, center_y, rotation_freq, 'ARENA', this_traj); 
                    end
                    if isempty(subsegments.items)
                        subsegments = segmentation_speed_change(pts,segments.items(i),center_x,center_y, dt_mins(I), first_seg, other_seg, speed_thresholds(J));
                    else
                        subsegments = subsegments.append(segmentation_speed_change(pts,segments.items(i),center_x,center_y, dt_mins(I), first_seg, other_seg, speed_thresholds(J)));
                    end
                end
                if ~exist(fullfile(output,'subsegmentation'),'dir')
                    mkdir(fullfile(output,'subsegmentation'))
                end
                str = ['subseg_',num2str(speed_thresholds(J)),'_',num2str(dt_mins(I)),'.mat'];
                save(fullfile(output,'subsegmentation',str),'subsegments');
            end
        end
    end
    
    %% PLOT: speed change
    if SUBSEGMENTATION_SHOCK_SECTOR_PLOT
        files = dir(fullfile(output,'subsegmentation','*.mat'));
        for j = 1:length(files)
            if ~isempty(todo)
                if ~ismember(files(j).name,todo)
                    continue
                end
            end
            [~,tmp] = fileparts(files(j).name);
            if ~exist(fullfile(output_figs,'speed_change',tmp),'dir')
                mkdir(fullfile(output_figs,'speed_change',tmp))
            end
            load(fullfile(files(j).folder,files(j).name),'subsegments');
            n = length(subsegments.items);
            for i = 1:n
                f = plot_aapa(subsegments.items(i).points(:,2:3));
                name = sprintf('p%d_tr%d_id%d_gr%d',...
                    i, subsegments.items(i).trial, subsegments.items(i).id, subsegments.items(i).group);
                export_figure(f, fullfile(output_figs,'speed_change',tmp), name, get_export_format, get_export_properties);
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
                export_figure(f, fullfile(output_figs,'speed_change',tmp), name, get_export_format, get_export_properties);
                close(f);
            end
        end
    end

    %% Features: speed change
    if SUBSEGMENTATION_SHOCK_SECTOR_FEATURES
        files = dir(fullfile(output,'subsegmentation','*.mat'));
        paths = [];
        if arena_coordinates
            load(fullfile(output,'full_paths.mat'),'paths');
        end
        for i = 1:length(files)
            load(fullfile(files(i).folder,files(i).name),'subsegments');
            feature_values = compute_features_values(subsegments,paths);
            if ~exist(fullfile(output,'feature_values_subsegments'),'dir')
                mkdir(fullfile(output,'feature_values_subsegments'))
            end
            save(fullfile(output,'feature_values_subsegments',files(i).name),'feature_values');
        end
    end
    
    
    
end