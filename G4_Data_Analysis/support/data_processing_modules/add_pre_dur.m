function ts_data = add_pre_dur(ts_data, unaligned_data, move_times, ts_time)

    preind = find(ts_time==0) - 1; % The number of data points before movement to include
    for idx = 1:size(ts_data,1)
        for cond = 1:size(ts_data,2)
            for rep = 1:size(ts_data,3)
                move = move_times(cond, rep); % index at which movement happened
                if ~isnan(move)
                    if sum(~isnan(squeeze(ts_data(idx, cond, rep, :)))) ~= 0
                        if move >= preind
                            data_to_add = squeeze(unaligned_data(idx, cond, rep, move-(preind-1):move));
                        else
                            diffe = preind - move;
                            data_to_add = [nan([diffe 1]); squeeze(unaligned_data(idx, cond, rep, 1:move))];
                        end
                        ts_data(idx, cond, rep, :) = circshift(ts_data(idx, cond, rep, :), preind);
                        ts_data(idx,cond, rep, 1:preind) = data_to_add;
                    end
                end
  
            end
        end
    end
end
 
%% TO DO
% Right now, if movement happens early and move is less than preind, I just
% fill in the beginning with nans (since the trial doesn't have enough data
% before movement to fulfill the pre_dur settings). A better option would
% be to access the raw data and pull data from whatever trial ran before,
% so every trial has a full pre_dur worth of data before the movement time.
% 