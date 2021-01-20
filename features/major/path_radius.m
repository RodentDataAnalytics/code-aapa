function [medr, iqrr] = path_radius(pts, center_x, center_y, center_r)    
%PATH_RADIUS distance of every point to the center of the arena. The
%natural logarithm is used in order to capture time.

    d = sqrt( power(pts(:, 2) - center_x, 2) + power(pts(:, 3) - center_y, 2) ) / center_r;       
    d(d == 0) = 1e-5; % avoid zero-radius
    
    d = -log(d); %natural logarithm of d, ln(d).
    medr = median(d);
    iqrr = iqr(d);
end