function [maxs] = get_max_process_normalization(max_prctile, ...
    timeseries_data, num_conds, num_datapoints, num_datatypes, num_reps)


    

    datalen = numel(timeseries_data(1,:,:,:));
    tmpdata = reshape(timeseries_data,[num_datatypes datalen]);
    maxs = repmat(prctile(tmpdata,max_prctile,2),[1 num_conds num_reps num_datapoints]);

end