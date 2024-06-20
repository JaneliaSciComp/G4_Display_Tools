function [frame_position_check] = check_frame_position(path_to_protocol, start_times, stop_times, exp_order, ...
    Log, condModes, corrTolerance, framePosTolerance, framePosPercentile, perctile_tol, num_conds_short)

    num_conds = size(exp_order,1);
    num_reps = size(exp_order,2);
    exp = load(path_to_protocol,'-mat');
    [expPath, expName, ~] = fileparts(path_to_protocol);
    blockTrials = exp.exp_parameters.block_trials;
    shift_numbers = zeros(num_conds,num_reps);
    percent_off_zero = zeros(num_conds, num_reps);
    conds_outside_corr_tolerance = {};
    frame_pos_avg_diff_above_tol = {};
    frame_pos_prctile_above_tol = {};

    for cond = 1:num_conds
        if condModes(cond) == 1
            funcName = blockTrials{cond,3};
            funcPath = fullfile(expPath, 'Functions', [funcName '.mat']);
            funcData = load(funcPath);
            expectedData = funcData.pfnparam.func;
    
            for rep = 1:num_reps
                trial = find(exp_order(:,rep)==cond);
                trialind = num_conds*(rep-1) + trial;
                if trialind <= length(start_times)
                    start_ind = find(Log.Frames.Time(1,:)>=(start_times(trialind)),1);
                    stop_ind = find(Log.Frames.Time(1,:)<=(stop_times(trialind)),1,'last');
                    repData = Log.Frames.Position(start_ind:stop_ind);
                    repData = double(repData + 1); %As of right now it looks like the Log starts frames at 0
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
                        conds_outside_corr_tolerance{end+1} = [cond, rep];
                    end
                    aligned_data{cond, rep} = repData;
                    aligned_data{cond, rep}(1:abs(shift_numbers(cond,rep))) = []; %Always shift left, 
                    %                                                               there should always be a lag in recorded data, 
                    %                                                               it wouldn't ever be ahead so no need 
                    %                                                               to ever shift the other way.
                    diff = [];
    
                    if length(expectedData) <= length(aligned_data{cond, rep}) % The number of points to compare is always the length of the
                                                                               % shorter array
                        num_comparisons = length(expectedData);
                    else
                        num_comparisons = length(aligned_data{cond, rep});
                    end
                    for dp = 1:num_comparisons
    
                        diff(dp) = abs(expectedData(dp) - aligned_data{cond, rep}(dp));
    
                    end
                    avg_diffs(cond, rep) = mean(diff);
                    max_diffs(cond, rep) = max(diff);
                    prctile_diffs(cond, rep) = prctile(diff, framePosPercentile);
                    if avg_diffs(cond, rep) >  framePosTolerance
                        frame_pos_avg_diff_above_tol{end+1} = [cond, rep];
                    end
                    if prctile_diffs(cond, rep) > perctile_tol
                        frame_pos_prctile_above_tol{end+1} = [cond, rep];
                    end

                else
                    avg_diffs(cond, rep) = NaN;
                    max_diffs(cond, rep) = NaN;
                    prctile_diffs(cond, rep) = NaN;
                end
                

            end

        end

    end

    frame_position_check = struct;
    frame_position_check.average_difference = avg_diffs;
    frame_position_check.max_difference = max_diffs;
    frame_position_check.percentile_difference = prctile_diffs;
    frame_position_check.correlation_outside_tolerance = conds_outside_corr_tolerance;
    frame_position_check.average_above_tolerance = frame_pos_avg_diff_above_tol;
    frame_position_check.percentile_above_tolerance = frame_pos_prctile_above_tol;

    % Display warnings to the user for any condition/rep pairs that fell
    % out of tolerance ranges provided by the user.
    if  ~isempty(conds_outside_corr_tolerance)
        msg = ['These condition and rep pairs were above tolerance when the ' ...
            'recorded frame positions were cross correlated with the expected position function:'];
        for p = 1:length(conds_outside_corr_tolerance)
            msg = [msg ' cond/rep: ' num2str(conds_outside_corr_tolerance{p}) ','];
        end

        warning(msg);
    end

    if ~isempty(frame_pos_avg_diff_above_tol)

        msg = ['When the recorded position frame was compared to the position ' ...
            'function point by point, the average difference was above tolerance for these cond/rep pairs:'];

        for p = 1:length(frame_pos_avg_diff_above_tol)
            msg = [msg ' cond/rep: ' num2str(frame_pos_avg_diff_above_tol{p}) ','];
        end

        warning(msg);

    end

    if ~isempty(frame_pos_prctile_above_tol)

        msg = ['When the recorded position frame was compared to the position ' ...
            'function point by point, the percentile value was above tolerance for these condition/rep pairs:'];

        for p = 1:length(frame_pos_prctile_above_tol)
            msg = [msg ' cond/rep: ' num2str(frame_pos_prctile_above_tol{p}) ','];
        end

        warning(msg);

    end



end