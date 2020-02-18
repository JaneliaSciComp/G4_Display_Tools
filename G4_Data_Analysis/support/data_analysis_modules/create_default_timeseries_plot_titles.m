function [OL_cond_name] = create_default_timeseries_plot_titles(OL_conds, cond_name, path)
    
    %get files in directory
    
    [files, subFolders] = get_files_and_subdirectories(path);
    %check results path and make sure it has a .g4p file in it. 
    
    file_index = find(contains(files, '.g4p'));

    %If there is no g4p file, prompt the user to browse to the protocol
    %folder
    if isempty(file_index)
        path = uigetdir(path, "Please select the protocol folder");
        [files, subFolders] = get_files_and_subdirectories(path);
        file_index = find(contains(files, '.g4p'));
        
        %If the protocol folder they browse to still has no .g4p file, give
        %display that to the screen and give all graphs blank names. 
        if isempty(file_index)
            disp("There is no .g4p file in this protocol folder");
            OL_cond_name = cell(1,length(OL_conds));
            for i = 1:length(OL_cond_name)
                for j = 1:size(OL_conds{i},1)
                    for k = 1:size(OL_conds{i},2)

                        OL_cond_name{i}(j,k) = ' ';

                    end
                end
            end
            return;
        end
    end
    
    %IF you get here, it found the g4p file. 
    
    exp = load(fullfile(path, files{file_index}), '-mat');
 
    OL_cond_name = cell(1,length(OL_conds));
%     for i = 1:length(OL_cond_name)
%         OL_cond_name{i} = nan(size(OL_conds{i},1), size(OL_conds{i},2));
%     end
  
        for i = 1:length(OL_cond_name)
            for j = 1:size(OL_conds{i},1)
                for k = 1:size(OL_conds{i},2)
                    if isempty(cond_name)
                        if isnan(OL_conds{i}(j,k))
                            continue;
                        end
                        patname = exp.exp_parameters.block_trials{OL_conds{i}(j,k),2};
                        if ~isempty(exp.exp_parameters.block_trials{OL_conds{i}(j,k),3})
                            funcname = exp.exp_parameters.block_trials{OL_conds{i}(j,k),3};
                        else
                            funcname = '';
                        end
                        patparts = strsplit(patname,'_');
                        funcparts = strsplit(funcname,'_');
                        if ~isempty(funcparts)
                            plot_name = [patparts{2},funcparts{2}, funcparts{3}];
                        else
                            plot_name = patparts{2};
                        end
                        OL_cond_name{i}(j,k) = string(plot_name);
                    else
                        OL_cond_name{i}(j,k) = ' ';
                    end
                end
            end
        end


end