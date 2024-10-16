function [bad_conds, bad_reps, bad_inter] = consolidate_bad_conds(dur_conds, ...
    dur_inter, wbf_conds, slope_conds)

    bad_conditions = [dur_conds; wbf_conds; slope_conds];
    for i = size(bad_conditions,1):-1:1
        for j = size(bad_conditions,1):-1:1
            if i == j
                continue;
            elseif bad_conditions(i,:) == bad_conditions(j,:)
                bad_conditions(i,:) = [];
                break;
            end
        end
    end
    if ~isempty(bad_conditions)
        bad_conds = bad_conditions(:,2);
        bad_reps = bad_conditions(:,1);
    else
        bad_conds = [];
        bad_reps = [];
    end
    if ~isempty(dur_inter)
        bad_inter = dur_inter;
    else
        bad_inter = [];
    end
  
end