function [move_aligned_ts_data, aligned_inter_data, bad_intertrials] = shift_data_to_movement(ts_data, ...
    frame_movement_times, num_ADC_chans, Frame_ind, inter_data, inter_move_times, inter_shift_limit)
    
    num_conds = size(ts_data,2);
    num_reps = size(ts_data,3);
    move_aligned_ts_data = nan(size(ts_data));
    aligned_inter_data = nan(size(inter_data));
    bad_intertrials = [];
    for cond = 1:num_conds
        for rep = 1:num_reps
            
            shift = frame_movement_times(cond, rep);
            for chan = 1:num_ADC_chans          
                unshifted_data = squeeze(ts_data(chan, cond, rep, :));
                if sum(~isnan(unshifted_data))>0
                    if shift ~= 0 && ~isnan(shift)
                        % make shift neg bc we always want to shift left
                        shifted_data = circshift(unshifted_data, shift*(-1));
                        shifted_data(end-(shift-1):end) = NaN;           
                    else
                        shifted_data = unshifted_data;
                    end
                    move_aligned_ts_data(chan, cond, rep, :) = shifted_data;
                end
            end
            unshifted_fr_data = squeeze(ts_data(Frame_ind, cond, rep, :));
            if sum(~isnan(unshifted_fr_data))>0
                
                if shift ~= 0 && ~isnan(shift)
                    shifted_fr_data = circshift(unshifted_fr_data, shift*(-1));
                    shifted_fr_data(end+(shift+1):end) = NaN;
                else
                    shifted_fr_data = unshifted_fr_data;
                end
                move_aligned_ts_data(Frame_ind, cond, rep, :) = shifted_fr_data;
            end


        end
    end
    for trial = 1:size(inter_data,1)
        bad = 1;
        intshift = inter_move_times(trial);
        unshifted_intdata = inter_data(trial,:);
        if sum(~isnan(inter_data(trial,:))) > 0
            if intshift ~= 0 && ~isnan(intshift)
                if shift/size(inter_data,2) < inter_shift_limit
                    shifted_intdata = circshift(unshifted_intdata, shift*(-1));
                    shifted_intdata(end-(shift-1):end) = NaN;
                else
                    bad_intertrials(bad) = trial;
                    bad = bad + 1;
                    shifted_intdata = nan([1 size(inter_data,2)]);
                end
            else
                shifted_intdata = unshifted_intdata;
            end
            aligned_inter_data(trial,:) = shifted_intdata;
        end



    end

    

end