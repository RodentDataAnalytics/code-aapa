function [ speed ] = path_speed( pts,varargin )
%PATH_SPEED computes the speed of the animal
%tolerance: compute only if length between points is more than this value

	PATH_SPEED_TOLERANCE = 0;
	
    for i = 1:length(varargin)
		if isequal(varargin{i},'PATH_SPEED_TOLERANCE')
			PATH_SPEED_TOLERANCE = varargin{i+1};
		end
    end	

    if size(pts,1) < 3 || size(pts,2) < 3
        speed = 0;
        return
    end   
    
    speed = [];
    for i = 2:size(pts,1)
        d = sqrt( (pts(i,2)-pts(i-1,2))^2 + (pts(i,3)-pts(i-1,3))^2 );
        if d >= PATH_SPEED_TOLERANCE % discard points which are too close together
            dt = pts(i,1) - pts(i-1,1);
            speed = [speed; d/dt];
        end
    end 
end

