function frame_movement_times = get_pattern_move_times_test(ts_data, Frame_ind)

    frame_data = squeeze(ts_data(Frame_ind, :, :, :));
    num_conds = size(frame_data, 1);
    num_reps = size(frame_data, 2);
    
    frame_movement_times = NaN([num_conds num_reps]);

    for cond = 1:num_conds
        for rep = 1:num_reps
            idx = 1;
            while frame_data(cond, rep, idx + 1) - frame_data(cond, rep, idx) == 0 ...
                    || isnan(frame_data(cond, rep, idx + 1) - frame_data(cond, rep, idx))
                idx = idx + 1;
                if idx == size(frame_data,3) - 1
                    idx = NaN;
                    break;
                end
            end
            time_to_move = idx;
            frame_movement_times(cond, rep) = time_to_move;
        end
    end
end
