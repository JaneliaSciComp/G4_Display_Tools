function peak_frames = get_peak(ts_data, volt_idx, gaussVals, gaussFits)
    
    for cond = 1:size(ts_data,2)
        for rep = 1:size(ts_data,3)
            coeffs = coeffvalues(gaussFits{cond, rep});
            vals = gaussVals{cond, rep};
            vals = vals(~isnan(vals));
            x = 2:length(vals)+1;
            est_y = gaussian_get_y(x, coeffs);
            [pk loc] = findpeaks(est_y, x);
            if isempty(pk) 
                pk = NaN;
                loc = NaN;
            end
            peak_frames(cond, rep, :) = [loc pk];
            % [peaksDark{cond, rep} locsDark{cond, rep}] = findpeaks(est_y_dark, xDark);
            % [peaksLight{cond, rep} locsLight{cond, rep}] = findpeaks(est_y_light, xLight);


        end
    end


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