function [Log, stop_times] = remove_excess_time(Log, start_times, stop_times, trial_options, postTrialTimes, time_conv, pre_dur)
    
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
    if trial_options(1) %There is a pretrial
        start_cond = 2;
    else
        start_cond = 1;
    end
     for time = start_cond:length(start_times)-1
        if time <= length(postTrialTimes)/2
            if trial_options(1) 
                time1 = postTrialTimes(time*2);
                time2 = postTrialTimes(time*2 + 1);
            else
                time1 = postTrialTimes(time*2 - 1);
                time2 = postTrialTimes(time*2);
            end
            totTime = time1 + time2;
            num_inds_erase = totTime/timestamp_diff;
            
            frame_inds_erase = totTime/frame_timestamp_diff;
 
            start_time_ind = find(Log.ADC.Time(1,:)>=(start_times(time)),1);
            frame_start_ind = find(Log.Frames.Time(:)>=(start_times(time)),1);
 
            %remove data corresponding to the amount of time in time1 from
            %data directly preceding the start time (so remove it from the
            %end of the previous trial)
            if num_inds_erase < start_time_ind
                ind1 = start_time_ind - num_inds_erase;
            else
                ind1 = 1;
            end
            if start_time_ind > 1
                ind2 = start_time_ind - 1;
            else
                ind2 = 1;
            end
            if frame_inds_erase < frame_start_ind
                frameInd1 = frame_start_ind - frame_inds_erase;
            else
                frameInd1 = 1;
            end
            if frame_start_ind > 1
               frameInd2 = frame_start_ind - 1;
            else
                frameInd2 = 1;
            end
        
            Log.Frames.Time(frameInd1:frameInd2) = [];
            Log.Frames.Position(frameInd1:frameInd2) = [];
            Log.ADC.Time(:, ind1:ind2) = [];
            Log.ADC.Volts(:, ind1:ind2) = [];
            
             %remove data corresponding to the amount of time in time2 from
            %data directly preceding the NEXT trial's start time (so remove
            %it from the end of the current trial)
            
           
 
%             for chan = 1:4
%                 Log.ADC.Time(chan, ind1:ind2) = [];
%                 Log.ADC.Volts(chan, ind1:ind2) = [];
% 
%             end
            if time > 1
               stop_times(time-1) = Log.ADC.Time(1, ind1-1);
            end
            
            
        end
    end

    

            


end