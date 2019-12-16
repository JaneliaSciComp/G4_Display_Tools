

classdef create_data_analysis_tool < handle
    
       
    properties
        exp_folder
        genotype
        trial_options
        CombData
        processed_data_file
        flags
        
        histogram_plot_option
        histogram_plot_settings
        histogram_annotation_settings
        
        CL_histogram_plot_option
        CL_datatypes
        CL_conds
        CL_hist_plot_settings
        
        timeseries_plot_option
        OL_datatypes        
        OL_conds
        timeseries_plot_settings
        patterns
        looms
        wf
        cond_name
        
        TC_plot_option
        TC_datatypes
        TC_conds
        TC_plot_settings
        
        datatype_indices
        
        normalize_option
        normalize_settings
        
        save_settings
        
        num_groups
        num_exps
        
        data_needed
    
        %% TO ADD A NEW MODULE
%         new_module_option
        %new_module_settings (if necessary)
        
    end
    
    methods

        function self = create_data_analysis_tool(exp_folder, trial_options, varargin)
            
            % exp_folder: cell array of paths containing G4_Processed_Data.mat files
            % trial_options: 1x3 logical array [pre-trial, intertrial, post-trial]
            
            % Get plot settings from DA_plot_settings.m
            [self.normalize_settings, self.histogram_plot_settings, self.histogram_annotation_settings, ...
    self.CL_hist_plot_settings, self.timeseries_plot_settings, self.TC_plot_settings, self.save_settings] = DA_plot_settings();

        %% USER-UPDATED SETTINGS HERE
            
        % Filename of processed data files being read
            self.processed_data_file = 'smallfield_V2_G4_Processed_Data';
            
        %Filepath at which to save plots
            self.save_settings.save_path = '/Users/taylorl/Desktop/data_analysis/old_data';
            
        %Genotype(s) being compared
            genotypes = ["empty-split", "LPLC-2", "LC-18", "T4_T5", "LC-15", "LC-25", "LC-11", "LC-17", "LC-4"];
            for i = 1:length(genotypes)
                self.genotype{i} = genotypes(i);
            end
            
            % CL_conds: matrix of closed-loop (CL) conditions to plot as histograms
            % OL_conds: matrix of open-loop (OL) conditions to plot as timeseries
            % TC_conds: matrix of open-loop conditions to plot as tuning curves (TC)

        %Determines the location of each condition number on the plots.
        %If these are left blank, the plots will be laid out in the
        %default way
   
            self.OL_conds{1} = [1 3; 5 7; 9 11; 13 15]; %3x1, 3x3, 3x3 ON, 8x8 (4 x 2 plots)
            self.OL_conds{2} = [17 19; 21 23; 25 27; 29 31]; %16x16, 64x3, 64x3 ON, 64x16 (4 x 2 plots)
            self.OL_conds{3} = [33 34; 35 36; 37 38; 39 40]; %left and right Looms (4 x 2 plots)
            self.OL_conds{4} = [41; 43]; %yaw and sideslip (2 x 1 plots)
            %self.OL_conds = [];
            self.CL_conds = []; 
            self.TC_conds = []; 
            
        %% Generate condition names for timeseries plot titles
            self.timeseries_plot_settings.cond_name = cell(1,81);
            patterns = ["3x1", "3x3", "3x3 ON", "8x8", "16x16", "64x3", "63x3 ON", "64x16"];
            looms = ["Left", "Right"];
            wf = ["Yaw", "Sideslip"];
            for p = 1:length(patterns)  % 8 patterns % 2 sweeps
                self.timeseries_plot_settings.cond_name{1+4*(p-1)} = [patterns(p) ' L 0.35 Hz Sweep'];
                self.timeseries_plot_settings.cond_name{2+4*(p-1)} = [patterns(p) ' R 0.35 Hz Sweep'];
                self.timeseries_plot_settings.cond_name{3+4*(p-1)} = [patterns(p) ' L 1.07 Hz Sweep'];
                self.timeseries_plot_settings.cond_name{4+4*(p-1)} = [patterns(p) ' R 1.07 Hz Sweep'];
            end

            for l = 1:2 % 2 looms
                self.timeseries_plot_settings.cond_name{33+4*(l-1)} = [looms(l) ' R/V 20'];
                self.timeseries_plot_settings.cond_name{34+4*(l-1)} = [looms(l) ' R/V 40'];
                self.timeseries_plot_settings.cond_name{35+4*(l-1)} = [looms(l) ' R/V 80'];
                self.timeseries_plot_settings.cond_name{36+4*(l-1)} = [looms(l) ' 200 deg/s'];
            end

            for w = 1:2 % 2 wide-field rotations
                self.timeseries_plot_settings.cond_name{41+2*(w-1)} = [wf(w) ' CW 10 Hz'];
                self.timeseries_plot_settings.cond_name{42+2*(w-1)} = [wf(w) ' CCW 10 Hz'];   
            end
            
        %% Datatypes
        %datatype options for flying data: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR', 'faLmR'
        %datatype options for walking data: 'Vx0_chan', 'Vx1_chan', 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', 'Sideslip'
           
            self.CL_datatypes = {'Frame Position'}; %datatypes to plot as histograms
            self.OL_datatypes = {'faLmR'}; %datatypes to plot as timeseries
            self.TC_datatypes = {'LmR','LpR'}; %datatypes to plot as tuning curves

        %% TO ADD A NEW MODULE
        %If there are any settings necessary for new module, add them here
        %self.new_module_settings = {};
            
        
        %% END OF USER-DEFINED SETTINGS
        
        
        
            self.normalize_option = 0; %0 = don't normalize, 1 = normalize every fly, 2 = normalize every group
            self.histogram_plot_option = 0;
            self.CL_histogram_plot_option = 0;
            self.timeseries_plot_option = 0;
            self.TC_plot_option = 0;


        %% Settings based on inputs
            self.exp_folder = exp_folder;
            [self.num_groups, self.num_exps] = size(exp_folder);
            self.trial_options = trial_options;
                        
        
            
        %% Update settings based on flags
            self.flags = varargin;
            self.data_needed = {'conditionModes', 'channelNames', 'summaries'};
            for i = 1:length(self.flags)
                switch self.flags{i}
                    case '-norm1' %Normalize over each fly
                        
                        self.normalize_option = 1;
                        self.data_needed{end+1} = 'timeseries_avg_over_reps';
                        self.data_needed{end+1} = 'histograms';
                        
                    case '-norm2' %Normalize over groups
                        
                        self.normalize_option = 2;
                        self.data_needed{end+1} = 'timeseries_avg_over_reps';
                        self.data_needed{end+1} = 'histograms';
                        
                        
                    case '-hist' %Do basic histogram plots
                        
                        self.histogram_plot_option = 1;
                        self.data_needed{end+1} = 'timeseries_avg_over_reps';
                        self.data_needed{end+1} = 'interhistogram';
                        
                    case '-CLhist' %Do closed loop histogram plots
                        
                        self.CL_histogram_plot_option = 1;
                        self.data_needed{end+1} = 'histograms';
                        
                    case '-TSplot' %Do timeseries plots
                        
                        self.timeseries_plot_option = 1;
                        self.data_needed{end+1} = 'timeseries_avg_over_reps';
                        
                    case '-TCplot' %Do tuning curve plots
                        
                        self.TC_plot_option = 1;
                        
                    %% Add new module
                    %Add a new flag to indicate your module and add a case
                    %for it. 
                    
%                     case '-new_module_flag'
%                         self.new_module_option = 1;
%                          %self.data_needed{end+1} = 'whatever field you need from .mat file';
                        
                
                end
                
            end
            self.data_needed{end+1} = 'timestamps';
            self.data_needed = unique(self.data_needed);
            
            %% Always load channelNames, conditionModes, and timestamps
            files = dir(exp_folder{1,1});
            try
                Data_name = files(contains({files.name},{self.processed_data_file})).name;
            catch
                error('cannot find TDMSlogs file in specified folder')
            end

            load(fullfile(exp_folder{1,1},Data_name), 'channelNames', 'conditionModes', 'timestamps');
            self.CombData.timestamps = timestamps;
            self.CombData.channelNames = channelNames;
            self.CombData.conditionModes = conditionModes;
            
            %% Variables that must be calculated
            
            %Create default plot layout for any plots flagged but not
            %supplied
            
            if self.timeseries_plot_option == 1 && isempty(self.OL_conds)
                self.OL_conds = create_default_OL_plot_layout(conditionModes, self.OL_conds);
            end
            
            if self.CL_histogram_plot_option == 1 && isempty(self.CL_conds)
                self.CL_conds = create_default_CL_plot_layout(conditionModes, self.CL_conds);
            end
            
            if self.TC_plot_option == 1 && isempty(self.TC_conds)
                self.TC_conds = create_default_TC_plot_layout(conditionModes, self.TC_conds);
            end
        
            [self.datatype_indices.Frame_ind, self.datatype_indices.OL_inds, self.datatype_indices.CL_inds, ...
                self.datatype_indices.TC_inds] = get_datatype_indices(channelNames, self.OL_datatypes, ...
                self.CL_datatypes, self.TC_datatypes);
            
            
            %% Run Data analysis based on settings
            
            
            
        end
        
        function run_analysis(self)
            
            [num_positions, num_datatypes, num_conds, num_datapoints, self.CombData] ...
                = load_specified_data(self.exp_folder, self.CombData, self.data_needed, self.processed_data_file);
           
            if self.normalize_option ~= 0
                
                self.CombData = normalize_data(self, num_conds, num_datapoints, num_datatypes, num_positions);
                
            end
            
            if self.histogram_plot_option == 1
                plot_basic_histograms(self.CombData.timeseries_avg_over_reps, self.CombData.interhistogram, ...
                    self.TC_datatypes, self.histogram_plot_settings, self.num_groups, self.num_exps,...
                    self.genotype, self.datatype_indices.TC_inds, self.trial_options, self.histogram_annotation_settings);
            end
            
            if self.CL_histogram_plot_option == 1
               
                for k = 1:numel(self.CL_conds)
                    plot_CL_histograms(self.CL_conds{k}, self.datatype_indices.CL_inds, ...
                        self.CombData.histograms, self.num_groups, self.CL_hist_plot_settings);
                end

            end
            
            if self.timeseries_plot_option == 1
                for k = 1:numel(self.OL_conds)
                    plot_OL_timeseries(self.CombData.timeseries_avg_over_reps, ...
                        self.CombData.timestamps, self.OL_conds{k}, self.datatype_indices.OL_inds, ...
                        self.datatype_indices.Frame_ind, self.num_groups, self.genotype, self.timeseries_plot_settings);
                end
                
            end
            
            if self.TC_plot_option == 1
                for k = 1:numel(self.TC_conds)
                    plot_TC_specified_OLtrials(self.TC_plot_settings, self.TC_conds{k}, self.datatype_indices.TC_inds, ...
                       self.TC_plot_settings.overlap, self.num_groups, self.CombData);
                end
                
            end
            
            %% ADD NEW MODULE
            %Add an if statement here for your new module
%             if self.new_module_option == 1
%                 new_mod_test();
%             end
            
            save_figures(self.save_settings, self.genotype);

            
        end
        
        
    end
    
    
    
end






