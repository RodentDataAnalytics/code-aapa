function feature_values = compute_features_values(segments,paths)
%COMPUTE_FEATURES

    [center_x,center_y,center_r,trial_angle,time_r,rotation_freq] = exp_properties;

    arena_coordinates = 1; %use the given arena coordinates
    %arena_coordinates_missing = [9,1,19,1]; %track,group,id,trial
    arena_coordinates_missing = []; %we now have everything

    n = length(segments.items);
    nf = 23; %number of features
    feature_values = nan(n,nf);
    
    fprintf('Computing features for %d paths...',n);
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
        if isempty(paths) || iflag %we do not have/want arena coordinates 
            %Ang. distance shock signed
            feature_values(i,1) = path_mean_angle_signed(pts,center_x,center_y,trial_angle);
            %Log radius & Log variance radius 
            [feature_values(i,2), feature_values(i,3)] = path_radius(pts, center_x, center_y, center_r);
            %Time centre
            feature_values(i,4) = path_time_within_radius(pts, center_x, center_y, time_r, rotation_freq);
            %IQR speed arena & Average speed (arena)
            [feature_values(i,6), feature_values(i,5),~,~] = path_velocity_rot(pts, center_x, center_y, rotation_freq);
            %Mode angular velocity (arena) & Average angular velocity (arena)
            [feature_values(i,8), feature_values(i,7)] = path_angular_velocity(pts, center_x, center_y);
            %Angular dispersion
            feature_values(i,9) = path_angular_dispersion(pts, center_x, center_y);
            %Angular dispersion (arena)
            feature_values(i,10) = path_angular_dispersion_rot(pts, center_x, center_y, rotation_freq);
            %Frequency speed change (arena)
            feature_values(i,11) = path_speed_change_frequency(pts, center_x, center_y, rotation_freq);

            %Angular distance shock
            feature_values(i,12) = path_angular_distance_shock(pts, center_x, center_y, trial_angle);
            %Variance angular velocity (arena) (same?? Maybe the other is with arena... TOCHECK)
            [~, feature_values(i,13)] = path_angular_velocity(pts, center_x, center_y);
            %Shock radius
            feature_values(i,14) = path_event_radius(pts, center_x, center_y, center_r, 2);
            %Number of entrances
            feature_values(i,15) = path_entrances_shock(pts);
            %Maximum time between shocks
            feature_values(i,16) = path_max_inter_event(pts, 2);
            %Time for first shock
            feature_values(i,17) = path_first_event(pts, 2);        
            
            %Variance speed arena (again?!)
            [~,feature_values(i,18),~,~] = path_velocity_rot(pts, center_x, center_y, rotation_freq);
            
            %Length (arena)
            feature_values(i,19) = path_length_rot(pts, center_x, center_y, rotation_freq);
            %Number of shocks
            feature_values(i,20) = path_count_events(pts, 2);
            %IQR radius (arena)
            [~, feature_values(i,21)] = path_radius_rot(pts, center_x, center_y, center_r, rotation_freq);
            
            %Length
            feature_values(i,22) = path_length(pts);
            %Latency
            feature_values(i,23) = path_latency(pts);
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
            %Ang. distance shock signed
            feature_values(i,1) = path_mean_angle_signed(pts,center_x,center_y,trial_angle);
            %Log radius & Log variance radius 
            [feature_values(i,2), feature_values(i,3)] = path_radius(pts, center_x, center_y, center_r);
            %Time centre
            feature_values(i,4) = path_time_within_radius(segments.items(i), center_x, center_y, time_r, rotation_freq, 'ARENA', this_traj);
            %IQR speed arena & Average speed (arena)
            [feature_values(i,6), feature_values(i,5),~,~] = path_velocity_rot(segments.items(i), center_x, center_y, rotation_freq, 'ARENA', this_traj);
            %Mode angular velocity (arena) & Average angular velocity (arena)
            [feature_values(i,8), feature_values(i,7)]  = path_angular_velocity(pts, center_x, center_y);
            %Angular dispersion
            feature_values(i,9) = path_angular_dispersion(pts, center_x, center_y);
            %Angular dispersion (arena)
            feature_values(i,10) = path_angular_dispersion_rot(segments.items(i), center_x, center_y, rotation_freq, 'ARENA', this_traj);
            %Frequency speed change (arena)
            feature_values(i,11) = path_speed_change_frequency(segments.items(i), center_x, center_y, rotation_freq, 'ARENA', this_traj);

            %Angular distance shock
            feature_values(i,12) = path_angular_distance_shock(pts, center_x, center_y, trial_angle);
            
            %Variance angular velocity (arena) (same?? Maybe the other is with arena... TOCHECK)
            [~, feature_values(i,13)] = path_angular_velocity(pts, center_x, center_y);
            
            %Shock radius
            feature_values(i,14) = path_event_radius(pts, center_x, center_y, center_r, 2);
            %Number of entrances
            feature_values(i,15) = path_entrances_shock(pts);
            %Maximum time between shocks
            feature_values(i,16) = path_max_inter_event(pts, 2);
            %Time for first shock
            feature_values(i,17) = path_first_event(pts, 2);        
            
            %Variance speed arena (again?!)
            [~,feature_values(i,18),~,~] = path_velocity_rot(segments.items(i), center_x, center_y, rotation_freq, 'ARENA', this_traj);
            
            %Length (arena)
            feature_values(i,19) = path_length_rot(segments.items(i), center_x, center_y, rotation_freq, 'ARENA', this_traj);
            %Number of shocks
            feature_values(i,20) = path_count_events(pts, 2);
            %IQR radius (arena)
            [~, feature_values(i,21)] = path_radius_rot(segments.items(i), center_x, center_y, center_r, rotation_freq, 'ARENA', this_traj);
            
            %Length
            feature_values(i,22) = path_length(pts);
            %Latency
            feature_values(i,23) = path_latency(pts);
        end
    end
end
