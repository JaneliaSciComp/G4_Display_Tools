function [cond_dur, cond_modes, cond_frame_move_time] = organize_durations_modes(num_conds, num_reps, ...
    num_trials, exp_order, trial_stop_times, trial_start_times, ...
    trial_move_start_times, trial_modes, time_conv) 
    
    % Holds duration of each trial
    cond_dur = nan(num_conds, num_reps);
    
    %Tells you t he time between the start of the trial (as defined by sending 
    %the 'Start-Display' command and the first movement of the pattern for each condition
    cond_frame_move_time = nan(num_conds, num_reps);
    
    % Holds the mode of each condition
    cond_modes = nan(num_conds, num_reps);
    
    for trial=1:num_trials
        cond = exp_order(trial);
        rep = floor((trial-1)/num_conds)+1;
        cond_dur(cond,rep) = double(trial_stop_times(trial) - trial_start_times(trial))/time_conv;
        cond_modes(cond,rep) = trial_modes(trial);
        cond_frame_move_time(cond, rep) = (double(trial_move_start_times(trial)) - double(trial_start_times(trial)))/(time_conv/1000);
    end

end