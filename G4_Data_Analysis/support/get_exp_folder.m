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

%% This is the function for the new file system arrangement. 
function [exp_folder, field_values] = get_exp_folder(field_to_sort_by, field_values, single_group, single_fly, single_fly_path,  path_to_protocol, control)

     if single_fly == 1
        exp_folder = {single_fly_path};
        return;
     end
     [protocol_subFiles, protocol_subFolders] = get_files_and_subdirectories(path_to_protocol);
     num_dates = length(protocol_subFolders);
   
    if isempty(field_values)
        %Get field values
        field_values = {};
        total_fly = 1;
        for date = 1:num_dates
            folder_path = fullfile(path_to_protocol, protocol_subFolders{date});
            [fly_files, fly_folders] = get_files_and_subdirectories(folder_path);
            num_flies = length(fly_folders);
            for fly = 1:num_flies
                fly_file = fullfile(folder_path, fly_folders{fly});
                if isfile(fullfile(fly_file, 'metadata.mat'))
                    metadata = load(fullfile(fly_file, 'metadata.mat'));
                else
                    continue;
                end
                field_values{total_fly} = metadata.metadata.(field_to_sort_by{1}(1));
                total_fly = total_fly + 1;
            end
        end
        field_values = unique(field_values);
        
       
        
        if ~isempty(control)
            
            %move control genotype to first element in field_values
            ctrl_ind = find(strcmp(field_values, control));
            if isempty(ctrl_ind)
                disp("Could not find control genotype provided in the results. Control will not be plotted.");
            else
                for val = ctrl_ind:-1:2
                    field_values(val) = field_values(val-1);
                end
                field_values(1) = {control};
            end
            for i = 1:length(field_values)
                field_values{i} = string(field_values{i});
            end
                       
        else
            
            %user wants each group on its own with no control
            
        end
       
        if length(field_to_sort_by) ~= length(field_values)
            while length(field_to_sort_by) ~= length(field_values)
                field_to_sort_by{end+1} = field_to_sort_by{end};
            end
        end
    else
        
        
    end
        
    
    exp_folder = cell(size(field_values,1));

    for i = 1:num_dates
        folder_path = fullfile(path_to_protocol, protocol_subFolders{i});
        [fly_files, fly_folders] = get_files_and_subdirectories(folder_path);
        num_flies = length(fly_folders);
        for k = 1:num_flies
            fly_file = fullfile(folder_path, fly_folders{k});
            if isfile(fullfile(fly_file, 'metadata.mat'))
                metadata = load(fullfile(fly_file, 'metadata.mat'));
            else
                continue;
            end
            for l = 1:length(field_to_sort_by)
                for j = 1:length(field_to_sort_by{l})
                    

                    if contains(metadata.metadata.(field_to_sort_by{l}(j)),field_values{l}(j))
                        passed(j) = 1;
                    else
                        passed(j) = 0;

                    end
                    
                    
                end
                if sum(passed) == j
                    exp_folder{l,end+1} = fly_file;
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


