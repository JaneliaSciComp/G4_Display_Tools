function [timeseries_data, maxVal] = normalize_ts_data(L_chan_idx, R_chan_idx, timeseries_data, maxs)
    
    maxVal = max([maxs(L_chan_idx,1,1),maxs(R_chan_idx,1,1)]); %Gets the max value between the left and right channels
    datatypes = [L_chan_idx, R_chan_idx];
    for datatype = datatypes
        
        timeseries_data(datatype,:,:) = timeseries_data(datatype,:,:)./maxVal;
        %Divide every data point in the left and right wing channels in
        %timeseries_data by the max value. 

    end
    
end