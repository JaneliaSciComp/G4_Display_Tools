
%Does this need all timeseries data or just averaged timeseries data? 

%Variables needed for this: num_groups, num_exps, num_datatypes, num_conds,
%num_datapoints, 

function [baselines, maxs] = normalization_fly(timeseries_data, base_start, ...
    base_stop, max_start, max_stop, max_prctile, num_conds, num_datapoints, num_datatypes, num_groups, num_exps)

    
    datalen = numel(timeseries_data(1,1,1,:,base_start:base_stop));
    tmpdata = reshape(timeseries_data(:,:,:,:,base_start:base_stop),[num_groups num_exps num_datatypes datalen]);
    baselines = repmat(mean(tmpdata,4,'omitnan'),[1 1 1 num_conds num_datapoints]);
    datalen = numel(timeseries_data(1,1,1,:,max_start:max_stop));
    tmpdata = reshape(timeseries_data(:,:,:,:,max_start:max_stop),[num_groups num_exps num_datatypes datalen]);
    maxs = repmat(prctile(tmpdata,max_prctile,4),[1 1 1 num_conds num_datapoints]);

end