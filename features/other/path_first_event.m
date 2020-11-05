function p = path_first_event(pts, state)

    pos = find(pts(:, 4) == state);
    
    if ~isempty(pos)
        p = pts(pos(1), 1);
    else
        p = 1e9;
    end
end