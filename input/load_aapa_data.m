function traj = load_aapa_data(ppath,group,pattern,id_day_mask,varargin)
%LOAD_AAPA_DATA 
    
    rev_day = 1; %option to parsr day and trial numbers from file name
    TRIAL_TYPES = [2 2 2 2 2 3];

    traj = trajectories([]);
    track = 1;
    
    files = dir(fullfile(ppath,pattern{1}));
    files_arena = dir(fullfile(ppath,pattern{2}));

    fprintf('Importing %d trajectories...\n', length(files));

    for j = 1:length(files)
        %Get the points (room)
        pts = read_trajectory(fullfile(files(j).folder,files(j).name));

        if size(pts, 1) == 0
            continue;
        end

        %Get day and trial from file name
        temp = sscanf(files(j).name, id_day_mask);
        if rev_day
            id = temp(2);
            trial = temp(1);
        else
            id = temp(1);
            trial = temp(2);
        end

%             if force_trial > 0       force_trial=0
%                 trial = force_trial;
%             end  
        
        %Get the points (arena)
        if isempty(varargin)
            pts_arena = read_trajectory(fullfile(files_arena(j).folder,files_arena(j).name));
        else
            %Generate the coordinates using the script
            center_x = 127;
            center_y = 127;
            pts_arena = path_arena_coord( pts, center_x, center_y, 1);
        end
            
        %Append the trajectory
        new_traj = trajectory(pts, 1, track, group, id, trial, trial , -1, -1, 1, TRIAL_TYPES(trial));
        new_traj.set_property('ARENA_COORDINATES', pts_arena);
        traj = traj.append(new_traj); 
        
        track = track + 1;
    end
        
    
end

