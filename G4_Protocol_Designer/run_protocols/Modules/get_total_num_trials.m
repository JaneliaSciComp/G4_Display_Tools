function num = get_total_num_trials(p)

    num = 0; 
    if p.pre_start == 1
        num = num + 1;
    end
    if p.inter_type == 1
        num = num + (p.reps*p.num_cond) - 1;
        %Minus 1 because there is no intertrial before the first
        %block trial OR after the last block trial.
    
    end
    if p.post_type == 1
        num = num + 1;
    end
    num = num + (p.reps*p.num_cond);
    %adds total number of block trials (not including intertrials)

end