function [OL_conds] = create_default_OL_plot_layout(conditionModes, OL_condsIn, plot_both_dir)
    
    
    default_W = [2 2 2 2 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5]; %width of figure by number of subplots
    default_H = [1 1 2 2 2 2 3 3 3 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 6 6 6 6 6]; %height of figure by number of subplots

    %find all open-loop conditions, organize into block
    conds_vec = find(conditionModes~=4); 
    if ~isempty(conds_vec) && isempty(OL_condsIn)
        if plot_both_dir == 1
            for i = length(conds_vec):-1:1
                if rem(conds_vec(i),2) == 0
                    conds_vec(i) = [];
                end
            end
        end
        num_conds = length(conds_vec);
        W = default_W(min([num_conds length(default_W)])); %get number of subplot columns (up to default limit)
        H = default_H(min([num_conds length(default_W)])); %get number of subplot rows
        D = ceil(num_conds/length(default_W)); %number of figures
%try just converting to cell at end? 
        OL_conds = nan([W H D]);
        OL_conds(1:num_conds) = conds_vec;
        OL_conds = permute(OL_conds,[2 1 3]);
    elseif isempty(conds_vec)
        OL_conds = [];
    else
        OL_conds = OL_condsIn;
    end
    
    if ~iscell(OL_conds)
        for i = 1:length(OL_conds(1,1,:))
            OL_conds_cell{i} = OL_conds(:,:,i);
        end

        OL_conds = OL_conds_cell;
    end
    
    %create matching durations cell array
    
    

end