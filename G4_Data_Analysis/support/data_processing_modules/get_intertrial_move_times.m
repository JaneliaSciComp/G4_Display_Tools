function [intertrial_move_times] = get_intertrial_move_times(inter_data)

    for trial = 1:size(inter_data,1)
        
        idx = 1;
        while inter_data(trial,idx+1)-inter_data(trial,idx) == 0 || isnan(inter_data(idx+1)-inter_data(idx))...
                && idx < size(inter_data,2)
            idx = idx + 1;
        end
        intertrial_move_times(trial) = idx;

    end

end

