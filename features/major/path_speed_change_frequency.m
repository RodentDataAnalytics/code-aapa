function f = path_speed_change_frequency(pts, center_x, center_y, f, varargin)
%PATH_SPEED_CHANGE_FREQUENCY measures the number of times the speed changes
%abruptly within the path based also on arena rotation.
% perc: percentage

    % Coordinates based on the arena rotation
    pts = path_arena_coord(pts, center_x, center_y, f, varargin{:});
    
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
    
    v = abs(pts(:, 4));     
    % this is our baseline speed
    vm = median(v);    
    thresh = vm + range(v)/4;
    
    p = [];
    a = v(1) > thresh;
    for i = 1:length(v)
        if a
            if v(i) < thresh
                a = 0;
            end        
        elseif v(i) >= thresh
            p = [p, pts(i, 1)];
            a = 1;            
        end
    end        
    
    f = length(p) / (pts(end, 1) - pts(1, 1));
end

