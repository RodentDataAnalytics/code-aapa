function [center_x,center_y,center_r,trial_angle,time_r,rotation_freq] = exp_properties
%EXP_PROPERTIES 

    center_x = 127;
    center_y = 127;
    center_r = 127;
    trial_angle = pi/180*135; %all trials have the same angle
    time_r = 0.75*center_r;   %TIME_WITHIN_RADIUS_R
    rotation_freq = 1;
    
end

