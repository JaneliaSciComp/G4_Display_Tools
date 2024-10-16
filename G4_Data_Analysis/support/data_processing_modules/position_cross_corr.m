function alignment_data = position_cross_corr(position_functions, ...
    num_conds_short, condModes, ts_data, Frame_ind, corrTolerance)

    num_conds = size(ts_data,2);
    num_reps = size(ts_data,3);
    shift_numbers = nan([num_conds num_reps]);
    percent_off_zero = nan([num_conds num_reps]);
    conds_outside_corr_tolerance = {};
    avg_shift_nums = nan([num_conds num_reps]);

    for cond = 1:num_conds-num_conds_short
        if condModes(cond) == 1
            expectedData = position_functions{cond};
            for rep = 1:num_reps
                collData = squeeze(ts_data(Frame_ind, cond, rep, :));
                if ~isnan(collData)
                    [corrs, lags] = xcorr(expectedData, collData);
                    shift = lags(corrs==max(corrs));
                    avgShift = sum(lags .* corrs) / sum(corrs);
                    if length(shift) > 1
                        shift = shift(end);
                    end
                    shift_numbers(cond, rep) = shift;
                    avg_shift_nums(cond, rep) = avgShift;
                    percent_off_zero(cond, rep) = abs(shift/size(lags,2));
                    if percent_off_zero(cond,rep) > corrTolerance
                        conds_outside_corr_tolerance{end+1} = [cond, rep];
                    end
                else
                    shift_numbers(cond, rep) = nan;
                    avg_shift_nums(cond, rep) = nan;
                    percent_off_zero(cond, rep) = nan;
                end
            end
        end
    end
    alignment_data = struct;
    alignment_data.shift_numbers = shift_numbers;
    alignment_data.percent_off_zero = percent_off_zero;
    alignment_data.conds_outside_corr_tol = conds_outside_corr_tolerance;



end