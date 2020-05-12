function [pos_series, mean_pos_series] = get_position_series(ts_data, Frame_ind, ...
    num_positions, data_pad, LmR_ind, sm_delay, pos_conditions)
    
    if ~isempty(pos_conditions)
        ts_pos_data = ts_data(:,pos_conditions,:,:);
    else
        ts_pos_data = ts_data;
    end
    [num_chans, num_conds, num_reps, max_pts] = size(ts_pos_data);  
%    ts_pos_data = round(ts_pos_data*100);
    
    tmp = (squeeze(ts_pos_data(Frame_ind,1,:,:)));
    for rep = 1:size(tmp,1)
        for pt = 1:size(tmp,2)
            if ~isnan(tmp(rep, pt)) && floor(tmp(rep,pt)) ~= tmp(rep,pt)
                error("Position data has non-integers");
            end
        end
    end
    
    pos_series = nan(num_conds, num_reps, num_positions); % just choose 192 for general case of 1 pos per frame position 

    for cond_ind = 1:num_conds
        for rep_ind = 1:num_reps
            % next few lines extract the indices of the data we wish to
            % analyze. Here we assume that the data structure may have nans at a few
            % positions in front and the more padded at the end. 
            temp_pos_ts = squeeze(ts_pos_data(Frame_ind,cond_ind,rep_ind, :));
            temp_analysis_inds = find(isfinite(temp_pos_ts)); 
            analysis_inds = temp_analysis_inds(data_pad:(end-data_pad));
            pos_ts = temp_pos_ts(analysis_inds);

            step_candidates = find(diff(pos_ts)); % find the indices where the position changes

            med_step_size = median(diff(step_candidates)); % what's the avergae gap size

            % currently missing from this code below:
            % 1) not backing off for first and last steps (the flat parts),
            % only using equal length step sizes, so missing 2 points relative
            % to method a
            % 2) don't check that each mean_step_val is unique; if something goes wrong, could end up
            % coppying over same data multiple times if don't check
            for step_inds = 1:length(step_candidates)-1 
                if abs(step_candidates(step_inds + 1) - step_candidates(step_inds) - med_step_size)/med_step_size < 0.5 % is step size is within 50% of the median
                    step_range_rel = step_candidates(step_inds):step_candidates(step_inds+1) + 1;
                    mean_step_val = mean(pos_ts(step_range_rel) );
                    if abs(mean_step_val - round(mean_step_val)) > 0.1 warning('error with step detection'); end
                    mean_step_val = round(mean_step_val); % force it to be an integer

                    step_range_abs = analysis_inds(step_range_rel) + sm_delay ; % sm_delay is offset in time (response lags stim appearance)

                    if size(step_range_abs) > 0 
                        pos_series(cond_ind, rep_ind, mean_step_val) = squeeze(nanmean(ts_pos_data(LmR_ind,cond_ind,rep_ind, step_range_abs), 4)); 
                    else
                        warning('step length error')
                    end

                else
                    % debug
                    [cond_ind rep_ind step_inds abs(step_candidates(step_inds + 1) - step_candidates(step_inds) - med_step_size)/med_step_size]
                    warning('long step, not counting');
                end
            end
        end
    end

    mean_pos_series = squeeze(nanmean(pos_series, 2));

    

end