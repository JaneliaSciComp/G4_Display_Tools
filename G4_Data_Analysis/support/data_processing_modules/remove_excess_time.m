function [Log, stop_times] = remove_excess_time(Log, start_times, stop_times, stop_idx, postTrialTimes, time_conv, pre_dur)
    
    % This function takes in postTrialTimes, which contains the amount of
    % time elapsed before and after each trial while other code was running
    % (like code updating the progress bar, the arena parameters, and
    % streaming data). Each trial will have two numbers in postTrialTimes.
    % The first is the amount of extra time on the end of the previous
    % trial. The 2nd is the amount of extra time on the end of the current
    % trial. Each trial has two periods of time where the condition is over
    % but the log is still collecting data while other code runs. First,
    % the code that updates data streaming stuff runs as soon as a trial
    % ends, and may take 200-300 ms. Then, code that updates the arena's
    % parameters and progress bar for the next trial runs. These are timed
    % separately. This amount of time worth of data is removed from the end
    % of each trial, so when we make our data sets and check for errors, we don't
    % have excessively longer data than the duration for each condition.

    timestamp_diff = Log.ADC.Time(1,2)-Log.ADC.Time(1,1);
    frame_timestamp_diff = Log.Frames.Time(2) - Log.Frames.Time(1);
    postTrialTimes = postTrialTimes*time_conv;
    for time = 2:length(start_times)-1
        if time <= length(postTrialTimes)/2
            time1 = postTrialTimes(time*2-1);
            time2 = postTrialTimes(time*2);
            num_inds_erase1 = time1/timestamp_diff;
            num_inds_erase2 = time2/timestamp_diff;
            frame_inds_erase1 = time1/frame_timestamp_diff;
            frame_inds_erase2 = time2/frame_timestamp_diff;
            start_time_ind = find(Log.ADC.Time(1,:)>=(start_times(time)*time_conv),1);
            frame_start_ind = find(Log.Frames.Time(:)>=(start_times(time)*time_conv),1);
            next_trial_start_time_ind = find(Log.ADC.Time(1,:)>=(start_times(time+1)*time_conv),1);
            next_trial_frame_start_ind = find(Log.Frames.Time(:)>=(start_times(time+1)*time_conv),1);
            %remove data corresponding to the amount of time in time1 from
            %data directly preceding the start time (so remove it from the
            %end of the previous trial)
            ind11 = start_time_ind - num_inds_erase1;
            ind12 = start_time_ind - 1;
            frameInd11 = frame_start_ind - frame_inds_erase1;
            frameInd12 = frame_start_ind - 1;
        
            Log.Frames.Time(frameInd11:frameInd12) = [];
            Log.Frames.Position(frameInd11:frameInd12) = [];
            Log.ADC.Time(:, ind11:ind12) = [];
            Log.ADC.Volts(:, ind11:ind12) = [];
            
             %remove data corresponding to the amount of time in time2 from
            %data directly preceding the NEXT trial's start time (so remove
            %it from the end of the current trial)
            
            ind21 = next_trial_start_time_ind - num_inds_erase2;
            ind22 = next_trial_start_time_ind - 1;
            frameInd21 = next_trial_frame_start_ind - frame_inds_erase2;
            frameInd22 = next_trial_frame_start_ind - 1;
            
            Log.Frames.Time(frameInd21:frameInd22) = [];
            Log.Frames.Position(frameInd21:frameInd22) = [];
            Log.ADC.Time(:, ind21:ind22) = [];
            Log.ADC.Volts(:, ind21:ind22) = [];

%             for chan = 1:4
%                 Log.ADC.Time(chan, ind1:ind2) = [];
%                 Log.ADC.Volts(chan, ind1:ind2) = [];
% 
%             end
            
%            stop_times(time-1) = Log.ADC.Time(1, ind11-1);
            
        end
    end
    
    for t = 2:length(start_times)
        
        start_ind = find(Log.ADC.Time(1,:)>=(start_times(time)*time_conv),1);
        stop_times(time-1) = Log.ADC.Time(1, start_ind-1);
    end
    
    

            


end