function pts = path_arena_coord( coords, center_x, center_y, f, varargin )    
% Coordinates based on the arena rotation

    tol = 0;
    traj = [];
    for i = 1:length(varargin)
        if isequal(varargin{i},'PATH_LENGTH_TOLERANCE')
			tol = varargin{i+1};
        elseif isequal(varargin{i},'ARENA')
            traj = varargin{i+1}; %this should be a 'trajectory' object
        end
    end
    
    
    if isempty(traj)
        %We do not have the arena coordinates
        pts = coords(1, :);
        for i = 2:size(coords, 1)                
            dt = coords(i - 1, 1) - coords(1, 1);
            x = coords(i, 2) - center_x;
            y = coords(i, 3) - center_y;

            xx = x*cos(-2*pi*dt*f/60) - y*sin(-2*pi*dt*f/60);
            yy = x*sin(-2*pi*dt*f/60) + y*cos(-2*pi*dt*f/60);

            pts = [pts; coords(i, 1), xx + center_x, yy + center_y, coords(i, 4:end)];
        end
    else
        %We have the arena coordinates
        pts = traj.property('ARENA_COORDINATES');
        if traj.start_time ~= -1
            % take only a subset of the points
            i = 1;
            while(pts(i, 1) < coords.start_time && i < size(pts, 1))
                i = i + 1;
            end
            istart = max(i - 1, 1);
            while(pts(i, 1) < coords.end_time && i < size(pts, 1))
                i = i + 1;
            end
            iend = min(size(pts, 1), i);                                        

            pts = pts(istart:iend, :);
        end
    end
    
 
    if tol > 0
        [coord, ix] = dpsimplify(pts(:, 2:3), tol);
        % take the times of the simplified path
        pts = [pts(ix, 1), coord, pts(ix, 4:end)];
    end
end