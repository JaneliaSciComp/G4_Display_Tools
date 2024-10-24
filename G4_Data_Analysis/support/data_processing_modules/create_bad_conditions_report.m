function summary = create_bad_conditions_report(bad_conds, bad_inter, ...
    bad_trials_summary, num_conds, num_reps, trial_options, num_trials,...
    num_trials_short, num_conds_short)    

    num_intertrials = (num_trials - 1)*trial_options(2);
    
    codes = {'DUR', 'CC', 'WBF', 'SL', 'MOV'};
    conditionReps_removed = length(bad_conds);
    total_conditionReps = num_reps * num_conds;
    total_trials = total_conditionReps + num_intertrials + trial_options(1) + trial_options(3) - num_trials_short;
    intertrials_removed = length(bad_inter);
    total_trials_removed = conditionReps_removed + intertrials_removed; 
    total_trials_run = total_trials - total_trials_removed;
    conditions_run = num_conds*num_reps - conditionReps_removed - num_conds_short;

    dur_conds = bad_trials_summary.duration_conds;
    wbf_conds = bad_trials_summary.wbf_conds;
    slope_conds = bad_trials_summary.slope_conds;    
    xcorr_conds = bad_trials_summary.xcorr_conds;
    move_conds = bad_trials_summary.posfunc_conds;
    move_inter = bad_trials_summary.movement_intertrials;
    dur_inter = bad_trials_summary.duration_intertrials;
    
    summary{1} = 'CODES: ';
    summary{2} = strcat(codes{1}, ': Wrong duration');
    summary{3} = strcat(codes{2}, ': Cross Correlation too far off.');
    summary{4} = strcat(codes{3}, ': Fly stopped flying too much.');
    summary{5} = strcat(codes{4}, ': Slope of results is 0.');
    summary{6} = strcat(codes{5}, ': The screen did not move correctly.');
    summary{7} = '';
    summary{8} = strcat(num2str(total_trials_run), ' trials run of ', ...
        num2str(total_trials), ' total.');
    summary{9} = strcat(num2str(conditions_run), ' condition reps run of ',  ...
        num2str(total_conditionReps), ' reps total');
    summary{10} = strcat(num2str(num_trials_short), ' total trials not run due to ', ...
        'ending the experiment early.');
    summary{11} = 'Bad conditions: ';
    summ_ind = 12;
    

    for dur_cond = 1:size(dur_conds,1)
        summary{summ_ind} = strcat('Condition: ', num2str(dur_conds(dur_cond, 2)), ...
            '     Rep: ', num2str(dur_conds(dur_cond, 1)), '     Error Code: ', codes{1});
        summ_ind = summ_ind + 1;
    end


    for wbf_cond = 1:size(wbf_conds,1)
        summary{summ_ind} = strcat('Condition: ', num2str(wbf_conds(wbf_cond, 2)), ...
            '     Rep: ', num2str(wbf_conds(wbf_cond, 1)), '     Error Code: ', codes{3});
        summ_ind = summ_ind + 1;
    end
    
    for slope_cond = 1:size(slope_conds,1)
        summary{summ_ind} = strcat('Condition: ', num2str(slope_conds(slope_cond, 2)), ...
            '     Rep: ', num2str(slope_conds(slope_cond, 1)), '     Error Code: ', codes{4});
        summ_ind = summ_ind + 1;
    end

    for xcorr_cond = 1:size(xcorr_conds,1)
        summary{summ_ind} = strcat('Condition: ', num2str(xcorr_conds(xcorr_cond, 2)), ...
            '     Rep: ', num2str(xcorr_conds(xcorr_cond, 1)), '     Error Code: ', codes{2});
        summ_ind = summ_ind + 1;
    end

    for move_cond = 1:size(move_conds,1)
        summary{summ_ind} = strcat('Condition: ', num2str(move_conds(move_cond, 2)), ...
            '     Rep: ', num2str(move_conds(move_cond, 1)), '     Error Code: ', codes{5});
        summ_ind = summ_ind + 1;
    end 

    summary{summ_ind} = 'Bad Intertrials: ';
    summ_ind = summ_ind + 1;
    if isempty(dur_inter) && isempty(move_inter)
        summary{summ_ind} = 'None';
        summ_ind = summ_ind + 1;
    else
        for inter = 1:length(dur_inter)
            summary{summ_ind} = strcat('Intertrial # ', num2str(dur_inter(inter)),...
                '     Error Code: ', codes{1});
            summ_ind = summ_ind + 1;
        end

        for m_inter = 1:length(move_inter)
            summary{summ_ind} = strcat('Intertrial # ', num2str(move_inter(m_inter)),...
                '     Error Code: ', codes{5});
            summ_ind = summ_ind + 1;
        end
    end   
end