function [timeseries_data] = normalize_ts_data(channel_order, timeseries_data, maxs)

    for datatype = 1:length(channel_order)

        timeseries_data(datatype,:,:) = timeseries_data(datatype,:,:)./maxs(datatype,:,:);

    end
    
end