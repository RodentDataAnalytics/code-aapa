function part1_rawData(output,output_figs,RAW_DATA,RAW_DATA_PLOT,RAW_DATA_FEATURES)

    %RAW_DATA = 0;          %Load the raw data
    %RAW_DATA_PLOT = 0;     %Plot the raw data
    %RAW_DATA_FEATURES = 0; %Compute features for the full trajectories

    get_export_format = '.png';
    get_export_properties = 'Low Quality';
    
    arena_coordinates = 1; %use the given arena coordinates
    %arena_coordinates_missing = [9,1,19,1]; %track,group,id,trial
    arena_coordinates_missing = []; %we now have everything


    %% Load the raw data
    if RAW_DATA
        ppath = fullfile(pwd,'raw');
        %Control
        traj = load_aapa_data(ppath,1,{'ho*Room*.dat','ho*Arena*.dat'},'hod%dr%d');
        %Silver
        traj = traj.append( load_aapa_data(ppath,2,{'nd*Room*.dat','nd*Arena*.dat'},'nd%dr%d') );
        paths = traj;
        save(fullfile(output,'full_paths.mat'),'paths');
    end

    %% Features: full paths
    if RAW_DATA_FEATURES
        paths = [];
        if ~exist(fullfile(output,'full_paths.mat'),'file')
            error('Full paths do not exist.');
        else
            load(fullfile(output,'full_paths.mat'),'paths');
        end
        feature_values = compute_features_values(paths,paths);
        save(fullfile(output,'feature_values_paths.mat'),'feature_values');
    end

    %% PLOT: full paths
    if RAW_DATA_PLOT
        if ~exist(fullfile(output,'full_paths.mat'),'file')
            error('Full paths do not exist.');
        else
            load(fullfile(output,'full_paths.mat'),'paths');
        end
        n = length(paths.items);
        for i = 1:n
            f = plot_aapa(paths.items(i).points(:,2:3));
            name = sprintf('p%d_tr%d_id%d_gr%d',...
                i, paths.items(i).trial, paths.items(i).id, paths.items(i).group);
            export_figure(f, output_figs, name, get_export_format, get_export_properties);
            close(f);

            pts = paths.items(i).property('ARENA_COORDINATES');
            f = plot_aapa(pts(:,2:3),'draw_shock');
            name = sprintf('p%d_tr%d_id%d_gr%d_arena',...
                i, paths.items(i).trial, paths.items(i).id, paths.items(i).group);
            export_figure(f, output_figs, name, get_export_format, get_export_properties);
            close(f);
        end
    end
    
end