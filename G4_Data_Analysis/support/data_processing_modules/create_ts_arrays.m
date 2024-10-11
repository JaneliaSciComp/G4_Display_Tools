function [ts_time, ts_data, inter_ts_time, inter_ts_data] = create_ts_arrays(cond_dur, ...
    data_rate, pre_dur, post_dur, num_ts_datatypes, num_conds, num_reps, ...
    trial_options, intertrial_durs, num_trials)


    %pre-allocate space
    longest_dur = max(max(cond_dur));
    data_period = 1/data_rate;
    ts_time = -pre_dur-data_period:data_period:longest_dur+post_dur+data_period; 
    ts_data = nan([num_ts_datatypes+1 num_conds num_reps length(ts_time)]);
    if trial_options(2) %if intertrials were run
        inter_ts_time = 0:1/data_rate:max(intertrial_durs)+0.01; 
        inter_ts_data = nan([num_trials-1 length(inter_ts_time)]);
    else
        inter_ts_time = [];
        inter_ts_data = [];
    end 
    
end