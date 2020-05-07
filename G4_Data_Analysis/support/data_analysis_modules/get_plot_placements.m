function [bottom_left_places, left_column_places] = get_plot_placements(conds) 

    for i = 1:length(conds)
        a = ~isnan(conds{i});
        bottom_left_places{i} = sum(a(:,1));

        if size(conds{i},1) ~= 1

            for m = 1:size(conds{i},1)
                left_column_places{i}(m) = m;
            end


        else

            left_column_places{i} = 1;
        end
    end
            
end