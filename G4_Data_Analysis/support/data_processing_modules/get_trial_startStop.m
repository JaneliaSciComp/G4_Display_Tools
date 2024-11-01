function [num_trials, trial_start_times, trial_stop_times, trial_modes, ...
    intertrial_start_times, intertrial_stop_times, intertrial_durs, times] = ...
    get_trial_startStop(exp_order, trial_options, times, modeID_order, ...
    time_conv, trials_rerun, ended_early)
    

    start_times = times.origin_start_times;
    stop_times = times.origin_stop_times;
%    frame_movement_start_times = times.origin_movement_start_times;
    rerun_start_times = times.rerun_start_times;
    rerun_stop_times = times.rerun_stop_times;
%    rerun_movement_start_times = times.rerun_movement_start_times;
    
    num_trials = numel(exp_order); %Only refers to conditions not inter/pre/post

    
    % assert(length(start_times)==num_trials + trial_options(1) + trial_options(3) + ((num_trials-1)*trial_options(2)),...
    %     'unexpected number  of trials detected - check that pre-trial, post-trial, and intertrial options are correct')
    if ended_early
        trial_options(3) = 0;
    end

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
%        trial_move_start_times = frame_movement_start_times(trial_start_ind:2:trial_end_ind);
        trial_modes = modeID_order(trial_start_ind:2:trial_end_ind);
        
        if ~isempty(rerun_start_times)
            rerun_trial_start_times = rerun_start_times(1:2:end);
            rerun_trial_stop_times = rerun_stop_times(1:2:end);
 %           rerun_trial_move_start_times = rerun_movement_start_times(1:2:end);
            rerun_intertrial_start_times = rerun_start_times(2:2:end-1);
            rerun_intertrial_stop_times = rerun_stop_times(2:2:end-1);
        else
            rerun_trial_start_times = [];
            rerun_trial_stop_times = [];
%            rerun_trial_move_start_times = [];
            rerun_intertrial_start_times = [];
            rerun_intertrial_stop_times = [];
        end

        %get start times/modes of intertrials
        intertrial_start_times = start_times(trial_start_ind+1:2:trial_end_ind-1);
        intertrial_stop_times = stop_times(trial_start_ind+1:2:trial_end_ind-1);
        intertrial_modes = modeID_order(trial_start_ind+1:2:trial_end_ind-1);
        intertrial_durs = double(intertrial_stop_times - intertrial_start_times)/time_conv;
        assert(all(intertrial_modes-intertrial_modes(1)==0),...
            'unexpected order of trials and intertrials - check that pre-trial, post-trial, and intertrial options are correct')

    else
        %get start times/modes of trials
        trial_start_times = start_times(trial_start_ind:trial_end_ind);
        trial_stop_times = stop_times(trial_start_ind:trial_end_ind);
%        trial_move_start_times = frame_movement_start_times(trial_start_ind:trial_end_ind);
        trial_modes = modeID_order(trial_start_ind:trial_end_ind);
        intertrial_start_times = [];
        intertrial_stop_times = [];
        intertrial_durs = [];
        
        if ~isempty(rerun_start_times)
            rerun_trial_start_times = rerun_start_times;
            rerun_trial_stop_times = rerun_stop_times;
%            rerun_trial_move_start_times = rerun_movement_start_times;
        else
            rerun_trial_start_times = [];
            rerun_trial_stop_times = [];
%            rerun_trial_move_start_times = [];
        end
        rerun_intertrial_start_times = [];
        rerun_intertrial_stop_times = [];
            
    end
    
    
    % At this point, get the start times of any trials that were re-run,
    % figure out what condition/rep was being re-run, and replace the
    % appropriate timestamp in trial_start_times with the timestamp of the
    % re-run version
    
    for rerun = 1:length(trials_rerun)
        
        % Find the re run condition and rep in exp_order to get the trial
        % number
        
        rerun_cond = trials_rerun{rerun}(1);
        rerun_rep = trials_rerun{rerun}(2);
        
        trial = find(exp_order(rerun_rep,:)==rerun_cond);
        trial_num = size(exp_order,2)*(rerun_rep-1) + trial;     
        
        %replace the appropriate timestamp in trial_start_times, stop
        %times, and move start times, with the rerun timestamps. 
        
        trial_start_times(trial_num) = rerun_trial_start_times(rerun);
        trial_stop_times(trial_num) = rerun_trial_stop_times(rerun);
%        trial_move_start_times(trial_num) = rerun_trial_move_start_times(rerun);
        
        
    end
    
    times.rerun_trial_start_times = rerun_trial_start_times;
    times.rerun_trial_stop_times = rerun_trial_stop_times;
%    times.rerun_trial_move_start_times = rerun_trial_move_start_times;
    times.rerun_intertrial_start_times = rerun_intertrial_start_times;
    times.rerun_intertrial_stop_times = rerun_intertrial_stop_times;

end