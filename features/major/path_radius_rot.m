function [medr, iqrr] = path_radius_rot(pts, center_x, center_y, center_r, f, varargin)    
%PATH_RADIUS_ROT distance of every point to the center of the arena. The
%natural logarithm is used in order to capture time.

    pts = path_arena_coord(pts, center_x, center_y, f, varargin{:});

    d = sqrt( power(pts(:, 2) - center_x, 2) + power(pts(:, 3) - center_y, 2) ) / center_r;       
    d(d == 0) = 1e-5; % avoid zero-radius
    
    %d = -log(d); %natural logarithm of d, ln(d).
    medr = median(d);
    iqrr = iqr(d);
end