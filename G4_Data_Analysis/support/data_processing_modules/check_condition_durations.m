function [bad_conds, bad_intertrials] = check_condition_durations(cond_dur, intertrial_durs, path_to_protocol)
    bad_conds = [];
    bad_intertrials = [];
    exp = load(path_to_protocol, '-mat');
    for cond = 1:size(exp.exp_parameters.block_trials,1)
        expected_durs(cond) = exp.exp_parameters.block_trials{cond, 12};
    end
    count = 1;
    for rep = 1:size(cond_dur,2)

        for con = 1:size(cond_dur,1)
            if abs(1 - expected_durs(con)/cond_dur(con, rep)) > .1
                bad_conds(count, :) = [rep con];
                count = count + 1;
            end
        end
    end
    
    if ~isempty(intertrial_durs)
        c = 1;
        intertrial_dur = exp.exp_parameters.intertrial{12};
        for in = 1:length(intertrial_durs)
            if abs(1 -intertrial_dur/intertrial_durs(in)) > .1
                bad_intertrials(c) = in;
                c = c + 1;
            end
        end
    end
        
    
    


end