function get_intertrial_data(experiment_folder, processing_settings)

    % Get list of all folders from experiment folders and pull out only the
    % date folders. 

    all = dir(experiment_folder);
    isub = [all(:).isdir];
    folder_names = {all(isub).name};
    folder_names(ismember(folder_names,{'.','..'})) = [];
    date_folders = {};
    date = 1;
    for f = 1:length(folder_names)
        if strcmp(folder_names{f}(1), '0') || strcmp(folder_names{f}(1), '1')
            date_folders{date} = folder_names{f};
            date = date + 1;
        end
    end
    
    %Load settings (same for all flies)
    s = load(processing_settings);
    
    % Pull out all necessary settings that are the same accross flies
    %specify time ranges for parsing and data analysis
    data_rate = s.settings.data_rate; % rate (in Hz) which all data will be aligned to
    pre_dur = s.settings.pre_dur; %seconds before start of trial to include
    post_dur = s.settings.post_dur; %seconds after end of trial to include
    da_start = s.settings.da_start; %seconds after start of trial to start data analysis
    da_stop = s.settings.da_stop; %seconds before end of trial to end data analysis
    time_conv = s.settings.time_conv; %converts seconds to microseconds (TDMS timestamps are in micros)
    common_cond_dur = s.settings.common_cond_dur; %sets whether all condition durations are the same (1) or not (0), for error-checking
    processed_file_name = s.settings.processed_file_name;
    hist_datatypes = s.settings.hist_datatypes; %{'Frame Position', 'LmR', 'LpR'};
    trial_options = s.settings.trial_options;
    faLmR = s.settings.enable_faLmR;
    condition_pairs = s.settings.condition_pairs;
    enable_pos_series = s.settings.enable_pos_series;
    pos_conditions = s.settings.pos_conditions;
    num_positions = s.settings.num_positions;
    data_pad = s.settings.data_pad;
    sm_delay = s.settings.sm_delay;
    manual_first_start = s.settings.manual_first_start;
    combined_command = s.settings.combined_command;
    max_prctile = s.settings.max_prctile;
    path_to_protocol = s.settings.path_to_protocol;
    percent_to_shift = s.settings.percent_to_shift;
    wbf_range = s.settings.wbf_range;
    wbf_cutoff = s.settings.wbf_cutoff;
    wbf_end_percent = s.settings.wbf_end_percent;

    if isfield(s.settings, 'cross_correlation_tolerance')
        corrTolerance = s.settings.cross_correlation_tolerance;
    else
        corrTolerance = .02;
    end

    if isfield(s.settings, 'flying')
        flying = s.settings.flying;
    else
        flying = 1;
    end

    if isfield(s.settings, 'remove_nonflying_trials')
        remove_nonflying_trials = s.settings.remove_nonflying_trials;
    else
        remove_nonflying_trials = 1;
    end

    if isfield(s.settings, 'duration_diff_limit')
        duration_diff_limit = s.settings.duration_diff_limit;
    else
        duration_diff_limit = .1;
    end
    
    if isempty(s.settings.summary_save_path)
        summary_save_path = exp_folder;
    else
        summary_save_path = s.settings.summary_save_path;
    end
    summary_filename = strcat(s.settings.summary_filename, '.txt');


    %Set which command we should be looking for in the log files
    if combined_command == 1
        command_string = 'Set control mode, pattern id, pattern function id, ao function id, frame rate';
    else
        command_string = 'start-display';
    end

     %get indices for all datatypes - Any datatype not present in the
    %channel_order variable will return an empty index.
    Frame_ind = strcmpi(channel_order,'Frame Position');
    LmR_ind = find(strcmpi(channel_order,'LmR'));
    LpR_ind = find(strcmpi(channel_order,'LpR'));
    LmR_chan_idx = find(strcmpi(channel_order,'LmR_chan'));
    L_chan_idx = find(strcmpi(channel_order,'L_chan'));
    R_chan_idx = find(strcmpi(channel_order,'R_chan'));
    F_chan_idx = find(strcmpi(channel_order,'F_chan'));
    Current_idx = find(strcmpi(channel_order, 'current'));
    Volt_idx = find(strcmpi(channel_order, 'voltage'));
%    faLmR_ind = find(strcmpi(channel_order,'faLmR'));
    num_ts_datatypes = length(channel_order);
    num_ADC_chans = length(Log.ADC.Channels);
    



    %Loop through each date folder and each fly 

    for d = 1:length(date_folders)
        % For each date folder, get list of flies 

        allFlies = dir(fullfile(experiment_folder, date_folders{d}));
        isubFlies = [allFlies(:).isdir];
        fly_folder_names = {all(isubFlies).name};
        fly_folder_names(ismember(fly_folder_names,{'.','..'})) = [];

        for fly = 1:length(fly_folder_names)
            
            % For each fly in a single date folder

            fly_folder = fullfile(experiment_folder, date_folders{d}, fly_folder_names{fly});

            Log = load_tdms_log(fly_folder);
            metadata_file = fullfile(fly_folder, 'metadata.mat');
    
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
            [exp_order, num_conds, num_reps] = get_exp_order(fly_folder);

                % Determine the start and stop times of each trial
    
            [start_idx, stop_idx, start_times, stop_times] = get_start_stop_times(Log, command_string, manual_first_start);
            [frame_movement_start_times] = get_pattern_movement_times(start_times, Log);

            % Returns a struct, times, with 8 fields. The start times, stop times,
            % start idx, and movement times for the original trials and the rerun
            % trials. 
            times = separate_originals_from_reruns(start_times, stop_times, start_idx, ...
                trial_options, trials_rerun, num_conds, num_reps, frame_movement_start_times);
            
            %get order of pattern IDs (maybe use for error-checking?)
            [modeID_order, patternID_order] = get_modeID_order(combined_command, Log, times.origin_start_idx);

            %Determine start and stop times for different trial types (pre, inter,
    %regular). This also replaces start/stop times of trials marked as bad
    %during streaming with the start/stop times of the final re-run of that
    %trial so the correct data will be pulled later1`

            [num_trials, trial_start_times, trial_stop_times, ...
            trial_move_start_times,trial_modes, intertrial_start_times, intertrial_stop_times, ...
            intertrial_durs, times] = get_trial_startStop(exp_order, trial_options, ...
            times, modeID_order, time_conv, trials_rerun);

             %organize trial duration and control mode by condition/repetition
            [cond_dur, cond_modes,  cond_frame_move_time, cond_start_times, cond_gaps] = organize_durations_modes(num_conds, num_reps, ...
            num_trials, exp_order, trial_stop_times, trial_start_times,  ...
            trial_move_start_times, trial_modes, time_conv);
        
        
         % pre-allocate arrays for aligning the timeseries data
            [ts_time, ts_data, inter_ts_time, inter_ts_data] = create_ts_arrays(cond_dur, data_rate, pre_dur, post_dur, num_ts_datatypes, ...
            num_conds, num_reps, trial_options, intertrial_durs, num_trials);

            [bad_duration_conds, bad_duration_intertrials] = check_condition_durations(cond_dur, intertrial_durs, path_to_protocol, duration_diff_limit);

            for trial = 1:num_trials

                if trial_options(2)==1 && trial<num_trials && ~(any(trial==bad_duration_intertrials))
                    %get frame position data, upsampled to match ADC timestamps
                    start_ind = find(Log.Frames.Time(1,:)>=intertrial_start_times(trial),1);
                    stop_ind = find(Log.Frames.Time(1,:)<=intertrial_stop_times(trial),1,'last');
                    unaligned_time = double(Log.Frames.Time(1,start_ind:stop_ind)-intertrial_start_times(trial))/time_conv;
                    inter_ts_data(trial,:) = align_timeseries(inter_ts_time, unaligned_time, Log.Frames.Position(1,start_ind:stop_ind)+1, 'propagate', 'median');
                end
            end

            

        end


    end
    


end