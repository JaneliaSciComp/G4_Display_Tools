function [bad_conds] = check_flat_conditions(start_times, stop_times, Log, num_reps, num_conds, exp_order)
    
    count = 1;
    bad_conds = [];
    for rep = 1:num_reps
        for trial = 1:num_conds
            ind = num_conds*(rep-1) + trial;
            start_ind = find(Log.Frames.Time(1,:)>=(start_times(ind)),1);
            stop_ind = find(Log.Frames.Time(1,:)<=(stop_times(ind)),1,'last');
            data = Log.Frames.Position(start_ind:stop_ind);
            diff = [];
            for i = 1:length(data)-1
                diff(i) = double(data(i+1)) - double(data(i));
            end
            if diff == 0
                cond = exp_order(trial, rep);
                bad_conds(count, :) = [rep cond];
                count = count + 1;
            end
        end
    end
                
            
    

end