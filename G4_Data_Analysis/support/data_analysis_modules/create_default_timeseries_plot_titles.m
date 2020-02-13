function [OL_cond_name] = create_default_timeseries_plot_titles(OL_conds, cond_name)

    OL_cond_name = cell(1,length(OL_conds));
%     for i = 1:length(OL_cond_name)
%         OL_cond_name{i} = nan(size(OL_conds{i},1), size(OL_conds{i},2));
%     end
  
        for i = 1:length(OL_cond_name)
            for j = 1:size(OL_conds{i},1)
                for k = 1:size(OL_conds{i},2)
                    if isempty(cond_name)
                        OL_cond_name{i}(j,k) = "Condition " + string(OL_conds{i}(j,k));
                    else
                        OL_cond_name{i}(j,k) = ' ';
                    end
                end
            end
        end


end