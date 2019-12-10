
convert_processed_files = 0;
results_path =  '/Users/taylorl/Desktop/forLisa/';
results_files = dir(results_path);
dirFlags = [results_files.isdir];
results_subFolders = results_files(dirFlags);
results_subFolders(1:2) = [];

num_experiments = length(results_subFolders);

for i = 1:num_experiments
    
    folder = fullfile(results_path, results_subFolders(i).name);
    
    if convert_processed_files == 1
        convert_processed_file(folder);
    end
    
    fly_files = dir(folder);
    flyDirFlags = [fly_files.isdir];
    fly_folders = fly_files(flyDirFlags);
    fly_folders(1:2) = [];
    
    num_flies = length(fly_folders);
    for k = 1:num_flies
        exp_folder{i,k} = fullfile(folder,fly_folders(k).name);
    end
    
end

trial_options = [1 1 1];

