function lat = path_latency(pts)
%PATH_LATENCY 

    if size(pts, 1) > 0
        lat = pts(end, 1) - pts(1, 1);
    else
        lat = 0;
    end    

end

