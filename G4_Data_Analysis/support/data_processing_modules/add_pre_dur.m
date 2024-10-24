function ts_data = add_pre_dur(ts_data, unaligned_data, move_times, ts_time)

    preind = find(ts_time==0) - 1; % The number of data points before movement to include
    for idx = 1:size(ts_data,1)
        for cond = 1:size(ts_data,2)
            for rep = 1:size(ts_data,3)
                move = move_times(cond, rep); % index at which movement happened
                if ~isnan(move)
                    if sum(~isnan(squeeze(ts_data(idx, cond, rep, :)))) ~= 0
                        data_to_add = squeeze(unaligned_data(idx, cond, rep, move-(preind-1):move));
                        ts_data(idx, cond, rep, :) = circshift(ts_data(idx, cond, rep, :), preind);
                        ts_data(idx,cond, rep, 1:preind) = data_to_add;
                    end
                end
  
            end
        end
    end
end
