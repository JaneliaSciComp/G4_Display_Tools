function process_data_new(exp_folder, processing_settings_file)

%% Load .mat file containing settings and establish all parameters

    % Get data to be processed and processing settings manually if they
    % were not provided by the user
    if nargin==0
        exp_folder = uigetdir('C:/','Select a folder containing a G4_TDMS_Logs file');
        processing_settings_file = uigetfile('C:/','Select your processing settings file');
    end

    s = load(processing_settings_file);
    % channel_order = {'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR'}; %add faLmR below if desired (line 214)
    channel_order = s.settings.channel_order;


    %save all settings to be used in processing
    data_rate = s.settings.data_rate; % rate (in Hz) which all data will be aligned to
    pre_dur = s.settings.pre_dur; %seconds before start of frame position movement to include
    post_dur = s.settings.post_dur; %seconds after end of frame position movement to include
    da_start = s.settings.da_start; %seconds of data to remove from beginning before data analysis
    da_stop = s.settings.da_stop; %seconds of data to remove from end before data analysis
    time_conv = s.settings.time_conv; %converts seconds to microseconds (TDMS timestamps are in micros)
    common_cond_dur = s.settings.common_cond_dur; %sets whether all condition durations are the same (1) or not (0), for error-checking
    processed_file_name = s.settings.processed_file_name; %string used to name the .mat file containing processed data
    hist_datatypes = s.settings.hist_datatypes; %datatypes for histograms {'Frame Position', 'LmR', 'LpR'};
    trial_options = s.settings.trial_options; % array of three 1's or 0's indicating presence of pre/inter/post trial. [1 1 1] means all three present
    faLmR = s.settings.enable_faLmR; % 1 means you want faLmR calculated
    condition_pairs = s.settings.condition_pairs; % custom pairings for faLmR
    enable_pos_series = s.settings.enable_pos_series; % 1 means you want position series calculated
    pos_conditions = s.settings.pos_conditions; %conditions for psoition series
    num_positions = s.settings.num_positions;
    data_pad = s.settings.data_pad;
    sm_delay = s.settings.sm_delay;
    manual_first_start = s.settings.manual_first_start;
    combined_command = s.settings.combined_command; %1 if combined command was used
    max_prctile = s.settings.max_prctile;
    path_to_protocol = s.settings.path_to_protocol;
    percent_to_shift = s.settings.percent_to_shift;
    wbf_range = s.settings.wbf_range;
    wbf_cutoff = s.settings.wbf_cutoff;
    wbf_end_percent = s.settings.wbf_end_percent;

    %These settings were only added in newer versions of the settings file, so to
    %maintain the ability to use older versions, we check for their
    %presence and assign default values if they're not present.
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

    if isfield(s.settings, 'framePosPercentile')
        framePosPercentile = s.settings.framePosPercentile;
    else
        
        framePosPercentile = .98;
    end

    if isfield(s.settings, 'framePosTolerance')
        framePosTolerance = s.settings.framePosTolerance;
        
    else
        framePosTolerance = 1;
    end

    if isfield(s.settings, 'perctile_tol')
        perctile_tol = s.settings.perctile_tol;
        
    else
        perctile_tol = .02;
    end

    if isfield(s.settings, 'static_conds')
        static_conds = s.settings.static_conds;
    else
        static_conds = 0;
    end

    %Set which command we should be looking for in the log files
    if combined_command == 1
        command_string = 'Set control mode, pattern id, pattern function id, ao function id, frame rate';
    else
        command_string = 'start-display';
    end

    % Load TDMS file

    Log = load_tdms_log(exp_folder);
    
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
    
    metadata_file = fullfile(exp_folder, 'metadata.mat');

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



    %get the order in which conditions were run, the number of conditions
    %and repetitions in the experiment, and the total number of expected
    %trials
    [exp_order, num_conds, num_reps, total_exp_trials] = get_exp_order(exp_folder, trial_options);
    
    % Load the position functions for each condition and save the position
    % function (the expected frame position data) in the cell array
    % position_functions which has one element per condition. Save
    % experiment data (the loaded .g4p file) in exp for future use. 
    [position_functions, exp] = get_position_functions(path_to_protocol, num_conds);

    % Determine the start and stop times based on start-display command of
    % each trial (will be used later to find precise start/stop times).
    % start_idx and stop_idx contain the indices of the start and stop
    % display commands

    [start_idx, stop_idx, start_disp_times, stop_disp_times] = get_start_stop_times(Log, command_string, manual_first_start);

    % Returns a struct, times, which contains six arrays: 
%     times.origin_start_times = start_disp_times of original conditions
%     times.origin_stop_times = stop_disp_times of original conditions
%     times.origin_start_idx = start_idx of original conditions
%     times.rerun_start_times = same but for re-runs if there were any
%     times.rerun_stop_times 
%     times.rerun_start_idx 
%     ended_early is 1 if the experiment was ended early
%     num_trials_short is the number of trials that were not run if the
%     experiment was ended early.
    [times, ended_early, num_trials_short] = separate_originals_from_reruns(start_disp_times, stop_disp_times, start_idx, ...
        trial_options, trials_rerun, num_conds, num_reps);

      %get order of mode and pattern IDs (maybe use for error-checking?)
    [modeID_order, patternID_order] = get_modeID_order(combined_command, Log, times.origin_start_idx);
    


    %Determine start and stop times for different trial types (pre, inter,
    %regular). This also replaces start/stop times of trials marked as bad
    %during streaming with the start/stop times of the final re-run of that
    %trial so the correct data will be pulled later. Still using
    %start-display command (will fine tune alignment with frame position
    %movement later). trial_start_times includes conditions only, no
    %pre/inter/post. pre and post trials are not included at all, since
    %they aren't generally used in data analysis. 

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
    [ts_time, ts_data, inter_ts_time, inter_ts_data] = create_ts_arrays(cond_dur, data_rate, pre_dur, post_dur, num_ts_datatypes, ...
    num_conds, num_reps, trial_options, intertrial_durs, num_trials);

    
    % unaligned_ts_data: timeseries data that has not been aligned yet organized by cond/rep.

    unaligned_ts_data = get_unaligned_data(ts_data, num_ADC_chans, Log, ...
        trial_start_times, trial_stop_times, num_trials, num_conds_short, ...
        exp_order, Frame_ind);

    %Look for bad conditions due to duration, wbf, slope, etc and gather
    %cond/rep information.
    [bad_duration_conds, bad_duration_intertrials] = check_condition_durations(cond_dur, intertrial_durs, exp, duration_diff_limit);
    if ~static_conds
        [bad_slope_conds] = check_flat_conditions(unaligned_ts_data, Frame_ind);
    else
        bad_slope_conds = [];
    end
    if remove_nonflying_trials && flying
        [bad_WBF_conds, wbf_data] = find_bad_wbf_trials(unaligned_ts_data, wbf_range, ...
            wbf_cutoff,  wbf_end_percent, F_chan_idx);
    else
        bad_WBF_conds = [];
    end

       % Consolidate bad conditions from various reasons into one group with no repeats 
       % bad_conds and bad_reps line up, so for each element in bad_conds,
       % the corresponding element in bad_reps is the repetition of that
       % condition that was bad. 
    [bad_conds, bad_reps, bad_intertrials] = consolidate_bad_conds(bad_duration_conds, ...
        bad_duration_intertrials, bad_WBF_conds, bad_slope_conds);

    % Remove bad conditions from the unaligned_ts_data before doing cross
    % correlation so we don't waste time doing correlations on data we
    % already know is getting tossed. 

    unaligned_ts_data = remove_bad_conditions(unaligned_ts_data, bad_conds, bad_reps);
 
    % alignment_data: Struct with three variables
    %       - shift_numbers: the result of cross correlation between each
    %       collected frame position data and the expected frame position
    %       data telling how far to shift collected data to make them align
    %       - percent_off_zero: the percentage each cond/rep needs to be
    %       shifted
    %       - conds_outside_corr_tol: the cond/rep pairs for which
    %       percent_off_zero falls outside of tolerance. 
    alignment_data = position_cross_corr(position_functions, ...
    num_conds_short, cond_modes, unaligned_ts_data, Frame_ind, corrTolerance);

    % Check cross correlation data against the correlation tolerance which
    % determines if a condition was so far off it should be removed. Return
    % any bad conditions/reps for removal.
    [bad_corr_conds, bad_corr_reps] = compile_bad_xcorr_conds(alignment_data, ...
    corrTolerance, unaligned_ts_data);

    % Remove any conditions that need to be shifted by a larger percentage
    % than that given by the corrTolerance. 
    unaligned_ts_data = remove_bad_conditions(unaligned_ts_data, bad_corr_conds, bad_corr_reps);
    
    % Shifts each timeseries cond/rep pair by the lag
    % found by xcorr
    shifted_ts_data = shift_xcorrelated_data(ts_data, alignment_data, ...
    num_conds_short, Frame_ind, num_ADC_chans);

    % frame_movement_times: The index at which the pattern started moving
    %       for each cond/rep pair with index 0 being the start of the
    %       shifted data after cross correlating to its position function.

    % Now that data has been shifted, do cross correlation for quality
    % check




        % Find bad condition/rep pairs for removal before cross correlation
     % and shifting
    [bad_duration_conds, bad_duration_intertrials] = check_condition_durations(cond_dur, ...
        intertrial_durs, path_to_protocol, duration_diff_limit);
    if ~static_conds
        [bad_slope_conds] = check_flat_conditions(trial_start_times, trial_stop_times, Log, num_reps, num_conds, exp_order);
    else
        bad_slope_conds = [];
    end
     if remove_nonflying_trials && flying
        [bad_WBF_conds, wbf_data] = find_bad_wbf_trials(Log, unaligned_ts_data, ...
            wbf_range, wbf_cutoff, wbf_end_percent, trial_start_times, ...
            trial_stop_times, num_conds, num_reps, exp_order,  num_trials, num_conds_short);
    else
        bad_WBF_conds = [];
     end

      [bad_conds, bad_reps, bad_intertrials, bad_conds_summary] = ...
        consolidate_bad_conds(bad_duration_conds, bad_duration_intertrials,...
        bad_WBF_conds, bad_slope_conds, num_trials, num_conds, num_reps, trial_options);


end