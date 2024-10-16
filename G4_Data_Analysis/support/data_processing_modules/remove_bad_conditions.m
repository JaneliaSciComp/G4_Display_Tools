function ts_data = remove_bad_conditions(ts_data, bad_conds, bad_reps)
    
    for ind = 1:length(bad_conds)
        badCond = bad_conds(ind);
        badRep = bad_reps(ind);
        for chan = 1:size(ts_data,1)
            ts_data(chan, badCond, badRep, :) = nan([1 size(ts_data,4)]);
        end
    end

end