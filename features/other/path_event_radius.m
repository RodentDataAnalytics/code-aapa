function ret = path_event_radius(pts, center_x, center_y, radius, state, varargin)
%Average amount of time that the animal was inside the shock sector

    tol = 0;
    for i = 1:length(varargin)
        if isequal(varargin{i},'PATH_EVENT_RADIUS_TOLERANCE')
			tol = varargin{i+1};
        end
    end
    if tol > 0
        [coord, ix] = dpsimplify(pts(:, 2:3), tol);
        % take the times of the simplified path
        pts = [pts(ix, 1), coord, pts(ix, 4:end)];
    end                                               
                                                
    r = [];
    
    for i = 1:size(pts, 1)                
        if pts(i, 4) == state
            r = [r, sqrt( (pts(i, 2) - center_x)^2 + (pts(i, 3) - center_y)^2 ) / radius];            
        end        
    end   
    
    if isempty(r)
        ret = 1e9;
    else
        ret = mean(r);
    end
end