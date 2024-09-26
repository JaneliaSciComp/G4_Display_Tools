%% load all data files
function [CombData, files_excluded] = load_specified_data(exp_folder, CombData, fields_to_load, processed_filename)
    [num_groups, num_exps] = size(exp_folder);
%    CombData.conditionModes = CombData.conditionModes; 
%    CombData.channelNames = CombData.channelNames;
%     CombData.timestamps = CombData.timestamps;
    CombData.histograms_CL = [];
    CombData.interhistogram = [];
    CombData.timeseries = [];
    CombData.ts_avg_reps = [];

    CombData.summaries = [];
    CombData.LmR_avg_over_reps = [];
    CombData.LpR_avg_over_reps = [];
    
    files_excluded = {};
    
    %Load the first file to create initial array sizes
    
    files = dir(exp_folder{1,1});
    
    try
        Data_name = files(contains({files.name},{processed_filename})).name;
    catch
        
        error(['cannot find ' processed_filename ' file in ' exp_folder{1,1}]);
    end

    fields = load(fullfile(exp_folder{1,1},Data_name), fields_to_load{1:end});

    %Set each field in CombData to its initial size.
    for field = fields_to_load
        f = field{1};
        CombData.(f) = nan([num_groups, num_exps, size(fields.(f))]);
    end
    
        
    CombData.timestamps = fields.timestamps;
    CombData.channelNames = fields.channelNames;
    CombData.conditionModes = fields.conditionModes;
%    CombData.bad_crossCorr_conds = fields.bad_crossCorr_conds;
    CombData.bad_duration_conds = fields.bad_duration_conds;
    CombData.bad_duration_intertrials = fields.bad_duration_intertrials;
%    CombData.bad_slope_conds = fields.bad_slope_conds;
    CombData.bad_WBF_conds = fields.bad_WBF_conds;
        
    if ~isempty(find(strcmp(fields_to_load,'LmR_normalization_max'),1)) > 0
        CombData.LmR_normalization_max = fields.LmR_normalization_max;
    end
    
    if ~isempty(find(strcmp(fields_to_load,'normalization_maxes'),1)) > 0
        CombData.normalization_maxes = fields.normalization_maxes;
    end
    
    if ~isempty(find(strcmp(fields_to_load, 'pos_conditions'),1)) > 0
        CombData.pos_conditions = fields.pos_conditions;
    end
    
    for g = 1:num_groups
        for e = 1:num_exps
            if ~isempty(exp_folder{g,e})
               
                %load Data file

                files = dir(exp_folder{g,e});
                try
                    Data_name = files(contains({files.name},{processed_filename})).name;
                catch
                    
                    disp(['cannot find ' processed_filename ' file in ' exp_folder{g,e}])
                    files_excluded{end+1} = [exp_folder{g,e}, "could not find processed file"];
                    continue;
                   
                end

                fields = load(fullfile(exp_folder{g,e},Data_name), fields_to_load{1:end});
                
                %Check to make sure everything is the correct size - sanity
                %checks
                
                if ~isempty(CombData.ts_avg_reps) && ~isempty(CombData.timeseries)
%                     if ~all(size(squeeze(CombData.ts_avg_reps(1,1,:,:,1)))==size(squeeze(CombData.timeseries(1,1,:,:,1,1))))
%                         
%                         disp(['Data in ' exp_folder{g,e} 'appears to be the incorrect size']);
%                         files_excluded{end+1} = [exp_folder{g,e}, "timeseries data and avg timeseries data different sizes"];
%                         continue;
%                     end
                    

                end
                
                if isfield(fields,'ts_avg_reps') && ~isempty(fields.ts_avg_reps) && ~isempty(CombData.ts_avg_reps)
                   
                    if size(fields.ts_avg_reps,3) > 2*size(CombData.ts_avg_reps,5)
                        
                        disp(['Timeseries data in ' exp_folder{g,e} ' appears to be too large. It has been removed from this analysis.']);
                        files_excluded{end+1} = [exp_folder{g,e}, "timeseries data too large"];
                        continue;
                    end
                    
                end
                
                if isfield(fields,'interhistogram') && ~isempty(fields.interhistogram) && ~isempty(CombData.interhistogram)
                    if size(fields.interhistogram) ~= [size(CombData.interhistogram,3) size(CombData.interhistogram,4)]
                        disp(['Interhistogram data in ' exp_folder{g,e} ' appears to be the wrong size. It has been removed from this analysis.']);
                        files_excluded{end+1} = [exp_folder{g,e}, "interhistogram data wrong size"];
                        continue;
                    end
                end
                
                if isfield(fields, 'ts_avg_reps_norm') && ~isempty(CombData.ts_avg_reps)
                    if ~all(size(squeeze(CombData.ts_avg_reps(1,1,:,:,1)))==size(squeeze(CombData.ts_avg_reps_norm(1,1,:,:,1))))
                        disp(['Data in ' exp_folder{g,e} 'appears to be the incorrect size']);
                        files_excluded{end+1} = [exp_folder{g,e}, "mean timeseries data and normalized mean timeseries data are different sizes"];
                        continue;
                    end
                end
                
                
                for field = fields_to_load
                    fi = field{1};
                    switch fi
                        
                        case 'timeseries'
                            num_datapoints = size(fields.(fi),4);
                            if num_datapoints>size(CombData.(fi),6)
                                CombData.(fi)(:,:,:,:,size(CombData.(fi),6)+1:num_datapoints) = nan;
                                CombData.timestamps = fields.timestamps;
                            end
                            CombData.(fi)(g,e,:,:,:,1:num_datapoints) = fields.(fi);
                            
                        case 'timeseries_normalized'
                            
                            num_datapoints = size(fields.(fi),4);
                            if num_datapoints>size(CombData.(fi),6)
                                CombData.(fi)(:,:,:,:,size(CombData.(fi),6)+1:num_datapoints) = nan;
                                CombData.timestamps = fields.timestamps;
                            end
                            CombData.(fi)(g,e,:,:,:,1:num_datapoints) = fields.(fi);
                            
                        case 'ts_avg_reps'
                            
                            num_datapointsAvg = size(fields.(fi),3);
                            num_channels = size(fields.(fi),1);
                            if num_datapointsAvg>size(CombData.(fi),5)
                                CombData.(fi)(:,:,:,:,size(CombData.(fi),5)+1:num_datapointsAvg) = nan;
                                CombData.timestamps = fields.timestamps;
                            end
                            if num_channels < size(CombData.(fi),3)
                                for i = 1:size(CombData.(fi),3)-num_channels
                                    fields.(fi)(end+1,:,:) = nan(1, size(fields.(fi),2), size(fields.(fi),3));
                                end
                            end

                            CombData.(fi)(g,e,:,:,1:num_datapointsAvg) = fields.(fi);
                            
                        case 'ts_avg_reps_norm'
                            
                            num_datapointsAvg = size(fields.(fi),3);
                            num_channels = size(fields.(fi),1);
                            if num_datapointsAvg>size(CombData.(fi),5)
                                CombData.(fi)(:,:,:,:,size(CombData.(fi),5)+1:num_datapointsAvg) = nan;
                                CombData.timestamps = fields.timestamps;
                            end
                            if num_channels < size(CombData.(fi),3)
                                for i = 1:size(CombData.(fi),3)-num_channels
                                    fields.(fi)(end+1,:,:) = nan(1, size(fields.(fi),2), size(fields.(fi),3));
                                end
                            end

                            CombData.(fi)(g,e,:,:,1:num_datapointsAvg) = fields.(fi);
                            
                        case 'summaries'
                            num_channels = size(fields.(fi),1);
                            if num_channels < size(CombData.(fi),3)
                                for i = 1:size(CombData.(fi),3)-num_channels
                                    fields.(fi)(end+1,:,:) = nan(1, size(fields.(fi),2), size(fields.(fi),3));
                                end
                            end
                            CombData.(fi)(g,e,:,:,:) = fields.(fi);

                        case 'summaries_normalized'
                            
                            num_channels = size(fields.(fi),1);
                            if num_channels < size(CombData.(fi),3)
                                for i = 1:size(CombData.(fi),3)-num_channels
                                    fields.(fi)(end+1,:,:) = nan(1, size(fields.(fi),2), size(fields.(fi),3));
                                end
                            end
                            CombData.(fi)(g,e,:,:,:) = fields.(fi);
                            
                        case 'pos_series'
                            
                            num_datapointsPos = size(fields.(fi),3);
                            if num_datapointsPos>size(CombData.(fi),5)
                                CombData.(fi)(:,:,:,:,size(CombData.(fi),5)+1:num_datapointsPos) = nan;                       
                            end

                            CombData.(fi)(g,e,:,:,1:num_datapointsPos) = fields.(fi);
                            
                        case 'mean_pos_series'
                            
                            num_datapointsPos = size(fields.(fi),2);
                            if num_datapointsPos>size(CombData.(fi),4)
                                CombData.(fi)(:,:,:,size(CombData.(fi),4)+1:num_datapointsPos) = nan;                       
                            end

                            CombData.(fi)(g,e,:,1:num_datapointsPos) = fields.(fi);
                            
                            
                        case 'LmR_avg_over_reps'
                            
                            num_datapointsLmR = size(fields.(fi),3);
                            if num_datapointsLmR>size(CombData.(fi),5)
                                CombData.(fi)(:,:,:,:,size(CombData.(fi),5)+1:num_datapointsLmR) = nan;                       
                            end

                            CombData.(fi)(g,e,:,:,1:num_datapointsLmR) = fields.(fi);
                            
                        case 'LmR_avg_reps_norm'
                            num_datapointsLmR = size(fields.(fi),3);
                            if num_datapointsLmR>size(CombData.(fi),5)
                                CombData.(fi)(:,:,:,:,size(CombData.(fi),5)+1:num_datapointsLmR) = nan;                       
                            end

                            CombData.(fi)(g,e,:,:,1:num_datapointsLmR) = fields.(fi);
                            
                            
                            
                        case 'LpR_avg_over_reps'
                            
                            num_datapointsLpR = size(fields.(fi),3);
                            if num_datapointsLpR>size(CombData.(fi),5)
                                CombData.(fi)(:,:,:,:,size(CombData.(fi),5)+1:num_datapointsLpR) = nan;
                            end
                            CombData.(fi)(g,e,:,:,1:num_datapointsLpR) = fields.(fi);

                            
                        case 'LpR_avg_reps_norm'
                            
                            num_datapointsLpR = size(fields.(fi),3);
                            if num_datapointsLpR>size(CombData.(fi),5)
                                CombData.(fi)(:,:,:,:,size(CombData.(fi),5)+1:num_datapointsLpR) = nan;
                            end
                            CombData.(fi)(g,e,:,:,1:num_datapointsLpR) = fields.(fi);
                            
                        case 'faLmR_avg_over_reps'
                            
                            num_datapointsFa = size(fields.(fi),2);
                            if num_datapointsFa>size(CombData.(fi),4)
                                CombData.(fi)(:,:,:,size(CombData.(fi),4)+1:num_datapointsFa) = nan;
                            end
                            CombData.(fi)(g,e,:,1:num_datapointsFa) = fields.(fi);
                            
                        case 'faLmR_avg_reps_norm'
                            
                            num_datapointsFa = size(fields.(fi),2);
                            if num_datapointsFa>size(CombData.(fi),4)
                                CombData.(fi)(:,:,:,size(CombData.(fi),4)+1:num_datapointsFa) = nan;
                            end
                            CombData.(fi)(g,e,:,1:num_datapointsFa) = fields.(fi);
                            
                        case 'histograms_CL'
                            num_positions = size(fields.(fi),4);
                            if num_positions>size(CombData.(fi),6)
                                CombData.(fi)(:,:,:,:,:,size(CombData.(fi),6)+1:num_positions) = nan;
                            end
                            CombData.(fi)(g,e,:,:,:,1:num_positions) = fields.(fi);

                        case 'interhistogram'
                            
                            CombData.(fi)(g,e,:,:) = fields.(fi);
                            
                        case 'frame_movement_times_avg'
                            
                            CombData.(fi)(g,e,:,:) = fields.(fi);

                            
                    end
                    
                end

            end
        end
    end
    
    %check Data file for consistency with previously loaded Data files

    

    if ~isempty(CombData.histograms_CL) && ~isempty(CombData.timeseries)

        if num_positions>size(CombData.histograms_CL,6)
            CombData.timeseries(:,:,:,:,:,size(CombData.histograms_CL,6)+1:num_positions) = nan;
        end

    end
    
    
end