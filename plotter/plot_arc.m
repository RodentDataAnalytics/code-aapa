function P = plot_arc(a,b,h,k,r,parent)
    % Plot a circular arc as a pie wedge.
    % a is start of arc in radians, 
    % b is end of arc in radians, 
    % (h,k) is the center of the circle.
    % r is the radius.
    % Try this:   plot_arc(pi/4,3*pi/4,9,-4,3)
    % Author:  Matt Fig
    % https://www.mathworks.com/matlabcentral/answers/6322-drawing-a-segment-of-a-circle
    t = linspace(a,b);
    x = r*cos(t) + h;
    y = r*sin(t) + k;
    x = [x h x(1)];
    y = [y k y(1)];
    P = fill(x,y,'r','parent',parent);
    axis(parent,[h-r-1 h+r+1 k-r-1 k+r+1]) 
    if ~nargout
        clear P
    end
end