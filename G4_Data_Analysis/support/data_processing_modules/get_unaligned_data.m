function unaligned_ts_data = get_unaligned_data(ts_data, ...
    num_ADC_chans, Log, trial_start_times, trial_stop_times, num_trials, ...
    num_conds_short, exp_order, Frame_ind)

    unaligned_ts_data = ts_data;
    num_conds = size(ts_data, 2);    

    for trial=1:num_trials-num_conds_short
        cond = exp_order(trial);
        rep = floor((trial-1)/num_conds)+1;

        for chan = 1:num_ADC_chans
            start_ind = find(Log.ADC.Time(chan,:)>=trial_start_times(trial),1);
            stop_ind = find(Log.ADC.Time(chan,:)<=trial_stop_times(trial),1,'last');
            if isempty(stop_ind)
                stop_ind = length(Log.ADC.Time(chan,:));
            end
            data = Log.ADC.Volts(chan,start_ind:stop_ind);
            if length(data) < size(unaligned_ts_data,4)
                diff = size(unaligned_ts_data,4) - length(data);
                data = [data nan([1 diff])];
            elseif length(data) > size(unaligned_ts_data,4)
                data(size(unaligned_ts_data,4):end) = [];                
            end
            unaligned_ts_data(chan, cond, rep, :) = data;
        end
        %get frame position data for this trial, aligned to data rate
        start_ind_fr = find(Log.Frames.Time(1,:)>=trial_start_times(trial),1);
        stop_ind_fr = find(Log.Frames.Time(1,:)<=trial_stop_times(trial),1,'last');
        if isempty(stop_ind_fr)
            stop_ind_fr = length(Log.Frames.Time(1,:));
        end
        %Add 1 because raw data counts first frame as 0.
        fr_data = Log.Frames.Position(1,start_ind_fr:stop_ind_fr)+1;
        if length(fr_data) < size(unaligned_ts_data,4)
            fr_diff = size(unaligned_ts_data,4) - length(fr_data);
            fr_data = [fr_data nan([1 fr_diff])];
        elseif length(fr_data) > size(unaligned_ts_data,4)
            fr_data(size(unaligned_ts_data,4):end) = [];                
        end
        unaligned_ts_data(Frame_ind, cond, rep, :) = fr_data;
    end

    % Load expected frame position data for each trial. Use it to get the
    % movement time and to do cross correlation. 


end
