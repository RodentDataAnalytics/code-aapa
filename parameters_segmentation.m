% Why 0.6?
% Some stats to show why
output = fullfile(pwd,'results');

load(fullfile(output,'full_paths.mat'),'paths');
load(fullfile(output,'segmentation_shock.mat'),'segments');
load(fullfile(output,'feature_values_paths.mat'),'feature_values');
lens_full = feature_values(:,22);
load(fullfile(output,'feature_values_shock.mat'),'feature_values');
lens_shock = feature_values(:,22);
load(fullfile(output,'feature_values_subsegments','subseg_0.6_5.mat'),'feature_values');
lens_subsegs06 = feature_values(:,22);
load(fullfile(output,'feature_values_subsegments','subseg_0.7_5.mat'),'feature_values');
lens_subsegs07 = feature_values(:,22);
load(fullfile(output,'feature_values_subsegments','subseg_0.5_5.mat'),'feature_values');
lens_subsegs05 = feature_values(:,22);

N = length(segments.items);
[center_x,center_y,center_r,trial_angle,time_r,rotation_freq] = exp_properties;

%Parameters
tmin = 1;   %perform stats when the subsegment is at least of 1 sec
dt_min = 5; %exclude subsegments of that length          
SPEED_THRESHOLD = 0.6; %this needs to be checked

vms = cell(N,1);
len3 = [];
for i = 1:N
    iflag = 0;
    for j = 1:length(paths.items)
        if segments.items(i).track == paths.items(j).track &&...
                segments.items(i).group == paths.items(j).group &&...
                segments.items(i).id == paths.items(j).id &&...
                segments.items(i).trial == paths.items(j).trial
            this_traj = paths.items(j);
            iflag = 1;
            break;
        end
    end
    if ~iflag
        error('Arena coordinates not found!')
    end
    
    %Take the arena coordinates and apply some filtering
    pts = path_arena_coord(segments.items(i), center_x, center_y, rotation_freq, 'ARENA', this_traj); 
    [~, ~, pts] = path_angular_velocity(pts, center_x, center_y);
    pts = [pts(:, 1), medfilt1(pts(:, 2), 5)]; 
    
    pti = 1;
    n = size(pts, 1);
    new_seg = 1;
    cum_dist = 0; 
    
    myvms_for = {};
    
    while new_seg
        myvms = [];
        mypoints = {};
        mypoints_ = [];
        new_seg = 0;
        for ii = pti:n                                      
            if pts(ii, 1) - pts(pti, 1) < tmin
                lens = length(pts(pti:ii, 1));
                if lens == 1
                    lens2 = 0;
                else
                    lens2 = path_length(pts(pti:ii, :));
                end
                continue;
            end            
            
            % compute median speed
            vm = median( pts(pti:ii, 2) );
            % check with the threshold
            vm1 = abs(pts(ii, 2) - vm);
            myvms = [myvms;[vm,vm1,lens,lens2]];
            
            % see if we crossed the "threshold"
            if vm1 > SPEED_THRESHOLD
                % look for a "peak" point within 1 sec
                if ii < n
                    j = ii + 1;
                    ptf = j;
                    while j < n && pts(j, 1) - pts(ii, 1) <= .5  
                        if pts(ii, 2) > 0
                            if pts(j, 2) > pts(ii, 2)
                                ptf = j;
                            end
                        else
                            if pts(j, 2) < pts(ii, 2)
                                ptf = j;
                            end
                        end
                        j = j + 1;
                    end     
                    % see if we are long enough
                    mypoints = [mypoints;{[pts(pti, 1), pts(ptf, 1) - pts(pti, 1)]}];
                    if pts(ptf, 1) - pts(pti, 1) > dt_min                             
                        %here we keep the segment
                    else
                        len3 = [len3;path_length(pts(pti:ptf, :))]; 
                    end
                    pti = min(ptf + 1, n);        
                    new_seg = 1;
                    break;
                end                
            end
        end
        if isempty(mypoints)
            mypoints = {mypoints};
        end
        myvms_for = [myvms_for;[{myvms},mypoints]];
    end 
    vms{i} = myvms_for; 
end

%Merge all the subsegments
tmp = cell(length(vms),1);
for i = 1:length(vms)
    tmp{i} = cell2mat(vms{i}(:,1));
end
vms = [vms,tmp];

% Find peaks of angular speed
peaks = [];
for i = 1:length(vms)
    try
        pks = findpeaks(vms{i,2}(:,2));
        peaks = [peaks; [pks,i*ones(length(pks),1)]];
    catch
    end
end

% Local - Median(angular speed)
%histogram(peaks(:,1)); : cut the totally extreme values after 2
plotPeaks = peaks(:,1);
plotPeaks(plotPeaks > 2) = [];

f = figure('visible','off');
ax = axes(f);
percentiles = prctile(plotPeaks,[25,50,75]);
maximum = percentiles(3) + 1.5 * (percentiles(3) - percentiles(1));
box1 = plotPeaks;
box2 = plotPeaks(plotPeaks>maximum);
boxplot([box1;box2],[ones(length(box1),1);2*ones(length(box2),1)]);
percentiles2 = prctile(box2,[25,50,75]);
maximum2 = percentiles2(3) + 1.5 * (percentiles2(3) - percentiles2(1));

export_figure(f, pwd, 'speedPeaks', '.svg', 'High Quality');
close(f);

% Average length of segments within time less than tmin = 1
lengths1min = [];
lengths1size = [];
for i = 1:size(vms,1)
    for j = 1:size(vms{i,1},1)
        if ~isempty(vms{i,1}{j,1})
            lengths1min = [lengths1min;vms{i,1}{j,1}(end,4)];
            lengths1size = [lengths1size;vms{i,1}{j,1}(end,3)];
        end
    end
end
med1 = median(lengths1min); %1min
med2 = median(lengths1size);%size of 1 min
med3 = median(len3);        %5min

kept = 100*sum(lens_shock)/sum(lens_full);

kept06 = 100*sum(lens_subsegs06)/sum(lens_shock); % %of segments kept
kept07 = 100*sum(lens_subsegs07)/sum(lens_shock);
kept05 = 100*sum(lens_subsegs05)/sum(lens_shock);

