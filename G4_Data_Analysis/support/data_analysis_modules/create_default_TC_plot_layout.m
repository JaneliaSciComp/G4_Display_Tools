%If custom plot layouts are not provided, create the default layout with
%this

function [TC_conds] = create_default_TC_plot_layout(conditionModes, TC_condsIn)
    

    %Default number of conditions to plot together in a single tuning curve
    default_conds_per_curve = 7; 

    default_W = [1 2 2 2 3 3 3 3 3 4 4 4 4 4 4 4 5 5 5 5]; %width of figure by number of subplots
    default_H = [1 1 2 2 2 2 3 3 3 3 3 3 4 4 4 4 4 4 4 4]; %height of figure by number of subplots
          
    conds_vec = find(conditionModes~=4);
    if ~isempty(conds_vec) && isempty(TC_condsIn)
        %because you don't want conditions that are the same condition but
        %different direction on the same curve, take out all even
        %conditions. If plot_both_directions is set to 1, they'll be
        %plotted on the same axis as the odd condition.
        for i = length(conds_vec):-1:1
            if rem(conds_vec(i),2) == 0
                conds_vec(i) = [];
            end
        end
        num_conds = length(conds_vec);
        num_plots = ceil(num_conds/default_conds_per_curve);
        
        W = default_W(min([num_plots length(default_W)])); %get number of subplot columns (up to default limit)
        H = default_H(min([num_plots length(default_W)])); %get number of subplot rows
        D = ceil(num_plots/length(default_W)); %number of figures
        
        for fig = 1:D
            for row = 1:H
                TC_conds{fig}{row} = nan([W,default_conds_per_curve]);
            end
        end
            
        for fig = 1:D
            for row = 1:H
                for col = 1:W
                    if fig == D && row == H && col == W
                        num_left = num_conds - default_conds_per_curve*(row*col*fig-1);
                        TC_conds{fig}{row}(col,1:num_left) = conds_vec(fig*row*col*default_conds_per_curve - (default_conds_per_curve-1):end);
                    else
                        TC_conds{fig}{row}(col,1:end) = conds_vec((fig*row*col*default_conds_per_curve - (default_conds_per_curve-1) + (row-1)*(W*default_conds_per_curve - default_conds_per_curve*col)):(fig*row*col*default_conds_per_curve + (row-1)*(W*default_conds_per_curve - default_conds_per_curve*col)));
                    end
                end
            end
        end
   
    end

end