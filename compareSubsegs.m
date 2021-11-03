close all
clear all
clc
addpath(fullfile(pwd,'objects'));
addpath(fullfile(pwd,'plotter'));

dirFeatures = fullfile(pwd,'results','feature_values_subsegments');
dirSubsegs = fullfile(pwd,'results','subsegmentation');
dirLabels = fullfile(pwd,'results','labels');
outF = fullfile(pwd,'results','paperFigs','subseg');

subsegs = {'0.6_5'};

visibility = 'off';
get_export_format = '.eps';
get_export_properties = 'High Quality';
strClasses = {'thigmotaxis','incursion','focused','chaining','avoidance'};
strFeats = {'angular distance to shock sector',...
    'median log-radius', 'iqr log-radius', 'centrality',...
    'median speed', 'iqr speed',...
    'median angular speed', 'iqr angular speed',...
    'angular dispersion (room)','angular dispersion (arena)',...
    'speed change frequency'};


for S = 1:length(subsegs)
    % Load
    load(fullfile(dirFeatures,['subseg_',subsegs{S},'.mat']),'feature_values');
    load(fullfile(dirSubsegs,['subseg_',subsegs{S},'.mat']),'subsegments');
    load(fullfile(dirLabels,['labels_',subsegs{S},'.mat']),'labels');
    %labels = y(:,6);
    tmpF = fullfile(outF,subsegs{S});
    if ~exist(tmpF,'dir')
        mkdir(tmpF);
    end
    
    % Animals
    animals = unique([subsegments.items.id]);
    sessions = unique([subsegments.items.trial]);
    animals_data = cell(length(animals), length(sessions)+1);
    for i = 1:length(subsegments.items)   
        id = subsegments.items(i).id;
        tr = subsegments.items(i).trial;
        gr = subsegments.items(i).group;
        animals_data{id, tr} = [animals_data{id,tr}, labels(i)];
        animals_data{id, end} = gr;
    end
    
    % Classes
    [haxes, fig] = tight_subplot_cm(2, 3, ...
                    [2 2], [3 3], [3 2], 20, 35);
    set(fig, 'Visible', 'off');
    classes = 1:length(strClasses); % unique([animals_data{:}]);
    % total_counts = length(subsegments.items);
    % p_values = nan(1, length(classes));
    c = newline;
    p_stats = "Friedman test p-values: " + c;
    for i = classes
        mfried = zeros((length(animals)/2) * (length(sessions)-1), 2);
        plot_data = zeros((length(animals)/2), length(sessions), 2);
        k = 1;
        for j1 = 1 : length(animals)
            if j1 >= 11
                animal = j1 - 10;
            else
                animal = j1;
            end
            group_nr = animals_data{j1, 7};
            for session = 1 : length(sessions)
                % Number of subsegments of this class
                nsegments = length(find(animals_data{j1, session}==classes(i)));
                individual_counts = length(find(animals_data{j1, session} >= 1));
                if individual_counts > 0
                    percent_val = 100 * nsegments / individual_counts;  % Percentage
                else
                    percent_val = 0;
                end
                plot_data(animal, session, group_nr) = percent_val;
                if (session > 2) && (session <= 5)
                    mfried(k, group_nr) = percent_val;
                    k = k + 1;
                end
            end
            if j1==length(animals)/2
                k = 1;
            end
        end
        % Friedman test
        [p_value, tbl] = friedman(mfried, length(animals)/2, 'off');
        strClasses{i}
        p_value
        p_stats = p_stats + strClasses{i} + ": " + format_p_value(p_value) + c;
        % writetable(cell2table(tbl),fullfile(tmpF,['class',num2str(i),'.csv']), 'WriteVariableNames',0);
        %Sums
        %pdata = zeros(length(sessions), 2);
        %for j = 1:length(sessions)
        %    v = sum(plot_data(j:length(sessions):end, :), 1);
        %    pdata(j, :) = v;
        %end
        %Plots
        ax = haxes(i);
        axes(ax);
        tmp1 = plot_data(:, :, 1);
        tmp2 = plot_data(:, :, 2);
        make_boxplot(tmp1, tmp2, 6, ax);
        % bar(tmp1)
        ylim([0, ... 
              max([tmp1, tmp2],[],'all')]);
        % f = figure('Visible', visibility);
        % ax = axes(f);
        %b = bar(pdata,'LineWidth',1.5,'parent',ax);
        %b(1).FaceColor = [1, 1, 1];  % Control - white
        %b(2).FaceColor = [0, 0, 0];  % Treated - black
        %title([strClasses{i} '\r\n' 'p-value: ' num2str(p)], 'FontSize', 10);
        % xlabel(ax,'trials');
        % ylabel(ax,'subsegments');
        %export_figure(f, tmpF, ['class',num2str(i)], get_export_format, get_export_properties)
        %close(f)
        %f = figure('Visible',visibility);
        %ax = axes(f);
        % b = bar(100*pdata/size(feature_values,1),'LineWidth',1.5,'parent',ax);
        %b(1).FaceColor = [1, 1, 1];  % Control
        %b(2).FaceColor = [0, 0, 0];  % Treated
        title(strClasses{i});
        %xlabel(ax,'trials');
        ylabel(ax, 'percentage');
    end
    ax = haxes(6);
    axes(ax);
    set(ax, 'Visible', 'off');
    fig_pos = get(fig, 'Position');
    ax_pos = get(ax, 'Position');
    ax_pos = ax_pos ./ [fig_pos(3), fig_pos(4), fig_pos(3), fig_pos(4)];
    ax_x = ax_pos(1);
    ax_y = ax_pos(2);
    ax_width = ax_pos(3);
    ax_height = ax_pos(4);
    pr = 0.9;
    ax_x = ax_x + ((1 - pr) * ax_width / 2);
    ax_y = ax_y + ((1 - pr) * ax_height / 2);
    ax_width = pr * ax_width;
    ax_height = pr * ax_height;
    %patch([ax_x], ax_pos(2) + 0.01, [1 1 1]);
    %patch(ax_pos(1), ax_pos(2), [0 0 0]);
    
    annotation('textbox', [ax_x, ax_y, ax_width, ax_height], ...
        'String', p_stats, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    export_figure(fig, tmpF, ['behdifferences_' erase(subsegs{S}, ".") '_new'], get_export_format, get_export_properties)
    close(fig)

    % Features
    %{
    feats = feature_values(:,1:11);
    classes = unique(labels);
    [labs,idx] = sort(labels);
    feats = feats(idx,:);
    for i = 1:size(feats,2)
        f = figure('Visible',visibility);
        ax = axes(f);
        title(strFeats{i})
        boxplot(feats(:,i),labs,'parent',ax);
        xlabel(ax,'classes');
        ylabel(ax,'values');
        export_figure(f, tmpF, ['feat',num2str(i)], get_export_format, get_export_properties)
        close(f)
    end
    %}
end