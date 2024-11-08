function [faLmR_data, faLmR_data_norm] = get_faLmR(ts_data, ts_norm, LmR_ind, condition_pairs)

    num_conds = size(ts_data, 2);
    if isempty(condition_pairs)
        pair = 1;
        for con = 1:2:num_conds
            if con + 1 > num_conds
                condition_pairs{pair} = [];
            else
                condition_pairs{pair} = [con con+1];
            end
            pair = pair + 1;
        end
    end

    faLmR_data = NaN(length(condition_pairs), size(ts_data,3),  size(ts_data,4));
    faLmR_data_norm = NaN(length(condition_pairs), size(ts_data,3),  size(ts_data,4));

    for newc = 1:length(condition_pairs)
        tmp_data(1, :, :, :, :) = -ts_data(LmR_ind, condition_pairs{newc}(2), :, :);
        tmp_data(2,  :, :, :, :) = ts_data(LmR_ind, condition_pairs{newc}(1), :, :);

        new_cond = mean(tmp_data,1, 'omitnan');
        faLmR_data(newc,:,:) = squeeze(new_cond);

        tmp_norm(1, :, :, :, :) = -ts_norm(LmR_ind, condition_pairs{newc}(2), :, :);
        tmp_norm(2, :, :, :, :) = ts_norm(LmR_ind, condition_pairs{newc}(1), :, :);

        new_cond_norm = mean(tmp_norm,1, 'omitnan');
        faLmR_data_norm(newc, :, :) = squeeze(new_cond_norm);
    end
end