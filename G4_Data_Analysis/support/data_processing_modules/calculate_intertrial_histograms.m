function [inter_hist_data] = calculate_intertrial_histograms(inter_ts_data)

    max_pos = max(max(inter_ts_data,[],2));
    p = permute(1:max_pos,[3 1 2]);
    p_idx = inter_ts_data==p;
    inter_hist_data = permute(nansum(p_idx,2),[1 3 2]); 

end