function [hist_data] = calculate_histograms(da_data, hist_datatypes, Frame_ind, num_conds, num_reps,...
    LmR_ind, LpR_ind)

    %calculate histograms of/by pattern position
    num_hist_datatypes = length(hist_datatypes); 
    max_pos = max(max(max(da_data(Frame_ind,:,:,:),[],4),[],3),[],2);
    hist_data = nan([num_hist_datatypes num_conds num_reps max_pos]);
    p = permute(1:max_pos,[1 3 4 2]); %create array of all possible pattern position values along 4th dimension
    
    %get histogram of pattern position
    tmpdata = permute(da_data(Frame_ind,:,:,:),[2 3 4 1]);
    p_idx = tmpdata==p;
    hist_data(1,:,:,:) = nansum(p_idx,3); 
    
    %get mean turning, forward, and sideslip for each pattern position
    tmpdata = repmat(da_data([LmR_ind, LpR_ind],:,:,:),[1 1 1 1 max_pos]);
    p_idx = repmat(permute(p_idx,[5 1 2 3 4]),[2 1 1 1 1]);
    tmpdata(~p_idx) = nan;
    hist_data(2:3,:,:,:) = nanmean(tmpdata,4); %LmR and LpR by pattern position
    
    %do it again but with normalized 

end