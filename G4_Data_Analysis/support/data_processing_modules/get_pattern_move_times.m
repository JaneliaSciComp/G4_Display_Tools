function [pattern_movement_times, pos_func_movement_times, bad_conds_movement, ...
    bad_reps_movement] = get_pattern_move_times(ts_data, position_functions, Frame_ind)
    
    num_conds = size(ts_data,2);
    num_reps = size(ts_data,3);
    pattern_movement_times = nan([num_conds num_reps]);
    pos_func_movement_times = nan([1 num_conds]);
    bad_conds_movement = [];
    bad_reps_movement = [];
    for cond = 1:num_conds
        pos_func = position_functions{cond};
        if ~isnan(pos_func)
        %Find first movement in expected (position function) data.
            idx = 1; 
            while pos_func(idx + 1) - pos_func(idx) == 0
                idx = idx + 1;
            end
            exp_move = [pos_func(idx), pos_func(idx+1)];
            pos_func_movement_times(cond) = idx+1;
            for rep = 1:num_reps
                pos_data = squeeze(ts_data(Frame_ind, cond, rep, :));
                if sum(~isnan(pos_data))>0
                    pos_idx = 1;
                    found = 0;
                    while found == 0
                        if pos_data(pos_idx + 1) - pos_data(pos_idx) == 0
                            pos_idx = pos_idx + 1;
                        else
                            if [pos_data(pos_idx), pos_data(pos_idx + 1)] == exp_move
                                found = 1;
                            else
                                pos_idx = pos_idx + 1;
                            end
                        end
                        if pos_idx >= length(pos_data)
                            found = 2;
                        end
                    end
                    if found == 1
                        pattern_movement_times(cond, rep) = pos_idx+1; 
                    else
                        pattern_movement_times(cond,rep) = nan;
                        warning(['The pattern movement time could not be found for condition ' num2str(cond) 'rep ' num2str(rep) '. This data has been removed.']);
                        bad_conds_movement(end+1) = cond;
                        bad_reps_movement(end+1) = rep;
                    end    
                else
                    pattern_movement_times(cond, rep) = nan;
                end
            end
        else
            %Find movement time without using position function (less
            %accurate)
            for rep = 1:num_reps
                pos_data = squeeze(ts_data(Frame_ind, cond, rep,:));
                idx = 11; % Start at index of 11 to get past the random frames
                          % that sometimes appear right at the beginning.
                while pos_data(idx + 1) - pos_data(idx) == 0 || isnan(pos_data(idx + 1) - pos_data(idx)) ...
                        && idx < length(pos_data)
                    idx = idx + 1;
                end
                if idx < length(pos_data)
                    pattern_movement_times(cond, rep) = idx+1;
                else
                    pattern_movement_times(cond, rep) = nan;
                end

            end

        end
    end
end