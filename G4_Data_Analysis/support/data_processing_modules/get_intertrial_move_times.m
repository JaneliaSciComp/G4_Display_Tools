function [intertrial_move_times] = get_intertrial_move_times(inter_data, Frame_ind)

    for trial = 1:size(inter_data,2)
        
        idx = 1;
        while inter_data(Frame_ind, trial,idx+1)-inter_data(Frame_ind, trial,idx) == 0 ...
            || isnan(inter_data(Frame_ind, trial,idx+1)-inter_data(Frame_ind, trial,idx))...
                && idx < size(inter_data,3)
            idx = idx + 1;
        end
        intertrial_move_times(trial) = idx;

    end

end

