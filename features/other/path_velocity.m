function [vmean,viqr,vmax,vmin] = path_velocity(pts)
%PATH_VELOCITY 

    %trajectory_speed_impl
    spd = zeros(1, size(pts, 1));
    prev = 1;    
    for i = 2:size(pts, 1)
        % compute the length in cm and seconds
        len = norm( pts(i, 2:3) - pts(prev, 2:3) );        
        if len > 3
            dt = pts(i, 1) - pts(prev, 1);
            if prev > 1
                spd(prev:i) = 0.5*spd(prev - 1) + 0.5*len / dt;
            else
                spd(1:i) = len / dt;
            end
            prev = i;
        end
    end   
    pts = [pts(:, 1), pts(:, 2), pts(:, 3), spd'];

    vmean = mean(pts(:,4));
    viqr = iqr(pts(:,4));
    vmax = max(pts(:, 4));
    vmin = min(pts(:, 4));
end

