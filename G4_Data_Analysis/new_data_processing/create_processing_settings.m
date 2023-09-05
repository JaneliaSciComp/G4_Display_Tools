function create_processing_settings()

    settings = struct;

    %% Save settings
    settings_file_path = '/Users/taylorl/Downloads/emptySplit_UAS_Kir_JFRC49-17_02_28/processing_settings';

    %% General settings
    settings.trial_options = [1 1 1];
    settings.path_to_protocol = '/Users/taylorl/Downloads/streaming_test_protocol08-26-21_12-50-35.g4p';
    settings.channel_order = {'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR'};
    settings.hist_datatypes = {'Frame Position', 'LmR', 'LpR'};
    settings.manual_first_start = 0;
    settings.data_rate = 1000; % rate (in Hz) which all data will be aligned to
    settings.pre_dur = .05; %seconds before start of trial to include
    settings.post_dur = .05; %seconds after end of trial to include
    settings.da_start = .05; %seconds after start of trial to start data analysis
    settings.da_stop = .15; %seconds before end of trial to end data analysis
    settings.time_conv = 1000000; %converts seconds to microseconds (TDMS timestamps are in micros)
    settings.common_cond_dur = 0; %sets whether all condition durations are the same (1) or not (0), for error-checking
    settings.processed_file_name = 'processedData';
    settings.combined_command = 0; %Set to 1 if using the combined command
    settings.percent_to_shift = .015;
    settings.duration_diff_limit = .15; %If a trial takes longer than its intended duration by more than this percentage, throw it out
    settings.cross_correlation_tolerance = .02; %when a cross correlation is taken of all reps of a trial, any reps that are off zero by more than this percentage will be marked bad. Default 2%
    settings.flying = 1; %If this is a flying experiment, set to 1. If not, set to 0.
    %% Wing Beat Frequency Settings

    settings.remove_nonflying_trials = 1;   %% 1 if you want trials where the fly
                                            % didn't fly to be marked as bad and removed.
                                            % 0 if you don't want this
                                            % feature turned on.
    settings.wbf_range = [160 260];         %% Minimum and maximum acceptable wing beat frequencies
    settings.wbf_cutoff = .2;               %% Maximum acceptable portion of a condition where the fly is not flying
    settings.wbf_end_percent = .8;          %% If a fly is not flying for more than the above acceptable portion of a condition,
                                            % You can choose to keep the trial
                                            % anyway if this portion of the bad wbf
                                            % measurements are clustered in the last
                                            % ten percent of the condition. (Ie if
                                            % 80% of hte bad wbf readings are in the
                                            % last ten percent of the condition, the
                                            % first 90% of hte condition is probably
                                            % fine and worth keeping). If you want
                                            % to get rid of it as a bad trial no
                                            % matter where the bad wbf readings are,
                                            % set this to 1.


    %% Normalization settings
    % settings.normalize_to_baseline = {'LpR'};%datatypes to normalize by setting the baseline value to 1
    % settings.baseline_startstop = [0 1]; %start and stop times to use for baseline normalization
    % settings.normalize_to_max = {'LmR'}; %datatypes to normalize by setting the maximum (or minimum) values to +1 (or -1)
    % start and stop times to use for max normalization
    settings.max_prctile = 98;

    %% Position series settings
    settings.enable_pos_series = 0;         % If you want position series, set to 1. Only use on sweeps
    settings.pos_conditions = [1:28];       %% A 1xn array with numbers of conditions to be included in position series
                                            % Leave empty if all conditions to be
                                            % included.
    settings.sm_delay = 0; %add delay in ms to account for sensorimotor delay
    settings.num_positions = 192;
    settings.data_pad = 10; %in ms

    %% FaLmR settings - flipping and averaging only implemented for LmR data
    settings.enable_faLmR = 1; %If you want to do faLmR, set this to 1.
                            %If not, set it to 0

    % If you leave condition_pairs empty, flipped and averaged pairs will default to
    % 1-2, 3-4, 5-6, etc, with even conditions being flipped. If you want conditions paired differently,
    % uncomment the settings.condition_pairs cell array below. The number
    % of cell array elements (numbers in the {}) should be half the total
    % number of conditions (unless you are pairing some conditions multiple times).
    % When the pairs are flipped and averaged, the
    % second number will be the one that is flipped (made negative).

    % This will result in a flipped and averaged data set which is similar
    % to the timeseries data set, but will be only approximately half the
    % size. element 1, in this dataset, would be the data from the first
    % pair flipped and averaged, element 2, the second pair, etc.

%    settings.condition_pairs = {};
    settings.condition_pairs{1} = [1 6];
    settings.condition_pairs{2} = [2 5];
    settings.condition_pairs{3} = [3 8];
    settings.condition_pairs{4} = [4 7];
    settings.condition_pairs{5} = [9 10];
    settings.condition_pairs{6} = [10 9];
    settings.condition_pairs{7} = [11 12];
    settings.condition_pairs{8} = [12 11];
    settings.condition_pairs{9} = [13 14];
    settings.condition_pairs{10} = [14 13];
%     settings.condition_pairs{11} = [15 20];
%     settings.condition_pairs{12} = [16 19];
%     settings.condition_pairs{13} = [21 26];
%     settings.condition_pairs{14} = [22 25];
%     settings.condition_pairs{15} = [23 28];
%     settings.condition_pairs{16} = [24 27];

    %% Summary settings
    settings.summary_filename = 'Summary_of_bad_trials'; %Filename of the summary of which trials weren't run and why
    settings.summary_save_path = []; %Leave empty if you want the summary saved in the fly folder.

    %% Do adjustments and save .mat file

%     if settings.enable_faLmR
%         settings.channel_order{end + 1} = 'faLmR';
%     end

    save(settings_file_path, 'settings');
end