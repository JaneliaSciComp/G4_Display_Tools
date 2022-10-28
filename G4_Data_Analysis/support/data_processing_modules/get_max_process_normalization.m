function [maxs] = get_max_process_normalization(max_prctile, ...
    timeseries_data, num_conds, num_datapoints, num_datatypes, num_reps)


    

    datalen = numel(timeseries_data(1,:,:,:)); % Get length of data
    tmpdata = reshape(timeseries_data,[num_datatypes datalen]); %changes array shape so 
    % that each channel has all data points in one array for that channel,
    % so 7 x 400,000 ish
    maxs = repmat(prctile(tmpdata,max_prctile,2),[1 num_conds num_reps num_datapoints]);
    %returns array the same size as timeseries_data but where every element
    %is the max_prctile of the dataset. Usually set to 98th percentile. The
    %percentile value is different for each channel so there are 7
    %different values total.

end