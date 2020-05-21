function [pos_conds] = create_default_posSeries_layout(pos_conditions, pos_condsIN, plot_both_dir)
    

    default_W = [2 2 2 2 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5]; %width of figure by number of subplots
    default_H = [1 1 2 2 2 2 3 3 3 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 6 6 6 6 6]; %height of figure by number of subplots

    %find all open-loop conditions, organize into block
    conds_vec = pos_conditions;
    if ~isempty(conds_vec) && isempty(pos_condsIN)
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
        pos_conds = nan([W H D]);
        pos_conds(1:num_conds) = conds_vec;
        pos_conds = permute(pos_conds,[2 1 3]);
    elseif isempty(conds_vec)
        pos_conds = [];
    else
        pos_conds = pos_condsIn;
    end
    
    if ~iscell(pos_conds)
        for i = 1:length(pos_conds(1,1,:))
            pos_conds_cell{i} = pos_conds(:,:,i);
        end

        pos_conds = pos_conds_cell;
    end
    
    %create matching durations cell array

end