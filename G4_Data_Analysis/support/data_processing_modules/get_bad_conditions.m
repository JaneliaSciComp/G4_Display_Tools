function [bad_conds, bad_reps, bad_intertrials] = get_bad_conditions(common_cond_dur, cond_dur, ...
    num_reps, exp_folder, trial_options, intertrial_durs)

    if common_cond_dur == 1
        median_dur = repmat(median(cond_dur,2),[1 num_reps]); %find median duration for each condition
        dur_error = abs(cond_dur-median_dur)./median_dur; %find condition duration error away from median
        [bad_conds, bad_reps] = find(dur_error>0.01); %find bad trials (any trial where duration is off by >1%)
        if ~isempty(bad_conds) %display bad trials
            out = regexp(exp_folder,filesep,'start');
            exp_name = exp_folder(out(end)+1:end);
            fprintf([exp_name ' excluded trials' ])
            fprintf(' - cond %d, rep %d',[bad_conds bad_reps]')
            fprintf('\n')
        end
    else
        bad_conds = [];
        bad_reps = [];
    end
    
    %check intertrial durations for experiment errors
    if trial_options(2)
        median_dur = median(intertrial_durs,2); %find median duration for each intertrial
        dur_error = abs(intertrial_durs-median_dur)./median_dur; %find intertrial duration error away from median
        bad_intertrials = find(dur_error>0.01); %find bad intertrials (any trial where duration is off by >1%)
        if ~isempty(bad_intertrials) %display bad intertrials
            out = regexp(exp_folder,filesep,'start');
            exp_name = exp_folder(out(end)+1:end);
            fprintf([exp_name ' excluded intertrials' ])
            fprintf(' - trial %d',[bad_intertrials]')
            fprintf('\n')
        end
    end

end