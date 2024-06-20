function [bad_trials, wbf_data] = find_bad_wbf_trials(Log, ts_data, wbf_range, wbf_cutoff, ...
    wbf_end_percent, start_times, stop_times, num_conds, num_reps, exp_order, num_trials, num_trials_short)

    %set variables
    wbf_data = nan([num_conds num_reps size(ts_data,4)]);
    wbf_Rawdata = Log.ADC.Volts(4,:);
    wbf_time = Log.ADC.Time(4,:);
    bad_trial_count = 0;
    bad_indices = [];
    bad_trials = [];
    trials_run = num_trials - num_trials_short; %If experiment was ended early, get total trials actually run.
    
    
    for cond = 1:num_conds
        for rep = 1:num_reps
            
            %For each condition and rep, get the appropriate set of data
            trial = find(exp_order(:,rep)==cond);
            trialind = num_conds*(rep-1) + trial;
            if trialind <= trials_run
                start_ind = find(wbf_time(:)>=(start_times(trialind)),1);
                stop_ind = find(wbf_time(:)<=(stop_times(trialind)),1,'last');
                data = wbf_Rawdata(start_ind:stop_ind);
                wbf_data(cond, rep, :) = [data nan([1,size(ts_data,4) - length(data)])];
                
                count = 1;
            
                %find all elements where the wbf falls outside of acceptable
                %range and count them. 
                for wb = 1:size(wbf_data,3)
                    if wbf_data(cond, rep, wb)*100 < wbf_range(1) || wbf_data(cond, rep, wb)*100 > wbf_range(2)
                        bad_indices(count) = wb; 
                        count = count + 1;
                    end
                end
            
                %Check if the portion of bad wbf readings is above the user's
                %quality cutoff
                if count/size(wbf_data,3) > wbf_cutoff
                    
                    %if it is, check to see how many of the bad readings are
                    %clustered in the end. 
                    end_count = 1;
                    for w = 1:length(bad_indices)
                        if bad_indices(w) > .9*size(wbf_data,3)
                            end_count = end_count + 1;
                        end
                    end
                    
                    %If the portion of bad readings clustered at the end is
                    %smaller than the user provided percentage, record the
                    %trial as bad
                    if end_count/count <= wbf_end_percent
    
                        bad_trial_count = bad_trial_count + 1;
                        bad_trials(bad_trial_count,:) = [rep, cond];
                    end
                    
                    %If enough of the bad wbf readings are clustered at the
                    %end, keep the trial because the majority of the trial
                    %should be useable. 
                end

            end
     
       end     
    end
            
            
    
   

end