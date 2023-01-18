function total_time = get_total_experiment_length(p)

    total_time = 0; 
    if p.inter_type == 1
        for i = 1:p.num_cond
            total_time = total_time + p.block_trials{i,12} + p.inter_dur;
        end
        total_time = (total_time * p.reps) - p.inter_dur; %bc no intertrial before first rep OR after last rep of the block.
    else %meaning no intertrial
        for i = 1:p.num_cond
            total_time = total_time + p.block_trials{i,12};
        end
        total_time = total_time * p.reps;
    end
    
    if p.pre_start == 1
        total_time = total_time + p.pre_dur;
    end
    if p.post_type == 1
        total_time = total_time + p.post_dur;
    end

end