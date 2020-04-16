function [timeseries_data, histograms] = normalize_ts_data(settings,...
    channelNames, timeseries_data,  num_positions, maxs)

    for datatype = 1:length(channelNames.timeseries)

        timeseries_data(datatype,:,:) = timeseries_data(datatype,:,:)./maxs(datatype,:,:);
        summaries(datatype,:,:) = summaries(datatype,:,:)./maxs(datatype,:,1);
        d = find(strcmpi(channelNames.histograms,datatype));
        if ~isempty(histograms)
            histograms(d,:,:,:) = histograms(d,:,:,:)./repmat(maxs(d,:,1),[1 1 1 num_positions]);
        end
    end
    
end