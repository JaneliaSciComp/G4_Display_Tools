
function process_protocol_2_ephysGrid(exp_folder, settings_file)
    

    
    %% Update this section to match protocol
    trial_options = [0 0 0];   
   
%    metadata_file = 'C:\Users\taylo\Documents\Programming\Reiser\EphysGridTestData\2024_12_12_13_40\metadata_2024_12_12_13_40.mat';
    grid_columns = [14 14];
    grid_rows = [14 14];
    grid_conds = [1 2]; % The number of the condition that displays squares and needs a grid plot

    %% Don't change below this line
%    G4_TDMS_folder2struct(fullfile(exp_folder, 'Log Files'));
 %   movefile(fullfile(exp_folder,'Log Files','*'),exp_folder);

    load(settings_file);
    processed_file_name = settings.processed_file_name;
    channel_order = settings.channel_order; 
    len_var_tol = settings.len_var_tol; % By what percentage can the display time of a square vary before tossing it
    path_to_protocol = settings.path_to_protocol;
    % trial_options = settings.trial_options;
    combined_command = settings.combined_command;
    manual_first_start = settings.manual_first_start;
    data_rate = settings.data_rate;    
    pre_dur = settings.pre_dur;
    post_dur = settings.post_dur;
    time_conv = settings.time_conv;
    corrTolerance = settings.cross_correlation_tolerance;
    metadata_file = fullfile(exp_folder, 'metadata.mat');
    neutral_frame = settings.neutral_frame; % The frame of the pattern that is neutral, to be shown between each square
    % grid_columns = settings.grid_columns;
    % grid_rows = settings.grid_rows;
    downsample_n = settings.downsample_n;
    
    Log = load_tdms_log(exp_folder);
    
    num_ts_datatypes = length(channel_order);
    
    %Set which command we should be looking for in the log files
    if combined_command == 1
        command_string = 'Set control mode, pattern id, pattern function id, ao function id, frame rate';
    else
        command_string = 'Start-Display';
    end
    
    Volt_idx = find(strcmpi(channel_order, 'voltage'));
    Frame_ind = strcmpi(channel_order,'Frame Position');
    num_ADC_chans = length(Log.ADC.Channels);
    

    load(fullfile(exp_folder, 'currentExp.mat'));
    num_conds = length(currentExp.pattern.patternList);
    num_starts = length(find(strcmp(Log.Commands.Name, command_string)));
    if sum(trial_options==[0 0 0])==3
        num_reps = num_starts/num_conds;
    elseif sum(trial_options==[1 0 0])==3
        num_reps = (num_starts-1)/num_conds;

    elseif sum(trial_options==[0 1 0])==3
         num_reps = num_starts/(num_conds + (num_conds-1));

    elseif sum(trial_options==[0 0 1])==3
        num_reps = (num_starts-1)/num_conds;

    elseif sum(trial_options==[1 1 0])==3
        num_reps = (num_starts -1)/(num_conds + (num_conds-1));
    elseif sum(trial_options==[0 1 1])==3
        num_reps = (num_starts -1)/(num_conds + (num_conds-1));
    elseif sum(trial_options==[1 0 1])==3
        num_reps = (num_starts-2)/num_conds;
    elseif sum(trial_options==[1 1 1])==3
        num_reps = (num_starts-2)/(num_conds + (num_conds-1));
    end

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

    %Assumes no randomization
    for rep = 1:num_reps
        exp_order(:, rep) = [1:num_conds];
    end

    %get position functions for alignment - assumes mode 1
    for cond = 1:num_conds
        funcName = currentExp.function.functionName{cond};
        funcPath = fullfile(exp_folder, 'Functions', funcName);
        funcData = load(funcPath);
        expectedData = funcData.pfnparam.func;
        position_functions{cond} = expectedData;
        expanded_posfuncs{cond} = nan([1 length(expectedData)*(data_rate/500)]);
        el = 1;
        for full = 1:(data_rate/500):length(expanded_posfuncs{cond})
            expanded_posfuncs{cond}(full) = expectedData(el);
            expanded_posfuncs{cond}(full+1:full+((data_rate/500)-1)) = expectedData(el);
            el = el + 1;
        end
    end

%Get patterns for grid conditions
    for gridcond = 1:length(grid_conds)
        patName = currentExp.pattern.pattNames{grid_conds(gridcond)};
        patPath = fullfile(exp_folder, 'Patterns', patName);
        patData = load(patPath);
        pattern_data = patData.pattern.Pats;
        grid_patterns{gridcond} = pattern_data;
    end

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
        intertrial_stop_times, inter_ts_data, trial_options, data_rate);

    alignment_data = position_cross_corr(expanded_posfuncs, ...
    num_conds_short, cond_modes, unaligned_cond_data, Frame_ind, corrTolerance);

%    shifted_cond_data = shift_xcorrelated_data(unaligned_cond_data, alignment_data, ...
%    Frame_ind, num_ADC_chans);
    shifted_cond_data = unaligned_cond_data;
    if ~isempty(alignment_data.conds_outside_corr_tol)
        warning('At least one condition fell out of tolerance during cross correlation. Please check alignment_data for more info.');
    end
    

    [pattern_movement_times, pos_func_movement_times, bad_conds_movement, ...
    bad_reps_movement] = get_pattern_move_times(shifted_cond_data, ...
    position_functions, Frame_ind);
    if ~isempty(unaligned_inter_data)
        [intertrial_move_times] = get_intertrial_move_times(unaligned_inter_data, Frame_ind);
    else
        intertrial_move_times = [];
    end

    % In this type of protocol only the first x number of conditions are grid displays, 
%       The rest are bars. The conditions that are grids are given by grid_conds
    num_conds_grid = length(grid_conds);
    for c = 1:length(grid_conds)
        expanded_posfuncs_grid{c} = expanded_posfuncs{grid_conds(c)};
        shifted_cond_data_grid(:,c,:,:) = shifted_cond_data(:, grid_conds(c), :, :);
    end
    % 
    % % Also the first condition runs through the position function twice so
    % % we need to divide up into first half and second half
    % 
    % shifted_data_cond1_part1 = shifted_cond_data_cond1(:,:,:,1:size(shifted_cond_data_cond1,4)/2);
    % shifted_data_cond1_part2 = shifted_cond_data_cond1(:,:,:,size(shifted_cond_data_cond1,4)/2:size(shifted_cond_data_cond1,4));


    %Get frame position movement times (expected and actual) and time gaps
    %between them. 
    [exp_frame_moves, exp_frame_move_inds, frame_moves, ...
    frame_move_inds, exp_frame_gaps,frame_gaps, bad_gaps] = ...
        get_frame_gaps(expanded_posfuncs_grid, shifted_cond_data_grid, Frame_ind);

    % [~, ~, frame_moves_pt2, ...
    % frame_move_inds_pt2, ~,frame_gaps_pt2, bad_gaps_pt2] = ...
    %     get_frame_gaps(expanded_posfuncs_cond1, shifted_data_cond1_part2, Frame_ind);

    
    data_period = 1/data_rate;
    maxdiffs = [];
    
    for move = 1:length(expanded_posfuncs_grid)
        flash_durs{move} = exp_frame_gaps{move}(1:2:end);
        maxdiffs(move) = max(flash_durs{move}(:));
        ts_time{move} = data_period:data_period:maxdiffs(move)/data_rate;
    end
    longest_dur = max(maxdiffs);
   
    for cond = 1:num_conds_grid
        num_frames(cond) = size(grid_patterns{cond},3);
    end
    max_num_frames = max(num_frames);
    
    ts_data_grid = nan([num_ts_datatypes num_conds_grid num_reps max_num_frames longest_dur]);

      %Check quality. There are likely gaps in frame_gaps from noise frames
    %at beginning or end. Compare gaps to expected gaps and remove excess
    %ts_data is the data collected during stims, 5-D, [channel condition
    %rep frame data]. neutral_ts_data is the data collected during the
    %neutral display directly before that frame, so the data at
    %neutral_ts_data(2, 1, 1, 12, :) is the data collected directly before
    %the 12th frame was displayed. In both cases, the frame=1 dimension is
    %all NaNs because frame 1 is not a stim. So ts_data(2,2,2,1,:) will
    %give no data because frame 1 is the neutral frame. 

    [ts_data_grid, neutral_ts_data] = separate_grid_data(ts_data_grid, shifted_cond_data_grid, frame_move_inds, ...
        Frame_ind, num_frames, num_ADC_chans);

    % [ts_data_grid_pt2, neutral_ts_data_pt2] = separate_grid_data(ts_data_grid, shifted_data_cond1_part2, frame_move_inds_pt2, ...
    %     Frame_ind, num_frames, num_ADC_chans);

    % for chan = 1:size(ts_data_grid,1)
    %     for cond = 1:size(ts_data_grid,2)
    %         for rep = 1:size(ts_data_grid,3)
    %             for frame = 1:size(ts_data_grid,4)
    %                 if frame == 393
    %                     ts_data_grid_pt2(chan, cond, rep, frame, :) = ts_data_grid_pt1(chan, cond, rep, frame, :);
    %                 end
    %                 ts_data_grid(chan, cond, rep, frame, :) = ((ts_data_grid_pt1(chan, cond, rep, frame, :)+ts_data_grid_pt2(chan, cond, rep, frame, :))./2);
    %                 neutral_ts_data(chan, cond, rep, frame, :) = ((neutral_ts_data_pt1(chan,cond,rep,frame,:)+neutral_ts_data_pt2(chan,cond,rep,frame,:))./2);
    %             end
    %         end
    %     end
    % end

    

    % downsample data

    % Separate the data collected from dark flashes and light flashes

    [dark_sq_data, light_sq_data, dark_avgReps_data, light_avgReps_data, ...
        dark_sq_neutral, light_sq_neutral, dark_avgReps_neutral, light_avgReps_neutral] = ...
    separate_light_dark(ts_data_grid, neutral_ts_data, num_frames);

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
    gridVoltData = [];
    for gridcond = 1:length(grid_conds)
        for gridrep = 1:num_reps
            for frame = 1:num_frames(1)

                gridVoltData = [gridVoltData; squeeze(ts_data_grid(2, grid_conds(gridcond), gridrep, frame, :))];

            end
        end
    end
    gridVoltData(isnan(gridVoltData)) = [];
    medianVoltage = median(gridVoltData);
    maxVoltage = prctile(gridVoltData,99.999);
    minVoltage = prctile(gridVoltData,0.001);
    voltageRange = diff([maxVoltage minVoltage]);

    [peak_frames, peak_frames_avg, gaussColors] = get_peak(ts_data_grid, Volt_idx, grid_rows, grid_columns, medianVoltage);


    create_grid_plot(dark_sq_data_ds, light_sq_data_ds, grid_rows, grid_columns, ...
        2, ts_time_ds, exp_folder, gaussColors, medianVoltage, maxVoltage, minVoltage);
    % 
    % ts_data = shifted_cond_data;
    %  for chan = 1:size(ts_data,1)
    %     for cond = 1:size(ts_data,2)
    %         for rep = 1:size(ts_data,3)
    %             for frame = 1:size(ts_data,4)
    %                 ts_data_ds(chan,cond,rep,frame,:) = downsample(squeeze(ts_data(chan,cond,rep,frame,:)),downsample_n);
    % 
    %             end
    %         end
    %     end
    %     ts_time_ds{cond} = downsample(ts_time{cond}, downsample_n);
    % end

        ts_data = shifted_cond_data;
       save(fullfile(exp_folder,processed_file_name), 'ts_data', 'ts_data_grid', 'neutral_ts_data', ...
        'channel_order', 'frame_moves', 'frame_move_inds',  'frame_gaps', 'bad_gaps', ...
        'dark_sq_data', 'dark_sq_neutral', 'light_sq_neutral', 'light_sq_data', ...
        'dark_sq_data_ds', 'light_sq_data_ds', 'dark_avgReps_neutral', 'dark_avgReps_data', ...
        'light_avgReps_neutral', 'light_avgReps_data', 'alignment_data', ...
        'medianVoltage', 'maxVoltage', 'voltageRange', 'peak_frames', 'peak_frames_avg', "-v7.3")%, 'hist_xvals', 'hist_yvals');

end
