function [segments,partition,cum_partitions] = segmentation_shock(traj)
%SEGMENTATION_SHOCK

    POINT_STATE_SHOCK = 2;
    POINT_STATE_OUTSIDE_LATENCY = 4;
    dt_min = 5;
    nmin = 2; %min number of segments per trajectory
    nmax = 0; %how many segments we want to keep (0 = all)
    
    n = length(traj.items);
    segments = trajectories([]);
    partition = zeros(1,n);
    cum_partitions = zeros(1,n);
    off = 0;
    
    fprintf('Segmenting %d trajectories... ',n);

    for i = 1:n
        this_traj_segs = trajectories([]);
        
        beg = 1;
        s = 0; % no shock          
        cum_dist = [0];
        sub_seg = [];
        for k = 1:size(traj.items(i).points, 1)
            if k > 1
                cum_dist(k) = cum_dist(k - 1) + sqrt(sum( (traj.items(i).points(k, 2:3) - traj.items(i).points(k - 1, 2:3)).^2 ));
            end
            if s == 0 && traj.items(i).points(k, 4) == POINT_STATE_SHOCK
                % entered a shock area
                s = 1;
                if k > beg
                    % add sub-trajectory
                    sub_seg = [sub_seg; beg, k - 1];
                end
                beg = k;
            elseif s == 1 && ( traj.items(i).points(k, 4) == 0 || ...
                               traj.items(i).points(k, 4) == POINT_STATE_OUTSIDE_LATENCY )
                % left shock area
                beg = k;
                s = 0;
            end
        end
        if s == 0 && k > beg
            sub_seg = [sub_seg; beg, k - 1];
        end
        % add all sub-segments
        idx = 0;
        for k = 1:size(sub_seg, 1)                        
            if traj.items(i).points(sub_seg(k, 2), 1) - traj.items(i).points(sub_seg(k, 1), 1) >= dt_min
                idx = idx + 1;
                this_traj_segs = this_traj_segs.append( ...
                    trajectory(traj.items(i).points(sub_seg(k, 1):sub_seg(k, 2), :), traj.items(i).set, traj.items(i).track, traj.items(i).group, traj.items(i).id, traj.items(i).trial, traj.items(i).session, idx, cum_dist(sub_seg(k, 1)), sub_seg(k, 1), traj.items(i).trial_type, traj.items(i).all_properties) ...
                );                             
            end
        end
        %append the segments of this trajectory
        len = length(this_traj_segs.items);
        if len >= nmin
            if nmax > 0 && nmax < len
                segments = segments.append(this_traj_segs.items(1:nmax));
            else
                segments = segments.append(this_traj_segs);
            end
            partition(i) = len;
            cum_partitions(i) = off;
            off = off + len;
        else
            cum_partitions(i) = off;
        end
    end
    
    fprintf(': %d segments created.\n',length(segments.items));
end

