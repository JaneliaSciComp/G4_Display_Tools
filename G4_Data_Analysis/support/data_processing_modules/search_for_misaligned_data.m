function ts_data = search_for_misaligned_data(ts_data, dev_limit, num_conds, num_reps, Frame_ind)
    indices = nan(num_conds, num_reps);
    for  cond = 1:num_conds
        for rep = 1:num_reps
            if isnan(nanmean(ts_data(Frame_ind, cond, rep, :)))
                indices(cond, rep) = NaN;
            else
                l = 1;
                while ts_data(Frame_ind, cond, rep, l+1) - ts_data(Frame_ind, cond, rep, l) == 0 || ...
                        isnan((ts_data(Frame_ind, cond, rep, l+1) - ts_data(Frame_ind, cond, rep, l)))
                    l = l + 1;
                end
                if ~isempty(find(isnan(ts_data(Frame_ind, cond, rep, l:l+10))))
                    nan_inds = find(isnan(ts_data(Frame_ind, cond, rep, l:l+10)));
                    l = nan_inds(end) + l + 1;
                    while ts_data(Frame_ind, cond, rep, l+1) - ts_data(Frame_ind, cond, rep, l) == 0 || ...
                        isnan((ts_data(Frame_ind, cond, rep, l+1) - ts_data(Frame_ind, cond, rep, l)))
                        
                        l = l + 1;
                    end
                end
                indices(cond,rep) = l;
                
            end
        end
        mean_idx = nanmean(indices(cond,:));
        if isnan(mean_idx)
            rep_needs_aligned(cond) = NaN;
            continue;
        end
        for i = 1:length(indices(cond,:))
            if ~isnan(indices(cond,i))
                diffs(i) = abs(indices(cond,i) - mean_idx);
            else
                diffs(i) = NaN;
            end
        end
        
        last_ind = floor(mean_idx);
        if last_ind == 0
            last_ind = 1;
        end
        r = 1;
        while isnan(ts_data(Frame_ind, cond, r, :))
            r = r + 1;
        end
        while ~isnan(ts_data(Frame_ind, cond, r, last_ind))
            last_ind = last_ind + 1;
        end
        trial_length = last_ind - mean_idx;
        
        max_diff_idx = find(diffs==max(diffs));
        if length(max_diff_idx) == 1
            
            if diffs(max_diff_idx) > dev_limit*trial_length
                rep_needs_aligned(cond) = max_diff_idx;
            else
                rep_needs_aligned(cond) = NaN;
            end
        else
            rep_needs_aligned(cond) = NaN;
        end

        diffs = [];
                    
        
        
    end
    
    for con = 1:num_conds
        if ~isnan(rep_needs_aligned(con))
            inds = indices(con,:);
            inds(rep_needs_aligned(con)) = [];            
            mean_good_reps = nanmean(inds);
            idx = indices(con, rep_needs_aligned(con));
            shift_amt = floor(abs(idx - mean_good_reps));
            pad = nan(shift_amt,1);
            
            for datatype = 1:size(ts_data,1)
                
                new = squeeze(ts_data(datatype, con, rep_needs_aligned(con), :));
                if isreal(sqrt(idx - mean_good_reps))
                    %shift left
                    new(1:shift_amt) = [];
                    new = [new; squeeze(pad)];
                else
                    %shift right
                    new(end-shift_amt+1:end) = [];
                    new = [squeeze(pad); new];
                end
                ts_data(datatype, con, rep_needs_aligned(con),:) = new;
                new = [];
            end
        end
    end
            
    

end