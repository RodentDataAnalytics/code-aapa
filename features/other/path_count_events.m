function n = path_count_events(pts, state)
    n = sum(pts(:, 4) == state);    
end