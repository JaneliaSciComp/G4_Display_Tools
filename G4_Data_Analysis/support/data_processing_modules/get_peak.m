function peak_frames = get_peak(ts_data, volt_idx)
    
    for cond = 1:size(ts_data, 2)
        for rep = 1:size(ts_data,3)
            peak_val = -1000;
            peak_frame = 1;
            for frame = 1:size(ts_data,4)
                if ~isnan(ts_data(volt_idx, cond, rep, frame, 1))

                    new_peak = max(ts_data(volt_idx, cond, rep, frame, :));
                    if new_peak > peak_val
                        peak_val = new_peak;
                        peak_frame = frame;
                    end

                end
            end
            peak = [peak_frame, peak_val];
            peak_frames(cond, rep, :) = peak;
        end
    end
                    

end