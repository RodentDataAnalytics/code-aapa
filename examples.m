% Plot some animal pathing

get_export_format = '.svg';
get_export_properties = 'High Quality';

output = fullfile(pwd,'results');

if ~exist(fullfile(output,'paperFigs','examples'),'dir')
    mkdir(fullfile(output,'paperFigs','examples'))
end

% Full paths
load(fullfile(output,'full_paths.mat'),'paths');
for i = 1:3
    f = plot_aapa(paths.items(i).points(:,2:3));
    name = sprintf('p%d_tr%d_id%d_gr%d',...
        i, paths.items(i).trial, paths.items(i).id, paths.items(i).group);
    export_figure(f, fullfile(output,'paperFigs','examples'), name, get_export_format, get_export_properties);
    close(f);

    pts = paths.items(i).property('ARENA_COORDINATES');
    f = plot_aapa(pts(:,2:3),'draw_shock');
    name = sprintf('p%d_tr%d_id%d_gr%d_arena',...
        i, paths.items(i).trial, paths.items(i).id, paths.items(i).group);
    export_figure(f, fullfile(output,'paperFigs','examples'), name, get_export_format, get_export_properties);
    close(f);
end

% Segments
load(fullfile(output,'segmentation_shock.mat'),'segments');
for i = 1:3
    f = plot_aapa(segments.items(i).points(:,2:3));
    name = sprintf('p%d_tr%d_id%d_gr%d_seg%d',...
        i, segments.items(i).trial, segments.items(i).id, segments.items(i).group, segments.items(i).segment);
    export_figure(f, fullfile(output,'paperFigs','examples'), name, get_export_format, get_export_properties);
    close(f);

    pts = segments.items(i).property('ARENA_COORDINATES');
    ii = find(pts(:,1) >= segments.items(i).points(1,1));
    jj = find(pts(:,1) <= segments.items(i).points(end,1));
    if isempty(ii) || isempty(jj) || pts(ii(1),1) > pts(jj(end),1)
        warning('Arena coordinates not found!')
        ii = 1;
        jj = size(pts,1);
    end
    f = plot_aapa(pts(ii(1):jj(end),2:3),'draw_shock');
    name = sprintf('p%d_tr%d_id%d_gr%d_seg%d_arena',...
        i, segments.items(i).trial, segments.items(i).id, segments.items(i).group, segments.items(i).segment);
    export_figure(f, fullfile(output,'paperFigs','examples'), name, get_export_format, get_export_properties);
    close(f);
end

% Subsegments
load(fullfile(output,'subsegmentation','subseg_0.6_5.mat'),'subsegments');
for i = 1:3
    f = plot_aapa(subsegments.items(i).points(:,2:3));
    name = sprintf('sub%d_tr%d_id%d_gr%d',...
        i, subsegments.items(i).trial, subsegments.items(i).id, subsegments.items(i).group);
    export_figure(f, fullfile(output,'paperFigs','examples'), name, get_export_format, get_export_properties);
    close(f);

    pts = subsegments.items(i).property('ARENA_COORDINATES');
    ii = find(pts(:,1) >= subsegments.items(i).points(1,1));
    jj = find(pts(:,1) <= subsegments.items(i).points(end,1));
    if isempty(ii) || isempty(jj) || pts(ii(1),1) > pts(jj(end),1)
        warning('Arena coordinates not found!')
        ii = 1;
        jj = size(pts,1);
    end
    f = plot_aapa(pts(ii(1):jj(end),2:3),'draw_shock');
    name = sprintf('sub%d_tr%d_id%d_gr%d_arena',...
        i, subsegments.items(i).trial, subsegments.items(i).id, subsegments.items(i).group);
    export_figure(f, fullfile(output,'paperFigs','examples'), name, get_export_format, get_export_properties);
    close(f);
end

% Classes
toplot = {[7,10,6035], [29,3365,6032], [5,103,2526], [50,309,520], [174,154,269]};
for i = 1:length(toplot)
    switch i 
        case 1
            c = 'TT';
        case 2
            c = 'IC';
        case 3
            c = 'FC';
        case 4
            c = 'CH';
        case 5
            c = 'AD';
        otherwise
            error('Wrong class')
    end
    for j = 1:length(toplot{i})
        idx = toplot{i}(j);
        
        f = plot_aapa(subsegments.items(idx).points(:,2:3));
        name = sprintf('%s_sub%d_tr%d_id%d_gr%d',c,...
            idx, subsegments.items(idx).trial, subsegments.items(idx).id, subsegments.items(idx).group);
        export_figure(f, fullfile(output,'paperFigs','examples'), name, get_export_format, get_export_properties);
        close(f);

        pts = subsegments.items(idx).property('ARENA_COORDINATES');
        ii = find(pts(:,1) >= subsegments.items(idx).points(1,1));
        jj = find(pts(:,1) <= subsegments.items(idx).points(end,1));
        if isempty(ii) || isempty(jj) || pts(ii(1),1) > pts(jj(end),1)
            warning('Arena coordinates not found!')
            ii = 1;
            jj = size(pts,1);
        end
        f = plot_aapa(pts(ii(1):jj(end),2:3),'draw_shock');
        name = sprintf('%s_sub%d_tr%d_id%d_gr%d_arena',c,...
            idx, subsegments.items(idx).trial, subsegments.items(idx).id, subsegments.items(idx).group);
        export_figure(f, fullfile(output,'paperFigs','examples'), name, get_export_format, get_export_properties);
        close(f);    
    end
end