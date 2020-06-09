function [conds] = create_default_plot_layout(conds_vec)

    default_W = [2 2 2 2 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5]; %width of figure by number of subplots
    default_H = [1 1 2 2 2 2 3 3 3 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 6 6 6 6 6]; %height of figure by number of subplots
    
    if ~isempty(conds_vec)
        
        num_conds = length(conds_vec);
        W = default_W(min([num_conds length(default_W)])); %get number of subplot columns (up to default limit)
        H = default_H(min([num_conds length(default_W)])); %get number of subplot rows
        D = ceil(num_conds/length(default_W)); %number of figures
        conds = nan([W H D]);
        conds(1:num_conds) = conds_vec;
        conds = permute(conds,[2 1 3]);
    else 
        conds = [];
        
    end
    
    if ~iscell(conds)
        for i = 1:length(conds(1,1,:))
            conds_cell{i} = conds(:,:,i);
        end

        conds = conds_cell;
    end
    

end