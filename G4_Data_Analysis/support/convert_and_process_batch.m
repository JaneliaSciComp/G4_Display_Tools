% This script requires that all flies run that day were saved in a single
% folder as is the default when using the Conductor. It also requires that
% there be no extra folders. Ie the folder should look like:

% 11_08_2023
%     - fly_genotype-09_18_22
%     - fly_genotype-11_12_37
%     - fly_genotype-14_24_50

% This script, when given the path to the folder 11_08_2023 will go through
% each fly folder and convert their TDMS files into a matlab struct as well
% as process that data into datasets IF a processing settings filepath is
% provided. If it is not provided, it'll only convert the TDMS files. If
% you want to convert multiple days' worth of flies, then you should run
% this script separately for each date. 

% Additionally, you must run this script on a computer containing the G4
% Conductor software, as it will use functions built into the Conductor.

%% User must update these variables.
date_folder = 'C:\Users\taylo\Documents\Programming\Reiser\LPTephys_protocol01_upd_06-30-23_13-27-38\06_30_2023';
processing_settings_file = 'C:\Users\taylo\Documents\Programming\Reiser\LPTephys_protocol01_upd_06-30-23_13-27-38\processing_settings.mat';

%% Do not edit beyond this point

% get list of subfolders
all = dir(date_folder);
isub = [all(:).isdir];
folder_names = {all(isub).name};
folder_names(ismember(folder_names,{'.','..'})) = [];


% Open up the Conductor's controller to access its functions
run_con = G4_conductor_controller();
disp("Running. Please do not close matlab...");

for fold = 1:length(folder_names)

    fly_results_folder = fullfile(date_folder, folder_names{fold});
    
    % Get folder and files names of the fly results folder so you can
    % check to make sure the data hasn't already been processed.
    all_fly = dir(fly_results_folder);
    isub_fly = [all_fly(:).isdir];
    folder_names_fly = {all_fly(isub_fly).name};
    folder_names_fly(ismember(folder_names_fly,{'.','..'})) = [];
    isafile = logical([]);
    for i = 1:length(isub_fly)
        if isub_fly(i) == 1
            isafile(i) = false;
        else
            isafile(i) = true;
        end
    end
    file_names = {all_fly(isafile).name};
    file_names(ismember(file_names,{'.','..'})) = [];
    tdms_present = 0;
    processed_present = 0;
    for file = 1:length(file_names)
        if contains(file_names{file},'TDMS')
            tdms_present = 1;
        end
        if contains(file_names{file}, 'Processed')
            processed_present = 1;
        end
    end

    % If any file was found in the folder containing "TDMS" in the name,
    % then check for processed data. If it's not present, process the data
    % assuming a settings file was provided. If it is also present, just
    % skip this iteration entirely.
    if tdms_present
        if processed_present
            continue;
        else
            if isfile(processing_settings_file)
                process_data(fly_results_folder, processing_settings_file);
            end
            continue;
        end
    end

    % At this point we know the data has not been converted or processed.
    % Check how many tdms folders are in the fly folder
    num_logs = run_con.check_number_logs(fly_results_folder);
    
    % If there's one, convert like normal. if there's more than
    % one, convert all Logs to matlab structs separately. Display
    % message to user if there are no logs found.
    
    if num_logs == 1
        G4_TDMS_folder2struct(fly_results_folder);

    elseif num_logs > 1
        run_con.convert_multiple_logs(fly_results_folder);
    
        %consolidate multiple resulting structs into one struct
        Log = run_con.consolidate_log_structs(fly_results_folder);
        LogFinalName = 'G4_TDMS_Logs_Final.mat';
        save(fullfile(fly_results_folder, LogFinalName),'Log');
       
    else
        disp("No tdms folders could be found in folder " + fly_results_folder);
    end

    if isfile(processing_settings_file)
         process_data(fly_results_folder, processing_settings_file);

    end

end

disp("Finished processing. It is safe to close matlab.");
