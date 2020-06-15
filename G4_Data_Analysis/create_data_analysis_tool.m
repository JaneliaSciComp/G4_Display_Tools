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
        gen_settings
        
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
        TC_plot_titles
        
        pos_plot_option
        pos_plot_settings
        MP_plot_settings
        
        comp_plot_option
        comp_plot_settings
        
        datatype_indices
%         
    %    normalize_option
%         normalize_settings
        
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
        %% Function that creates the object with all data analysis settings and functions
        function self = create_data_analysis_tool(settings_file, varargin)
           
 
            % Make sure settings file exists
            if ~isfile(settings_file)
                disp("Cannot find settings file");
                return;
            end
            
            %Load settings file
            settings = load(settings_file);
            
            %Set all necessary variables to properties of the class
            self.exp_settings = settings.exp_settings;
            self.gen_settings = settings.gen_settings;
            self.histogram_plot_settings = settings.histogram_plot_settings;
            self.histogram_annotation_settings = settings.histogram_annotation_settings;
            self.CL_hist_plot_settings = settings.CL_hist_plot_settings;
            self.timeseries_plot_settings = settings.timeseries_plot_settings;
            self.TC_plot_settings = settings.TC_plot_settings;
            self.pos_plot_settings = settings.pos_plot_settings;
            self.save_settings = settings.save_settings;
            self.MP_plot_settings = settings.MP_plot_settings;
            self.comp_plot_settings = settings.comp_settings;
            
            self.exp_folder = self.exp_settings.exp_folder;
            self.trial_options = self.exp_settings.trial_options;
            
            self.histogram_plot_option = 0;
            self.CL_histogram_plot_option = 0;
            self.timeseries_plot_option = 0;
            self.TC_plot_option = 0;
            self.pos_plot_option = 0;
            self.comp_plot_option = 0;
            
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
            
            %Get number of groups and experiments per group
            [self.num_groups, self.num_exps] = size(self.exp_folder);
            
            %Check if there is a control group
            if ~isempty(self.exp_settings.control_genotype)
                self.control_genotype = 1;
            else
                self.control_genotype = 0;  
            end
           

        %% Update settings based on flags
        
        %use flags to determine which variables from the processed data
        %file are needed.
            self.flags = varargin;
            self.data_needed = {'conditionModes', 'channelNames', 'summaries'};
            for i = 1:length(self.flags)
                
                switch lower(self.flags{i})
                
                    case '-hist' %Do basic histogram plots
                        
                        self.histogram_plot_option = 1;
                        self.data_needed{end+1} = 'ts_avg_reps';
                        self.data_needed{end+1} = 'interhistogram';
                        
                    case '-clhist' %Do closed loop histogram plots
                        
                        self.CL_histogram_plot_option = 1;
                        self.data_needed{end+1} = 'histograms_CL';
                        
                    case '-tsplot' %Do timeseries plots
                        
                        self.timeseries_plot_option = 1;
                        self.data_needed{end+1} = 'ts_avg_reps';
                        
                    case '-tcplot' %Do tuning curve plots
                        
                        self.TC_plot_option = 1;
                        
                    case '-posplot' %Do M, P, and maybe position series plots
                        
                        self.pos_plot_option = 1;
                        self.data_needed{end+1} = 'mean_pos_series';
                        self.data_needed{end+1} = 'pos_conditions';
                        
                    case '-compplot' %Do comparison plot
                        
                        self.comp_plot_option = 1;
                        self.data_needed{end+1} = 'mean_pos_series';
                        self.data_needed{end+1} = 'ts_avg_reps';
                        self.data_needed{end+1} = 'ts_avg_reps_norm';
                        
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
            
            if self.exp_settings.plot_norm_and_unnorm
                self.data_needed{end+1} = 'ts_avg_reps_norm';
                self.data_needed{end+1} = 'summaries_normalized';
            end
            
            self.data_needed{end+1} = 'timestamps';
            self.data_needed = unique(self.data_needed);
            
            %% Always load channelNames, conditionModes, and timestamps
            files = dir(self.exp_folder{1,1});
            try
                Data_name = files(contains({files.name},{self.processed_data_file})).name;
            catch
                error('cannot find processed file in specified folder')
            end

            load(fullfile(self.exp_folder{1,1},Data_name), 'channelNames', 'conditionModes', 'timestamps', 'ts_avg_reps', 'pos_conditions');
            self.CombData.timestamps = timestamps;
            self.CombData.channelNames = channelNames;
            self.CombData.conditionModes = conditionModes;
            self.CombData.pos_conditions = pos_conditions;
            
             %Get path to .g4p file
            [g4ppath] = get_g4p_file(self.save_settings.path_to_protocol);

            %% Create default plot axis labels for any that were not
            %provided.
            [self.OL_conds_axis_labels, self.TC_plot_settings.axis_labels, ...
                self.pos_plot_settings.axis_labels, self.MP_plot_settings.axis_labels] = ...
            generate_default_axis_labels(self.timeseries_plot_settings.axis_labels,...
                self.TC_plot_settings.axis_labels, self.pos_plot_settings.axis_labels, ...
                self.MP_plot_settings.axis_labels, self.OL_datatypes, self.TC_datatypes);

            %Create default plot layout for any plots flagged but not
            %supplied
            
            %% Create any default layouts that are called for and were not provided
            
            if self.timeseries_plot_option == 1 && isempty(self.OL_conds) %timeseries are being plotted but a plot layout was not provided
                
                %Figure out which conditions need to be plotted.
                [conds_vec_ts] = get_conds_to_plot('ts_plot', self.timeseries_plot_settings, conditionModes);
                
                %Create default layout for given condition vector
                self.OL_conds = create_default_plot_layout(conds_vec_ts);
                
            end
            
            if self.CL_histogram_plot_option && isempty(self.CL_conds)
                
                %Figure out which conditions need to be plotted.
                [conds_vec_cl] = get_conds_to_plot('cl_hist', conditionModes);
                
                 %Create default layout for given condition vector
                self.CL_conds = create_default_plot_layout(conds_vec_cl);
            end
            
            if self.pos_plot_option && isempty(self.pos_plot_settings.pos_conds) && ...
                    self.pos_plot_settings.plot_pos_averaged
                %Figure out which conditions need to be plotted.
                [conds_vec_pos] = get_conds_to_plot('pos_plot', self.pos_plot_settings, pos_conditions);
                
                %Create default layout for given condition vector
                self.pos_plot_settings.pos_conds = create_default_plot_layout(conds_vec_pos);
            end
            
            if self.pos_plot_option && isempty(self.MP_plot_settings.mp_conds)
                %Figure out which conditions need to be plotted.
                [conds_vec_mp] = get_conds_to_plot('mp_plot', pos_conditions);
                %Create default layout for given condition vector
                self.MP_plot_settings.mp_conds = create_default_plot_layout(conds_vec_mp);
            end
            
            if self.TC_plot_option == 1 && isempty(self.TC_conds)
                
                %Tuning curves are weird so have their own function to get
                %default layout.
                self.TC_conds = create_default_TC_plot_layout(conditionModes, self.TC_conds);
            end
            
           %% Create default subplot titles that are called for and were not provided

            if self.timeseries_plot_option && isempty(self.timeseries_plot_settings.cond_name) || ~isempty(self.timeseries_plot_settings.cond_name == 0)
                self.timeseries_plot_settings.cond_name = create_default_plot_titles(self.OL_conds, self.timeseries_plot_settings.cond_name, g4ppath);
            end

            
            if self.pos_plot_option && isempty(self.MP_plot_settings.cond_name)
                self.MP_plot_settings.cond_name = create_default_plot_titles(self.MP_plot_settings.mp_conds, self.MP_plot_settings.cond_name, g4ppath);
            end
            
            if self.CL_histogram_plot_option && isempty(self.CL_hist_plot_settings.cond_name)
                self.CL_hist_plot_settings.cond_name = create_default_plot_titles(self.CL_conds, self.CL_hist_plot_settings.cond_name, g4ppath);
            end
            
            if self.pos_plot_option && isempty(self.pos_plot_settings.cond_name) && ...
                    self.pos_plot_settings.plot_pos_averaged
                self.pos_plot_settings.cond_name = create_default_plot_titles(self.pos_plot_settings.pos_conds, ...
                    self.pos_plot_settings.cond_name, g4ppath);
            end
            
            %Tuning curves are weird and need their own function to create
            %default plot titles
             if self.TC_plot_option == 1 && isempty(self.TC_plot_settings.cond_name) || ~isempty(self.TC_plot_settings.cond_name == 0)
                self.TC_plot_titles = create_default_TC_titles(self.TC_conds, self.TC_plot_settings.cond_name, g4ppath);
            end
          
            %% Create default figure names that are called for and were not provided
           
            %Create default figure names if none are provided, check figure
            %names against number of figures if they are provided
            
            %for timeseries plots
            if self.timeseries_plot_option
                self.timeseries_plot_settings.figure_names = get_figure_names('ts',...
                    self.timeseries_plot_settings.figure_names, self.OL_datatypes, self.OL_conds);
            end
            
            %for closed loop histograms (not implemented yet in plotting
            %function)
            if self.CL_histogram_plot_option 
                self.CL_hist_plot_settings.figure_names = get_figure_names('cl_hist',...
                    self.CL_hist_plot_settings.figure_names, self.CL_datatypes, self.CL_conds);
            end
            
            %for tuning curves
            if self.TC_plot_option
                self.TC_plot_settings.figure_names = get_figure_names('tc', ...
                    self.TC_plot_settings.figure_names, self.TC_datatypes, self.TC_conds);
            end
            
            %for M and P plots, and position series if applicable.
            if self.pos_plot_option
                self.MP_plot_settings.figure_names = get_figure_names('mp', ...
                    self.MP_plot_settings.figure_names, self.MP_plot_settings.mp_conds);
                if self.pos_plot_settings.plot_pos_averaged
                    self.pos_plot_settings.figure_names = get_figure_names('pos', ...
                        self.pos_plot_settings.figure_names, self.pos_plot_settings.pos_conds);
                end
                
            end
            
            %for comparison plot if applicable
            
            if self.comp_plot_option && isempty(self.comp_plot_settings.figure_names)
                self.comp_plot_settings.figure_names = get_figure_names('comp', ...
                    self.comp_plot_settings.figure_names, self.comp_plot_settings.conditions,...
                    self.comp_plot_settings.rows_per_fig);
            end
            
            
            %% Get default x limits for timeseries plots if not provided
            if isempty(self.OL_conds_durations) && self.timeseries_plot_option
                    
                 self.OL_conds_durations = create_default_OL_durations(self.OL_conds, ts_avg_reps, self.CombData.timestamps);
                %run module to set durations (x axis limits)
            end
            
            
            %% Get placements of subplots, so we know which ones should have enabled axes    
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
            self.MP_plot_settings.top_left_place = 1;
            self.pos_plot_settings.top_left_place = 1;
            
            if self.timeseries_plot_option == 1
                [self.timeseries_bottom_left_places, self.timeseries_left_column_places] = ...
                   get_plot_placements(self.OL_conds);
            end
            if self.pos_plot_option == 1
            
              [self.MP_plot_settings.bottom_left_place, self.MP_plot_settings.left_column_places] = ...
                 get_plot_placements(self.MP_plot_settings.mp_conds);
            end
            
            if self.pos_plot_option && self.pos_plot_settings.plot_pos_averaged
                [self.pos_plot_settings.bottom_left_place, self.pos_plot_settings.left_column_places] = ...
                    get_plot_placements(self.pos_plot_settings.pos_conds);
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

        end
        
        function run_single_analysis(self)
            
            analyses_run = {'Single'};
            single = 1;
            %in this case, exp_folder should be a cell array with one
            %element, the path to the processed data file. 
            
            [self.CombData, files_excluded] = load_specified_data(self.exp_folder, ...
                self.CombData, self.data_needed, self.processed_data_file);
           
            if self.histogram_plot_option
                plot_basic_histograms(self.CombData.ts_avg_reps, self.CombData.interhistogram, ...
                    self.TC_datatypes, self.gen_settings, self.histogram_plot_settings, self.num_groups, self.num_exps,...
                    self.genotype, self.datatype_indices.TC_inds, self.trial_options, self.histogram_annotation_settings, single, self.save_settings);
                
                analyses_run{end+1} = 'Basic histograms';
            end
            
            if self.exp_settings.plot_norm_and_unnorm == 1
                norm = 0;
                for it = 1:2

                    %run generate plots
                    analyses_run = self.generate_plots(analyses_run, norm, single);

                    for name = 1:length(self.timeseries_plot_settings.figure_names)
                       self.timeseries_plot_settings.figure_names(name) = self.timeseries_plot_settings.figure_names(name) + " - Normalized";
                    end
                    for tcname = 1:length(self.TC_plot_settings.figure_names)
                       self.TC_plot_settings.figure_names(tcname) = self.TC_plot_settings.figure_names(tcname) + " - Normalized";
                    end
                    norm = 1;
                end
            else
                norm = 0;
                analyses_run = self.generate_plots(analyses_run, norm, single);
            end
            
            if self.pos_plot_option == 1
                [P, M, P_flies, M_flies] = generate_M_and_P(self.CombData.mean_pos_series, ...
                    self.MP_plot_settings.mp_conds, self.MP_plot_settings);
                
                plot_position_series(self.gen_settings, self.MP_plot_settings, ...
                    self.pos_plot_settings, self.save_settings, self.CombData.mean_pos_series, ...
                    P, M, P_flies, M_flies, self.genotype, self.control_genotype);

                
                analyses_run{end + 1} = 'Position Series';

            end
                
            
            analyses_run = unique(analyses_run);
     
            update_individual_fly_log_files(self.exp_folder, self.save_settings.save_path, ...
            analyses_run, files_excluded);
         end

        
        function run_group_analysis(self)
            
            analyses_run = {'Group'};
            single = 0;
            
            [self.CombData, files_excluded] = load_specified_data(self.exp_folder, ...
                self.CombData, self.data_needed, self.processed_data_file);
           
            if self.histogram_plot_option == 1
                if self.exp_settings.plot_all_genotypes == 1
                    for group = 2:size(self.exp_folder,1)
                        timeseries_data = [self.CombData.ts_avg_reps(1,:,:,:,:);self.CombData.ts_avg_reps(group,:,:,:,:)];
                        interhistogram = [self.CombData.interhistogram(1,:,:,:); self.CombData.interhistogram(group,:,:,:)];
                        number_groups = size(timeseries_data,1);
                        genotypes = {self.genotype{1}, self.genotype{group}};
                        plot_basic_histograms(timeseries_data, interhistogram, self.TC_datatypes, ...
                            self.gen_settings, self.histogram_plot_settings, number_groups, self.num_exps, genotypes, ...
                            self.datatype_indices.TC_inds, self.trial_options, self.histogram_annotation_settings, single, self.save_settings);
                    end
                else
                    plot_basic_histograms(self.CombData.ts_avg_reps, self.CombData.interhistogram, ...
                        self.TC_datatypes, self.gen_settings, self.histogram_plot_settings, self.num_groups, self.num_exps,...
                        self.genotype, self.datatype_indices.TC_inds, self.trial_options, self.histogram_annotation_settings, single, self.save_settings);
                end

                analyses_run{end+1} = 'Basic histograms';
            end
            
            if self.exp_settings.plot_norm_and_unnorm == 1
                norm = 0;
                for it = 1:2
                    analyses_run = self.generate_plots(analyses_run, norm, single);
                    norm = 1;
                    for name = 1:length(self.timeseries_plot_settings.figure_names)
                       self.timeseries_plot_settings.figure_names(name) = self.timeseries_plot_settings.figure_names(name) + " - Normalized";
                    end
                    for subname = 1:length(self.timeseries_plot_settings.subplot_figure_names)
                        for datasubname = 1:length(self.timeseries_plot_settings.subplot_figure_names{subname})
                            self.timeseries_plot_settings.subplot_figure_names{subname}(datasubname) = self.timeseries_plot_settings.subplot_figure_names{subname}(datasubname) + " - Normalized";
                        end
                    end

                    for tcname = 1:length(self.TC_plot_settings.figure_names)
                       self.TC_plot_settings.figure_names(tcname) = self.TC_plot_settings.figure_names(tcname) + " - Normalized";
                    end
                    for subtcname = 1:length(self.TC_plot_settings.subplot_figure_names)
                        for datatcsubname = 1:length(self.TC_plot_settings.subplot_figure_names{subtcname})
                            self.TC_plot_settings.subplot_figure_names{subtcname}(datatcsubname) = self.TC_plot_settings.subplot_figure_names{subtcname}(datatcsubname) + " - Normalized";
                        end
                    end
                end
                for revert_name = 1:length(self.timeseries_plot_settings.figure_names)
                    self.timeseries_plot_settings.figure_names(revert_name) = erase(self.timeseries_plot_settings.figure_names(revert_name), " - Normalized");
                end
                for revert_subname = 1:length(self.timeseries_plot_settings.subplot_figure_names)
                    for revert_datasubname = 1:length(self.timeseries_plot_settings.subplot_figure_names{revert_subname})
                        self.timeseries_plot_settings.subplot_figure_names{revert_subname}(revert_datasubname) = erase(self.timeseries_plot_settings.subplot_figure_names{revert_subname}(revert_datasubname), " - Normalized");
                    end
                end
                for revert_tcname = 1:length(self.TC_plot_settings.figure_names)
                    self.TC_plot_settings.figure_names(revert_tcname) = erase(self.TC_plot_settings.figure_names(revert_tcname), " - Normalized");
                end
                for revert_tcsubname = 1:length(self.TC_plot_settings.subplot_figure_names)
                    for revert_tcdatasubname = 1:length(self.TC_plot_settings.subplot_figure_names{revert_tcsubname})
                        self.TC_plot_settings.subplot_figure_names{revert_tcsubname}(revert_tcdatasubname) = erase(self.TC_plot_settings.subplot_figure_names{revert_tcsubname}(revert_tcdatasubname), " - Normalized");
                    end
                end
            else
                norm = 0;
                analyses_run = self.generate_plots(analyses_run, norm, single);
            end
            
            if self.pos_plot_option == 1
                [P, M, P_flies, M_flies] = generate_M_and_P(self.CombData.mean_pos_series, ...
                    self.MP_plot_settings.mp_conds, self.MP_plot_settings);
                
                plot_position_series(self.gen_settings, self.MP_plot_settings, self.pos_plot_settings, ...
                    self.save_settings, self.CombData.mean_pos_series, ...
                    P, M, P_flies, M_flies, self.genotype, self.control_genotype);

                
                analyses_run{end + 1} = 'Position Series';

            end
            
            if self.comp_plot_option == 1
                [P, M, P_flies, M_flies] = generate_M_and_P(self.CombData.mean_pos_series, ...
                    self.MP_plot_settings.mp_conds, self.MP_plot_settings);
                
                create_comparison_figure(self.CombData, self.gen_settings,...
                    self.comp_plot_settings, self.timeseries_plot_settings, ...
                    self.pos_plot_settings, self.MP_plot_settings, P, M, ...
                    P_flies, M_flies, single, self.save_settings, self.genotype, self.control_genotype);
            end

            analyses_run = unique(analyses_run);
                
        
            
            %% ADD NEW MODULE
            %Add an if statement here for your new module
%             if self.new_module_option == 1
%                 new_mod_test();
%             end

            update_analysis_file_group(self.group_being_analyzed_name, self.save_settings.path_to_protocol, ...
                self.save_settings.save_path, analyses_run, files_excluded, ...
                self.OL_datatypes, self.CL_datatypes, self.TC_datatypes, self.genotype);
            
            update_individual_fly_log_files(self.exp_folder, self.save_settings.save_path, ...
                analyses_run, files_excluded);
            
        end
        
        function [analyses_run] = generate_plots(self, analyses_run, norm, single)


            if self.CL_histogram_plot_option == 1

                for k = 1:numel(self.CL_conds)
                    plot_CL_histograms(self.CL_conds{k}, self.datatype_indices.CL_inds, ...
                        self.CombData.histograms, self.num_groups, self.CL_hist_plot_settings);
                end

                analyses_run{end+1} = 'CL histograms';

            end

            if self.timeseries_plot_option == 1
                if self.exp_settings.plot_all_genotypes == 1 && self.num_groups > 1
                    for group = 2:size(self.exp_folder,1)
                        if norm == 0
                            timeseries_data = [self.CombData.ts_avg_reps(1,:,:,:,:);self.CombData.ts_avg_reps(group,:,:,:,:)];
                        else
                            timeseries_data = [self.CombData.ts_avg_reps_norm(1,:,:,:,:);self.CombData.ts_avg_reps_norm(group,:,:,:,:)];
                        end
                        number_groups = size(timeseries_data,1);
                        genotypes = {self.genotype{1}, self.genotype{group}};
                        for k = 1:numel(self.OL_conds)
                            plot_OL_timeseries(timeseries_data, self.CombData.timestamps, ...
                                self.OL_conds{k}, self.OL_conds_durations{k}, self.timeseries_plot_settings.cond_name{k}, ...
                                self.datatype_indices.OL_inds, self.OL_conds_axis_labels, ...
                                self.datatype_indices.Frame_ind, number_groups, genotypes, self.control_genotype, self.timeseries_plot_settings,...
                                self.timeseries_top_left_place, self.timeseries_bottom_left_places{k}, ...
                                self.timeseries_left_column_places{k},self.timeseries_plot_settings.figure_names, ...
                                single, self.save_settings, k, self.gen_settings);
                        end
                    end
                else

                    for k = 1:numel(self.OL_conds)
                        if norm == 0
                            timeseries_data = self.CombData.ts_avg_reps;
                        else
                            timeseries_data = self.CombData.ts_avg_reps_norm;
                        end
                        plot_OL_timeseries(timeseries_data, ...
                            self.CombData.timestamps, self.OL_conds{k}, self.OL_conds_durations{k}, self.timeseries_plot_settings.cond_name{k}, ...
                            self.datatype_indices.OL_inds, self.OL_conds_axis_labels, ...
                            self.datatype_indices.Frame_ind, self.num_groups, self.genotype, self.control_genotype, self.timeseries_plot_settings,...
                            self.timeseries_top_left_place, self.timeseries_bottom_left_places{k}, ...
                            self.timeseries_left_column_places{k},self.timeseries_plot_settings.figure_names, ...
                            single, self.save_settings, k, self.gen_settings);


                    end
                end

                analyses_run{end+1} = 'Timeseries Plots';

            end

            if self.TC_plot_option == 1
                
                if self.exp_settings.plot_all_genotypes == 1
                    for group = 2:size(self.exp_folder,1)
                        if norm == 0
                            
                            summaries = [self.CombData.summaries(1,:,:,:,:);self.CombData.summaries(group,:,:,:,:)];
                        else
                            
                            summaries= [self.CombData.summaries_normalized(1,:,:,:,:);self.CombData.summaries_normalized(group,:,:,:,:)];
                            
                        end
                        number_groups = size(summaries,1);
                        genotypes = {self.genotype{1}, self.genotype{group}};
                        for k = 1:length(self.TC_conds)
                            plot_TC_specified_OLtrials(self.TC_plot_settings, self.gen_settings, self.TC_conds{k}, self.TC_plot_titles{k}, self.datatype_indices.TC_inds, ...
                               genotypes, self.control_genotype, number_groups, summaries, single, self.save_settings, k);
                        end
                    end
                else
                    if norm == 0
                        summaries = self.CombData.summaries;
                    else
                        summaries = self.CombData.summaries_normalized;
                    end

                    for k = 1:length(self.TC_conds)
                        plot_TC_specified_OLtrials(self.TC_plot_settings, self.gen_settings, self.TC_conds{k}, self.TC_plot_titles{k}, self.datatype_indices.TC_inds, ...
                           self.genotype, self.control_genotype, self.num_groups, summaries, single, self.save_settings, k);
                    end
                end

                analyses_run{end+1} = 'Tuning Curves';

            end
            

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






