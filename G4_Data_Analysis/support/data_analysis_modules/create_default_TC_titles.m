function [TC_cond_name] = create_default_TC_titles(TC_conds, cond_name, g4ppath)
    
    num_figs = length(TC_conds);
    num_rows = length(TC_conds{1});
    num_cols = size(TC_conds{1}{1},1);

    
    TC_cond_name = cell(1,num_figs);
    %If the .g4p file wasn't found, give all graphs blank names. 
    if isempty(g4ppath)
        for i = 1:length(TC_cond_name)
            for j = 1:num_rows
                for k = 1:num_cols

                    TC_cond_name{i}(j,k) = ' ';

                end
            end
        end
        return;
    end
    
    exp = load(g4ppath,'-mat');
    
    for fig = 1:num_figs
        for row = 1:num_rows
            for col = 1:num_cols
                if isempty(cond_name)

                    if isnan(TC_conds{fig}{row}(col,1))
                        continue;
                    end
                    patname = exp.exp_parameters.block_trials{TC_conds{fig}{row}(col,1),2};

                    patparts = strsplit(patname,'_');

                    plot_name = patparts{2};

                    TC_cond_name{fig}(row,col) = string(plot_name);
                else
                    TC_cond_name{fig}(row,col) = ' ';
                end

            end
        end
    end
    


end