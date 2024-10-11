function get_shift_values(ts_data, num_ADC_chans,Log, trial_start_times, ...
    trial_stop_times, num_trials, num_conds_short, exp_order, Frame_ind, ...
    path_to_protocol, condModes)

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
            unaligned_ts_data(chan, cond, rep, :) = data;
        end
        %get frame position data for this trial, aligned to data rate
        start_ind_fr = find(Log.Frames.Time(1,:)>=trial_start_times(trial),1);
        stop_ind_fr = find(Log.Frames.Time(1,:)<=trial_stop_times(trial),1,'last');
        if isempty(stop_ind)
            stop_ind = length(Log.Frames.Time(1,:));
        end
        fr_data = Log.Frames.Position(1,start_ind_fr:stop_ind_fr)+1;
        unaligned_ts_data(Frame_ind, cond, rep, :) = fr_data;
    end

    % Get the times at which the frame first moved
    exp = load(path_to_protocol,'-mat');
    [expPath, expName, ~] = fileparts(path_to_protocol);
    blockTrials = exp.exp_parameters.block_trials;

    for cond = 1:num_conds
        if condModes(cond) == 1
            funcName = blockTrials{cond,3};
            funcPath = fullfile(expPath, 'Functions', [funcName '.mat']);
            funcData = load(funcPath);
            expectedData = funcData.pfnparam.func;
            exp_idx = 1; 
            while expectedData(exp_idx + 1) - expectedData(exp_idx) == 0
                exp_idx = exp_idx + 1; 
            end
            expectedMove = [expectedData(exp_idx) expectedData(exp_idx + 1)]; 

            

        end
    end



end
