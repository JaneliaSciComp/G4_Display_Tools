function [peak_frames, peak_frames_avg] = get_peak(ts_data, volt_idx,  grid_rows, grid_columns)
    

    ts_data_avg = squeeze(mean(ts_data,3, 'omitnan'));
    for cond = 1:size(ts_data,2)
        for frame = 2:size(ts_data,4)
            avgVolt = mean(squeeze(ts_data_avg(Volt_idx, cond, frame, :)), 'omitnan');
            gaussVals{cond}(frame) = avgVolt-medianVoltage;  
            
        end
        [absMax, absMaxFrame] = max(gaussVals{cond});
        redInds = find(gaussVals{cond}>.9*absMax);

    end



    % for cond = 1:size(ts_data,2)
    %     for rep = 1:size(ts_data,3)
    %         coeffs = coeffvalues(gaussFits{cond, rep});
    %         vals = gaussVals{cond, rep};
    %         vals = vals(~isnan(vals));
    %         x = 2:length(vals)+1;
    %         est_y = gaussian_get_y(x, coeffs);
    %         [pk loc] = findpeaks(est_y, x);
    %         if isempty(pk) 
    %             pk = NaN;
    %             loc = NaN;
    %         end
    %         peak_frames(cond, rep, :) = [loc pk];
    % 
    % 
    %         % [peaksDark{cond, rep} locsDark{cond, rep}] = findpeaks(est_y_dark, xDark);
    %         % [peaksLight{cond, rep} locsLight{cond, rep}] = findpeaks(est_y_light, xLight);
    % 
    % 
    %     end
    % 
    %     coeffsAvg = coeffvalues(gaussFitsAvg{cond});
    %     valsAvg = gaussValsAvg{cond};
    %     valsAvg = valsAvg(~isnan(valsAvg));
    %     xAvg = 2:length(valsAvg)+1;
    %     est_y_avg = gaussian_get_y(xAvg, coeffsAvg);
    %     [pkAvg locAvg] = findpeaks(est_y_avg, xAvg);
    %     if isempty(pkAvg)
    %         pkAvg = NaN;
    %         locAvg = NaN;
    %     end
    %     peak_frames_avg(cond, :) = [locAvg pkAvg];
    %     cols = grid_columns(cond);
    %     for r = 1:grid_rows(cond)
    %         est_y_arrayD(r,:) = est_y_avg(((r*cols - cols) + 1):r*cols);
    %     end
    %     for r = 1:grid_rows(cond)
    %         est_y_arrayL(r,:) = est_y_avg(((r*cols-cols)+1+numel(est_y_arrayD)):r*cols+numel(est_y_arrayD));
    %     end
    % end


    % for cond = 1:size(ts_data, 2)
    %     for rep = 1:size(ts_data,3)
    %         peak_val = -1000;
    %         peak_frame = 1;
    %         for frame = 1:size(ts_data,4)
    %             if ~isnan(ts_data(volt_idx, cond, rep, frame, 1))
    % 
    %                 new_peak = max(ts_data(volt_idx, cond, rep, frame, :));
    %                 if new_peak > peak_val
    %                     peak_val = new_peak;
    %                     peak_frame = frame;
    %                 end
    % 
    %             end
    %         end
    %         peak = [peak_frame, peak_val];
    %         peak_frames(cond, rep, :) = peak;
    %     end
    % end
                    

end