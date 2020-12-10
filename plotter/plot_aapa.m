function f = plot_aapa(points,varargin)
%PLOT_AAPA 

    visible = 0;
    draw_start = 1;
    draw_end = 1;
    draw_shock = 1;
    draw_arena = 1;
    ax = [];

    ang = pi/180*135; %ones(1,6); %'SHOCK_AREA_ANGLE'
    ra = 127;
    x0 = 127;
    y0 = 127;
    
    LineWidth_traj = 2;
    Color_path = [0 0 0];
    LineStyle = '-';
    
    Color_start = 'blue';
    Symbol_start = 'filled';
    Symbol_start_area = 80;
    Symbol_start_linewidth = 1;
    
    Color_end = 'red';
    Symbol_end = 'x';
    Symbol_end_area = 100;
    Symbol_end_linewidth = 2;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'draw_shock')
            draw_shock = 0;
        elseif isequal(varargin{i},'draw_end')
            draw_end = 0;
        elseif isequal(varargin{i},'draw_start')
            draw_start = 0;    
        elseif isequal(varargin{i},'draw_arena')
            draw_arena = 0;            
        elseif isequal(varargin{i},'parent')
            ax = varargin{i+1};
            
        elseif isequal(varargin{i},'Color_path')
            Color_path = varargin{i+1};        
        elseif isequal(varargin{i},'Color_start')
            Color_start = varargin{i+1};
        elseif isequal(varargin{i},'Color_end')
            Color_end = varargin{i+1};
        
        elseif isequal(varargin{i},'visible')
            visible = varargin{i+1};
        end
    end
    
    if isempty(ax)
        f = figure('Visible',visible);
        ax = axes(f);
    else
        f = [];
    end
    hold(ax,'on');
    axis(ax,'square','off');
    daspect(ax,[1 1 1]); 
    
    % draw the arena
    if draw_arena
        rectangle('Position',[x0 - ra, y0 - ra, ra*2, ra*2],...
        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3, 'parent',ax);
    end
    
    % draw a 60 deg shock area
    if draw_shock
        angi = ang - pi/6;
        angf = ang + pi/6;
        harc = plot_arc(angi, angf, x0, y0, ra*.99, ax);
        set(harc,'edgecolor', [.6 .6 .6], 'linewidth', .1, 'facecolor', [.6 .6 .6]);
    end
    
    % draw the animal path
    plot(points(:,1), points(:,2), '-', 'LineWidth', LineWidth_traj, 'Color', Color_path, 'LineStyle', LineStyle, 'parent',ax);
    
    % mark starting and ending points
    if draw_start
        scatter(points(1,1), points(1,2),...
            Symbol_start_area,Symbol_start,...
            'MarkerEdgeColor',Color_start,'MarkerFaceColor',Color_start,...
            'LineWidth',Symbol_start_linewidth,'parent',ax);
    end
    if draw_end
        scatter(points(end,1), points(end,2),...
            Symbol_end_area,Symbol_end,...
            'MarkerEdgeColor',Color_end,'MarkerFaceColor',Color_end,...
            'LineWidth',Symbol_end_linewidth,'parent',ax);
    end
    
    hold(ax,'off');
end

