function position_functions = get_position_functions(path_to_protocol, num_conds)

    exp = load(path_to_protocol,'-mat');
    [expPath, expName, ~] = fileparts(path_to_protocol);
    blockTrials = exp.exp_parameters.block_trials;
    position_functions = {};

    for cond = 1:num_conds
        funcName = blockTrials{cond,3};
        funcPath = fullfile(expPath, 'Functions', [funcName '.mat']);
        funcData = load(funcPath);
        expectedData = funcData.pfnparam.func;
        position_functions{cond} = expectedData;

    end



end 