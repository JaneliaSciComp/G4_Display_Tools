%% Script to use until the new file system is put in place.
% 
% %% Remember, to work, the paths to be placed in the exp_folders should be two levels below the results_path
% % Results_path -> Experiment Folders -> Fly folders with individual results
% 
% convert_processed_files = 0;
% results_path =  '/Users/taylorl/Desktop/Protocol004_OpticFlow_KirShibire_01-09-20_13-23-42/';
% results_files = dir(results_path);
% allNames = {results_files(:).name};
% hidden_ind = startsWith(allNames,'.');
% results_files(hidden_ind) = [];
% dirFlags = [results_files.isdir];
% results_subFolders = results_files(dirFlags);
% subFolder_names = {results_subFolders(:).name};
% subFiles = results_files(~dirFlags);
% subFile_names = {subFiles(:).name};
% 
% 
% num_experiments = length(results_subFolders);
% 
% for i = 1:num_experiments
%     
%     folder = fullfile(results_path, results_subFolders(i).name);
%     
%     if convert_processed_files == 1
%         convert_processed_file(folder);
%     end
%     
%     fly_files = dir(folder);
%     flyDirFlags = [fly_files.isdir];
%     fly_folders = fly_files(flyDirFlags);
%     fly_folders(1:2) = [];
%     
%     num_flies = length(fly_folders);
%     for k = 1:num_flies
%         exp_folder{i,k} = fullfile(folder,fly_folders(k).name);
%     end
%     
% end
% 
% trial_options = [1 1 1];




% This script will generate the exp_folder and trial_options variables
% required by the data analysis tools. You must adjust the user-defined
% settings to get accurate output

%% Settings required
%field_to_sort_by - A string indicating which metadata field you want to
    %group flies by. This must match exactly the field name in metadata.mat.
    %(Ie, the genotype field is called 'fly_genotype'
    
%single_group - Set this equal to 1 if you are looking at a single value of
    %the field to sort by. For example, if you're sorting by genotype and you
    %only want to analyze the data of a single genotype, set this to 1. If you
    %are looking at multiple genotypes, set this to 0.
    
%field_values - the values for the metadata field you want to analyze. For
    %example, if you're sorting by gentoype, this variable should be a string
    %matching the genotype you're interested in, such as 'OL0048B_UAS_Kir_JFRC49'
    
    %NOTE: Please remember that the order of genotypes in this array should
    %match the order of genotypes given in create_data_analysis_tool or
    %your legend may be incorrect. 
    
%trial_options - a 3x1 array of ones and zeros indicating the present of
    %pre, inter, and postrials in the format [pre inter post]. So [1 0 1]
    %indicates there was a pre and post trial, but no inter-trials. 
    
%path_to_protocol - the filepath, in the form of a string, to the protocol
    %folder. This folder should have subfolders named by date, and each of
    %those should have the fly folders for all flies run on that date. 

%% This is the function for the new file system arrangement. Find old system below.
function [exp_folder, trial_options] = get_exp_folder()

%     %% User-defined settings
% 
%Each cell element of field_to_sort_by represents a single group. So all
%fields in one cell element will be used to narrow down that single group
%of flies. 

%For example, field_to_sort_by{1} = ["fly_genotype", "fly_age"];
%             field_to_sort_by{2} = ["experimenter, "fly_age"];
%             field_values{1} = ["emptySplit_JFRC100_JFRC49","3-6 days"];
%             field_values{2} = ["kappagantular", "3-6 days"];
              
              %The above will produce two groups of flies, so an exp_folder
              %of 2 by x. The first group will contain only flies that
              %have the genotype emptySplit_JFRC100_JFRC49 AND are 3-6 days
              %old. The second group will contain all flies run by
              %kappagantular and are 3-6 days old. These groups may have
              %some overlap.
    field_to_sort_by{1} = ["fly_genotype"];
%     field_to_sort_by{2} = ["fly_genotype"];
%     field_to_sort_by{3} = ["rearing_protocol"];

    single_group = 0;
    single_fly = 0;
    field_values{1} = ["emptySplit_JFRC100_JFRC49"];
%     field_values{2} = ["emptySplit_UAS_Kir_JFRC49"];
%     field_values{3} = ["Kir 1"];

 %   field_values{2} = ["Kir 1", "01 17"];
    %field_values = ["OL0048B_UAS_Kir_JFRC49","emptySplit_UAS_Kir_JFRC49","OL0010B_UAS_Kir_JFRC49"];
    trial_options = [1 1 1];
    path_to_protocol =  '/Users/taylorl/Desktop/Protocol004_OpticFlow_KirShibire_01-09-20_13-23-42';
    exp_folder = cell(length(field_values),1);


    %% End User-defined settings
    if single_fly == 1
        exp_folder = {path_to_protocol};
        return;
    end

    date_folders = dir(path_to_protocol);
    allNames = {date_folders(:).name};
    hidden_ind = startsWith(allNames,'.');
    date_folders(hidden_ind) = [];
    dirFlags = [date_folders.isdir];
    protocol_subFolders = date_folders(dirFlags);


    num_dates = length(protocol_subFolders);

    for i = 1:num_dates

        folder = fullfile(path_to_protocol, protocol_subFolders(i).name);
        fly_files = dir(folder);
        fly_names = {fly_files(:).name};
        hidden_ind = startsWith(fly_names,'.');
        fly_files(hidden_ind) = [];
        flyDirFlags = [fly_files.isdir];
        fly_folders = fly_files(flyDirFlags);

        num_flies = length(fly_folders);

        for k = 1:num_flies
            fly_file = fullfile(folder, fly_folders(k).name);
            if isfile(fullfile(fly_file, 'metadata.mat'))
                metadata = load(fullfile(fly_file, 'metadata.mat'));
            else
                continue;
            end
            for l = 1:length(field_to_sort_by)
                for j = 1:length(field_to_sort_by{l})
                    for m = 1:length(field_values{l})

                        if contains(metadata.metadata.(field_to_sort_by{l}(j)),field_values{l}(m))
                            passed(m) = 1;
                        else
                            passed(m) = 0;

                        end
                    end
                    if sum(passed) == m
                        exp_folder{l,end+1} = fly_file;
                    end
                end
            end
        end

    end

    if single_group == 0 
        longest_group = 0;
        for i = 1:size(exp_folder,1)
            x = exp_folder(i,:);
            index = cellfun(@isempty, x) == 0;
            tmp = x(index);
            if length(tmp) > longest_group
                longest_group = length(tmp);
            end
        end

        new_exp_folder = cell(size(exp_folder,1), longest_group);
        new_exp_folder(:,:) = {''};
        for j = 1:size(exp_folder,1)
            index = cellfun(@isempty, exp_folder(j,:)) == 0;
            tmp = exp_folder(j,index);
            new_exp_folder(j,1:length(tmp)) = tmp;
        end
        exp_folder = new_exp_folder;

    else

        index = cellfun(@isempty, exp_folder) == 0;
        exp_folder = exp_folder(index);


    end

end


