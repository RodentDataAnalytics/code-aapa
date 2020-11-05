function n = path_entrances_shock(pts)

    n = sum(diff(pts(:, 4) > 0 & pts(:, 4) < 5) == 1);
    
end