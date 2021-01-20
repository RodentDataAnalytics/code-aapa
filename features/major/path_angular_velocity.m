function [vmean,viqr,pts] = path_angular_velocity( pts, center_x, center_y, varargin )
%TRAJECTORY_ANGULAR_VELOCITY computes the angular velocity of the path
    
    tol = 0;
    for i = 1:length(varargin)
        if isequal(varargin{i},'PATH_ANGULARE_VEL_TOLERANCE')
			tol = varargin{i+1};
        end
    end
    if tol > 0
        [coord, ix] = dpsimplify(pts(:, 2:3), tol);
        % take the times of the simplified path
        pts = [pts(ix, 1), coord, pts(ix, 4:end)];
    end
    
    % distance to the centre
    d = [pts(:, 2) - center_x, pts(:, 3) - center_y];       
    
    % the total angular distance moved
    dA = 0;
    dt = 1e-5;
            
    for i = 2:size(d, 1) 
        atanA = atan2( d(i - 1, 2), d(i - 1, 1) );
        atanB = atan2( d(i, 2), d(i, 1) );
            
        % check quadrants
        qd1 = quadrant(d(i - 1, 1), d(i -1, 2) );
        qd2 = quadrant(d(i, 1), d(i, 2) ); 

        % cannot have a too large angle, or jumping more than 1 quadrant at
        % once        
        if ( abs(qd1 - qd2) <= 1 || (qd1 == 1 && qd2 ==4) || (qd1 == 4 && qd2 == 1) ) 
            if qd2 == 3 && qd1 == 2
                % moving from the 2nd to the 3rd quadrants
                atanB = 2*pi + atanB;
            elseif qd2 == 2 && qd1 == 3
                atanA = 2*pi + atanA;
            end

            dA = [dA, atanB - atanA];
        else
            % some kind of discontinuity, take last value
            dA = [dA, dA(end)];            
        end
        
        dt = [dt, pts(i, 1) - pts(i - 1, 1)];
    end
                
    pts = [ pts(:, 1), (dA ./ dt)' ];       
    
    pts_f = [pts(:, 1), medfilt1(pts(:, 2), 5)];
       
    % mean and variances
    viqr = iqr(pts_f(:, 2));
    vmean = mean(pts_f(:, 2));
    
    function qd = quadrant(x, y)
        if x > 0
            if y > 0
                qd = 1;
            else
                qd = 4;
            end
        else
            if y > 0
                qd = 2;
            else
                qd = 3;
            end
        end
    end
end