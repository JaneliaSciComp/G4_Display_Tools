function [peak_frames, peak_frames_avg, gaussColors] = get_peak(ts_data, volt_idx,  grid_rows, grid_columns, medianVoltage)
    
    for cond = 1:size(ts_data,2)
        for rep = 1:size(ts_data,3)
            for frame = 1:size(ts_data,4)
                repsVolt = mean(squeeze(ts_data(volt_idx, cond, rep, frame, :)), 'omitnan');
                gaussValsReps{cond, rep}(frame) = repsVolt-medianVoltage;
            end
            [ma, in] = max(gaussValsReps{cond, rep});
            peak_frames(cond, rep, :) = [in, ma];
        end
    end


    ts_data_avg = squeeze(mean(ts_data,3, 'omitnan'));
    for cond = 1:size(ts_data,2)
        for frame = 2:size(ts_data,4)
            avgVolt = mean(squeeze(ts_data_avg(volt_idx, cond, frame, :)), 'omitnan');
            gaussVals{cond}(frame) = avgVolt-medianVoltage;  
            
        end
        [absMax, absMaxFrame] = max(gaussVals{cond});
        peak_frames_avg(cond, :) = [absMaxFrame, absMax];
        redInds{cond} = find(gaussVals{cond}>.9*absMax);
        orangeInds{cond} = find(gaussVals{cond} >.8*absMax);
        yellowInds{cond} = find(gaussVals{cond} >.7*absMax);
        for ri = 1:length(redInds{cond})
            orangeInds{cond}(orangeInds{cond}==redInds{cond}(ri)) = [];
            yellowInds{cond}(yellowInds{cond}==redInds{cond}(ri)) = [];
        end
        for oi = 1:length(orangeInds{cond})
            yellowInds{cond}(yellowInds{cond}==orangeInds{cond}(oi)) = [];
        end
        redVals{cond} = gaussVals{cond}(redInds{cond});
        orangeVals{cond} = gaussVals{cond}(orangeInds{cond});
        yellowVals{cond} = gaussVals{cond}(yellowInds{cond});

    end

    gaussColors = struct;
    gaussColors.redInds = redInds;
    gaussColors.redVals = redVals;
    gaussColors.orangeInds = orangeInds;
    gaussColors.orangeVals = orangeVals;
    gaussColors.yellowInds = yellowInds;
    gaussColors.yellowVals = yellowVals;

end