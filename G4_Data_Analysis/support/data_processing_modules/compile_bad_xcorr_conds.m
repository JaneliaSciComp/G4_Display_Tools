function [bad_corr_conds, bad_corr_reps] = compile_bad_xcorr_conds(alignment_data, ...
    corrTolerance, ts_data)
    
    num_conds = size(ts_data,2);
    num_reps = size(ts_data,3);
    bad_corr_conds = [];
    bad_corr_reps = [];
    count = 1;

    for cond = 1:num_conds
        for rep = 1:num_reps
            if ~isnan(alignment_data.percent_off_zero(cond,rep))
                if alignment_data.percent_off_zero(cond,rep) > corrTolerance
                    bad_corr_conds(count) = cond;
                    bad_corr_reps(count) = rep;
                    count = count + 1;
                end
            end
        end
    end



end