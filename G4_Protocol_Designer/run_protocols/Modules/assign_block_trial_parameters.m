function trial = assign_block_trial_parameters(params, p, c)

    trial.trial_mode = params.block_trials{c,1};
    trial.pat_id = p.block_pat_indices(c);
    trial.pos_id = p.block_pos_indices(c);
    if length(params.block_ao_indices) >= c
        trial.trial_ao_indices = params.block_ao_indices(c,:);
    else
        trial.trial_ao_indices = [];
    end
    %Set frame index
    if isempty(params.block_trials{c,8})
        trial.frame_ind = 1;
    elseif strcmp(params.block_trials{c,8},'r')
        trial.frame_ind = randperm(p.num_block_frames(c),1);
    else
       trial.frame_ind = str2num(params.block_trials{c,8});
    end
     
    trial.frame_rate = params.block_trials{c, 9};
    trial.gain = params.block_trials{c, 10};
    trial.offset = params.block_trials{c, 11};
    trial.dur = params.block_trials{c, 12};

end