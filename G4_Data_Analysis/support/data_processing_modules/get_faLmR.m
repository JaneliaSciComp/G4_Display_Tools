function [faLmR_data, faLmR_data_norm] = get_faLmR(ts_data, ts_norm, LmR_ind, condition_pairs)
    
    faLmR_data = NaN(length(condition_pairs), size(ts_data,3),  size(ts_data,4));
    faLmR_data_norm = NaN(length(condition_pairs), size(ts_data,3),  size(ts_data,4));

    if isempty(condition_pairs)
        
        for new = 1:length(condition_pairs)
            tmp(1, :,:,:,:) = -ts_data(LmR_ind, condition_pairs{new}(2), :, :);
            tmp(2, :,:,:,:) = ts_data(LmR_ind, condition_pairs{new}(1), :, :);
            
            new_condition = nanmean(tmp,1);
            faLmR_data(new,:,:) = squeeze(new_condition);
            
            tmpNorm(1,:,:,:,:) = -ts_norm(LmR_ind, condition_pairs{new}(2), :, :);
            tmpNorm(2, :, :, :, :) = ts_norm(LmR_ind, condition_pairs{new}(1), :, :);
            
            new_condition_norm = nanmean(tmpNorm,1);
            faLmR_data_norm(new, :, :) = squeeze(new_condition_norm);
        end
        
        
    else
        
        for newc = 1:length(condition_pairs)
            tmp_data(1, :, :, :, :) = -ts_data(LmR_ind, condition_pairs{newc}(2), :, :);
            tmp_data(2,  :, :, :, :) = ts_data(LmR_ind, condition_pairs{newc}(1), :, :);

            new_cond = nanmean(tmp_data,1);
            faLmR_data(newc,:,:) = squeeze(new_cond);

            tmp_norm(1, :, :, :, :) = -ts_norm(LmR_ind, condition_pairs{newc}(2), :, :);
            tmp_norm(2, :, :, :, :) = ts_norm(LmR_ind, condition_pairs{newc}(1), :, :);

            new_cond_norm = nanmean(tmp_norm,1);
            faLmR_data_norm(newc, :, :) = squeeze(new_cond_norm);


        end
        
    end


end