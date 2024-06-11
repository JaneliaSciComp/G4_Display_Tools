function [times, ended_early, num_extra_trials] = separate_originals_from_reruns(start_times, ...
    stop_times, start_idx, trial_options, trials_rerun, num_conds, num_reps, frame_movement_start_times)
   
    num_trials = num_conds*num_reps; 
   
    total_original_trials = num_trials + trial_options(1) + trial_options(3) + ((num_trials-1)*trial_options(2)); 
    if length(trials_rerun) ~= 0
        total_rerun_trials = length(trials_rerun) + (length(trials_rerun)-1)*trial_options(2)+1;
    else
        total_rerun_trials = 0;
    end
   
    if total_original_trials + total_rerun_trials > length(start_times)
       warning(['The number of trials detected do not match the number of trials expected. ' ...
           'It is assumed this experiment was ended early and processing will attempt to continue anyway.']);
       ended_early = 1;
       num_extra_trials = total_original_trials + total_rerun_trials - length(start_times);
    elseif total_original_trials + total_rerun_trials < length(start_times)
        warning('More trials executed than were expected. Processing may fail.');
        ended_early = 0;
        num_extra_trials = 0;
    else
        ended_early = 0;
        num_extra_trials = 0;
    end

   
    if length(start_times) > total_original_trials
       
       % Set origin_start_times, stop times, and stop idx to reflect only
       % the times of the original trials
       if trial_options(3)
           originalEndPt = total_original_trials - 1;
       else
           originalEndPt = total_original_trials;
       end
       
       for trial = 1:originalEndPt
           origin_start_times(trial) = start_times(trial);
           origin_stop_times(trial) = stop_times(trial);
           origin_start_idx(trial) = start_idx(trial);
           origin_movement_start_times(trial) = frame_movement_start_times(trial);
       end
       
       %Because post trial is run AFTER the rescheduled conditions
       if trial_options(3)
           origin_start_times(end+1) = start_times(end);
           origin_stop_times(end+1) = stop_times(end);
           origin_start_idx(end+1) = start_idx(end);
           origin_movement_start_times(end+1) = frame_movement_start_times(end);
       end
       
       for rerun = 1:total_rerun_trials
           idx = originalEndPt + rerun;
           
           rerun_start_times(rerun) = start_times(idx);
           rerun_stop_times(rerun) = stop_times(idx);
           rerun_start_idx(rerun) = start_idx(idx);
           rerun_movement_start_times(rerun) = frame_movement_start_times(idx);
       end
       
    else
       
       origin_start_times = start_times;
       origin_stop_times = stop_times;
       origin_start_idx = start_idx;
       origin_movement_start_times = frame_movement_start_times;
       
       rerun_start_times = [];
       rerun_stop_times = [];
       rerun_start_idx = [];
       rerun_movement_start_times = [];
       
       
       
    end
   
    times = struct;
    times.origin_start_times = origin_start_times;
    times.origin_stop_times = origin_stop_times;
    times.origin_start_idx = origin_start_idx;
    times.origin_movement_start_times = origin_movement_start_times;
    times.rerun_start_times = rerun_start_times;
    times.rerun_stop_times = rerun_stop_times;
    times.rerun_start_idx = rerun_start_idx;
    times.rerun_movement_start_times = rerun_movement_start_times;
   
end