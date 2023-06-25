function [baselines, maxs] = get_max_process_normalization(settings, ...
    timeseries_data, timestamps, num_conds, num_datapoints, num_datatypes)

    baseline_startstop = settings.baseline_startstop;
    max_startstop = settings.max_startstop;
    max_prctile = settings.max_prctile;

    base_start = find(timestamps>=baseline_startstop(1),1);
    base_stop = find(timestamps<=baseline_startstop(2),1,'last');
    max_start = find(timestamps>=max_startstop(1),1);
    max_stop = find(timestamps<=max_startstop(2),1,'last');

    datalen = numel(timeseries_data(1,:,base_start:base_stop));
    tmpdata = reshape(timeseries_data(:,:,base_start:base_stop),[num_datatypes datalen]);
    baselines = repmat(mean(tmpdata,2, 'omitnan'),[1 num_conds num_datapoints]);
    datalen = numel(timeseries_data(1,:,max_start:max_stop));
    tmpdata = reshape(timeseries_data(:,:,max_start:max_stop),[num_datatypes datalen]);
    maxs = repmat(prctile(tmpdata,max_prctile,2),[1 num_conds num_datapoints]);
end
