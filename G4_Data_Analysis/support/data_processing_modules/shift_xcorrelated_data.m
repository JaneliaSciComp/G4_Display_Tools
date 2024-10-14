function shifted_ts_data = shift_xcorrelated_data(ts_data, alignment_data, ...
    num_conds_short, Frame_ind, num_ADC_chans)

    shift_numbers = alignment_data.shift_numbers;
    num_conds = size(ts_data,2);
    num_reps = size(ts_data,3);
    shifted_ts_data = nan(size(ts_data));

    for cond = 1:num_conds-num_conds_short
        for rep = 1:num_reps
            shift = shift_numbers(cond, rep);
            for chan = 1:num_ADC_chans
                
                unshifted_data = squeeze(ts_data(chan, cond, rep, :));
                if shift > 0
                    shifted_data = circshift(unshifted_data, shift);
                    shifted_data(1:shift) = NaN;
                elseif shift < 0
                    shifted_data = circshift(unshifted_data, shift);
                    shifted_data(end+(shift+1):end) = NaN;
                else
                    shifted_data = unshifted_data;
                end
                shifted_ts_data(chan, cond, rep, :) = shifted_data;

            end
            unshifted_fr_data = squeeze(ts_data(Frame_ind, cond, rep, :));
            if shift > 0
                shifted_fr_data = circshift(unshifted_fr_data, shift);
                shifted_fr_data(1:shift) = NaN;
            elseif shift < 0
                shifted_fr_data = circshift(unshifted_fr_data, shift);
                shifted_fr_data(end+(shift+1):end) = NaN;
            else
                shifted_fr_data = unshifted_fr_data;
            end
            shifted_ts_data(Frame_ind, cond, rep, :) = shifted_fr_data;
        end
    end

end