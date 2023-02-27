%% This function takes in the path to the desired results folder (or it takes in no
% variables and will prompt you for this path). It will cycle through each
% fly in the results folder and convert that fly's processed data file to
% the new format. 

%%
function convert_processed_file(varargin)

%Go through experiment folders. For each processed file

% - load the file
% - save all fields except timeseries to a new struct
% - go through the timeseries data and average
% - set new field avg_timeseries
% - save to new file 

    %* alternately, could save average timeseries field to original
    %processed file, and only load some variables from the file in plottin
    
%Put in link to results folder. It will go through each fly folder int he
%results folder and convert the processed data file to the new format.
    if isempty(varargin)

        results_folder = uigetdir;

    else

        results_folder = varargin{1};
    end
    files = dir(results_folder);
    dirFlags = [files.isdir];
    fly_folders = files(dirFlags);
    fly_folders(1:2) = [];
    processed_file_name = 'smallfield_V2_G4_Processed_Data';

    %BASED ON G4_Process_Data_flyingdetector_smallfield_V2.m  Ensure the
    %processing file used to create the processed data file had the same order
    %of fields. 
    LmR_ind = 6;
    LpR_ind = 7;

    for i = 1:length(fly_folders)

        fly_files = dir(fullfile(results_folder,fly_folders(i).name));

        try
            Data_name = fly_files(contains({fly_files.name},{processed_file_name})).name;
        catch
            %error('cannot find processed data file in specified folder')
            processed_file_name2 = 'G4_Processed_Data';
            
            try Data_name = fly_files(contains({fly_files.name},{processed_file_name2})).name;
                
            catch
                
                error('cannot find a processed file')
            end
        end
        full_filename = fullfile(results_folder,fly_folders(i).name,Data_name);
        load(full_filename, 'Data');

        %Want to normalize data before averaging it? 
        %Take average of timeseries data
        %average ts_data over number of reps
        timeseries_avg_over_reps = squeeze(mean(Data.timeseries, 3,'omitnan'));

        %average LmR data over number of reps
        LmR_avg_over_reps = squeeze(mean(Data.timeseries(LmR_ind,:,:,:),3,'omitnan'));

        %average LpR data over number of reps
        LpR_avg_over_reps = squeeze(mean(Data.timeseries(LpR_ind,:,:,:),3,'omitnan'));

        %average ts_data over all trials
        timeseries_avg_all_trials = squeeze(mean(timeseries_avg_over_reps,2,'omitnan'));

        %average LmR data over all trials
        LmR_avg_all_trials = squeeze(mean(LmR_avg_over_reps,1,'omitnan'));

        %average LpR data over all trials
        LpR_avg_all_trials = squeeze(mean(LpR_avg_over_reps,1,'omitnan'));



        save(full_filename, '-struct', 'Data');

        save(full_filename, 'timeseries_avg_over_reps', 'LmR_avg_over_reps', ...
            'LpR_avg_over_reps', 'timeseries_avg_all_trials', 'LmR_avg_all_trials', ...
            'LpR_avg_all_trials', '-append');


    end
end

