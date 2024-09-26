 classdef create_data_analysis_tool < handle
    
       
    properties
        
        % Properties obtained from the settings file 
        exp_settings
        gen_settings
        histogram_plot_settings
        histogram_annotation_settings
        CL_hist_plot_settings
        timeseries_plot_settings
        TC_plot_settings
        pos_plot_settings
        MP_plot_settings
        comp_plot_settings
        save_settings
        proc_settings
        
        
        % Properties passed in through the initial command
        flags
        
        
        % Properties created during initialization
        CombData
        histogram_plot_option
        CL_histogram_plot_option
        timeseries_plot_option
        TC_plot_option
        pos_plot_option
        comp_plot_option
        group_analysis
        single_analysis
        faLmR
        model %class that holds variables and datasets to be saved at the end of analysis

        % Need to move elsewhere

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
            
            %% Load settings file
            settings = load(settings_file);
            
            %% Set all necessary variables to properties of the class
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
            self.proc_settings = settings.proc_settings;
            
%             self.exp_settings.exp_folder = self.exp_settings.exp_folder;
%             self.proc_settings.trial_options = self.proc_settings.trial_options;
            
            self.histogram_plot_option = 0;
            self.CL_histogram_plot_option = 0;
            self.timeseries_plot_option = 0;
            self.TC_plot_option = 0;
            self.pos_plot_option = 0;
            self.comp_plot_option = 0;
            
            self.single_analysis = 0;
            self.group_analysis = 0;
            
            if ~iscell(self.exp_settings.genotypes)
                self.exp_settings.genotypes = num2cell(self.exp_settings.genotypes);
            end
            

            %% Determine if flipped and averaged data is being plotted
            if ~isempty(find(strcmp(self.timeseries_plot_settings.OL_datatypes, 'faLmR')))
                self.faLmR = 1;
                self.timeseries_plot_settings.OL_datatypes(strcmp(self.timeseries_plot_settings.OL_datatypes,'faLmR')==1) = [];
            else
                self.faLmR = 0;
            end


        %% Update settings based on flags
        
        %use flags to determine which variables from the processed data
        %file are needed.
            self.flags = varargin;
            data_needed = {'conditionModes', 'channelNames', 'summaries', ...
                'summaries_normalized', 'timestamps',...
                'bad_duration_conds', 'bad_duration_intertrials', 'bad_WBF_conds'};
            for i = 1:length(self.flags)
                
                switch lower(self.flags{i})
                
                    case '-hist' %Do basic histogram plots
                        
                        self.histogram_plot_option = 1;
                        data_needed{end+1} = 'ts_avg_reps';
                        data_needed{end+1} = 'interhistogram';
                        
                    case '-clhist' %Do closed loop histogram plots
                        
                        self.CL_histogram_plot_option = 1;
                        data_needed{end+1} = 'histograms_CL';
                        
                    case '-tsplot' %Do timeseries plots
                        
                        self.timeseries_plot_option = 1;
                        data_needed{end+1} = 'ts_avg_reps_norm';
                        data_needed{end+1} = 'ts_avg_reps';
                        data_needed{end+1} = 'timeseries';
                        data_needed{end+1} = 'timeseries_normalized';
                        data_needed{end+1} = 'frame_movement_times_avg';
                        
                        if self.faLmR == 1

                            data_needed{end+1} = 'faLmR_avg_reps_norm';

                        end

                    case '-tcplot' %Do tuning curve plots
                        
                        self.TC_plot_option = 1;
                        
                    case '-posplot' %Do M, P, and maybe position series plots
                        
                        self.pos_plot_option = 1;
                        data_needed{end+1} = 'mean_pos_series';
                        data_needed{end+1} = 'pos_conditions';
                        
                    case '-compplot' %Do comparison plot
                        
                        self.comp_plot_option = 1;
                        data_needed{end+1} = 'mean_pos_series';
                        data_needed{end+1} = 'ts_avg_reps';
                        data_needed{end+1} = 'ts_avg_reps_norm';
                        
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
            
            %% Add unnormalized data if necessary
            if self.exp_settings.plot_norm_and_unnorm
                data_needed{end+1} = 'ts_avg_reps';
                if self.faLmR == 1
                    data_needed{end+1} = 'faLmR_avg_over_reps';
                end

            end

            data_needed = unique(data_needed);
            
            %% Always load channelNames, conditionModes, and timestamps
            files = dir(self.exp_settings.exp_folder{1,1});
            try
                Data_name = files(contains({files.name},{self.proc_settings.processed_file_name})).name;
            catch
                error('cannot find processed file in specified folder')
            end

            load(fullfile(self.exp_settings.exp_folder{1,1},Data_name), 'channelNames', 'conditionModes', 'timestamps', 'ts_avg_reps', 'pos_conditions', 'faLmR_avg_over_reps');
            self.CombData.timestamps = timestamps;
            self.CombData.channelNames = channelNames;
            self.CombData.conditionModes = conditionModes;
            self.CombData.pos_conditions = pos_conditions;
            
             %% Establish model which will track dataset changes, indices, 
            %other things that need tracking throughout analysis
            
            self.model = da_model(self);


            %% Create default plot axis labels for any that were not
            %provided.
            [self.timeseries_plot_settings.OL_TS_conds_axis_labels, self.TC_plot_settings.axis_labels, ...
                self.pos_plot_settings.axis_labels, self.MP_plot_settings.axis_labels] = ...
            generate_default_axis_labels(self.timeseries_plot_settings.axis_labels,...
                self.TC_plot_settings.axis_labels, self.pos_plot_settings.axis_labels, ...
                self.MP_plot_settings.axis_labels, self.timeseries_plot_settings.OL_datatypes, ...
                self.TC_plot_settings.TC_datatypes);

            %Create default plot layout for any plots flagged but not
            %supplied
            
            %% Create any default layouts that are called for and were not provided
            
            %timeseries
            if self.timeseries_plot_option == 1 && isempty(self.timeseries_plot_settings.OL_TS_conds) %timeseries are being plotted but a plot layout was not provided
                
                %Figure out which conditions need to be plotted.
                [conds_vec_ts] = get_conds_to_plot('ts_plot', self.timeseries_plot_settings, conditionModes);
                
                %Create default layout for given condition vector
                self.timeseries_plot_settings.OL_TS_conds = create_default_plot_layout(conds_vec_ts);

                if self.faLmR==1 && isempty(self.timeseries_plot_settings.faLmR_conds)
                    self.timeseries_plot_settings.faLmR_conds = create_default_faLmR_layout(faLmR_avg_over_reps, self.timeseries_plot_settings.faLmR_plot_both_directions);
                end
                    
                
            end
            
            % Closed loop histograms
            if self.CL_histogram_plot_option && isempty(self.CL_hist_plot_settings.CL_hist_conds)
                
                %Figure out which conditions need to be plotted.
                [conds_vec_cl] = get_conds_to_plot('cl_hist', conditionModes);
                
                if isempty(conds_vec_cl)
                    disp("No closed loop conditions were found, so closed loop histograms will not be plotted.");
                    self.CL_histogram_plot_option = 0;
                else
                 %Create default layout for given condition vector
                    self.CL_hist_plot_settings.CL_hist_conds = create_default_plot_layout(conds_vec_cl);
                end
            end
            
            % Position series plots
            if self.pos_plot_option && isempty(self.pos_plot_settings.pos_conds) && ...
                    self.pos_plot_settings.plot_pos_averaged
                %Figure out which conditions need to be plotted.
                [conds_vec_pos] = get_conds_to_plot('pos_plot', self.pos_plot_settings, pos_conditions);
                
                %Create default layout for given condition vector
                self.pos_plot_settings.pos_conds = create_default_plot_layout(conds_vec_pos);
            end
            
            %M and P plots
            if self.pos_plot_option && isempty(self.MP_plot_settings.mp_conds)
                %Figure out which conditions need to be plotted.
                [conds_vec_mp] = get_conds_to_plot('mp_plot', pos_conditions);
                %Create default layout for given condition vector
                self.MP_plot_settings.mp_conds = create_default_plot_layout(conds_vec_mp);
            end
            
            %Tuning curves
            if self.TC_plot_option == 1 && isempty(self.TC_plot_settings.OL_TC_conds)
                
                %Tuning curves are weird so have their own function to get
                %default layout.
                self.TC_plot_settings.OL_TC_conds = create_default_TC_plot_layout(conditionModes, self.TC_plot_settings.OL_TC_conds);
            end
            
           %% Create default subplot titles that are called for and were not provided
            %timeseries
            if self.timeseries_plot_option && isempty(self.timeseries_plot_settings.cond_name)
                self.timeseries_plot_settings.cond_name = create_default_plot_titles(self.timeseries_plot_settings.OL_TS_conds, self.timeseries_plot_settings.cond_name, self.model.g4p_path);
            end

            %M and P plots
            if self.pos_plot_option && isempty(self.MP_plot_settings.cond_name)
                self.MP_plot_settings.cond_name = create_default_plot_titles(self.MP_plot_settings.mp_conds, self.MP_plot_settings.cond_name, self.model.g4p_path);
            end
            %closed loop histograms
            if self.CL_histogram_plot_option && isempty(self.CL_hist_plot_settings.cond_name)
                self.CL_hist_plot_settings.cond_name = create_default_plot_titles(self.CL_hist_plot_settings.CL_hist_conds, self.CL_hist_plot_settings.cond_name, self.model.g4p_path);
            end
            %position series
            if self.pos_plot_option && isempty(self.pos_plot_settings.cond_name) && ...
                    self.pos_plot_settings.plot_pos_averaged
                self.pos_plot_settings.cond_name = create_default_plot_titles(self.pos_plot_settings.pos_conds, ...
                    self.pos_plot_settings.cond_name, self.model.g4p_path);
            end
            
            %Tuning curves are weird and need their own function to create
            %default plot titles
             if self.TC_plot_option == 1 && isempty(self.TC_plot_settings.cond_name) || ~isempty(self.TC_plot_settings.cond_name == 0)
                self.TC_plot_settings.TC_plot_titles = create_default_TC_titles(self.TC_plot_settings.OL_TC_conds, self.TC_plot_settings.cond_name, self.model.g4p_path);
            end
          
            %% Create default figure names that are called for and were not provided
           
            %Create default figure names if none are provided, check figure
            %names against number of figures if they are provided
            
            %for timeseries plots
            if self.timeseries_plot_option
                self.timeseries_plot_settings.figure_names = get_figure_names('ts',...
                    self.timeseries_plot_settings.figure_names, self.timeseries_plot_settings.OL_datatypes, self.timeseries_plot_settings.OL_TS_conds);
            end
            
            %for closed loop histograms (not implemented yet in plotting
            %function)
            if self.CL_histogram_plot_option 
                self.CL_hist_plot_settings.figure_names = get_figure_names('cl_hist',...
                    self.CL_hist_plot_settings.figure_names, self.CL_hist_plot_settings.CL_datatypes, self.CL_hist_plot_settings.CL_hist_conds);
            end
            
            %for tuning curves
            if self.TC_plot_option
                self.TC_plot_settings.figure_names = get_figure_names('tc', ...
                    self.TC_plot_settings.figure_names, self.TC_plot_settings.TC_datatypes, self.TC_plot_settings.OL_TC_conds);
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
            if isempty(self.timeseries_plot_settings.OL_TS_durations) && self.timeseries_plot_option
                    
                 self.timeseries_plot_settings.OL_TS_durations = create_default_OL_durations(self.timeseries_plot_settings.OL_TS_conds, ts_avg_reps, self.CombData.timestamps);
                %run module to set durations (x axis limits)
            end
            
            %% Get faLmR pairings if they were left empty in the settings and are needed.
            
            if self.timeseries_plot_option && self.timeseries_plot_settings.plot_both_directions ...
                    && isempty(self.timeseries_plot_settings.opposing_condition_pairs)
            
                self.timeseries_plot_settings.opposing_condition_pairs = get_default_timeseries_pairings(self.exp_settings);
            end

            
            %% Perform checks to make sure nothing is missing or incorrect
            
            self.run_safety_checks();
            
            %% Update model
            
            self.model.update_model(self);
            
            %% Load all data needed for the analysis
            
            [self.CombData, self.model.files_excluded] = load_specified_data(self.exp_settings.exp_folder, ...
                self.CombData, data_needed, self.proc_settings.processed_file_name);
            
            self.model.get_removed_trials(self.CombData)
            
            %% Do any necessary processing of the datasets
            
            self.update_datasets()

            
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
            
            if self.histogram_plot_option
                plot_basic_histograms(self.model, self.CombData.ts_avg_reps, self.CombData.interhistogram, ...
                    self.TC_plot_settings, self.gen_settings, self.histogram_plot_settings,self.exp_settings,...
                    self.proc_settings, self.histogram_annotation_settings, single, self.save_settings, ...
                    self.model.num_groups, self.exp_settings.genotypes);
                
                analyses_run{end+1} = 'Basic histograms';
            end
            
            % Always plot normalized plots
            norm = 1;
            
            % Add - Normalized to the end of all timeseries and
                % tuning curve figure titles. 
            [self.timeseries_plot_settings, self.TC_plot_settings] = add_titles_text(" - Normalized",...
                 self.timeseries_plot_settings, self.TC_plot_settings);
            
            %generate normalized timeseries and tuning curve plots
            analyses_run = self.generate_plots(analyses_run, norm, single);
            
            %Remove -Normalized from all ts/tc titles
            [self.timeseries_plot_settings, self.TC_plot_settings] = revert_titles_text(" - Normalized", ...
                self.timeseries_plot_settings, self.TC_plot_settings);
                
            if self.exp_settings.plot_norm_and_unnorm == 1
                norm = 0;

                % If settings dictate, create unnormalized plots
                analyses_run = self.generate_plots(analyses_run, norm, single);
 
            end
            
            if self.pos_plot_option == 1
                [P, M, P_flies, M_flies] = generate_M_and_P(self.CombData.mean_pos_series, ...
                    self.MP_plot_settings.mp_conds, self.MP_plot_settings);
                
                plot_position_series(self.gen_settings, self.MP_plot_settings, ...
                    self.pos_plot_settings, self.save_settings, self.CombData.mean_pos_series, ...
                    P, M, P_flies, M_flies, self.exp_settings.genotypes, self.exp_settings.control_genotype);

                
                analyses_run{end + 1} = 'Position Series';

            end
                
            
            analyses_run = unique(analyses_run);
     
            update_individual_fly_log_files(self.exp_settings.exp_folder, self.save_settings.save_path, ...
            analyses_run, self.model.files_excluded);
        
            create_pdf_report(self.save_settings.report_path, self.save_settings.save_path, ...
                self.save_settings.report_plotType_order, self.save_settings.norm_order);
         end

        
        function run_group_analysis(self)
            
            analyses_run = {'Group'};
            single = 0;

            if self.histogram_plot_option == 1
                if self.exp_settings.plot_all_genotypes == 1
                    for group = 2:size(self.exp_settings.exp_folder,1)
                        timeseries_data = [self.CombData.ts_avg_reps(1,:,:,:,:);self.CombData.ts_avg_reps(group,:,:,:,:)];
                        interhistogram = [self.CombData.interhistogram(1,:,:,:); self.CombData.interhistogram(group,:,:,:)];
                        number_groups = size(timeseries_data,1);
                        genotypes = {self.exp_settings.genotypes{1}, self.exp_settings.genotypes{group}};
                        
                        plot_basic_histograms(self.model, timeseries_data, interhistogram, ...
                    self.TC_plot_settings, self.gen_settings, self.histogram_plot_settings,self.exp_settings,...
                    self.proc_settings, self.histogram_annotation_settings, single, self.save_settings, ...
                    number_groups, genotypes);
                    end
                else
                     plot_basic_histograms(self.model, self.CombData.ts_avg_reps, self.CombData.interhistogram, ...
                    self.TC_plot_settings, self.gen_settings, self.histogram_plot_settings,self.exp_settings,...
                    self.proc_settings, self.histogram_annotation_settings, single, self.save_settings, ...
                    self.model.num_groups, self.exp_settings.genotypes);
                end

                analyses_run{end+1} = 'Basic histograms';
            end
            
            % Always plot normalized plots
            norm = 1;
            
            % Add - Normalized to the end of all timeseries and
                % tuning curve figure titles. 
            [self.timeseries_plot_settings, self.TC_plot_settings] = add_titles_text(" - Normalized",...
                 self.timeseries_plot_settings, self.TC_plot_settings);
            
            %generate normalized timeseries and tuning curve plots
            analyses_run = self.generate_plots(analyses_run, norm, single);
            
            %Remove -Normalized from all ts/tc titles
            [self.timeseries_plot_settings, self.TC_plot_settings] = revert_titles_text(" - Normalized", ...
                self.timeseries_plot_settings, self.TC_plot_settings);
                
            if self.exp_settings.plot_norm_and_unnorm == 1
                norm = 0;

                % If settings dictate, create unnormalized plots
                analyses_run = self.generate_plots(analyses_run, norm, single);
 
            end
            
            if self.pos_plot_option == 1
                [P, M, P_flies, M_flies] = generate_M_and_P(self.CombData.mean_pos_series, ...
                    self.MP_plot_settings.mp_conds, self.MP_plot_settings);
                
                plot_position_series(self.gen_settings, self.MP_plot_settings, self.pos_plot_settings, ...
                    self.save_settings, self.CombData.mean_pos_series, ...
                    P, M, P_flies, M_flies, self.exp_settings.genotypes, self.exp_settings.control_genotype);

                
                analyses_run{end + 1} = 'Position Series';

            end
            
            if self.comp_plot_option == 1
                [P, M, P_flies, M_flies] = generate_M_and_P(self.CombData.mean_pos_series, ...
                    self.MP_plot_settings.mp_conds, self.MP_plot_settings);
                
                create_comparison_figure(self.CombData, self.gen_settings,...
                    self.comp_plot_settings, self.timeseries_plot_settings, ...
                    self.pos_plot_settings, self.MP_plot_settings, P, M, ...
                    P_flies, M_flies, single, self.save_settings, self.exp_settings.genotypes, self.exp_settings.control_genotype);
            end

            analyses_run = unique(analyses_run);
                
        
            
            %% ADD NEW MODULE
            %Add an if statement here for your new module
%             if self.new_module_option == 1
%                 new_mod_test();
%             end

            update_analysis_file_group(self.exp_settings.group_being_analyzed_name, self.proc_settings.protocol_folder, ...
                self.save_settings.save_path, analyses_run, self.model.files_excluded, ...
                self.timeseries_plot_settings.OL_datatypes, self.CL_hist_plot_settings.CL_datatypes, self.TC_plot_settings.TC_datatypes, self.exp_settings.genotypes);
            
            update_individual_fly_log_files(self.exp_settings.exp_folder, self.save_settings.save_path, ...
                analyses_run, self.model.files_excluded);
            
            create_pdf_report(self.save_settings.report_path, self.save_settings.save_path, ...
                self.save_settings.report_plotType_order, self.save_settings.norm_order);
            
        end
        
        function [analyses_run] = generate_plots(self, analyses_run, norm, single)


            if self.CL_histogram_plot_option == 1

                for k = 1:numel(self.CL_hist_plot_settings.CL_hist_conds)
                    plot_CL_histograms(self.CL_hist_plot_settings.CL_hist_conds{k}, self.model.datatype_indices.CL_inds, ...
                        self.CombData.histograms_CL, self.model.num_groups, self.CL_hist_plot_settings, self.gen_settings, self.save_settings);
                end

                analyses_run{end+1} = 'CL histograms';

            end

            if self.timeseries_plot_option == 1
                if self.exp_settings.plot_all_genotypes == 1 && self.model.num_groups > 1
                    for group = 2:size(self.exp_settings.exp_folder,1)
                        
                        %Pull all correct data for that group
                        if norm == 0
                            timeseries_data = [self.CombData.ts_avg_reps(1,:,:,:,:);self.CombData.ts_avg_reps(group,:,:,:,:)];
                            falmr_data = [self.CombData.faLmR_avg_over_reps(1,:,:,:);self.CombData.faLmR_avg_over_reps(group,:,:,:)];
                        else
                            timeseries_data = [self.CombData.ts_avg_reps_norm(1,:,:,:,:);self.CombData.ts_avg_reps_norm(group,:,:,:,:)];
                            falmr_data = [self.CombData.faLmR_avg_reps_norm(1,:,:,:);self.CombData.faLmR_avg_reps_norm(group,:,:,:)];
                        end
                        number_groups = size(timeseries_data,1);
                        genotypes = {self.exp_settings.genotypes{1}, self.exp_settings.genotypes{group}};
                        
                        pattern_movement_time = [self.CombData.frame_movement_times_avg(1,:,:,:);self.CombData.frame_movement_times_avg(group,:,:,:)];
                        
                        %Plot timeseries groups in a loop, once per group
                        for k = 1:numel(self.timeseries_plot_settings.OL_TS_conds)
                            plot_OL_timeseries(timeseries_data, self.CombData.timestamps, ...
                                self.model, self.timeseries_plot_settings, self.exp_settings,...
                                self.save_settings, self.gen_settings, number_groups, ...
                                genotypes, single, k,  pattern_movement_time);
                            
                          
                        end
                        if self.faLmR == 1
                            
                            plot_falmr_timeseries(falmr_data, self.CombData.timestamps, ...
                                self.timeseries_plot_settings, self.exp_settings, self.model, ...
                                self.save_settings, self.gen_settings, number_groups, genotypes, ...
                                single, pattern_movement_time);
                            

                        end
                    end
                else

                    
                    if ~single || ~self.timeseries_plot_settings.show_individual_reps
                       
                        if norm == 0
                            timeseries_data = self.CombData.ts_avg_reps;
                            if self.faLmR
                                falmr_data = self.CombData.faLmR_avg_over_reps;
                            end

                        else
                            timeseries_data = self.CombData.ts_avg_reps_norm;
                            if self.faLmR
                                falmr_data = self.CombData.faLmR_avg_reps_norm;
                            end
                        end
                        

                        
                        % Pattern movement time is ordered by condition - may need to make a second
% one ordered by how conditions are paired during flipping and averaging? 

                        pattern_movement_time = self.CombData.frame_movement_times_avg;
                        for k = 1:numel(self.timeseries_plot_settings.OL_TS_conds)
                            plot_OL_timeseries(timeseries_data, self.CombData.timestamps, ...
                                self.model, self.timeseries_plot_settings, self.exp_settings,...
                                self.save_settings, self.gen_settings, self.model.num_groups, ...
                                self.exp_settings.genotypes, single, k,  pattern_movement_time);
                            
                        end
                        if self.faLmR == 1
                           plot_falmr_timeseries(falmr_data, self.CombData.timestamps, ...
                                self.timeseries_plot_settings, self.exp_settings, self.model, ...
                                self.save_settings, self.gen_settings, self.model.num_groups, ...
                                self.exp_settings.genotypes, single, pattern_movement_time);
                        end
                    else
                        % Don't offer falmr plotting which shows each
                    % repetition - it would be hard to make it readable. 

                            if norm == 0
                                timeseries_data = self.CombData.timeseries;
                            else
                                timeseries_data = self.CombData.timeseries_normalized;
                            end
                            
                            pattern_movement_time = self.CombData.frame_movement_times_avg;
                            
                            for k = 1:numel(self.timeseries_plot_settings.OL_TS_conds)
                            plot_OL_timeseries(timeseries_data, self.CombData.timestamps, ...
                                self.model, self.timeseries_plot_settings, self.exp_settings,...
                                self.save_settings, self.gen_settings, self.model.num_groups, ...
                                self.exp_settings.genotypes, single, k,  pattern_movement_time);
                            
                            end
                             
                     end


                end

                analyses_run{end+1} = 'Timeseries Plots';
                if self.faLmR == 1
                    analyses_run{end+1} = 'faLmR';
                end

            end

            if self.TC_plot_option == 1
                
                if self.exp_settings.plot_all_genotypes == 1
                    for group = 2:size(self.exp_settings.exp_folder,1)
                        if norm == 0
                            
                            summaries = [self.CombData.summaries(1,:,:,:,:);self.CombData.summaries(group,:,:,:,:)];
                        else
                            
                            summaries= [self.CombData.summaries_normalized(1,:,:,:,:);self.CombData.summaries_normalized(group,:,:,:,:)];
                            
                        end
                        number_groups = size(summaries,1);
                        genotypes = {self.exp_settings.genotypes{1}, self.exp_settings.genotypes{group}};
                        for k = 1:length(self.TC_plot_settings.OL_TC_conds)
                            plot_TC_specified_OLtrials(self.TC_plot_settings, self.gen_settings, self.TC_plot_settings.OL_TC_conds{k}, self.TC_plot_settings.TC_plot_titles{k}, self.model.datatype_indices.TC_inds, ...
                               genotypes, self.exp_settings.control_genotype, number_groups, summaries, single, self.save_settings, k);
                        end
                    end
                else
                    if norm == 0
                        summaries = self.CombData.summaries;
                    else
                        summaries = self.CombData.summaries_normalized;
                    end

                    for k = 1:length(self.TC_plot_settings.OL_TC_conds)
                        plot_TC_specified_OLtrials(self.TC_plot_settings, self.gen_settings, self.TC_plot_settings.OL_TC_conds{k}, self.TC_plot_settings.TC_plot_titles{k}, self.model.datatype_indices.TC_inds, ...
                           self.exp_settings.genotypes, self.exp_settings.control_genotype, self.model.num_groups, summaries, single, self.save_settings, k);
                    end
                end

                analyses_run{end+1} = 'Tuning Curves';

            end
            

        end

        function update_datasets(self)
            [num_groups, num_exps] = size(self.exp_settings.exp_folder);
            if num_groups == 1 && num_exps == 1
                single = 1;
            else
                single = 0;
            end
            
            
                
            
        end
     
        
        function run_safety_checks(self)
           
            if ~isempty(self.timeseries_plot_settings.OL_TS_conds) && ~isempty(self.timeseries_plot_settings.OL_TS_durations)
                
                %OL_conds and OL_TS_durations must be exactly the same
                %dimensions
                
                if size(self.timeseries_plot_settings.OL_TS_conds) ~= size(self.timeseries_plot_settings.OL_TS_durations)
                    errordlg("Your OL_conds and OL_TS_durations arrays must be exaclty the same size.")
                    return;
                end
                
                for i = 1:length(self.timeseries_plot_settings.OL_TS_conds)
                    if size(self.timeseries_plot_settings.OL_TS_conds{i}) ~= size(self.timeseries_plot_settings.OL_TS_durations{i})
                        errordlg("Your OL_conds and OL_TS_durations arrays must be exaclty the same size.");
                        return;
                    end
                end
                
                      
                    
                
            end
                
            
        end
        
        
    end
    
    
    
end






