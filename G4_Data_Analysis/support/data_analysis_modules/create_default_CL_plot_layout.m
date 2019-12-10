function [CL_conds] = create_default_CL_plot_layout(conditionModes, CL_condsIn)

    default_W = [2 2 2 2 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5]; %width of figure by number of subplots
    default_H = [1 1 2 2 2 2 3 3 3 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 6 6 6 6 6]; %height of figure by number of subplots

    %find all closed-loop conditions, organize into block
    conds_vec = find(conditionModes==4); 
    if ~isempty(conds_vec) && isempty(CL_condsIn)
        num_conds = length(conds_vec);
        W = default_W(min([num_conds length(default_W)])); %get number of subplot columns (up to default limit)
        H = default_H(min([num_conds length(default_W)])); %get number of subplot rows
        D = ceil(num_conds/length(default_W)); %number of figures
        CL_conds = nan([W H D]);
        CL_conds(1:num_conds) = conds_vec;
        CL_conds = permute(CL_conds,[2 1 3]);
    elseif isempty(conds_vec)
        CL_conds = [];
    else
        CL_conds = CL_condsIn;
    end
    
    if ~iscell(CL_conds)
        
        CL_conds = num2cell(CL_conds); 
    end


end