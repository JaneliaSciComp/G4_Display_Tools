function create_processing_settings()
    
    settings = struct;
    
    %% Save settings
    
    settings_file_path = '/Users/taylorl/Desktop/CT1_Ablation_03-16-20_12-39-26/processing_settings';
    
    
    
    %% General settings
    settings.trial_options = [1 1 1];
    settings.path_to_protocol = '/Users/taylorl/Desktop/CT1_Ablation_03-16-20_12-39-26/CT1_Ablation_03-16-20_12-39-26.g4p';
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
    settings.processed_file_name = 'testing_new_processing';
    settings.combined_command = 0; %Set to 1 if using the combined command
    settings.percent_to_shift = .015;
    
    %% Wing Beat Frequency Settings
    
    settings.wbf_range = [160 260]; %Minimum and maximum acceptable wing beat frequencies
    settings.wbf_cutoff = .2; %Maximum acceptable portion of a condition where the fly is not flying
    settings.wbf_end_percent = .8; %If a fly is not flying for more than the above acceptable portion of a condition,
                                    %You can choose to keep the trial
                                    %anyway if this portion of the bad wbf
                                    %measurements are clustered in the last
                                    %ten percent of the condition. (Ie if
                                    %80% of hte bad wbf readings are in the
                                    %last ten percent of the condition, the
                                    %first 90% of hte condition is probably
                                    %fine and worth keeping). If you want
                                    %to get rid of it as a bad trial no
                                    %matter where the bad wbf readings are,
                                    %set this to 1.
    
    %% Normalization settings
    
    %settings.normalize_to_baseline = {'LpR'};%datatypes to normalize by setting the baseline value to 1
    %settings.baseline_startstop = [0 1]; %start and stop times to use for baseline normalization
    %settings.normalize_to_max = {'LmR'}; %datatypes to normalize by setting the maximum (or minimum) values to +1 (or -1)
 %start and stop times to use for max normalization
    settings.max_prctile = 98; 
    
    
    %% Position series settings
    settings.enable_pos_series = 1; %If you want position series, set to 1. Only use on sweeps
    settings.pos_conditions = [1:28]; %A 1xn array with numbers of conditions to be included in position series
                                  %Leave empty if all conditions to be
                                  %included.
    settings.sm_delay = 0; %add delay in ms to account for sensorimotor delay
    settings.num_positions = 192;
    settings.data_pad = 10; %in ms
    
    %% FaLmR settings
    settings.enable_faLmR = 1; %If you want to do faLmR, set this to 1. 
                            %Everything else will be updated automatically.
                            
    %% Summary settings
    settings.summary_filename = 'Summary_of_bad_trials'; %Filename of the summary of which trials weren't run and why
    settings.summary_save_path = []; %Leave empty if you want the summary saved in the fly folder.
                            
                            
    %% Do adjustments and save .mat file
    
    if settings.enable_faLmR
        settings.channel_order{end + 1} = 'faLmR';
    end

    save(settings_file_path, 'settings');


end