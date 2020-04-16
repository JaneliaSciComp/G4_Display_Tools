function [ts_data, ts_norm] = get_faLmR(ts_data, ts_norm, LmR_ind, faLmR_ind)

    if isempty(faLmR_ind)
        disp("faLmR was not included in the datatypes to be analyzed.")
        return;
    end
    ts_data(:,:,:,:,2) = nan; %duplicate ts_data along new dimension
    ts_data(faLmR_ind,:,:,:,:,1) = ts_data(LmR_ind,:,:,:,:,1); %1st set of values = LmR
	ts_data(faLmR_ind,1:2:end,:,:,2) = -ts_data(faLmR_ind,2:2:end,:,:,1); % left side of panel
	ts_data(faLmR_ind,2:2:end,:,:,2) = -ts_data(faLmR_ind,1:2:end,:,:,1);% from right side of panel
	ts_data = nanmean(ts_data,5); %average together the 2 sets of values (only for faLmR, everything else stays the same)
    
    %Do the same but with normalized data
    
    ts_norm(:,:,:,:,2) = nan; %duplicate ts_norm along new dimension
    ts_norm(faLmR_ind,:,:,:,:,1) = ts_norm(LmR_ind,:,:,:,:,1); %1st set of values = LmR
	ts_norm(faLmR_ind,1:2:end,:,:,2) = -ts_norm(faLmR_ind,2:2:end,:,:,1); % left side of panel
	ts_norm(faLmR_ind,2:2:end,:,:,2) = -ts_norm(faLmR_ind,1:2:end,:,:,1);% from right side of panel
	ts_norm = nanmean(ts_norm,5); %average together the 2 sets of values (only for faLmR, everything else stays the same)


end