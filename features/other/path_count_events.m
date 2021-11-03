function n = path_count_events(pts, state)
    % n = sum(pts(:, 4) == state);
    state_on = pts(:, 4) == state;
    onsets = diff(state_on) == 1;
    n = length(find(onsets));
end