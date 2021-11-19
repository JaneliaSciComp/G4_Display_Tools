function [num_trials, trial_start_times, trial_stop_times,trial_move_start_times,...
    trial_modes, intertrial_start_times, intertrial_stop_times, ...
    intertrial_durs] = get_trial_startStop(exp_order, trial_options, start_times, stop_times, ...
    frame_movement_start_times, modeID_order, time_conv)
    
    num_trials = numel(exp_order);
    assert(length(start_times)==num_trials + trial_options(1) + trial_options(3) + ((num_trials-1)*trial_options(2)),...
        'unexpected number  of trials detected - check that pre-trial, post-trial, and intertrial options are correct')
    if trial_options(1) %if pre-trial was run
        trial_start_ind = 2; %exclude pre-trial
    else
        trial_start_ind = 1;
    end
    
    if trial_options(3) %if post-trial was run
        trial_end_ind = length(start_times)-1; %exclude post-trial
    else
        trial_end_ind = length(start_times);
%        start_times = [start_times stop_times(end)]; %if no post-trial, add last 'stop-display' to mark end of last trial
    end
    
    if trial_options(2) %if intertrials were run
        %get start times/modes of trials
        trial_start_times = start_times(trial_start_ind:2:trial_end_ind);
        trial_stop_times = stop_times(trial_start_ind:2:trial_end_ind);
        trial_move_start_times = frame_movement_start_times(trial_start_ind:2:trial_end_ind);
        trial_modes = modeID_order(trial_start_ind:2:trial_end_ind);

        %get start times/modes of intertrials
        intertrial_start_times = trial_start_times(2:2:end-1);
        intertrial_stop_times = trial_stop_times(2:2:end-1);
        intertrial_modes = modeID_order(trial_start_ind+1:2:trial_end_ind-1);
        intertrial_durs = double(intertrial_stop_times - intertrial_start_times)/time_conv;
        assert(all(intertrial_modes-intertrial_modes(1)==0),...
            'unexpected order of trials and intertrials - check that pre-trial, post-trial, and intertrial options are correct')
    else
        %get start times/modes of trials
        trial_start_times = start_times(trial_start_ind:trial_end_ind);
        trial_stop_times = start_times(trial_start_ind+1:trial_end_ind+1);
        trial_move_start_times = frame_movement_start_times(trial_start_ind:trial_end_ind);
        trial_modes = modeID_order(trial_start_ind:trial_end_ind);
    end

end