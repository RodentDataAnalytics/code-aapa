function tmax = path_max_inter_event(pts, state)
% TRAJECTORY_INTER_EVENT_TIMES
    
    pos = find(pts(:, 4) == state);
    if ~isempty(pos)
        ts = pts(pos, 1);
        tmax = ts(1);
        for i = 2:length(ts)
            if ts(i) - ts(i - 1) > tmax
                tmax = ts(i) - ts(i - 1);
            end                
        end
    else
        tmax = 0;
    end
end