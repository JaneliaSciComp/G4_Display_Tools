function [bad_FP_conds] = check_frame_position(path_to_protocol, start_times, stop_times, exp_order, ...
    Log, condModes, corrTolerance, framePosTolerance)

    num_conds = size(exp_order,1);
    num_reps = size(exp_order,2);
    exp = load(path_to_protocol,'-mat');
    [expPath, expName, ~] = fileparts(path_to_protocol);
    blockTrials = exp.exp_parameters.block_trials;
    conds_outside_corr_tolerance = [];
    bad_FP_conds = [];
    


    for cond = 1:num_conds
        if condModes(cond) == 1
            funcName = blockTrials{cond,3};
            funcPath = fullfile(expPath, 'Functions', [funcName '.mat']);
            funcData = load(funcPath);
            expectedData = funcData.pfnparam.func;
    
            for rep = 1:num_reps
                trial = find(exp_order(:,rep)==cond);
                trialind = num_conds*(rep-1) + trial;
                start_ind = find(Log.Frames.Time(1,:)>=(start_times(trialind)),1);
                stop_ind = find(Log.Frames.Time(1,:)<=(stop_times(trialind)),1,'last');
                repData = Log.Frames.Position(start_ind:stop_ind);
                repData = repData + 1; %As of right now it looks like the Log starts frames at 0
                                        % (the first frame is recorded as  0) where as the function numbers
                                        % frames starting at 1. So add 1 to all recorded numbers to make sure
                                        % they're both indicating the same frame with their numbers.
                [corrs, lags] = xcorr(expectedData, repData);
                shift = lags(corrs==max(corrs));
                if length(shift) > 1
                    shift = shift(end);
                end
                shift_numbers(cond, rep) = shift;
                percent_off_zero(cond, rep) = abs(shift/size(lags,2));
                if percent_off_zero(cond,rep) > corrTolerance
                    conds_outside_corr_tolerance(end+1, end+1) = [cond, rep];
                end
                aligned_data{cond, rep} = repData;
                aligned_data{cond, rep}(1:abs(shift_numbers(cond,rep))) = [];
                diff = [];

                if length(expectedData) <= length(aligned_data{cond, rep})
                    num_comparisons = length(expectedData);
                else
                    num_comparisons = length(aligned_data{cond, rep});
                end
                for dp = 1:num_comparisons

                    diff(dp) = abs(expectedData(dp) - aligned_data{cond, rep}(dp));

                end
                avg_diffs(cond, rep) = mean(diff);
                max_diffs(cond, rep) = max(diff);
                prctile_diffs(cond, rep) = prctile(diff, 97);
                

            end

        end

    end

    % For each repetition of each condition
        % If the condition includes a position function
            % Get recorded frame position data for trial
            % get position function data
            % Do a cross correlation to find out how far shifted they are
            % Align them using the cross correlation info
            % Compare the two with some buffer for variation


end