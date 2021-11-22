function [Log, stop_times] = remove_excess_time(Log, start_times, stop_times, stop_idx, postTrialTimes, time_conv, pre_dur)
    
    % This function takes in postTrialTimes, which contains the amount of
    % time elapsed after each trial while the data streaming stuff updated.
    % It removes that amount of time worth of data directly before each
    % start time, so when we make our data sets and check for errors, we don't
    % have excessively longer data than the duration for each condition.

    timestamp_diff = Log.ADC.Time(1,2)-Log.ADC.Time(1,1);
    frame_timestamp_diff = Log.Frames.Time(2) - Log.Frames.Time(1);
    postTrialTimes = postTrialTimes*time_conv;
    for time = 2:length(start_times)
        if time <= length(postTrialTimes)
            num_inds_erase = postTrialTimes(time-1)/timestamp_diff;
            frame_inds_erase = postTrialTimes(time-1)/frame_timestamp_diff;
            start_time_ind = find(Log.ADC.Time(1,:)>=(start_times(time)-pre_dur*time_conv),1);
            frame_start_ind = find(Log.Frames.Time(:)>=(start_times(time)-pre_dur*time_conv),1);
            %remove data corresponding to the correct amount of time from the
            %Log
            ind1 = start_time_ind - num_inds_erase;
            ind2 = start_time_ind - 1;
            frameInd1 = frame_start_ind - frame_inds_erase;
            frameInd2 = frame_start_ind - 1;
        
            Log.Frames.Time(frameInd1:frameInd2) = [];
            Log.Frames.Position(frameInd1:frameInd2) = [];
            Log.ADC.Time(:, ind1:ind2) = [];
            Log.ADC.Volts(:, ind1:ind2) = [];

%             for chan = 1:4
%                 Log.ADC.Time(chan, ind1:ind2) = [];
%                 Log.ADC.Volts(chan, ind1:ind2) = [];
% 
%             end
            
            stop_times(time-1) = Log.ADC.Time(1, ind1-1);
            
        end
    end
    

            


end