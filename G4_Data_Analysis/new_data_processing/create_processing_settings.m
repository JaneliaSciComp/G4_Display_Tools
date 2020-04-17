function create_processing_settings()
    
    settings = struct;
    
    %% Save settings
    
    settings_file_path = '/Users/taylorl/Desktop/processing_settings';
    
    
    %% General settings
    settings.trial_options = [1 1 1];
    settings.channel_order = {'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR'}; 
    settings.hist_datatypes = {'Frame Position', 'LmR', 'LpR'};
    settings.manual_first_start = 0;
    settings.data_rate = 1000; % rate (in Hz) which all data will be aligned to
    settings.pre_dur = 1; %seconds before start of trial to include
    settings.post_dur = 1; %seconds after end of trial to include
    settings.da_start = .05; %seconds after start of trial to start data analysis
    settings.da_stop = .15; %seconds before end of trial to end data analysis
    settings.time_conv = 1000000; %converts seconds to microseconds (TDMS timestamps are in micros)
    settings.common_cond_dur = 0; %sets whether all condition durations are the same (1) or not (0), for error-checking
    settings.processed_file_name = 'testing_new_processing';
    settings.combined_command = 0; %Set to 1 if using the combined command
    
    %% Normalization settings
    
    %settings.normalize_to_baseline = {'LpR'};%datatypes to normalize by setting the baseline value to 1
    %settings.baseline_startstop = [0 1]; %start and stop times to use for baseline normalization
    %settings.normalize_to_max = {'LmR'}; %datatypes to normalize by setting the maximum (or minimum) values to +1 (or -1)
 %start and stop times to use for max normalization
    settings.max_prctile = 98; 
    
    
    %% Position series settings
    settings.enable_pos_series = 1; %If you want position series, set to 1. Only use on sweeps
    settings.pos_conditions = []; %A 1xn array with numbers of conditions to be included in position series
                                  %Leave empty if all conditions to be
                                  %included.
    settings.sm_delay = 0; %add delay in ms to account for sensorimotor delay
    settings.num_positions = 192;
    settings.data_pad = 1050; %in ms
    
    %% FaLmR settings
    settings.enable_faLmR = 1; %If you want to do faLmR, set this to 1. 
                            %Everything else will be updated automatically.
                            
                            
    %% Do adjustments and save .mat file
    
    if settings.enable_faLmR
        settings.channel_order{end + 1} = 'faLmR';
    end

    save(settings_file_path, 'settings');


end