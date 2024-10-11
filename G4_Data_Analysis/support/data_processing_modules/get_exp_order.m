function [exp_order, num_conds, num_reps, total_exp_trials] = get_exp_order(exp_folder, trial_options)
    
    if ~isfile(fullfile(exp_folder, 'exp_order.mat'))
        error('Cannot find exp_order.mat in given experiment folder');
    end
    
    load(fullfile(exp_folder,'exp_order.mat'),'exp_order');
    exp_order = exp_order'; %change to [condition, repetition]
    [num_conds, num_reps] = size(exp_order);

    total_exp_trials = num_conds*num_reps  + trial_options(1) + trial_options(3);
    if trial_options(2)
        total_exp_trials = total_exp_trials + ((num_conds*num_reps) - 1);
    end

end