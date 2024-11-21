%% User must update these variables.
results_folder = 'C:\Users\taylo\Documents\Programming\Reiser\RealData\Protocol004_OpticFlow_KirShibire_01-09-20_13-23-42\Results';
processing_settings_file = 'C:\Users\taylo\Documents\Programming\Reiser\RealData\Protocol004_OpticFlow_KirShibire_01-09-20_13-23-42\DA_Files\processing_settings_Lisa_daStart.mat';

%% Do not edit beyond this point
% get list of subfolders
all = dir(results_folder);
isub = [all(:).isdir];
genotype_folders = {all(isub).name};
genotype_folders(ismember(genotype_folders,{'.','..'})) = [];

for g = 1:length(genotype_folders)

    
    geno_results_folder = fullfile(results_folder, genotype_folders{g});
    
    % Get folder and files names of the fly results folder so you can
    % check to make sure the data hasn't already been processed.
    all_fly = dir(geno_results_folder);
    isub_fly = [all_fly(:).isdir];
    folder_names_fly = {all_fly(isub_fly).name};
    folder_names_fly(ismember(folder_names_fly,{'.','..','Plots'})) = [];

    for fly = 1:length(folder_names_fly)
        process_data(fullfile(geno_results_folder, folder_names_fly{fly}), processing_settings_file);
    end
end