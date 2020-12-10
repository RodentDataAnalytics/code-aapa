function f = make_boxplot(dataG1, dataG2, ntrials)
%PMAKE_BOXPLOT 

    if size(dataG1,2) ~= size(dataG2,2)
        error('Groups should have the same number of trials')
    end

    pos = 0;
    for i = 1:ntrials
        for j = 1:2
            if i ~= 1 && j == 1
                pos = [pos, pos(end)+2];
            else
                pos = [pos, pos(end)+1];
            end
        end
    end
    pos(1) = [];
    posx = [];
    for i = 1:2:length(pos)
        posx = [posx, mean([pos(i),pos(i+1)])];
    end
    posx_str = cellstr(num2str((1:length(posx))'));
    if size(posx_str,1) == 6
        posx_str{6} = 'test';
    end

    t = [];
    for j = 1:size(dataG1,2)
        t = [t,dataG1(:,j)];
        t = [t,dataG2(:,j)];
    end
    
    f = figure('Visible','off');
    ax = axes(f);
    boxplot(t,'positions',pos);
    set(ax,'XTick',posx,'XTickLabel',posx_str);
    xlabel('Trials');
    box off;
    
    h = findobj(ax,'Tag','Box');
    for j=1:2:length(h)
         patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
    end
    h = findobj(ax,'Tag','Median');
    for j=1:2:length(h)
         line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', 2.5);
    end

    h = findobj(ax,'Tag','Box');
    for j=2:2:length(h)
         patch(get(h(j),'XData'), get(h(j), 'YData'), [1 1 1]);
    end
    h = findobj(ax,'Tag','Median');
    for j=2:2:length(h)
         line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [0 0 0], 'LineWidth', 2.5);
    end
    
    h = findobj(ax, 'Tag', 'Outliers');
    set(h, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0]);
    set(h, 'Visible', 'off'); 
end

