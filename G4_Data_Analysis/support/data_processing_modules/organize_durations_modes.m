function [cond_dur, cond_modes] = organize_durations_modes(num_conds, num_reps, ...
    num_trials, exp_order, trial_stop_times, trial_start_times, trial_modes, time_conv) 
    
    cond_dur = nan(num_conds, num_reps);
    cond_modes = nan(num_conds, num_reps);
    for trial=1:num_trials
        cond = exp_order(trial);
        rep = floor((trial-1)/num_conds)+1;
        cond_dur(cond,rep) = double(trial_stop_times(trial) - trial_start_times(trial))/time_conv;
        cond_modes(cond,rep) = trial_modes(trial);
    end

end