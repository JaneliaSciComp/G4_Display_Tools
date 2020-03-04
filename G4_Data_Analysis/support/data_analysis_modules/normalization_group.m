%Does this need to be done over all timeseries data or over averaged
%timeseries data? Should this be a setting? 

function [baselines, maxs] = normalization_group(timeseries_data, base_start, base_stop, ...
    max_start, max_stop, max_prctile, num_conds, num_datapoints, num_datatypes, ...
    num_groups, num_exps)

    tmptimeseries = permute(timeseries_data,[1 3 2 4 5]); %[group type exp cond rep datapoint]
    datalen = numel(tmptimeseries(1,1,:,:,base_start:base_stop));
    tmpdata = reshape(tmptimeseries(:,:,:,:,base_start:base_stop),[num_groups num_datatypes datalen]);
    baselines = repmat(nanmean(tmpdata,3),[1 1 num_exps num_conds num_datapoints]);
    baselines = permute(baselines,[1 3 2 4 5]); %[group exp type cond rep datapoint]
    datalen = numel(tmptimeseries(1,1,:,:,max_start:max_stop));
    tmpdata = reshape(tmptimeseries(:,:,:,:,max_start:max_stop),[num_groups num_datatypes datalen]);
    maxs = repmat(prctile(tmpdata,max_prctile,3),[1 1 num_exps num_conds num_datapoints]);
    maxs = permute(maxs,[1 3 2 4 5]); %[group exp type cond rep datapoint]

end