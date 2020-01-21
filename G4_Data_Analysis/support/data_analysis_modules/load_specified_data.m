%% load all data files
function [num_positions, num_datatypes, num_conds, num_datapoints, CombData, files_excluded] = load_specified_data(exp_folder, CombData, fields_to_load, processed_filename)
    [num_groups, num_exps] = size(exp_folder);
%    CombData.conditionModes = CombData.conditionModes; 
%    CombData.channelNames = CombData.channelNames;
%     CombData.timestamps = CombData.timestamps;
    CombData.histograms = [];
    CombData.interhistogram = [];
    CombData.timeseries = [];
    CombData.timeseries_avg_over_reps = nan([num_groups, num_exps]);

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
    
    CombData.timestamps = fields.timestamps;
    CombData.channelNames = fields.channelNames;
    CombData.conditionModes = fields.conditionModes;
    
    if ~isempty(find(strcmp(fields_to_load,'histograms'),1)) > 0
        CombData.histograms = nan([num_groups, num_exps, size(fields.histograms)]);
    end
    if ~isempty(find(strcmp(fields_to_load,'interhistogram'),1)) > 0
        CombData.interhistogram = nan([num_groups, num_exps, size(fields.interhistogram)]);
    end
    if ~isempty(find(strcmp(fields_to_load,'timeseries_avg_over_reps'),1)) > 0
        CombData.timeseries_avg_over_reps = nan([num_groups, num_exps, size(fields.timeseries_avg_over_reps)]);
    end
    if ~isempty(find(strcmp(fields_to_load,'summaries'),1)) > 0
        CombData.summaries = nan([num_groups, num_exps, size(fields.summaries)]);
    end
    if ~isempty(find(strcmp(fields_to_load,'timeseries'),1)) > 0
        CombData.timeseries = nan([num_groups, num_exps, size(fields.timeseries)]);
    end
    if ~isempty(find(strcmp(fields_to_load,'LmR_avg_over_reps'),1)) > 0
        CombData.LmR_avg_over_reps = nan([num_groups, num_exps, size(fields.LmR_avg_over_reps)]);
    end
    if ~isempty(find(strcmp(fields_to_load,'LpR_avg_over_reps'),1)) > 0
        CombData.LpR_avg_over_reps = nan([num_groups, num_exps, size(fields.LpR_avg_over_reps)]);
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
                
                if ~isempty(CombData.timeseries_avg_over_reps) && ~isempty(CombData.timeseries)
                    if ~all(size(squeeze(CombData.timeseries_avg_over_reps(1,1,:,:,1)))==size(squeeze(CombData.timeseries(1,1,:,:,1,1))))
                        
                        disp(['Data in ' exp_folder{g,e} 'appears to be the incorrect size']);
                        files_excluded{end+1} = [exp_folder{g,e}, "timeseries data and avg timeseries data different sizes"];
                        continue;
                    end
                    

                end
                
                if isfield(fields,'timeseries_avg_over_reps') && ~isempty(fields.timeseries_avg_over_reps) && ~isempty(CombData.timeseries_avg_over_reps)
                   
                    if size(fields.timeseries_avg_over_reps,3) > 2*size(CombData.timeseries_avg_over_reps,5)
                        
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
                
                if ~isempty(find(strcmp(fields_to_load,'histograms'),1)) > 0
                    num_positions = size(fields.histograms,4);
                    if num_positions>size(CombData.histograms,6)
                        CombData.histograms(:,:,:,:,:,size(CombData.histograms,6)+1:num_positions) = nan;
                    end
                    CombData.histograms(g,e,:,:,:,1:num_positions) = fields.histograms;
                end
                
                if ~isempty(find(strcmp(fields_to_load,'interhistogram'),1)) > 0
                    CombData.interhistogram(g,e,:,:) = fields.interhistogram;
                end
                
                if ~isempty(find(strcmp(fields_to_load,'timeseries_avg_over_reps'),1)) > 0
                    num_datapointsAvg = size(fields.timeseries_avg_over_reps,3);
                    num_channels = size(fields.timeseries_avg_over_reps,1);
                    if num_datapointsAvg>size(CombData.timeseries_avg_over_reps,5)
                        CombData.timeseries_avg_over_reps(:,:,:,:,size(CombData.timeseries_avg_over_reps,5)+1:num_datapointsAvg) = nan;
                        CombData.timestamps = fields.timestamps;
                    end
                    if num_channels < size(CombData.timeseries_avg_over_reps,3)
                        for i = 1:size(CombData.timeseries_avg_over_reps,3)-num_channels
                            fields.timeseries_avg_over_reps(end+1,:,:) = nan(1, size(fields.timeseries_avg_over_reps,2), size(fields.timeseries_avg_over_reps,3));
                        end
                    end
                    
                    CombData.timeseries_avg_over_reps(g,e,:,:,1:num_datapointsAvg) = fields.timeseries_avg_over_reps;
                end
                
                if ~isempty(find(strcmp(fields_to_load,'summaries'),1)) > 0
                    num_channels = size(fields.summaries,1);
                    if num_channels < size(CombData.summaries,3)
                        for i = 1:size(CombData.summaries,3)-num_channels
                            fields.summaries(end+1,:,:) = nan(1, size(fields.summaries,2), size(fields.summaries,3));
                        end
                    end
                    CombData.summaries(g,e,:,:,:) = fields.summaries;
                end
                
                if ~isempty(find(strcmp(fields_to_load,'timeseries'),1)) > 0
%                     if num_positions>size(CombData.histograms,6)
%                         CombData.timeseries(:,:,:,:,size(CombData.histograms,6)+1:num_positions) = nan;
%                     end
                    num_datapoints = size(fields.timeseries,4);
                    if num_datapoints>size(CombData.timeseries,6)
                        CombData.timeseries(:,:,:,:,size(CombData.timeseries,6)+1:num_datapoints) = nan;
                        CombData.timestamps = fields.timestamps;
                    end
                    CombData.timeseries(g,e,:,:,:,1:num_datapoints) = fields.timeseries;
                end
                
                if ~isempty(find(strcmp(fields_to_load,'LmR_avg_over_reps'),1)) > 0
                    num_datapointsLmR = size(fields.LmR_avg_over_reps,3);
                    if num_datapointsLmR>size(CombData.LmR_avg_over_reps,5)
                        CombData.LmR_avg_over_reps(:,:,:,:,size(CombData.LmR_avg_over_reps,5)+1:num_datapointsLmR) = nan;                       
                    end
                    
                    CombData.LmR_avg_over_reps(g,e,:,:,1:num_datapointsLmR) = fields.LmR_avg_over_reps;
                end
                
                if ~isempty(find(strcmp(fields_to_load,'LpR_avg_over_reps'),1)) > 0
                    
                    num_datapointsLpR = size(fields.LpR_avg_over_reps,3);
                    if num_datapointsLpR>size(CombData.LpR_avg_over_reps,5)
                        CombData.LpR_avg_over_reps(:,:,:,:,size(CombData.LpR_avg_over_reps,5)+1:num_datapointsLpR) = nan;
                    end
                    CombData.LpR_avg_over_reps(g,e,:,:,1:num_datapointsLpR) = fields.LpR_avg_over_reps;
                    
                end
            end
        end
    end
    
    %check Data file for consistency with previously loaded Data files

    

    if ~isempty(CombData.histograms) && ~isempty(CombData.timeseries)

        if num_positions>size(CombData.histograms,6)
            CombData.timeseries(:,:,:,:,:,size(CombData.histograms,6)+1:num_positions) = nan;
        end
        [~, ~, num_datatypes, num_conds, num_reps, num_datapoints] = size(CombData.timeseries);
        num_positions = size(CombData.histograms,6);
        
    elseif ~isempty(CombData.histograms)
        num_positions = size(CombData.histograms,6);
        num_datatypes = [];
        num_conds = [];
        num_datapoints = [];
        
    elseif ~isempty(CombData.timeseries)
        [~, ~, num_datatypes, num_conds, num_datapoints] = size(CombData.timeseries);
        num_positions = [];
    else
        num_positions = [];
        num_datatypes = [];
        num_conds = [];
        num_datapoints = [];
        
    end
    
    if isempty(CombData.timeseries) && ~isempty(CombData.timeseries_avg_over_reps)
        [~, ~, num_datatypes, num_conds, num_datapoints] = size(CombData.timeseries_avg_over_reps);
    end
    
    
end