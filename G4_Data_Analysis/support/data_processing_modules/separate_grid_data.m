function ts_data = separate_grid_data(ts_data, shifted_cond_data, ...
    frame_move_inds, Frame_ind, num_frames, num_ADC_chans)
    stim_order = [];
    stim = 1;
    frame_data = squeeze(shifted_cond_data(Frame_ind, :, :, :));

    for cond = 1:size(frame_data,1)
        for rep = 1:size(frame_data,2)
            for ind = 1:2:size(frame_move_inds,3) %first index where it changes is start of first stim
                frame = frame_data(cond, rep, frame_move_inds(ind));
                stim_order(stim) = frame;
                stim = stim + 1;
                ts_data(Frame_ind, cond, rep, frame, :) = frame_data(cond, rep, frame_move_inds(ind):(frame_move_inds(ind+1)-1));

            end
        end
    end

    % Do the thing next where you get the timestamps for each index of
    % frame changing, and then use those to get the ADC indices for hte
    % same time points, and then use those to get the ADC data for those
    % same sections. 
                




end