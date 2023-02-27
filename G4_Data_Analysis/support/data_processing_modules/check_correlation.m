function [bad_conds] = check_correlation(start_times, stop_times, exp_order, Log, condModes)
    
    num_conds = size(exp_order,1);
    num_reps = size(exp_order,2);
    num_comparisons = ((num_reps-1)/2)*(num_reps);
    i =  1;
    for f = 1:num_reps -1
        for r = f+1:num_reps
            ref_array(i,:) = [f, r];
            i = i + 1;
        end
    end
    bad_conds = [];    
    bad_idx = 1;
    

    for cond = 1:num_conds
        if condModes(cond) == 1 || condModes(cond) == 2 || condModes(cond) == 3
            
            bad_comps = [];
            corrs = {};
            lags = {};
            for rep = 1:num_reps

                trial = find(exp_order(:,rep)==cond);
                trialind = num_conds*(rep-1) + trial;
                start_ind = find(Log.Frames.Time(1,:)>=(start_times(trialind)),1);
                stop_ind = find(Log.Frames.Time(1,:)<=(stop_times(trialind)),1,'last');              
                reps{rep,:} = Log.Frames.Position(start_ind:stop_ind);

            end


            ind = 1;
            for first = 1:num_reps - 1
                for rep = first+1:num_reps
                    v1 = squeeze(reps{first});
                    v2 = squeeze(reps{rep});
                    [corrs{cond, ind}, lags{cond, ind}] = xcorr(v1,v2);
                    ind = ind + 1;
                end
            end
            for comp = 1:size(corrs, 2)
                peaks(cond, comp) = max(corrs{cond, comp});
                pk_ind = corrs{cond, comp}==peaks(cond, comp);
                xval = lags{cond, comp}(pk_ind);
                if length(xval) > 1
                    xval = xval(end); %If there are two peaks of same height, take last one
                end
                percent_off_zero(cond, comp) = xval/size(lags{cond,comp},2);
            end

            if exist('peaks', 'var') == 1
                peaks(cond, comp+1) = mean(peaks(cond, 1:comp), 'omitnan');
                percent_off_zero(cond, comp+1) = mean(percent_off_zero(cond, 1:comp), 'omitnan');
            end
            index = 1;
            for c = 1:num_comparisons
                if abs(percent_off_zero(cond, c)) > .02
                    bad_comps(index) = c;
                    index = index + 1;
                end
            end
            if length(bad_comps) >= num_comparisons - ((floor(num_reps/2)-1)/2)*(floor(num_reps/2)) && ~isempty(bad_comps)
                for i = 1:num_reps
                    bad_conds(bad_idx,:) = [i, cond];
                    bad_idx = bad_idx + 1;
                end
            elseif length(bad_comps) >= 3
                bads = ref_array(bad_comps,:);
                common_num = intersect(bads(1,:), bads(2,:));
                for i = 3:size(bads,1)
                    common_num = intersect(bads(i,:), common_num);
                end
                if isempty(common_num)
                    for i = 1:num_reps
                        bad_conds(bad_idx,:) = [i, cond];
                        bad_idx = bad_idx + 1;
                    end
                else
                    bad_conds(bad_idx,:) = [common_num, cond];
                    bad_idx = bad_idx + 1;
                end
            elseif length(bad_comps) == 2
                bads = ref_array(bad_comps,:);
                common_num = intersect(bads(1,:), bads(2,:));
                if ~isempty(common_num)
                    bad_conds(bad_idx,:) = [common_num,cond];
                    bad_idx = bad_idx + 1;
                else
                    disp("Please manually check all reps of cond # " + num2str(cond) + ...
                        ". Cross correlations were off but the deviation could not be tied to any specific repetiton.");
                end
            elseif length(bad_comps) == 1
                disp("Please manually check all reps of cond # " + num2str(cond) + ...
                        ". One cross correlation was off but the deviation could not be tied to any specific repetiton.");
            end

        end
        
    end
end
