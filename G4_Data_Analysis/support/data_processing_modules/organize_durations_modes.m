function [cond_dur, cond_modes, cond_frame_move_time, cond_start_times, ...
    cond_gaps] = organize_durations_modes(num_conds, num_reps, ...
    num_trials, exp_order, trial_stop_times, trial_start_times, ...
    trial_move_start_times, trial_modes, time_conv, ended_early, num_trials_short) 
    
    % Holds duration of each trial
    cond_dur = nan(num_conds, num_reps);
    
    %Tells you t he time between the start of the trial (as defined by sending 
    %the 'Start-Display' command and the first movement of the pattern for each condition
    cond_frame_move_time = nan(num_conds, num_reps);

    %Tells you the timestamp at which the start-display was received for
    %each condition
    cond_start_times = nan(num_conds, num_reps);

    %Tells the you time that passed between the previous trial's end and
    %the condition's start. This doesn't include intertrials so the gap
    %should be expected to be the length of the intertrial plus a tiny
    %amount.

    cond_gaps = nan(num_conds, num_reps);
    
    
    % Holds the mode of each condition
    cond_modes = nan(num_conds, num_reps);
    if ended_early
        num_trials = num_trials - num_trials_short;
    end
    
    for trial=1:num_trials
        cond = exp_order(trial);
        rep = floor((trial-1)/num_conds)+1;
        cond_dur(cond,rep) = double(trial_stop_times(trial) - trial_start_times(trial))/time_conv;
        cond_modes(cond,rep) = trial_modes(trial);
        %time between the start of the trial and the timestamp at which the
        %frame position changed.
        cond_frame_move_time(cond, rep) = (double(trial_move_start_times(trial)) - double(trial_start_times(trial)))/(time_conv/1000);
        cond_start_times(cond,rep) = trial_start_times(trial);
        if trial == 1
            cond_gaps(cond,rep) = 0;
        else
            cond_gaps(cond,rep) = double(trial_start_times(trial)) - double(trial_stop_times(trial-1));
        end
    end

end