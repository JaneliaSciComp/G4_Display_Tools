function [unaligned_ts_data, unaligned_ts_time, unaligned_inter_data, ...
    unaligned_inter_time] = get_unaligned_data(ts_data, num_ADC_chans, Log, ...
    trial_start_times, trial_stop_times, num_trials, num_conds_short, exp_order, ...
    Frame_ind, time_conv, intertrial_start_times, intertrial_stop_times, ...
    inter_ts_data, trial_options)

    unaligned_ts_data = ts_data;
    unaligned_ts_time = ts_data;

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
            time = Log.ADC.Time(chan, start_ind:stop_ind)- trial_start_times(trial)/time_conv;
            if length(data) < size(unaligned_ts_data,4)
                diff = size(unaligned_ts_data,4) - length(data);
                data = [data nan([1 diff])];
                time = [time nan([1 diff])];
            elseif length(data) > size(unaligned_ts_data,4)
                data(size(unaligned_ts_data,4):end) = [];
                time(size(unaligned_ts_data,4):end) = []; 
            end
            
            unaligned_ts_data(chan, cond, rep, :) = data;
            unaligned_ts_time(chan, cond, rep, :) = time;
        end

        %get frame position data for this trial, aligned to data rate
        start_ind_fr = find(Log.Frames.Time(1,:)>=trial_start_times(trial),1);
        stop_ind_fr = find(Log.Frames.Time(1,:)<=trial_stop_times(trial),1,'last');
        if isempty(stop_ind_fr)
            stop_ind_fr = length(Log.Frames.Time(1,:));
        end
        %Add 1 because raw data counts first frame as 0.
        fr_data = Log.Frames.Position(1,start_ind_fr:stop_ind_fr)+1;
        fr_time = Log.Frames.Time(1,start_ind_fr:stop_ind_fr)- trial_start_times(trial)/time_conv;
        if length(fr_data) < size(unaligned_ts_data,4)
            fr_diff = size(unaligned_ts_data,4) - length(fr_data);
            fr_data = [fr_data nan([1 fr_diff])];
            fr_time = [fr_time nan([1 fr_diff])];
        elseif length(fr_data) > size(unaligned_ts_data,4)
            fr_data(size(unaligned_ts_data,4):end) = [];  
            fr_time(size(unaligned_ts_data,4):end) = [];  
        end
        unaligned_ts_data(Frame_ind, cond, rep, :) = fr_data;
        unaligned_ts_time(Frame_ind, cond, rep, :) = fr_time;

        %get intertrial data if it exists
         if trial_options(2)==1 && trial<num_trials
             % for chan_int = 1:num_ADC_chans
             %    %get frame position data, upsampled to match ADC timestamps
             %    start_it_ind = find(Log.Frames.Time(1,:)>=intertrial_start_times(trial),1);
             %    stop_it_ind = find(Log.Frames.Time(1,:)<=intertrial_stop_times(trial),1,'last');
             %    data_int = Log.ADC.Volts(chan_int, start_it_ind:stop_it_ind);
             %    time_int = Log.ADC.Time(chan_int, start_it_ind:stop_it_ind)- intertrial_start_times(trial)/time_conv;
             %    if length(data_int) < size(inter_ts_data,2)
             %        diff = size(inter_ts_data,2) - length(data_int);
             %        data_int = [data_int nan([1 diff])];
             %        time_int = [time_int nan([1 diff])];
             %    elseif length(data_int) > size(inter_ts_data,2)
             %        data_int(size(inter_ts_data,2):end) = [];
             %        time_int(size(inter_ts_data,2):end) = []; 
             %    end
             %    unaligned_inter_data(trial, :) = data_int; 
             %    unaligned_inter_time(trial, :) = time_int;
             % 
             % end

             %get frame position data for this trial, aligned to data rate
            start_fr_int = find(Log.Frames.Time(1,:)>=intertrial_start_times(trial),1);
            stop_fr_int = find(Log.Frames.Time(1,:)<=intertrial_stop_times(trial),1,'last');
            if isempty(stop_fr_int)
                stop_fr_int = length(Log.Frames.Time(1,:));
            end
            %Add 1 because raw data counts first frame as 0.
            fr_data_int = Log.Frames.Position(1,start_fr_int:stop_fr_int)+1;
            fr_time_int = Log.Frames.Time(1,start_fr_int:stop_fr_int)- intertrial_start_times(trial)/time_conv;
            if length(fr_data_int) < size(inter_ts_data,2)
                fr_int_diff = size(inter_ts_data,2) - length(fr_data_int);
                fr_data_int = [fr_data_int nan([1 fr_int_diff])];
                fr_time_int = [fr_time_int nan([1 fr_int_diff])];
            elseif length(fr_data_int) > size(inter_ts_data,2)
                fr_data_int(size(inter_ts_data,2):end) = [];  
                fr_time_int(size(inter_ts_data,2):end) = [];  
            end
            unaligned_inter_data(trial, :) = fr_data_int;
            unaligned_inter_time(trial, :) = fr_time_int;

        end
    end

end
