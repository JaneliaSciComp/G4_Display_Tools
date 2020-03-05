function [OL_cond_name] = create_default_timeseries_plot_titles(OL_conds, cond_name, g4ppath)
    
    %get files in directory
    
    
    OL_cond_name = cell(1,length(OL_conds));    
    %If the .g4p file wasn't found, give all graphs blank names. 
    if isempty(g4ppath)
        
        for i = 1:length(OL_cond_name)
            for j = 1:size(OL_conds{i},1)
                for k = 1:size(OL_conds{i},2)

                    OL_cond_name{i}(j,k) = ' ';

                end
            end
        end
        return;
    end
 
    %IF you get here, it found the g4p file. 
    
    exp = load(g4ppath, '-mat');

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
                        
                        %remove any sections of the name that consist of
                        %four numbers or 'G4'
                        patparts = patparts(cellfun(@isempty, regexp(patparts, '\d\d\d\d')));
                        patparts = patparts(cellfun(@isempty, regexp(patparts, 'G4')));
                        if ~isempty(funcname)
                            funcparts = strsplit(funcname,'_');

                            %remove any sections of the name that consist of
                            %four numbers or 'G4'
                            funcparts = funcparts(cellfun(@isempty,regexp(funcparts, '\d\d\d\d')));
                            funcparts = funcparts(cellfun(@isempty,regexp(funcparts, 'G4')));

                            plot_name = [join(patparts,' '), ' ', join(funcparts, ' ')];
                        else

                            plot_name = join(patparts,' ');
                        end
                      
                        OL_cond_name{i}(j,k) = string(plot_name);
                    else
                        OL_cond_name{i}(j,k) = ' ';
                    end
                end
            end
        end


end