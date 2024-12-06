function [ts_data, neutral_ts_data] = separate_grid_data(ts_data, shifted_cond_data, ...
    frame_move_inds, Frame_ind, num_frames, num_ADC_chans)
    stim_order = {};
    frame_data = shifted_cond_data(Frame_ind, :, :, :); 
    neutral_ts_data = ts_data;

    for cond = 1:size(frame_data,2)
        for rep = 1:size(frame_data,3)
            stim = 1;
            for ind = 1:2:size(frame_move_inds{cond, rep},2) %first index where it changes is start of first stim
                frame = frame_data(1, cond, rep, frame_move_inds{cond, rep}(ind));
                stim_order{cond}(rep, stim) = frame;
                stim = stim + 1;
                data = frame_data(1, cond, rep, frame_move_inds{cond, rep}(ind):(frame_move_inds{cond,rep}(ind+1)-1));
                dif = size(ts_data(Frame_ind, cond, rep, frame, :),5)-size(data,4);
                if dif > 0
                    data(end+1:end+dif) = NaN;
                elseif dif < 0
                    data(end+dif+1:end) = [];
                end

                ts_data(Frame_ind, cond, rep, frame, :) = data;

            end
        end
    end

    for chan = 1:num_ADC_chans
        for cond = 1:size(ts_data,2)
            for rep = 1:size(ts_data,3)
                stim = 1;
                first_neutral_data = squeeze(shifted_cond_data(chan, cond, rep, 1:frame_move_inds{cond, rep}(1)-1));
                first_frame = stim_order{cond}(rep, 1);
                neutral_ts_data(chan, cond, rep, first_frame, 1:length(first_neutral_data)) = first_neutral_data;
                for ind = 1:2:size(frame_move_inds{cond, rep},2) %first index where it changes is start of first stim

                    frame = stim_order{cond}(rep, stim);
                    data = shifted_cond_data(chan, cond, rep, frame_move_inds{cond, rep}(ind):(frame_move_inds{cond, rep}(ind+1)-1));
                    if ind > 1
                        neutral_data = shifted_cond_data(chan, cond, rep, frame_move_inds{cond, rep}(ind-1):frame_move_inds{cond, rep}(ind)-1);
                    end
                    dif = size(ts_data(chan, cond, rep, frame, :),5)-size(data,4);
                    if dif > 0
                        data(end+1:end+dif) = NaN;
                    elseif dif < 0
                        data(end+dif+1:end) = [];
                    end
    
                    ts_data(chan, cond, rep, frame, :) = data;
                    if ind > 1
                        neutral_ts_data(chan, cond, rep, frame, 1:length(neutral_data)) = neutral_data;
                    end
                    stim = stim + 1;

                end
                
            end
        end
    end



    % Do the thing next where you get the timestamps for each index of
    % frame changing, and then use those to get the ADC indices for hte
    % same time points, and then use those to get the ADC data for those
    % same sections. 
                




end