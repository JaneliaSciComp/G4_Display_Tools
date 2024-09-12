function [bad_conds, bad_reps, bad_inter, summary] = consolidate_bad_conds(dur_conds, ...
    dur_inter, wbf_conds, num_trials, num_conds, num_reps, trial_options)

    num_intertrials = (num_trials - 1)*trial_options(2);
    
    codes = {'DUR', 'CC', 'WBF', 'SL'};
    bad_conditions = [dur_conds; wbf_conds];
    for i = size(bad_conditions,1):-1:1
        for j = size(bad_conditions,1):-1:1
            if i == j
                continue;
            elseif bad_conditions(i,:) == bad_conditions(j,:)
                bad_conditions(i,:) = [];
                break;
            end
        end
    end
    if ~isempty(bad_conditions)
        bad_conds = bad_conditions(:,2);
        bad_reps = bad_conditions(:,1);
    else
        bad_conds = [];
        bad_reps = [];
    end
    if ~isempty(dur_inter)
        bad_inter = dur_inter;
    else
        bad_inter = [];
    end
   
% 
%     if ~isempty(bad_conds)
%         bad_conditions_cell{1,1} = bad_conds(1);
%         bad_conditions_cell{1,2} = bad_reps(1);
%         ind = 2;
% 
%         for badcond = 2:length(bad_conds)
%             curr_ind = find(cellfun(@(x)isequal(x,bad_conds(badcond)), bad_conditions_cell));
%             %iff curr_ind is empty, the condition hasn't been recorded yet. If
%             %it is > length(bad_conditions_cell) its in the reps column and doesn't
%             %count.
%             if ~isempty(curr_ind) 
%                 if curr_ind <= size(bad_conditions_cell,1)
%                     bad_conditions_cell{curr_ind,2} = [bad_conditions_cell{curr_ind,2}, bad_reps(badcond)];
%                 end
%             else
%                 bad_conditions_cell{ind,1} = bad_conds(badcond);
%                 bad_conditions_cell{ind,2} = bad_reps(badcond);
%                 ind = ind + 1;
%             end
%         end
%     else
%         bad_conditions_cell{1,1} = [];
%         bad_conditions_cell{1,2} = [];
%     end
%      


    conditionReps_removed = length(bad_conds);
    total_conditionReps = num_reps * num_conds;
    total_trials = total_conditionReps + num_intertrials + trial_options(1) + trial_options(3);
    intertrials_removed = length(bad_inter);
    total_trials_removed = conditionReps_removed + intertrials_removed; 
    total_trials_run = total_trials - total_trials_removed;
    conditions_run = num_conds*num_reps - conditionReps_removed;
    
    summary{1} = 'CODES: ';
    summary{2} = strcat(codes{1}, ': Wrong duration');
    summary{3} = strcat(codes{2}, ': Cross Correlation too far off.');
    summary{4} = strcat(codes{3}, ': Fly stopped flying too much.');
    summary{5} = strcat(codes{4}, ': Slope of results is 0.');
    summary{6} = '';
    summary{7} = strcat(num2str(total_trials_run), ' trials run of ', ...
        num2str(total_trials), ' total.');
    summary{8} = strcat(num2str(conditions_run), ' condition reps run of ',  ...
        num2str(total_conditionReps), ' reps total');
    summary{9} = 'Bad conditions: ';
    summ_ind = 10;
    

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
    
%     for slope_cond = 1:size(slope_conds,1)
%         summary{summ_ind} = strcat('Condition: ', num2str(slope_conds(slope_cond, 2)), ...
%             '     Rep: ', num2str(slope_conds(slope_cond, 1)), '     Error Code: ', codes{2});
%         summ_ind = summ_ind + 1;
%     end
    
%     for conds = 1:size(bad_conditions_cell,1)
%         curr_codes = {};
%         cc_ind = 1;
%         if ~isempty(dur_conds)
%             if ~isempty(find(dur_conds(:,2)==bad_conditions_cell{conds,1}))
%                 curr_codes{cc_ind} = codes{1};
%                 cc_ind = cc_ind + 1;
%             end
%         end
%         if ~isempty(slope_conds)
%             if ~isempty(find(slope_conds(:,2)==bad_conditions_cell{conds,1}))
%                 curr_codes{cc_ind} = codes{4};
%                 cc_ind = cc_ind + 1;
%             end
%         end
%         if ~isempty(corr_conds)
%             if ~isempty(find(corr_conds(:,2)==bad_conditions_cell{conds,1}))
%                 curr_codes{cc_ind} = codes{2};
%                 cc_ind = cc_ind + 1;
%             end
%         end
%         if ~isempty(wbf_conds)
%             if ~isempty(find(wbf_conds(:,2)==bad_conditions_cell{conds,1}))
%                 curr_codes{cc_ind} = codes{3};
%                 cc_ind = cc_ind + 1;
%             end
%         end
%         if ~isempty(curr_codes)
%             code = curr_codes{1};
%             if length(curr_codes)>1
%                 for c = 2:length(curr_codes)
%                     code = strcat(code, ', ', curr_codes{c});
%                 end
%             end
%         else
%             code = '';
%         end
%         msg = strcat('Condition: ', num2str(bad_conditions_cell{conds,1}),...
%             '    Rep(s): ', num2str(bad_conditions_cell{conds,2}), ...
%             '    Error Code(s): ', code);
%         summary{summ_ind} = msg;
%         summ_ind = summ_ind + 1;
%     end

    summary{summ_ind} = 'Bad Intertrials: ';
    summ_ind = summ_ind + 1;
    if isempty(dur_inter)
        summary{summ_ind} = 'None';
        summ_ind = summ_ind + 1;
    else
        for inter = 1:length(dur_inter)
            summary{summ_ind} = strcat('Intertrial # ', num2str(dur_inter(inter)),...
                '     Error Code: ', codes{1});
            summ_ind = summ_ind + 1;
        end
    end    
end