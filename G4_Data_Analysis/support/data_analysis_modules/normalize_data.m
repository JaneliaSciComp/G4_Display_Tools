function [CombData] = normalize_data(current_analysis, num_conds, num_datapoints, num_datatypes, num_positions)
    CombData = current_analysis.CombData;

    normalize_to_baseline = current_analysis.normalize_settings.normalize_to_baseline;
    baseline_startstop = current_analysis.normalize_settings.baseline_startstop;
    normalize_to_max = current_analysis.normalize_settings.normalize_to_max;
    max_startstop = current_analysis.normalize_settings.max_startstop;
    max_prctile = current_analysis.normalize_settings.max_prctile;
    
    base_start = find(current_analysis.CombData.timestamps>=baseline_startstop(1),1);
    base_stop = find(current_analysis.CombData.timestamps<=baseline_startstop(2),1,'last');
    max_start = find(current_analysis.CombData.timestamps>=max_startstop(1),1);
    max_stop = find(current_analysis.CombData.timestamps<=max_startstop(2),1,'last');
    
    if current_analysis.normalize_option == 1
        [baselines, maxs] = normalization_fly(current_analysis.CombData.timeseries_avg_over_reps, ...
            base_start, base_stop, max_start, max_stop, max_prctile, num_conds, num_datapoints, ...
            num_datatypes, current_analysis.num_groups, current_analysis.num_exps);
    elseif current_analysis.normalize_option == 2
        [baselines, maxs] = normalization_group(current_analysis.CombData.timeseries_avg_over_reps, base_start, ...
            base_stop, max_start, max_stop, max_prctile, num_conds, num_datapoints, ...
            num_datatypes, current_analysis.num_groups, current_analysis.num_exps);
    else
        disp("Normalization not performed.");
        return;
    end
    
    for datatype = normalize_to_baseline
        d = find(strcmpi(current_analysis.CombData.channelNames.timeseries,datatype));
        CombData.timeseries_avg_over_reps(:,:,d,:,:) = current_analysis.CombData.timeseries_avg_over_reps(:,:,d,:,:)./baselines(:,:,d,:,:);
        CombData.summaries(:,:,d,:,:) = current_analysis.CombData.summaries(:,:,d,:,:)./baselines(:,:,d,:,1);
        d = find(strcmpi(current_analysis.CombData.channelNames.histograms,datatype));
        if isfield(CombData, 'histograms')
            CombData.histograms(:,:,d,:,:,:) = current_analysis.CombData.histograms(:,:,d,:,:,:)./repmat(baselines(:,:,d,:,1),[1 1 1 1 1 num_positions]);
        end
    end
    for datatype = normalize_to_max
        d = find(strcmpi(current_analysis.CombData.channelNames.timeseries,datatype));
         CombData.timeseries_avg_over_reps(:,:,d,:,:) = current_analysis.CombData.timeseries_avg_over_reps(:,:,d,:,:)./maxs(:,:,d,:,:);
        CombData.summaries(:,:,d,:,:) = current_analysis.CombData.summaries(:,:,d,:,:)./maxs(:,:,d,:,1);
        d = find(strcmpi(current_analysis.CombData.channelNames.histograms,datatype));
        if isfield(CombData, 'histograms')
            CombData.histograms(:,:,d,:,:,:) = current_analysis.CombData.histograms(:,:,d,:,:,:)./repmat(maxs(:,:,d,:,1),[1 1 1 1 1 num_positions]);
        end
    end


end