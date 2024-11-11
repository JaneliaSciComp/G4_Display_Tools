function ephys_grid_processing(exp_folder)
    
    channel_order = {'current', 'voltage'};
    len_var_tol = .05; % By what percentage can the display time of a square vary before tossing it
    path_to_protocol = '';
    trial_options = [0 0 0];


    Log = load_tdms_log(exp_folder);
    Current_idx = find(strcmpi(channel_order, 'current'));
    Volt_idx = find(strcmpi(channel_order, 'voltage'));
    exp_data = load(path_to_protocol);

    [exp_order, num_conds, num_reps, total_exp_trials] = get_exp_order(exp_folder, trial_options);

    % Get position functions so we know how long each square is supposed to
    % display for

    [position_functions, exp] = get_position_functions(path_to_protocol, num_conds);

    raw_volt_data = Log.ADC.Volts(Volt_idx,:);
    raw_curr_data = Log.ADC.Volts(Current_idx,:);
    raw_frame_data = Log.Frames.Position(1,:);

end