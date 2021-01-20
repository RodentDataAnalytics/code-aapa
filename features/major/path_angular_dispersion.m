function ret = path_angular_dispersion( pts, center_x, center_y, varargin )
%PATH_ANGULAR_DISPERSION measures the angular spread of the trajectries. 
%Difference between the max nd min angles of the position vector of each
%trajectory coordinate.
    
    tol = 0;
    for i = 1:length(varargin)
        if isequal(varargin{i},'PATH_ANGULAR_DISPERSION_TOLERANCE')
			tol = varargin{i+1};
        end
    end
    if tol > 0
        [coord, ix] = dpsimplify(pts(:, 2:3), tol);
        % take the times of the simplified path
        pts = [pts(ix, 1), coord, pts(ix, 4:end)];
    end

    d = [pts(:, 2) - center_x, pts(:, 3) - center_y];
    % normalize it
    d = d ./ repmat(sqrt( d(:,1).^2 + d(:,2).^2), 1, 2);
        
    % use always the (1, 0) direction as basis
    u = [1, 0];
    ang_min = [];
    ang_max = [];
    
    for i = 1:size(d, 1)
        ang = abs(acos(dot(u, d(i, :))/(norm(u)*norm(d(i, :)))));  
        if d(i, 2) < 0
            ang = -ang;
        end
        if isempty(ang_min) || ang < ang_min
            ang_min = ang;
        end
        if isempty(ang_max) || ang > ang_max
            ang_max = ang;
        end
    end
    ret = ang_max - ang_min;
end