function [bad_trials, wbf_data] = find_bad_wbf_trials(ts_data, wbf_range, wbf_cutoff, ...
    wbf_end_percent, F_chan_idx)

    %set variables
    num_conds = size(ts_data,2);
    num_reps = size(ts_data,3);
    wbf_data = nan([num_conds num_reps size(ts_data,4)]);

    bad_trial_count = 0;
    bad_indices = [];
    bad_trials = [];

    for cond = 1:num_conds
        for rep = 1:num_reps
            
            %For each condition and rep, get the appropriate set of data
            data = squeeze(ts_data(F_chan_idx, cond, rep, :));
            wbf_data(cond, rep, :) = data;
            
            count = 1;
        
            %find all elements where the wbf falls outside of acceptable
            %range and count them. 
            if sum(~isnan(data))>0
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
            
            
    
   

