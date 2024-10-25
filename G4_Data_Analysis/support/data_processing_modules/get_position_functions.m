function [position_functions, exp] = get_position_functions(path_to_protocol, num_conds)

    exp = load(path_to_protocol,'-mat');
    [expPath, expName, ~] = fileparts(path_to_protocol);
    blockTrials = exp.exp_parameters.block_trials;
    position_functions = {};

    for cond = 1:num_conds
        mode = blockTrials{cond,1};
        if mode == 1 || mode == 5 || mode == 6
            funcName = blockTrials{cond,3};
            funcPath = fullfile(expPath, 'Functions', [funcName '.mat']);
            funcData = load(funcPath);
            expectedData = funcData.pfnparam.func;
            position_functions{cond} = expectedData;
        else
            positon_functions{cond} = NaN;
        end

    end



end 