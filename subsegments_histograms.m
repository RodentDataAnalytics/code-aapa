feats_str = {'Ang. distance shock signed';...%1
    'Log avg. radius';'Log var radius';...%2,3
    'Time centre';...%4
    'IQR speed arena';...%5
    'Average speed (arena)';...%6
    'Mode angular velocity (arena)';...%7
    'Average angular velocity (arena)';...%8
    'Angular dispersion';...%9
    'Angular dispersion (arena)';...%10
    'Frequency speed change (arena)';...%11
    'Angular distance shock';...%12
    'Variance angular velocity (arena)';...%13
    'Shock radius';...%14
    'Number of entrances';...%15
    'Maximum time between shocks';...%16
    'Time for first shock';...%17
    'Variance speed arena';...%18
    'Length (arena)';...%19
    'Number of shocks';...%20
    'IQR radius (arena)';...%21
    'Length';...%22
    'Latency'};%23

get_export_format = '.eps';
get_export_properties = 'High Quality';

subsegs = {'0.5_5', '0.55_5', '0.6_5'};

output = 'results';

load(fullfile(pwd, output, 'full_paths.mat'), 'paths');
feature_values_paths = load(fullfile(pwd, output, 'feature_values_paths.mat'), 'feature_values');

segments_shock = load(fullfile(pwd, output, 'segmentation_shock.mat'), 'segments');
feature_values_shock = load(fullfile(pwd, output, 'feature_values_shock.mat'), 'feature_values');

length_feat_idx = 22;
[haxes, fig] = tight_subplot_cm(1, length(subsegs), ...
                    [1 1], [2 2], [1 1], 15, 35);
for S = 1:length(subsegs)
    dirSubsegs = fullfile(pwd, output, 'subsegmentation');
    dirFeatures = fullfile(pwd, output, 'feature_values_subsegments');
    load(fullfile(dirSubsegs,['subseg_',subsegs{S},'.mat']),'subsegments');
    feature_values_subsegments = load(fullfile(dirFeatures,['subseg_',subsegs{S},'.mat']), 'feature_values');   
    ax = haxes(S);
    axes(ax);
    histogram(feature_values_subsegments.feature_values(:, length_feat_idx), ...
        'BinWidth', 30);
    thr = subsegs{S};
    thr = thr(1:end-2);
    title(['threshold: ' thr])
    xlabel('length (cm)')
    ylim([0, 850])
    xlim([0, 2000])
    set(gca,'box','off')
end
export_figure(fig, fullfile(pwd, output, 'paperFigs'), 'subsegments_length_histo_threeThresholds_new', get_export_format, get_export_properties)
close(fig)
