function ang = path_angular_distance_shock(pts, center_x, center_y, central_ang)
%TRAJECTORY_ANGLE Compute mean angle of the trajectory    
    
    dx = cos(central_ang);
    dy = sin(central_ang);

    d = [pts(:, 2) - center_x, pts(:, 3) - center_y];
    % normalize it
    norm_d = sqrt( d(:,1).^2 + d(:,2).^2);
    norm_d(norm_d == 0) =1e-5;

    d = d ./ repmat(norm_d, 1, 2);

    u = [dx, dy];
    v = [sum(d(:, 1)), sum(d(:, 2))];

    ang = abs(acos(dot(u, v)/(norm(u)*norm(v))));  

    assert(~isnan(ang));
    if ang > pi
        ang = 2*pi - ang;
    end    
end