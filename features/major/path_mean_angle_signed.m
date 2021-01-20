function ang = path_mean_angle_signed(pts,center_x,centre_y,trial_angle)
%PATH_MEAN_ANGLE_SIGNED measures the angular distance from the centre of
%the shock sector in the room coordinate frame to the angular centre of the
%segment.

    ang0 = 2*pi - trial_angle;
    
    d = [pts(:, 2) - center_x, pts(:, 3) - centre_y];
    % normalize it
    norm_d = sqrt( d(:,1).^2 + d(:,2).^2);
    norm_d(norm_d == 0) = 1e-5;

    d = d ./ repmat(norm_d, 1, 2);
    
    v = [sum(d(:, 1)); sum(d(:, 2))];
    
    % rotate point to the ref angle
    v = [cos(ang0) -sin(ang0); sin(ang0) cos(ang0)] * v;
    
    ang = atan2(v(2), v(1));
    
    if ang < 0
        ang = 2*pi + ang;
    end  
end
