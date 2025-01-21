function [unaligned_ts_data, unaligned_inter_data] = get_unaligned_data(ts_data, num_ADC_chans, Log, ...
    trial_start_times, trial_stop_times, num_trials, num_conds_short, exp_order, ...
    Frame_ind, time_conv, intertrial_start_times, intertrial_stop_times, ...
    inter_ts_data, trial_options, data_rate)

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
                data(size(unaligned_ts_data,4)+1:end) = [];
                time(size(unaligned_ts_data,4)+1:end) = []; 
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
     %   fr_time = Log.Frames.Time(1,start_ind_fr:stop_ind_fr)- trial_start_times(trial)/time_conv;
        % Frame position is measured every 2 ms, so each index in the array
        % represents 2 ms. In the ADC struct, every index represents 1 ms.
        % So we need to fill in the gaps of the frame position data to make
        % it the same length as the ADC data. 
        full_fr_data = nan([1 length(fr_data)*(data_rate/500)]);
        el = 1;
        for full = 1:(data_rate/500):length(full_fr_data)
            full_fr_data(full) = fr_data(el);
            full_fr_data(full+1:full+((data_rate/500)-1)) = fr_data(el);
            el = el + 1;
        end
        if length(full_fr_data) < size(unaligned_ts_data,4)
            fr_diff = size(unaligned_ts_data,4) - length(full_fr_data);
            full_fr_data = [full_fr_data nan([1 fr_diff])];
 %           fr_time = [fr_time nan([1 fr_diff])];
        elseif length(full_fr_data) > size(unaligned_ts_data,4)
            full_fr_data(size(unaligned_ts_data,4)+1:end) = [];  
 %           fr_time(size(unaligned_ts_data,4):end) = [];  
        end
        unaligned_ts_data(Frame_ind, cond, rep, :) = full_fr_data;
%        unaligned_ts_time(Frame_ind, cond, rep, :) = fr_time;

        %get intertrial data if it exists
         if trial_options(2)==1 && trial<num_trials
             for chan_int = 1:num_ADC_chans
                %get frame position data, upsampled to match ADC timestamps
                start_it_ind = find(Log.Frames.Time(1,:)>=intertrial_start_times(trial),1);
                stop_it_ind = find(Log.Frames.Time(1,:)<=intertrial_stop_times(trial),1,'last');
                data_int = Log.ADC.Volts(chan_int, start_it_ind:stop_it_ind);
 %               time_int = Log.ADC.Time(chan_int, start_it_ind:stop_it_ind)- intertrial_start_times(trial)/time_conv;
                if length(data_int) < size(inter_ts_data,3)
                    diff = size(inter_ts_data,3) - length(data_int);
                    data_int = [data_int nan([1 diff])];
 %                   time_int = [time_int nan([1 diff])];
                elseif length(data_int) > size(inter_ts_data,3)
                    data_int(size(inter_ts_data,3)+1:end) = [];
 %                   time_int(size(inter_ts_data,3):end) = []; 
                end
                unaligned_inter_data(chan_int, trial, :) = data_int; 
   %             unaligned_inter_time(chan_int, trial, :) = time_int;

             end

             %get frame position data for this trial, aligned to data rate
            start_fr_int = find(Log.Frames.Time(1,:)>=intertrial_start_times(trial),1);
            stop_fr_int = find(Log.Frames.Time(1,:)<=intertrial_stop_times(trial),1,'last');
            if isempty(stop_fr_int)
                stop_fr_int = length(Log.Frames.Time(1,:));
            end
            %Add 1 because raw data counts first frame as 0.
            fr_data_int = Log.Frames.Position(1,start_fr_int:stop_fr_int)+1;
            full_int_data = nan([1 length(fr_data_int)*2]);
            el = 1;
            for full = 1:2:length(full_int_data)
                full_int_data(full) = fr_data_int(el);
                full_int_data(full+1) = fr_data_int(el);
                el = el + 1;
            end
   %         fr_time_int = Log.Frames.Time(1,start_fr_int:stop_fr_int)- intertrial_start_times(trial)/time_conv;
            if length(full_int_data) < size(inter_ts_data,3)
                fr_int_diff = size(inter_ts_data,3) - length(full_int_data);
                full_int_data = [full_int_data nan([1 fr_int_diff])];
    %            fr_time_int = [fr_time_int nan([1 fr_int_diff])];
            elseif length(full_int_data) > size(inter_ts_data,3)
                full_int_data(size(inter_ts_data,3)+1:end) = [];  
      %          fr_time_int(size(inter_ts_data,3):end) = [];  
            end
            unaligned_inter_data(Frame_ind, trial, :) = full_int_data;
    %        unaligned_inter_time(Frame_ind, trial, :) = fr_time_int;

         elseif trial_options(2) == 0
             unaligned_inter_data = [];
%
        end
    end

end
