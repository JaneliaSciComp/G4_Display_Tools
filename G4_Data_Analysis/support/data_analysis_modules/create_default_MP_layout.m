function  [MP_conds] = create_default_MP_layout(pos_conditions, MP_condsIn)

    default_W = [2 2 2 2 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5]; %width of figure by number of subplots
    default_H = [1 1 2 2 2 2 3 3 3 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 6 6 6 6 6]; %height of figure by number of subplots

    %organize all relevant conditions into a vector

    if ~isempty(pos_conditions) && isempty(MP_condsIn)
        for i = length(pos_conditions):-1:1
            if rem(pos_conditions(i),2) == 0
                pos_conditions(i) = [];
            end
        end
  
        num_conds = length(pos_conditions);
        W = default_W(min([num_conds length(default_W)])); %get number of subplot columns (up to default limit)
        H = default_H(min([num_conds length(default_W)])); %get number of subplot rows
        D = ceil(num_conds/length(default_W)); %number of figures
%try just converting to cell at end? 
        MP_conds = nan([W H D]);
        MP_conds(1:num_conds) = pos_conditions;
        MP_conds = permute(MP_conds,[2 1 3]);
    elseif isempty(pos_conditions)
        MP_conds = [];
    else
        MP_conds = MP_condsIn;
    end
    
    if ~iscell(MP_conds)
        for i = 1:length(MP_conds(1,1,:))
            MP_conds_cell{i} = MP_conds(:,:,i);
        end

        MP_conds = MP_conds_cell;
    end
    
    %create matching durations cell array
    
    
end
