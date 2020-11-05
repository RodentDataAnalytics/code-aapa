function pts = read_trajectory(fn)
%READ_TRAJECTORY returns the points of the animal path

    rev_y = 1;
    rev_x = 0;
    d_arena = 254;
    d_max = 50;
    POINT_STATE_BAD = 5;

    % use a 3rd party function to read the file
    data = robustcsvread(fn);
    err = 0;
    pts = [];
    % HACK because of some Matlab stupidity
    for k = 1:length(data)        
        if isempty(data{k, 1})
            data{k,1} = '';
        end
    end
    % look for beginning of trajectory points
    l = strmatch('%%END_HEADER', data(:, 1));
    if isempty(l)
        err = 1;
    else
       for i = (l + 1):length(data)
           % extract time, X and Y coordinates
           if ~isempty(data{i, 1})
               t = sscanf(data{i, 2}, '%f');
               x = sscanf(data{i, 3}, '%f');
               y = sscanf(data{i, 4}, '%f');
               stat = sscanf(data{i, 6}, '%d'); % point status
               % discard missing samples
               if ~isempty(t) && ~isempty(x) && ~isempty(y) && ~isempty(stat) && stat ~= POINT_STATE_BAD
                   if ~(x == 0 && y == 0)
                       if rev_y
                           y = d_arena(1) - y;
                       end
                       if rev_x
                           x = d_arena(1) - x;
                       end
                       if ~isempty(pts) && d_max > 0
                           if sqrt(sum(([x y] - pts(end, 2:3)).^2)) > d_max
                               continue;
                           end
                       end                               
                       pts = [pts; t/1000. x y stat];
                   end
               end
           end
       end
    end

    if err
        error('invalid file format');
    end

end

