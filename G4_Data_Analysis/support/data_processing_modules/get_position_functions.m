function [position_functions, expanded_posfuncs, exp] = get_position_functions(path_to_protocol, num_conds, data_rate)

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
            expanded_posfuncs{cond} = nan([1 length(expectedData)*(data_rate/500)]);
            el = 1;
            for full = 1:(data_rate/500):length(expanded_posfuncs{cond})
                expanded_posfuncs{cond}(full) = expectedData(el);
                expanded_posfuncs{cond}(full+1:full+((data_rate/500)-1)) = expectedData(el);
                el = el + 1;
            end
        else
            position_functions{cond} = NaN;
        end
        

    end




end 