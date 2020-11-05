function [total_length,len_sf] = path_length_rot(pts, center_x, center_y, f, varargin)
%PATH_LENGTH_ROT Computes the length of the trajectory in the room frame
%tolerance: compute only if length between points is more than this value

    pts = path_arena_coord(pts, center_x, center_y, f, varargin{:});

    k = 0;
    if size(pts,2) == 2 %no time
        k = 1;
    end
    
    total_length = 0;
    for i = 2:size(pts,1)
        d = sqrt( (pts(i,2-k)-pts(i-1,2-k))^2 + (pts(i,3-k)-pts(i-1,3-k))^2 );
        total_length = total_length + d;
    end    
    
    len_sf = sqrt( (pts(1,2-k)-pts(end-1,2-k))^2 + (pts(1,3-k)-pts(end-1,3-k))^2 );
    
    %Alternative Way: results almost the same (difference = -9.0949e-13)
    % for i = 2:size(pts, 1)
    %     % compute the length in cm and seconds
    %     total_length = total_length + norm( pts(i, 2:3) - pts(i-1, 2:3) );        
    % end 
end

