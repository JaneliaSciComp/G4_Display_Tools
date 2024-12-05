function ephys_grid_processing(s, exp_folder)
    
    if strcmp(class(s), 'char')
        s = load(s);
        s = s.settings;
    end

    processed_file_name = s.processed_file_name;

    channel_order = s.channel_order; 
    len_var_tol = s.len_var_tol; % By what percentage can the display time of a square vary before tossing it
    path_to_protocol = s.path_to_protocol;
    trial_options = s.trial_options;
    combined_command = s.combined_command;
    manual_first_start = s.manual_first_start;
    data_rate = s.data_rate;    
    pre_dur = s.pre_dur;
    post_dur = s.post_dur;
    time_conv = s.time_conv;
    corrTolerance = s.cross_correlation_tolerance;
    metadata_file = fullfile(exp_folder, 'metadata.mat');
    neutral_frame = s.neutral_frame; % The frame of the pattern that is neutral, to be shown between each square
    grid_columns = s.grid_columns;
    grid_rows = s.grid_rows;
    downsample_n = s.downsample_n;

    % Metadata file contains list of conditions that were bad the first
    % time and re-run.
    if isfile(metadata_file)
        load(metadata_file)
        if isfield(metadata, 'trials_rerun')
            trials_rerun = metadata.trials_rerun;
        else
            trials_rerun = [];
        end
    else
        metadata = {};
        trials_rerun = [];
    end

    num_ts_datatypes = length(channel_order);

    %Set which command we should be looking for in the log files
    if combined_command == 1
        command_string = 'Set control mode, pattern id, pattern function id, ao function id, frame rate';
    else
        command_string = 'start-display';
    end

    Log = load_tdms_log(exp_folder);
   % Current_idx = find(strcmpi(channel_order, 'current'));
    Volt_idx = find(strcmpi(channel_order, 'voltage'));
    Frame_ind = strcmpi(channel_order,'Frame Position');
    num_ADC_chans = length(Log.ADC.Channels);

    % We will split up the data by condition first (four conditions, two
    % with squares displaying bright and two with squares displaying dark),
    % then split up each condition by frame position.
    [exp_order, num_conds, num_reps, total_exp_trials] = get_exp_order(exp_folder, trial_options);

    % Get position functions so we know how long each square is supposed to
    % display for

    [position_functions, expanded_posfuncs, exp] = get_position_functions(path_to_protocol, num_conds);

    % These start and stop timestamps refer to entire conditions, not individual
    % square displays, so if there's only 4 trials with no inter/pre/post,
    % then there should only be 4 elements in each array. 
    [start_idx, stop_idx, start_disp_times, stop_disp_times] = get_start_stop_times(Log, command_string, manual_first_start);

    [times, ended_early, num_trials_short] = separate_originals_from_reruns(start_disp_times, stop_disp_times, start_idx, ...
        trial_options, trials_rerun, num_conds, num_reps);

      %get order of mode and pattern IDs (maybe use for error-checking?)
    [modeID_order, patternID_order] = get_modeID_order(combined_command, Log, times.origin_start_idx);

        [num_trials, trial_start_times, trial_stop_times, trial_modes, ...
    intertrial_start_times, intertrial_stop_times, intertrial_durs, times] = ...
    get_trial_startStop(exp_order, trial_options, times, modeID_order, ...
    time_conv, trials_rerun, ended_early);

    %Get the number of conditions short (versus total trials short) if experiment was ended early.
    num_conds_short = num_trials - length(trial_start_times);

    %get information about the data (durations, modes, gaps, etc) organized
    %by condition/repetition
    [cond_dur, cond_modes, cond_start_times, cond_gaps] = organize_durations_modes(num_conds, num_reps, ...
    num_trials, exp_order, trial_stop_times, trial_start_times,  ...
    trial_modes, time_conv, ended_early, num_conds_short);

    % pre-allocate arrays for aligning the timeseries data
    [cond_time, cond_data, inter_ts_time, inter_ts_data] = create_ts_arrays(cond_dur, data_rate, pre_dur, post_dur, num_ts_datatypes, ...
    num_conds, num_reps, trial_options, intertrial_durs, num_trials);

     % unaligned_ts_data: timeseries data that has not been aligned yet organized by cond/rep.

    [unaligned_cond_data, unaligned_inter_data] = get_unaligned_data(cond_data, num_ADC_chans, Log, ...
        trial_start_times, trial_stop_times, num_trials, num_conds_short, ...
        exp_order, Frame_ind, time_conv, intertrial_start_times, ...
        intertrial_stop_times, inter_ts_data, trial_options);

    alignment_data = position_cross_corr(expanded_posfuncs, ...
    num_conds_short, cond_modes, unaligned_cond_data, Frame_ind, corrTolerance);

    shifted_cond_data = shift_xcorrelated_data(unaligned_cond_data, alignment_data, ...
    Frame_ind, num_ADC_chans);

    [pattern_movement_times, pos_func_movement_times, bad_conds_movement, ...
    bad_reps_movement] = get_pattern_move_times(shifted_cond_data, ...
    position_functions, Frame_ind);
    if ~isempty(unaligned_inter_data)
        [intertrial_move_times] = get_intertrial_move_times(unaligned_inter_data, Frame_ind);
    else
        intertrial_move_times = [];
    end

   % shifted_cond_data = remove_bad_conditions(shifted_cond_data, bad_conds_movement, bad_reps_movement);

    %Get frame position movement times (expected and actual) and time gaps
    %between them. 
    [exp_frame_moves, exp_frame_move_inds, frame_moves, ...
    frame_move_inds, exp_frame_gaps,frame_gaps, bad_gaps] = ...
        get_frame_gaps(expanded_posfuncs, shifted_cond_data, Frame_ind);

    
    data_period = 1/data_rate;
    maxdiffs = [];
    for move = 1:length(position_functions)
        maxdiffs(move) = max(exp_frame_gaps{move}(:));
        ts_time{move} = data_period:data_period:maxdiffs(move)/data_rate;
    end
    longest_dur = max(maxdiffs);
   
    for cond = 1:num_conds
        num_frames(cond) = max(position_functions{cond}(:));
    end
    max_num_frames = max(num_frames);
    
    ts_data = nan([num_ts_datatypes num_conds num_reps max_num_frames longest_dur]);

    %Check quality. There are likely gaps in frame_gaps from noise frames
    %at beginning or end. Compare gaps to expected gaps and remove excess
    %ts_data is the data collected during stims, 5-D, [channel condition
    %rep frame data]. neutral_ts_data is the data collected during the
    %neutral display directly before that frame, so the data at
    %neutral_ts_data(2, 1, 1, 12, :) is the data collected directly before
    %the 12th frame was displayed. In both cases, the frame=1 dimension is
    %all NaNs because frame 1 is not a stim. So ts_data(2,2,2,1,:) will
    %give no data because frame 1 is the neutral frame. 

    [ts_data, neutral_ts_data] = separate_grid_data(ts_data, shifted_cond_data, frame_move_inds, ...
        Frame_ind, num_frames, num_ADC_chans);

    % downsample data

    % Separate the data collected from dark flashes and light flashes

    [dark_sq_data, light_sq_data, dark_avgReps_data, light_avgReps_data, ...
        dark_sq_neutral, light_sq_neutral, dark_avgReps_neutral, light_avgReps_neutral] = ...
    separate_light_dark(ts_data, neutral_ts_data, position_functions);

    for cond = 1:length(dark_avgReps_data)
        for frame = 1:size(dark_avgReps_data{cond},2)
            avgVoltDark = mean(squeeze(dark_avgReps_data{cond}(Volt_idx, frame, :)), 'omitnan');
            avgNeutDark = mean(squeeze(dark_avgReps_neutral{cond}(Volt_idx, frame, :)), 'omitnan');
            gaussValsDark{cond}(frame) = avgVoltDark-avgNeutDark;
            avgVoltLight = mean(squeeze(light_avgReps_data{cond}(Volt_idx, frame, :)), 'omitnan');
            avgNeutLight = mean(squeeze(light_avgReps_neutral{cond}(Volt_idx, frame, :)), 'omitnan');
            gaussValsLight{cond}(frame) = avgVoltLight-avgNeutLight;
        end
    end

    for cond = 1:length(gaussValsDark)
        x = 1:length(gaussValsDark{cond});
        y = gaussValsDark{cond};
        gaussFitsDark{cond} = fit(x.', y.', 'gauss2');
        x2 = 1:length(gaussValsLight{cond});
        y2 = gaussValsLight{cond};
        gaussFitsLight{cond} = fit(x2.', y2.', 'gauss2');
    end
    % For each square subtract average response from average response
    % during the neutral time right before the square displayed. Do
    % gaussian fit on this grid of numbers to find peak location.



    %downsample the data to be plotted: 
    for cond = 1:length(dark_sq_data)
        for chan = 1:size(dark_sq_data{cond},1)
            for rep = 1:size(dark_sq_data{cond},3)
                for frame = 1:size(dark_sq_data{cond},4)
                    dark_sq_data_ds{cond}(chan,1,rep,frame,:) = downsample(squeeze(dark_sq_data{cond}(chan,1,rep,frame,:)),downsample_n);
                    light_sq_data_ds{cond}(chan,1,rep,frame,:) = downsample(squeeze(light_sq_data{cond}(chan,1,rep,frame,:)),downsample_n);
                end
            end
        end
        ts_time_ds{cond} = downsample(ts_time{cond}, downsample_n);
    end



    create_grid_plot(dark_sq_data_ds, light_sq_data_ds, grid_rows, grid_columns, ...
        2, ts_time_ds, gaussFitsDark, gaussFitsLight, gaussValsDark, gaussValsLight, ...
        exp_folder);

    peak_frames = get_peak(ts_data, Volt_idx);


    save(fullfile(exp_folder,processed_file_name), 'ts_data', 'neutral_ts_data', ...
        'channel_order', 'frame_moves', 'frame_move_inds', 'frame_gaps', 'bad_gaps', ...
        'dark_sq_data', 'dark_sq_neutral', 'light_sq_neutral', 'light_sq_data', ...
        'dark_sq_data_ds', 'light_sq_data_ds', 'dark_avgReps_neutral', 'dark_avgReps_data', ...
        'light_avgReps_neutral', 'light_avgReps_data', 'alignment_data', 'gaussValsDark', ...
        'gaussValsLight', 'gaussFitsLight', 'gaussFitsDark', 'peak_frames');

 

end