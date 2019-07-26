classdef G4_conductor_controller < handle
   
    properties
        model_;
        doc_;
        fig_;
        
        
        %GUI objects
        progress_axes_;
        axes_label_;
        progress_bar_;
        experimenter_box_
        exp_name_box_
        fly_name_box_
        fly_genotype_box_
        date_and_time_box_
        exp_type_menu_
        plotting_checkbox_
        plotting_textbox_
        processing_checkbox_
        processing_textbox_
        run_textbox_
        current_running_trial_
        browse_button_plotting_
        browse_button_processing_
        browse_button_run_
        %total_trials_;
        
        %These are pieces of text in the updates panel that are updated
        %every trial
        
        current_mode_
        current_pat_
        current_pos_
        current_ao1_
        current_ao2_
        current_ao3_
        current_ao4_
        current_frInd_
        current_frRate_
        current_gain_
        current_offset_
        current_duration_

        
    end
    
    
    properties (Dependent)
        model;
        doc;
        fig;

        progress_axes;
        axes_label;
        progress_bar;
        experimenter_box
        exp_name_box
        fly_name_box
        fly_genotype_box
        date_and_time_box
        exp_type_menu
        plotting_checkbox
        plotting_textbox
        processing_checkbox
        processing_textbox
        run_textbox
        current_running_trial
        browse_button_plotting
        browse_button_processing
        browse_button_run
       % total_trials;
       
        %These are pieces of text in the updates panel that are updated
        %every trial
        
        current_mode
        current_pat
        current_pos
        current_ao1
        current_ao2
        current_ao3
        current_ao4
        current_frInd
        current_frRate
        current_gain
        current_offset
        current_duration
        
        
    end
    
    
    
    methods
        
        %contstructor
        function self = G4_conductor_controller(varargin)
            self.fig = figure('Name', 'Fly Experiment Conductor', 'NumberTitle', 'off', 'units','pixels','MenuBar', 'none', ...
                'ToolBar', 'none', 'Resize', 'off');
            self.model = G4_conductor_model();
            self.doc = G4_document();
            
            
            if ~isempty(varargin)
                
                self.doc = varargin{1};
                
            end
            
            self.layout();
%             self.total_trials_ = self.model.get_repetitions()*length(self.model.block_trials_{:,1});
%             if strcmp(self.model.pretrial{2},'') == 0
%                 self.total_trials_ = self.total_trials_ + 1;
%             end
%             if strcmp(self.model.posttrial{2},'') == 0
%                 self.total_trials_ = self.total_trials_ + 1;
%             end
%             if strcmp(self.model.intertrial{2},'') == 0
%                 self.total_trials_ = self.total_trials_ + self.model.get_repetitions() - 1;%%%%%%%IS THIS CORRECT? IS THERE AN INTERTRIAL AFTER THE LAST repetition or before the first repetition?
%             end

            
            
        
        end
        
        function layout(self)
           pix = get(0, 'screensize');
           fig_size = [.25*pix(3), .25*pix(4), .5*pix(3), .5*pix(4)];
           set(self.fig,'Position',fig_size);

           
           menu = uimenu(self.fig, 'Text', 'File');
           menu_open = uimenu(menu, 'Text', 'Open', 'Callback', @self.open_g4p_file);
         %  menu_clear = uimenu(menu, 'Text', 'Clear', 'Callback', @self.clear_data);
           
            start_button = uicontrol(self.fig,'Style','pushbutton', 'String', 'Run', ...
                'units', 'pixels', 'Position', [15, fig_size(4)- 305, 115, 85],'Callback', @self.run);
            settings_pan = uipanel(self.fig, 'Title', 'Settings', 'FontSize', 13, 'units', 'pixels', ...
                'Position', [15, fig_size(4) - 215, 370, 200]);
            metadata_pan = uipanel(self.fig, 'Title', 'Metadata', 'units', 'pixels', ...
                'FontSize', 13, 'Position', [fig_size(3) - 300, fig_size(4) - 265, 275, 250]);
            status_pan = uipanel(self.fig, 'Title', 'Status', 'FontSize', 13, 'units', 'pixels', ...
                'Position', [15, 15, fig_size(3) - 30, fig_size(4)*.2]); 
            
            %Labels for status update showing current trial parameters
            current_trial = uicontrol(status_pan, 'Style', 'text', 'String', 'Current Trial:', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [10, 35, 100, 15]);
            mode_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Mode', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [115, 60, 55, 15]);
            pat_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Pattern', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [180, 60, 55, 15]);
            pos_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Position', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [245, 60, 60, 15]);
            ao1_label = uicontrol(status_pan, 'Style', 'text', 'String', 'AO1', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [320, 60, 55, 15]);
            ao2_label = uicontrol(status_pan, 'Style', 'text', 'String', 'AO2', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [385, 60, 55, 15]);
            ao3_label = uicontrol(status_pan, 'Style', 'text', 'String', 'AO3', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [450, 60, 55, 15]);
            ao4_label = uicontrol(status_pan, 'Style', 'text', 'String', 'AO4', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [515, 60, 55, 15]);
            frameInd_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Fr. Index', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [580, 60, 60, 15]);
            frRate_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Fr. Rate', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [655, 60, 55, 15]);
            gain_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Gain', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [720, 60, 55, 15]);
            off_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Offset', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [785, 60, 55, 15]);
            dur_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Duration', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [850, 60, 60, 15]);
            
            %Parameter values in status panel which change with every trial
            
            self.current_mode =  uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [115, 35, 55, 15]);
            self.current_pat = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [180, 35, 55, 15]);
            self.current_pos = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [245, 35, 60, 15]);
            self.current_ao1 = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [320, 35, 55, 15]);
            self.current_ao2 = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [385, 35, 55, 15]);
            self.current_ao3 = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [450, 35, 55, 15]);
            self.current_ao4 = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [515, 35, 55, 15]);
             self.current_frInd = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [580, 35, 60, 15]);
            self.current_frRate = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [655, 35, 55, 15]);
            self.current_gain = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [720, 35, 55, 15]);
            self.current_offset = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [785, 35, 55, 15]);
            self.current_duration = uicontrol(status_pan, 'Style', 'text', 'String', '', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [850, 35, 60, 15]);
            
            
            self.progress_axes = axes(self.fig, 'units','pixels', 'Position', [15, fig_size(4)*.2+30, fig_size(3) - 30 ,50]);
            self.axes_label = uicontrol(self.fig, 'Style', 'text', 'String', 'Progress:', 'FontSize', 13, ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [15, fig_size(4)*.2 + 85, 100, 20]);
            self.progress_bar = barh(0, 'Parent', self.progress_axes,'BaseValue', 0);
            self.progress_axes.XAxis.Limits = [0 1];
           % self.progress_axes.YAxis.Visible = 'off';
           % self.progress_axes.XAxis.Visible = 'off';
           self.progress_axes.YTickLabel = [];
           self.progress_axes.XTickLabel = [];
           self.progress_axes.XTick = [];
           self.progress_axes.YTick = [];
           reps = self.doc.repetitions;
           total_steps = self.doc.repetitions * length(self.doc.block_trials(:,1));
           if ~isempty(self.doc.intertrial{1})
               total_steps = total_steps + ((length(self.doc.block_trials(:,1)) - 1)*reps);
           end
           
           if ~isempty(self.doc.pretrial{1})
               total_steps = total_steps + 1;
           end
           if ~isempty(self.doc.posttrial{1})
               total_steps = total_steps + 1;
           end
           for i = 1:reps
               x = (i/reps);% + 1/total_steps;
               line('XData', [x, x], 'YDATA', [0,2]);
           end

            
            
            %Settings required from user
            experimenter_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Experimenter:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 200, 100, 15]);
            self.experimenter_box = uicontrol(metadata_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.model.experimenter, 'Position', [115, 200, 150, 18], 'Callback', @self.update_experimenter);
            exp_name_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Experiment Name:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 175, 100, 15]);
            self.exp_name_box = uicontrol(metadata_pan, 'Style', 'edit', 'String', self.doc.experiment_name, 'units', 'pixels', 'Position', ...
                [115, 175, 150, 18], 'Callback', @self.update_experiment_name);
            fly_name_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Fly Name:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 150, 100, 15]);
            self.fly_name_box = uicontrol(metadata_pan, 'Style', 'edit', 'String', self.model.fly_name, ...
                'units', 'pixels', 'Position', [115, 150, 150, 18], 'Callback', @self.update_fly_name);
            fly_genotype_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Fly Genotype', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 125, 100, 15]);
            self.fly_genotype_box = uicontrol(metadata_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.model.fly_genotype, 'Position', [115, 125, 150, 18], 'Callback', @self.update_genotype);
            date_and_time_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Date and Time:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 100, 100, 15]);
            self.date_and_time_box = uicontrol(metadata_pan, 'Style', 'edit', 'String', datestr(now, 'mm-dd-yyyy HH:MM:SS'), ...
                'units', 'pixels', 'Position', [115, 100, 150, 18]);
            exp_type_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Experiment Type:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 150, 100, 15]);
            self.exp_type_menu = uicontrol(settings_pan, 'Style', 'popupmenu', 'String', {'Flight','Camera walk', 'Chip walk'}, ...
                'units', 'pixels', 'Position', [115, 150, 150, 18], 'Callback', @self.update_experiment_type);
            test_button = uicontrol(settings_pan, 'Style', 'pushbutton', 'String', 'Run Test Protocol', ...
                'units', 'pixels', 'Position', [210, 120, 150, 20], 'Callback', @self.run_test);
            plotting_checkbox_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Plotting?', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 120, 45, 15]);
            self.plotting_checkbox = uicontrol(settings_pan, 'Style', 'checkbox', 'Value', self.model.do_plotting, ...
                'units', 'pixels', 'Position', [60, 120, 15, 15], 'Callback', @self.update_do_plotting);
            plotting_filename_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Plotting Protocol:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 95, 105, 15]);
            self.plotting_textbox = uicontrol(settings_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.model.plotting_file, 'Position', [120, 95, 160, 18], 'Callback', @self.update_plotting_file);
            self.browse_button_plotting = uicontrol(settings_pan, 'Style', 'pushbutton', 'units', 'pixels', ...
                'String', 'Browse', 'Position', [285, 95, 65, 18], 'Callback', @self.browse_plot_protocol);
            
            processing_checkbox_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Processing?', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [90, 120, 65, 15]);
            self.processing_checkbox = uicontrol(settings_pan, 'Style', 'checkbox', 'Value', self.model.do_processing, ...
                'units', 'pixels', 'Position', [160, 120, 15, 15], 'Callback', @self.update_do_processing);
            processing_filename_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Processing Protocol:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 70, 105, 15]);
            self.processing_textbox = uicontrol(settings_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.model.processing_file, 'Position', [120, 70, 160, 18], 'Callback', @self.update_processing_file);
            self.browse_button_processing = uicontrol(settings_pan, 'Style', 'pushbutton', 'units', 'pixels', ...
                'String', 'Browse', 'Position', [285, 70, 65, 18], 'Callback', @self.browse_process_protocol);
            
            run_filename_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Run Protocol:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 45, 105, 15]);
            self.run_textbox = uicontrol(settings_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.model.run_protocol_file, 'Position', [80, 45, 200, 18]);
            self.browse_button_run = uicontrol(settings_pan, 'Style', 'pushbutton', 'units', 'pixels', ...
                'String', 'Browse', 'Position', [285, 45, 65, 18], 'Callback', @self.browse_run_protocol);
            
            
        end
        
        function update_run_gui(self)
           
            self.experimenter_box.String = self.model.experimenter;
            self.exp_name_box.String = self.doc.experiment_name;
            self.fly_name_box.String = self.model.fly_name;
            self.fly_genotype_box.String = self.model.fly_genotype;
            self.date_and_time_box.String = datestr(now, 'mm-dd-yyyy HH:MM:SS');
            self.plotting_checkbox.Value = self.model.do_plotting;
            self.plotting_textbox.String = self.model.plotting_file;
            self.processing_checkbox.Value = self.model.do_processing;
            self.processing_textbox.String = self.model.processing_file;
            self.exp_type_menu.Value = self.model.experiment_type;
            self.run_textbox.String = self.model.run_protocol_file;
            
        end
        
        function update_fly_name(self, src, event)
            
            self.model.fly_name = src.String;
            self.update_run_gui();
            
        end
        
        function update_experimenter(self, src, event)
            
            self.model.experimenter = src.String;
            self.update_run_gui();
            
        end
        
        function update_experiment_name(self, src, event)
            
            errormsg = "The experiment has already been saved under this name. " ...
                + "If you would like to change the experiment name, close this window " ...
                + "and save it under the new name in the designer view.";
            waitfor(errordlg(errormsg));
            self.exp_name_box.String = self.doc.experiment_name;
            self.update_run_gui();
        end
        
        function update_genotype(self, src, event)
            self.model.fly_genotype = src.String;
            self.update_run_gui();
        end
        
        function update_do_plotting(self, src, event)
            self.model.do_plotting = src.Value;
            if self.model.do_plotting == 1
                set(self.plotting_textbox, 'enable', 'on');
                set(self.browse_button_plotting, 'enable','on');
            elseif self.model.do_plotting == 0
                set(self.plotting_textbox, 'enable', 'off');
                set(self.browse_button_plotting, 'enable','off');
                self.model.plotting_file = '';
            end
            self.update_run_gui();
        end
        
        function update_do_processing(self, src, event)
            self.model.do_processing = src.Value;
            if self.model.do_processing == 1
                set(self.processing_textbox,'enable', 'on');
                set(self.browse_button_processing, 'enable','on');
            elseif self.model.do_processing == 0
                set(self.processing_textbox, 'enable', 'off');
                set(self.browse_button_processing, 'enable', 'off');
                self.model.processing_file = '';
            end
            self.update_run_gui();
        end
        
        function update_plotting_file(self, src, event)
            self.model.plotting_file = src.String;
            self.update_run_gui();
        end
        
        function update_processing_file(self, src, event)
            self.model.processing_file = src.String;
            self.update_run_gui();
        end
        
        function update_experiment_type(self, src, event)
            self.model.experiment_type = src.Value;
            self.update_run_gui();
        end
        
        function update_progress(self, rep, trial, cond)
            increment = 1/(self.doc.repetitions * length(self.doc.block_trials(:,1)));

            distance = ((rep - 1)*length(self.doc.block_trials(:,1)) + trial)*increment;
            self.progress_axes.Title.String = "Rep " + rep + " of " + self.doc.repetitions +...
                ", Trial " + trial + " of " + length(self.doc.block_trials(:,1)) + ". Condition number: " + cond;
            self.progress_bar.YData = distance;
            
            drawnow;
            
        end
        
        function test_progress_bar(self, src, event)
        
            reps = self.doc.repetitions;
            trials = length(self.doc.block_trials(:,1));
            for i = 1:reps
                for j = 1:trials
                    
                    self.update_progress(i,j);
                    pause(1);
                end
            end
        
        
        end
        
     
        function open_g4p_file(self, src, event)
           
            [filename, top_folder_path] = uigetfile('*.g4p');
            filepath = fullfile(top_folder_path, filename);
       
            if isequal (top_folder_path,0)
            
            %They hit cancel, do nothing
            else
                
                self.doc.import_folder(top_folder_path);
                [exp_path, exp_name, ext] = fileparts(filepath);
              % [exp_path, exp_name] = fileparts(self.doc.top_folder_path_);
                self.doc.experiment_name = exp_name;
                self.doc.save_filename = top_folder_path;
                self.doc.top_export_path = top_folder_path;
                
                data = self.doc.open(filepath);
                p = data.exp_parameters;
                
                self.doc.repetitions = p.repetitions;
                self.doc.is_randomized = p.is_randomized;
                self.doc.is_chan1 = p.is_chan1;
                self.doc.is_chan2 = p.is_chan2;
                self.doc.is_chan3 = p.is_chan3;
                self.doc.is_chan4 = p.is_chan4;
                self.doc.chan1_rate = p.chan1_rate;
                self.doc.set_config_data(p.chan1_rate, 1);
                self.doc.chan2_rate = p.chan2_rate;
                self.doc.set_config_data(p.chan2_rate, 2);
                self.doc.chan3_rate = p.chan3_rate;
                self.doc.set_config_data(p.chan3_rate, 3);
                self.doc.chan4_rate = p.chan4_rate;
                self.doc.set_config_data(p.chan4_rate, 4);
                self.doc.num_rows = p.num_rows;
                self.doc.set_config_data(p.num_rows, 0);
                self.doc.update_config_file();
                
                for k = 1:13

                    self.doc.set_pretrial_property(k, p.pretrial{k});
                    self.doc.set_intertrial_property(k, p.intertrial{k});
                    self.doc.set_posttrial_property(k, p.posttrial{k});

                end

                for i = 2:length(self.doc.block_trials(:, 1))
                    self.doc.block_trials((i-(i-2)),:) = [];
                end
                block_x = length(p.block_trials(:,1));
                block_y = 1;

                for j = 1:block_x
                    if j > length(self.doc.block_trials(:,1))
                        newrow = p.block_trials(j,1:end);
                        self.doc.set_block_trial_property([j, block_y], newrow);
                    else
                        for n = 1:13
                            self.doc.set_block_trial_property([j, n], p.block_trials{j,n});
                        end
                    end

                end
                
                self.update_run_gui();
                
                
            end

            
        end

        function run(self, src, event)
            
            %Before creating the data and sending you to the run script,
            %check to make sure there are no issues that will disrupt the
            %run:--------------------------------------------------------
            
            %returns if you forgot to save the experiment.
            if strcmp(self.doc.save_filename,'') == 1
                waitfor(errordlg("You didn't save this experiment. Please go back and save then run the experiment again."));
                return
            end
            
            %gets path to experiment folder
            [experiment_path, g4p_filename, ext] = fileparts(self.doc.save_filename);
            experiment_folder = experiment_path;
            
            %creates Log Files folder if it doesn't exist
            if ~exist(fullfile(experiment_folder,'Log Files'),'dir')
                mkdir(experiment_folder,'Log Files');
            end
            
            %check if log files already present or if a fly by that name
            %already has results in this experiment folder.
            
            if length(dir([experiment_folder '\Log Files\']))>2
                waitfor(errordlg('unsorted files present in "Log Files" folder, remove before restarting experiment\n'));
                return;
            end
            if exist([experiment_folder '\Results\' self.model.fly_name],'dir')
                waitfor(errordlg('Results folder already exists with that fly name\n'));
                return;
            end
            %-------------------------------------------------------------
            
            %For ease of use throughout the function
            pretrial = self.doc.pretrial;
            intertrial = self.doc.intertrial;
            posttrial = self.doc.posttrial;
            block_trials = self.doc.block_trials;
            
            
            %This places all necessary parameters and data for running on
            %the screens in a struct and passes it all to the external
            %script at once
            
            parameters = struct; 
            parameters.pretrial = pretrial;
            
            %get_pattern_index is a separate function which takes the
            %string name of a pattern or function and returns its index
            %number. If the string is empty (ie, there is no position
            %function) it returns 0 as the index.

            parameters.pretrial_pat_index = self.doc.get_pattern_index(pretrial{2});
            parameters.pretrial_pos_index = self.doc.get_posfunc_index(pretrial{3});

            
            parameters.intertrial = intertrial;

            parameters.intertrial_pat_index = self.doc.get_pattern_index(intertrial{2});
            parameters.intertrial_pos_index = self.doc.get_posfunc_index(intertrial{3});

            
            parameters.block_trials = block_trials;

            for i = 1:length(self.doc.block_trials(:,1))
                parameters.block_pat_indices(i) = self.doc.get_pattern_index(block_trials{i,2}); 
                parameters.block_pos_indices(i) = self.doc.get_posfunc_index(block_trials{i,3});
            end
            
            parameters.posttrial = posttrial;

            parameters.posttrial_pat_index = self.doc.get_pattern_index(posttrial{2});
            parameters.posttrial_pos_index = self.doc.get_posfunc_index(posttrial{3});

            
            parameters.repetitions = self.doc.repetitions;
            parameters.is_randomized = self.doc.is_randomized;
            parameters.save_filename = self.doc.save_filename;
            parameters.fly_name = self.model.fly_name;
            
            
            %The following block of code will create an array called
            %active_ao_channels with the numbers of the active ao channels
            %(ie [0 2 3] means ao channels 1, 3, and 4 are active. It will also create
            %four arrays for the pre/inter/post/block trials of the indices of
            %the ao functions for that trial. 
            %-------------------------------------------------------------
            
                %make cell arrays for each ao channel listing all the
                %functions called for that channel across all trials.
            ao1_funcs = {};
                ao1_funcs{1} = pretrial{4};

                for c = 1:length(block_trials(:,1))
                    ao1_funcs{c+1} = block_trials{c,4};
                end
                ao1_funcs{end + 1} =  intertrial{4};
                ao1_funcs{end + 1} = posttrial{4};
                ao1_isnt_empty = ~cellfun('isempty',ao1_funcs);
            
            ao2_funcs = {};
                ao2_funcs{1} = pretrial{5};
                for c = 1:length(block_trials(:,1))
                    ao2_funcs{c+1} = block_trials{c,5};
                end
                ao2_funcs{end + 1} =  intertrial{5};
                ao2_funcs{end + 1} = posttrial{5};
                ao2_isnt_empty = ~cellfun('isempty',ao2_funcs);
            
            ao3_funcs = {};
                ao3_funcs{1} = pretrial{6};
                for c = 1:length(block_trials(:,1))
                    ao3_funcs{c+1} = block_trials{c,6};
                end
                ao3_funcs{end + 1} =  intertrial{6};
                ao3_funcs{end + 1} = posttrial{6};
                ao3_isnt_empty = ~cellfun('isempty',ao3_funcs);
            
            
            ao4_funcs = {};
                ao4_funcs{1} = pretrial{7};
                for c = 1:length(block_trials(:,1))
                    ao4_funcs{c+1} = block_trials{c,7};
                end
                ao4_funcs{end + 1} =  intertrial{7};
                ao4_funcs{end + 1} = posttrial{7};
                ao4_isnt_empty = ~cellfun('isempty',ao4_funcs);
                

           
            
                %Determine which channels should be active by going through
                %the arrays we just created and checking if they are empty
                %or not
            ao1_active = 0;
     
                if sum(ao1_isnt_empty) > 0
                    ao1_active = 1;
                end
           
            
            ao2_active = 0;

                if sum(ao2_isnt_empty) > 0
                    ao2_active = 1;
                end
            
            
            ao3_active = 0;
   
                if sum(ao3_isnt_empty) > 0
                    ao3_active = 1;
                end
          
            
            ao4_active = 0;
 
                if sum(ao4_isnt_empty) > 0
                    ao4_active = 1;
                end

            %channels is now an array of zeros and 1's, a 1 indicating that
            %channel is active, a 0 indicating it is not. 
            channels = [ao1_active, ao2_active, ao3_active, ao4_active];
            channel_nums = [0,1,2,3];

            
            
            %create an array of active ao channels which is formatted
            %correctly to be passed to the panel_com function.
            j = 1;
            active_ao_channels = [];
            for channel = 1:4
                if channels(channel) == 1
                    active_ao_channels(j) = channel_nums(channel);
                    j = j + 1;
                end
            end

            
            %now have active_ao_channels which is an array of 0 - 4
            %elements indicating which ao channels are active, ie [2 3]
            %indicates channels 3 and 4 are active.
            
            %Create an array for each section with the indices of their
            %aofunctions (no ao function returns an index of 0)
            pretrial_ao_indices = [];
            intertrial_ao_indices = [];
            ao_indices = [];
            posttrial_ao_indices = [];
            
            for i = 1:length(active_ao_channels)
                channel_num = active_ao_channels(i);
                pretrial_ao_indices(i) = self.doc.get_ao_index(pretrial{channel_num + 4});
                intertrial_ao_indices(i) = self.doc.get_ao_index(intertrial{channel_num + 4});
                posttrial_ao_indices(i) = self.doc.get_ao_index(posttrial{channel_num + 4});
            end
            
            
            for m = 1:length(active_ao_channels)
                channel_num = active_ao_channels(m);
                for k = 1:length(block_trials(:,1))
                    ao_indices(k,m) = self.doc.get_ao_index(block_trials{k, channel_num + 4});
                end
            end
            

         
            %-------------------------------------------------------------
            parameters.pretrial_ao_indices = pretrial_ao_indices;
            parameters.intertrial_ao_indices = intertrial_ao_indices;
            parameters.posttrial_ao_indices = posttrial_ao_indices;
            parameters.block_ao_indices = ao_indices;
            parameters.active_ao_channels = active_ao_channels;
            
            %Need to know how many frames each pattern in each trial has
            %in case the frame index on any of them needs to be randomized.
            if ~isempty(pretrial{1})
                parameters.num_pretrial_frames = length(self.doc.Patterns.(pretrial{2}).pattern.Pats(1,1,:));
            end
            if ~isempty(intertrial{1})
                parameters.num_intertrial_frames = length(self.doc.Patterns.(intertrial{2}).pattern.Pats(1,1,:));
            end
            if ~isempty(posttrial{1})
                parameters.num_posttrial_frames = length(self.doc.Patterns.(posttrial{2}).pattern.Pats(1,1,:));
            end
            for i = 1:length(block_trials(:,1))
                parameters.num_block_frames(i) = length(self.doc.Patterns.(block_trials{i,2}).pattern.Pats(1,1,:));
            end
            
            %Create experiment order .mat file and add the trial order to
            %parameters
            num_conditions = length(self.doc.block_trials(:,1));
            if self.doc.is_randomized == 1
                exp_order = NaN(self.doc.repetitions, num_conditions);
                for rep_ind = 1:self.doc.repetitions
                    exp_order(rep_ind,:) = randperm(num_conditions);
                end
            else
                exp_order = repmat(1:num_conditions,self.doc.repetitions,1);

            end
            
            save([experiment_folder '\Log Files\exp_order.mat'],'exp_order')
            
            parameters.exp_order = exp_order;
            parameters.experiment_folder = experiment_folder;
            
            %Make sure the run file entered exists
            if ~isfile(self.model.run_protocol_file)
                waitfor(errordlg("Please make sure you've entered a valid .m file to run the experiment."));
                return;
            end
            
            %Get function name of the script which will run the experiment
            [run_path, run_name, ext] = fileparts(self.model.run_protocol_file);
            
            %Create the full command
            run_command = run_name + "(self, parameters)";
            
            %run script
            eval(run_command);
            pause(3);
            
            
            %For some reason, if I gave the stop display and log commands
            %in the G4_default_run_protocol script, they were not received. But if I
            %place them here instead, they work. Something to look into in
            %the future.
%             Panel_com('stop_display');
%             pause(10);
% 
%             Panel_com('stop_log');
%             pause(10);
% 
%             disconnectHost;
%             pause(10);
            

            %Move the log files to the results file under the fly name
            movefile([experiment_folder '\Log Files\*'],fullfile(experiment_folder,'Results',self.model.fly_name));

                        
            if self.model.do_processing == 1 || self.model.do_plotting == 1
                self.progress_axes.Title.String = "Experiment Completed. Running post-processing.";
                drawnow;
            else
                self.progress_axes.Title.String = "Skipping post-processing.";
                drawnow;
            end
            
            %Run required post processing script that converts the TDMS
            %files into mat files.
            fly_results_folder = fullfile(experiment_folder,'Results',self.model.fly_name);

            %Always run this script
            G4_TDMS_folder2struct(fly_results_folder);

            
            %Set up trial options matrix
            
            if ~isempty(pretrial{1})
                is_pretrial = 1;
            else
                is_pretrial = 0;
            end
            if ~isempty(intertrial{1})
                is_intertrial = 1;
            else
                is_intertrial = 0;
            end
            if ~isempty(posttrial{1})
                is_posttrial = 1;
            else
                is_posttrial = 0;
            end
            trial_options = [is_pretrial, is_intertrial, is_posttrial];
            
            
            
            %Run post processing and plotting scripts if selected
            if self.model.do_processing == 1 && (strcmp(self.model.processing_file,'') || ~isfile(self.model.processing_file))
                waitfor(errordlg("Processing script was not run because the processing file could not be found. Please run manually."));
     
            elseif self.model.do_processing == 1 && isfile(self.model.processing_file)
                [proc_path, proc_name, proc_ext] = fileparts(self.model.processing_file);
                processing_command = proc_name + "(fly_results_folder, trial_options)";

                eval(processing_command);
            
            end
            
            if self.model.do_plotting == 1 && (strcmp(self.model.plotting_file,'') || ~isfile(self.model.plotting_file))
                waitfor(errordlg("Plotting script was not run because the plotting file could not be found. Please run manually."));
            elseif self.model.do_plotting == 1 && isfile(self.model.plotting_file)
                [plot_path, plot_name, plot_ext] = fileparts(self.model.plotting_file);
                plotting_command = plot_name + "(metadata.fly_results_folder, metadata.trial_options)";
                plot_file = strcat(plot_name, plot_ext);
                %Put all metadata in a struct to be passed to the
                %function which creates the pdf.
                
                metadata = struct;
                metadata.experimenter = self.model.experimenter;
                metadata.experiment_name = self.doc.experiment_name;
                metadata.experiment_protocol = self.model.run_protocol_file;
                
                %Turn experiment type (1,2, or 3) to matching word
                %("Flight", etc)
                if self.model.experiment_type == 1
                    metadata.experiment_type = "Flight";
                elseif self.model.experiment_type == 2
                    metadata.experiment_type = "Camera Walk";
                elseif self.model.experiment_type == 3
                    metadata.experiment_type = "Chip Walk";
                end
                metadata.fly_name = self.model.fly_name;
                metadata.genotype = self.model.fly_genotype;
                metadata.timestamp = self.date_and_time_box.String;
                metadata.plotting_protocol = self.model.plotting_file;
                metadata.processing_protocol = self.model.processing_file;
                if self.model.do_plotting == 1
                    metadata.do_plotting = "Yes";
                elseif self.model.do_plotting == 0
                    metadata.do_plotting = "No";
                end
                if self.model.do_processing == 1
                    metadata.do_processing = "Yes";
                elseif self.model.do_processing == 0
                    metadata.do_processing = "No";
                end

                metadata.plotting_command = plotting_command;
                metadata.fly_results_folder = fly_results_folder;
                metadata.trial_options = trial_options;
                
                
                
                %assigns the metadata struct to metadata in the base
                %workspace so publish can use it.
                assignin('base','metadata',metadata);
                assignin('base','fly_results_folder',fly_results_folder);
                assignin('base','trial_options',trial_options);


                %publishes the output (but not code) "create_pdf_script" to
                %a pdf file.
                options.codeToEvaluate = sprintf('%s(%s,%s,%s)',plot_name,'fly_results_folder','trial_options','metadata');
                options.format = 'pdf';
                options.outputDir = sprintf('%s',fly_results_folder);
                options.showCode = false;
                publish(plot_file,options);
                
                plot_filename = strcat(plot_name,'.pdf');
                new_plot_filename = strcat(self.model.fly_name,'.pdf');
                pdf_path = fullfile(fly_results_folder,plot_filename);
                new_pdf_path = fullfile(fly_results_folder,new_plot_filename);
                movefile(pdf_path, new_pdf_path);
                
                
                
            end
            
            self.progress_axes.Title.String = "Finished.";
            drawnow;

        end
        
       
        
        
        function run_test(self, src, event)
        
%             [testFilename, testFilepath] = uigetfile('*.g4p');
%             filepath = fullfile(testFilepath, testFilename);
%             
%             test_protocol_params = load(filepath, '-mat');
%             
            
   
        end
        
        function browse_run_protocol(self, src, event)
        
            [file, path] = uigetfile('*.m');
            self.model.run_protocol_file = fullfile(path,file);
            self.update_run_gui();
        
        end
        
        function browse_plot_protocol(self, src, event)
            
            [file, path] = uigetfile('*.m');
            self.model.plotting_file = fullfile(path,file);
            self.update_run_gui();
        end
        
        function browse_process_protocol(self, src, event)
            
            [file,path] = uigetfile('*.m');
            self.model.processing_file = fullfile(path,file);
            self.update_run_gui();
        end
        
        

        
        
        %SETTERS

        
        function set.model(self, value)
            self.model_ = value;
        end
        
        function set.fig(self, value)
            self.fig_ = value;
        end
        
%         function set.fly_name(self, value)
%             self.model.fly_name_ = value;
%         end
        
        function set.progress_axes(self, value)
            self.progress_axes_ = value;
        end
        
        function set.progress_bar(self, value)
            self.progress_bar_ = value;
        end
        
        function set.doc(self, value)
            self.doc_ = value;
        end
        
        function set.experimenter_box(self, value)
            self.experimenter_box_ = value;
        end
        
        function set.exp_name_box(self, value)
            self.exp_name_box_ = value;
        end
        
        function set.fly_name_box(self, value)
            self.fly_name_box_ = value;
        end
        
        function set.fly_genotype_box(self, value)
            self.fly_genotype_box_ = value;
        end
        
        function set.date_and_time_box(self, value)
            self.date_and_time_box_ = value;
        end
        
        function set.exp_type_menu(self, value)
            self.exp_type_menu_ = value;
        end
        
        function set.plotting_checkbox(self, value)
            self.plotting_checkbox_ = value;
        end
        
        function set.plotting_textbox(self, value)
            self.plotting_textbox_ = value;
        end
        
        function set.processing_checkbox(self, value)
            self.processing_checkbox_ = value;
        end
        
        function set.processing_textbox(self, value)
            self.processing_textbox_ = value;
        end
        
        function set.axes_label(self, value)
            self.axes_label_ = value;
        end
        
        function set.run_textbox(self, value)
            self.run_textbox_ = value;
        end
        
        function set.current_running_trial(self, value)
            self.current_running_trial_ = value;
        end
        
        function set.current_mode(self, value)
            self.current_mode_ = value;
        end
        
        function set.current_pat(self, value)
            self.current_pat_ = value;
        end
        
        function set.current_pos(self, value)
            self.current_pos_ = value;
        end
        
        function set.current_ao1(self, value)
            self.current_ao1_ = value;
        end
        
        function set.current_ao2(self, value)
            self.current_ao2_ = value;
        end
        
        function set.current_ao3(self, value)
            self.current_ao3_ = value;
        end
        
        function set.current_ao4(self, value)
            self.current_ao4_ = value;
        end
        
        function set.current_frInd(self, value)
            self.current_frInd_ = value;
        end
        
        function set.current_frRate(self, value)
            self.current_frRate_ = value;
        end
        
        function set.current_gain(self, value)
            self.current_gain_ = value;
        end
        
        function set.current_offset(self, value)
            self.current_offset_ = value;
        end
        
        function set.current_duration(self, value)
            self.current_duration_ = value;
        end
        
        function set.browse_button_plotting(self, value)
            self.browse_button_plotting_ = value;
        end
        
        function set.browse_button_processing(self, value)
            self.browse_button_processing_ = value;
        end
        
        function set.browse_button_run(self, value)
            self.browse_button_run_ = value;
        end
        



        %GETTERS
        
        function value = get.model(self)
           value = self.model_;
        end
        
        function value = get.fig(self)
            value = self.fig_;
        end
        
%         function value = get.fly_name(self)
%             value = self.model.fly_name_;
%         end
        
        function value = get.progress_axes(self)
            value = self.progress_axes_;
        end
        
        function value = get.progress_bar(self)
            value = self.progress_bar_;
        end
        
        function value = get.doc(self)
            value = self.doc_;
        end
        
        function value = get.experimenter_box(self)
            value = self.experimenter_box_;
        end
        
        function value = get.exp_name_box(self)
            value = self.exp_name_box_;
        end
        
        function value = get.fly_name_box(self)
            value = self.fly_name_box_;
        end
        
        function value = get.fly_genotype_box(self)
            value = self.fly_genotype_box_;
        end
        
        function value = get.date_and_time_box(self)
            value = self.date_and_time_box_;
        end
        
        function value = get.exp_type_menu(self)
            value = self.exp_type_menu_;
        end
        
        function value = get.plotting_checkbox(self)
            value = self.plotting_checkbox_;
        end
        
        function value = get.plotting_textbox(self)
            value = self.plotting_textbox_;
        end
        
        function value = get.processing_checkbox(self)
            value = self.processing_checkbox_;
        end
        
        function value = get.processing_textbox(self)
            value = self.processing_textbox_;
        end
        
        function value = get.axes_label(self)
            value = self.axes_label_;
        end
        
        function value = get.run_textbox(self)
            value = self.run_textbox_;
        end
        
        function value = get.current_running_trial(self)
            value = self.current_running_trial_;
        end
        
        function value = get.current_mode(self)
            value = self.current_mode_;
        end
        
        function value = get.current_pat(self)
            value = self.current_pat_;
        end
        
        function value = get.current_pos(self)
            value = self.current_pos_;
        end
        
        function value = get.current_ao1(self)
            value = self.current_ao1_;
        end
        
        function value = get.current_ao2(self)
            value = self.current_ao2_;
        end
        
        function value = get.current_ao3(self)
            value = self.current_ao3_;
        end
        
        function value = get.current_ao4(self)
            value = self.current_ao4_;
        end
        
        function value = get.current_frInd(self)
            value = self.current_frInd_;
        end
        
        function value = get.current_frRate(self)
            value = self.current_frRate_;
        end
        
        function value = get.current_gain(self)
            value = self.current_gain_;
        end
        
        function value = get.current_offset(self)
            value = self.current_offset_;
        end
        
        function value = get.current_duration(self)
            value = self.current_duration_;
        end
        
        function value = get.browse_button_plotting(self)
            value = self.browse_button_plotting_;
        end
        
        function value = get.browse_button_processing(self)
            value = self.browse_button_processing_;
        end
        
        function value = get.browse_button_run(self)
            value = self.browse_button_run;
        end
            

   
        
%         function [output] = get_fly_name(self)
%             output = self.model.fly_name_;
%         end
        
        
        
       
        
    end
    
    
    
end