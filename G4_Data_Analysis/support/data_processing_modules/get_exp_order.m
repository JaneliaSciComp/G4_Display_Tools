function [exp_order, num_conds, num_reps] = get_exp_order(exp_folder)
    
    if ~isfile(fullfile(exp_folder, 'exp_order.mat'))
        error('Cannot find exp_order.mat in given experiment folder');
    end
    
    load(fullfile(exp_folder,'exp_order.mat'),'exp_order');
    exp_order = exp_order'; %change to [condition, repetition]
    [num_conds, num_reps] = size(exp_order);

end