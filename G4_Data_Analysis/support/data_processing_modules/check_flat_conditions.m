function [bad_conds] = check_flat_conditions(unaligned_ts_data, Frame_ind)
    
    count = 1;
    bad_conds = [];
    num_conds = size(unaligned_ts_data,2);
    num_reps = size(unaligned_ts_data,3);

    for cond = 1:num_conds
        for rep = 1:num_reps            
            data = squeeze(unaligned_ts_data(Frame_ind, cond, rep, :));
            diff = [];
            if sum(~isnan(data))>0
                for i = 1:length(data)-1
                    diff(i) = double(data(i+1)) - double(data(i));
                end
                if diff == 0
                    bad_conds(count, :) = [rep cond];
                    count = count + 1;
                end
            end
        end
    end
                
            
    

end