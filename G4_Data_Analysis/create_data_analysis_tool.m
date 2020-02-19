 

classdef create_data_analysis_tool < handle
    
       
    properties
        exp_folder
        genotype
        control_genotype
        trial_options
        CombData
        processed_data_file
        flags
        exp_settings
        
        group_analysis
        single_analysis
        
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
        OL_conds_durations
        OL_conds_axis_labels
        timeseries_plot_settings
        patterns
        looms
        wf
        cond_name
        timeseries_top_left_place
        timeseries_bottom_left_places
        timeseries_left_column_places
        %timeseries_bottom_row_places
        
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
        
        group_being_analyzed_name
    
        %% TO ADD A NEW MODULE
%         new_module_option
        %new_module_settings (if necessary)
        
    end
    
    methods

        function self = create_data_analysis_tool(exp_folder, trial_options,  settings_file, varargin)
            
            % exp_folder: cell array of paths containing G4_Processed_Data.mat files
            % trial_options: 1x3 logical array [pre-trial, intertrial, post-trial]
            
            % Get plot settings from DA_plot_settings.m
            if ~isfile(settings_file)
                disp("Cannot find settings file");
                return;
            end
            %% For new file system set up
% %         %Information used to generate exp_folder and trial_options variables
% %         
% %             trial_options = [1 1 1];
% %         
% %         %How you want to sort flies - must match the field in the metadata
% %         %file exactly.
% %             field_to_sort_by = 'fly_genotype';
% %         
% %         %Set single_group to 1 if you are only analyzing one group (such as
% %         %one genotype). If you're comparing multiple groups, set it to 0
% %             single_group = 0; 
% %             
% %         %The value(s) which flies should have for the above metadata field
% %         %in order to be included in the group. This should be an array of
% %         %strings and should match the metadata values exactly. 
% %             field_values = ["OL0048B_UAS_Kir_JFRC49"];
% %             
% %         %Path to the protocol folder    
% %             path_to_protocol =  '/Users/taylorl/Desktop/Protocol_folder';
% %             
        

            settings = load(settings_file);
            self.exp_settings = settings.exp_settings;
            self.normalize_settings = settings.normalize_settings;
            self.histogram_plot_settings = settings.histogram_plot_settings;
            self.histogram_annotation_settings = settings.histogram_annotation_settings;
            self.CL_hist_plot_settings = settings.CL_hist_plot_settings;
            self.timeseries_plot_settings = settings.timeseries_plot_settings;
            self.TC_plot_settings = settings.TC_plot_settings;
            self.save_settings = settings.save_settings;
   
        
            self.normalize_option = 0; %0 = don't normalize, 1 = normalize every fly, 2 = normalize every group
            self.histogram_plot_option = 0;
            self.CL_histogram_plot_option = 0;
            self.timeseries_plot_option = 0;
            self.TC_plot_option = 0;
            self.single_analysis = 0;
            self.group_analysis = 0;
            
            self.processed_data_file = self.exp_settings.processed_data_file;
            self.group_being_analyzed_name = self.exp_settings.group_being_analyzed_name;
            
            for i = 1:length(self.exp_settings.genotypes)
                self.genotype{i} = self.exp_settings.genotypes(i);
            end

            self.OL_conds = self.timeseries_plot_settings.OL_TS_conds;
            self.OL_conds_durations = self.timeseries_plot_settings.OL_TS_durations;
            self.CL_conds = self.CL_hist_plot_settings.CL_hist_conds;
            self.TC_conds = self.TC_plot_settings.OL_TC_conds;
            
            self.CL_datatypes = self.CL_hist_plot_settings.CL_datatypes;
            self.OL_datatypes = self.timeseries_plot_settings.OL_datatypes;
            self.TC_datatypes = self.TC_plot_settings.TC_datatypes;
            
            if ~isempty(self.timeseries_plot_settings.OL_TSconds_axis_labels)
                self.OL_conds_axis_labels = self.timeseries_plot_settings.OL_TSconds_axis_labels;
            else
                for i = 1:length(self.OL_datatypes)
                    self.OL_conds_axis_labels{i} = ["Time(sec)", string(self.OL_datatypes{i})];
                end
            end
            
            if isempty(self.TC_plot_settings.TC_axis_labels)
                for i = 1:length(self.TC_datatypes)
                    self.TC_plot_settings.TC_axis_labels{i} = ["Frequency (Hz)", string(self.TC_datatypes{i})];
                end
            end
                
            

        %% Settings based on inputs
             %%%For new file system setup
%            self.exp_folder = get_exp_folder(field_to_sort_by, single_group, field_values, path_to_protocol);
            self.exp_folder = exp_folder;
            [self.num_groups, self.num_exps] = size(exp_folder);
            self.trial_options = trial_options;
            if ~isempty(self.exp_settings.control_genotype)
                self.control_genotype = find(strcmp(self.exp_settings.genotypes,self.exp_settings.control_genotype));
            else
                self.control_genotype = 0;  
            end
                

            
        %% Update settings based on flags
            self.flags = varargin;
            self.data_needed = {'conditionModes', 'channelNames', 'summaries'};
            for i = 1:length(self.flags)
                
                switch lower(self.flags{i})
                    case '-normfly' %Normalize over each fly
                        
                        self.normalize_option = 1;
                        self.data_needed{end+1} = 'timeseries_avg_over_reps';
                        self.data_needed{end+1} = 'histograms';
                        
                    case '-normgroup' %Normalize over groups
                        
                        self.normalize_option = 2;
                        self.data_needed{end+1} = 'timeseries_avg_over_reps';
                        self.data_needed{end+1} = 'histograms';
                        
                        
                    case '-hist' %Do basic histogram plots
                        
                        self.histogram_plot_option = 1;
                        self.data_needed{end+1} = 'timeseries_avg_over_reps';
                        self.data_needed{end+1} = 'interhistogram';
                        
                    case '-clhist' %Do closed loop histogram plots
                        
                        self.CL_histogram_plot_option = 1;
                        self.data_needed{end+1} = 'histograms';
                        
                    case '-tsplot' %Do timeseries plots
                        
                        self.timeseries_plot_option = 1;
                        self.data_needed{end+1} = 'timeseries_avg_over_reps';
                        
                    case '-tcplot' %Do tuning curve plots
                        
                        self.TC_plot_option = 1;                     
                        
                    case '-single'
                        
                        self.single_analysis = 1;
                        
                    case '-group'
                        
                        self.group_analysis = 1;

                        
                        
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
                error('cannot find processed file in specified folder')
            end

            load(fullfile(exp_folder{1,1},Data_name), 'channelNames', 'conditionModes', 'timestamps', 'timeseries_avg_over_reps');
            self.CombData.timestamps = timestamps;
            self.CombData.channelNames = channelNames;
            self.CombData.conditionModes = conditionModes;
            
            
            
            %% Variables that must be calculated
            
            %Create default plot layout for any plots flagged but not
            %supplied
            
            if self.timeseries_plot_option == 1 && isempty(self.OL_conds)
                self.OL_conds = create_default_OL_plot_layout(conditionModes, self.OL_conds, self.timeseries_plot_settings.plot_both_directions);
                
            end
            
            if isempty(self.timeseries_plot_settings.figure_names)
                self.timeseries_plot_settings.figure_names = string(self.OL_datatypes);
            end
                
            
            if numel(self.OL_conds) > length(self.timeseries_plot_settings.figure_names)
                orig_fig_names = self.timeseries_plot_settings.figure_names;
                while numel(self.OL_conds) > length(self.timeseries_plot_settings.figure_names)
                    self.timeseries_plot_settings.figure_names = [self.timeseries_plot_settings.figure_names, orig_fig_names];
                end
            end
            
            if isempty(self.OL_conds_durations) && self.timeseries_plot_option == 1
                    
                 self.OL_conds_durations = create_default_OL_durations(self.OL_conds, timeseries_avg_over_reps, self.CombData.timestamps);
                %run module to set durations (x axis limits)
            end
            
            if self.timeseries_plot_option == 1 && isempty(self.timeseries_plot_settings.cond_name) || ~isempty(self.timeseries_plot_settings.cond_name == 0)
                self.timeseries_plot_settings.cond_name = create_default_timeseries_plot_titles(self.OL_conds, self.timeseries_plot_settings.cond_name, self.save_settings.results_path);
            end
                
                %Determine which graphs are in the leftmost column so we know
            %to keep their y-axes turned on.
            
            %place refers to the count of the graph in order from top left
            %to bottom right. So for example, an OL_conds of [1 3 5; 7 8 9;
            %11 13 15;] shows a three by three grid of plots of those
            %condition numbers. The places would be [ 1 4 7; 2 5 8; 3 6 9;]
            %so conditions 1 7, and 11 would be in places 1, 2, and 3 and
            %would be marked as being the leftmost plots. The bottom row,
            %conditions 11, 13, and 15, would be in places 3, 6, and 9.
            %It's done this way because of the indexing in matlab. In this
            %example OL_conds, OL_conds(4) would be 3, because it goes down
            %columns, not across rows, and index increases. 

            %Top left place and bottom left place (1 and 3 in the above
            %example, or conditions 1 and 11), are calculated separately
            %because these two positions will additionally have a label on
            %their y and x-axes. 
            
            self.timeseries_top_left_place = 1;
            for i = 1:length(self.OL_conds)
                a = ~isnan(self.OL_conds{i});
                self.timeseries_bottom_left_places{i} = sum(a(:,1));
                %self.timeseries_plot_settings.bottom_left_place{i} = size(self.OL_conds{i},1)*size(self.OL_conds{i},2)-(size(self.OL_conds{i},2) - 1);
                %count = 1;
                if size(self.OL_conds{i},1) ~= 1
%                     for j = 1:size(self.OL_conds{i},1)*size(self.OL_conds{i},2)
%                         if mod(j, size(self.OL_conds{i},1)) == 0
%                             self.timeseries_bottom_row_places{i}(count) = j;
%                             count = count + 1;
%                         end
% 
%                     end
                    for m = 1:size(self.OL_conds{i},1)
                        self.timeseries_left_column_places{i}(m) = m;
                    end


                else
%                     for k = 1:length(self.OL_conds{i})
%                         self.timeseries_bottom_row_places{i}(k) = k;
%                     end
                    self.timeseries_left_column_places{i} = 1;
                end
            end
            
            
            
            if self.CL_histogram_plot_option == 1 && isempty(self.CL_conds)
                self.CL_conds = create_default_CL_plot_layout(conditionModes, self.CL_conds);
            end
            
            if self.TC_plot_option == 1 && isempty(self.TC_conds)
                self.TC_conds = create_default_TC_plot_layout(conditionModes, self.TC_conds);
            end
            if isempty(self.TC_plot_settings.figure_names)
                self.TC_plot_settings.figure_names = string(self.TC_datatypes);
            end
            if length(self.TC_conds) > length(self.TC_plot_settings.figure_names)
                orig_fig_names = self.TC_plot_settings.figure_names;
                while length(self.TC_conds) > length(self.TC_plot_settings.figure_names)
                    self.TC_plot_settings.figure_names = [self.TC_plot_settings.figure_names, orig_fig_names];
                end
            end
            
            
        
            [self.datatype_indices.Frame_ind, self.datatype_indices.OL_inds, self.datatype_indices.CL_inds, ...
                self.datatype_indices.TC_inds] = get_datatype_indices(channelNames, self.OL_datatypes, ...
                self.CL_datatypes, self.TC_datatypes);
            
            self.run_safety_checks();
            
            
            %% Run Data analysis based on settings
            
            
            
        end
        
        function run_analysis(self)
            
            if self.single_analysis
                
                self.run_single_analysis();
                               
            elseif self.group_analysis
                
                self.run_group_analysis();
                
            else
                
                disp("You must enter either the '-Group' or '-Single' flag");
                
            end
                        
            save_figures(self.save_settings, self.genotype);
            

        end
        
        function run_single_analysis(self)
            
            analyses_run = {'Single'};
            %in this case, exp_folder should be a cell array with one
            %element, the path to the processed data file. 
%             
%             metadata_file = fullfile(self.exp_folder{1}, 'metadata.mat');
%             load(metadata_file, 'metadata');
%             G4_Plot_Data_flyingdetector_pdf(self.exp_folder{1}, self.trial_options, ...
%                 metadata, self.processed_data_file);
            %disp("Single fly analysis coming soon");
            
            [num_positions, num_datatypes, num_conds, num_datapoints, self.CombData, files_excluded] ...
                = load_specified_data(self.exp_folder, self.CombData, self.data_needed, self.processed_data_file);
           
            if self.histogram_plot_option == 1
                plot_basic_histograms(self.CombData.timeseries_avg_over_reps, self.CombData.interhistogram, ...
                    self.TC_datatypes, self.histogram_plot_settings, self.num_groups, self.num_exps,...
                    self.genotype, self.datatype_indices.TC_inds, self.trial_options, self.histogram_annotation_settings);
                
                analyses_run{end+1} = 'Basic histograms';
            end
            
            if self.normalize_option ~= 0
                
                self.CombData = normalize_data(self, num_conds, num_datapoints, num_datatypes, num_positions);
                if self.normalize_option == 1
                    analyses_run{end+1} = 'Normalization 1';
                else
                    analyses_run{end+1} = 'Normalization 2';
                end
                
            end
            
            
            
            if self.CL_histogram_plot_option == 1
               
                for k = 1:numel(self.CL_conds)
                    plot_CL_histograms(self.CL_conds{k}, self.datatype_indices.CL_inds, ...
                        self.CombData.histograms, self.num_groups, self.CL_hist_plot_settings);
                end
                
                analyses_run{end+1} = 'CL histograms';

            end
            
            if self.timeseries_plot_option == 1
                
                for k = 1:numel(self.OL_conds)
                    plot_OL_timeseries(self.CombData.timeseries_avg_over_reps, ...
                        self.CombData.timestamps, self.OL_conds{k}, self.OL_conds_durations{k}, self.timeseries_plot_settings.cond_name{k}, ...
                        self.datatype_indices.OL_inds, self.OL_conds_axis_labels, ...
                        self.datatype_indices.Frame_ind, self.num_groups, self.genotype, self.control_genotype, self.timeseries_plot_settings,...
                        self.timeseries_top_left_place, self.timeseries_bottom_left_places{k}, ...
                        self.timeseries_left_column_places{k},self.timeseries_plot_settings.figure_names, 1);
                    
                    
                end
                
                analyses_run{end+1} = 'Timeseries Plots';
                
            end
            
            if self.TC_plot_option == 1
                
                for k = 1:length(self.TC_conds)
                    plot_TC_specified_OLtrials(self.TC_plot_settings, self.TC_conds{k}, self.datatype_indices.TC_inds, ...
                       self.genotype, self.control_genotype, self.num_groups, self.CombData, 1);
                end
                
                analyses_run{end+1} = 'Tuning Curves';
                    
            update_individual_fly_log_files(self.exp_folder, self.save_settings.save_path, ...
            analyses_run, files_excluded);
            end

                
        end
        
        function run_group_analysis(self)
            
            analyses_run = {'Group'};
            
            [num_positions, num_datatypes, num_conds, num_datapoints, self.CombData, files_excluded] ...
                = load_specified_data(self.exp_folder, self.CombData, self.data_needed, self.processed_data_file);
           
            if self.histogram_plot_option == 1
                plot_basic_histograms(self.CombData.timeseries_avg_over_reps, self.CombData.interhistogram, ...
                    self.TC_datatypes, self.histogram_plot_settings, self.num_groups, self.num_exps,...
                    self.genotype, self.datatype_indices.TC_inds, self.trial_options, self.histogram_annotation_settings);
                
                analyses_run{end+1} = 'Basic histograms';
            end
            
            if self.normalize_option ~= 0
                
                self.CombData = normalize_data(self, num_conds, num_datapoints, num_datatypes, num_positions);
                if self.normalize_option == 1
                    analyses_run{end+1} = 'Normalization 1';
                else
                    analyses_run{end+1} = 'Normalization 2';
                end
                
            end
            
            
            
            if self.CL_histogram_plot_option == 1
               
                for k = 1:numel(self.CL_conds)
                    plot_CL_histograms(self.CL_conds{k}, self.datatype_indices.CL_inds, ...
                        self.CombData.histograms, self.num_groups, self.CL_hist_plot_settings);
                end
                
                analyses_run{end+1} = 'CL histograms';

            end
            
            if self.timeseries_plot_option == 1
                
                for k = 1:numel(self.OL_conds)
                    plot_OL_timeseries(self.CombData.timeseries_avg_over_reps, ...
                        self.CombData.timestamps, self.OL_conds{k}, self.OL_conds_durations{k}, self.timeseries_plot_settings.cond_name{k}, ...
                        self.datatype_indices.OL_inds, self.OL_conds_axis_labels, ...
                        self.datatype_indices.Frame_ind, self.num_groups, self.genotype, self.control_genotype, self.timeseries_plot_settings,...
                        self.timeseries_top_left_place, self.timeseries_bottom_left_places{k}, ...
                        self.timeseries_left_column_places{k},self.timeseries_plot_settings.figure_names, 0);
                    
                    
                end
                
                analyses_run{end+1} = 'Timeseries Plots';
                
            end
            
            if self.TC_plot_option == 1
                
                for k = 1:length(self.TC_conds)
                    plot_TC_specified_OLtrials(self.TC_plot_settings, self.TC_conds{k}, self.datatype_indices.TC_inds, ...
                       self.genotype, self.control_genotype, self.num_groups, self.CombData, 0);
                end
                
                analyses_run{end+1} = 'Tuning Curves';
                
            end
            
            %% ADD NEW MODULE
            %Add an if statement here for your new module
%             if self.new_module_option == 1
%                 new_mod_test();
%             end

            update_analysis_file_group(self.group_being_analyzed_name, self.save_settings.results_path, ...
                self.save_settings.save_path, analyses_run, files_excluded, ...
                self.OL_datatypes, self.CL_datatypes, self.TC_datatypes, self.genotype);
            
            update_individual_fly_log_files(self.exp_folder, self.save_settings.save_path, ...
                analyses_run, files_excluded);
            
        end
        
        function run_safety_checks(self)
           
            if ~isempty(self.OL_conds) && ~isempty(self.OL_conds_durations)
                
                %OL_conds and OL_conds_durations must be exactly the same
                %dimensions
                
                if size(self.OL_conds) ~= size(self.OL_conds_durations)
                    errordlg("Your OL_conds and OL_conds_durations arrays must be exaclty the same size.")
                    return;
                end
                
                for i = 1:length(self.OL_conds)
                    if size(self.OL_conds{i}) ~= size(self.OL_conds_durations{i})
                        errordlg("Your OL_conds and OL_conds_durations arrays must be exaclty the same size.");
                        return;
                    end
                end
                
                      
                    
                
            end
                
            
        end
        
        
    end
    
    
    
end






