classdef G4_conductor_view < handle
    
    properties
        con_
        
        fig_
        progress_axes_
        axes_label_
        progress_bar_
        experimenter_box_
        exp_name_box_
        fly_name_box_
        fly_genotype_box_
        date_and_time_box_
        sex_box_
        temperature_box_
        age_box_
        rearing_protocol_box_
        light_cycle_box_
        comments_box_
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
        menu_open_
        recent_file_menu_items_
        
        current_mode_text_
        current_pat_text_
        current_pos_text_
        current_ao1_text_
        current_ao2_text_
        current_ao3_text_
        current_ao4_text_
        current_frInd_text_
        current_frRate_text_
        current_gain_text_
        current_offset_text_
        current_duration_text_
        expected_time_text_
        elapsed_time_text_
        remaining_time_text_
        
    end
    
    properties (Dependent)
        con
        
        fig
        progress_axes
        axes_label
        progress_bar
        experimenter_box
        exp_name_box
        fly_name_box
        fly_genotype_box
        date_and_time_box
        sex_box
        temperature_box
        age_box
        rearing_protocol_box
        light_cycle_box
        comments_box
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
        menu_open
        recent_file_menu_items
        
        current_mode_text
        current_pat_text
        current_pos_text
        current_ao1_text
        current_ao2_text
        current_ao3_text
        current_ao4_text
        current_frInd_text
        current_frRate_text
        current_gain_text
        current_offset_text
        current_duration_text
        expected_time_text
        elapsed_time_text
        remaining_time_text
        
    end
    
    methods
        
        %% Constructor
        function self = G4_conductor_view(con)
             self.fig = figure('Name', 'Fly Experiment Conductor', 'NumberTitle', 'off', 'units','pixels','MenuBar', 'none', ...
                'ToolBar', 'none', 'Resize', 'off');
            self.con = con;
            % Layout the window
            pix = get(0, 'screensize');
           fig_size = [.25*pix(3), .25*pix(4), .5*pix(3), .5*pix(4)];
           set(self.fig,'Position',fig_size);

           menu = uimenu(self.fig, 'Text', 'File');
           self.menu_open = uimenu(menu, 'Text', 'Open');
           menu_recent_files = uimenu(self.menu_open, 'Text', '.g4p file', 'Callback', @self.open);
           %menu_settings = uimenu(menu, 'Text', 'Settings', 'Callback', @self.open_settings);
            
                
            for i = 1:length(self.con.doc.recent_g4p_files)
                [~, filename] = fileparts(self.con.doc.recent_g4p_files{i});
                self.recent_file_menu_items{i} = uimenu(self.menu_open, 'Text', filename, 'Callback', {@self.open, self.con.doc.recent_g4p_files{i}});
            end
           
            start_button = uicontrol(self.fig,'Style','pushbutton', 'String', 'Run', ...
                'units', 'pixels', 'Position', [15, fig_size(4)- 305, 115, 85],'Callback', @self.run_exp);
            abort_button = uicontrol(self.fig,'Style','pushbutton', 'String', 'Abort Experiment',...
                'units', 'pixels', 'Position', [140, fig_size(4) - 305, 115, 85], 'Callback', @self.abort);
            settings_pan = uipanel(self.fig, 'Title', 'Settings', 'FontSize', 13, 'units', 'pixels', ...
                'Position', [15, fig_size(4) - 215, 370, 200]);
            metadata_pan = uipanel(self.fig, 'Title', 'Metadata', 'units', 'pixels', ...
                'FontSize', 13, 'Position', [fig_size(3) - 300, fig_size(4) - 305, 275, 305]);
            status_pan = uipanel(self.fig, 'Title', 'Status', 'FontSize', 13, 'units', 'pixels', ...
                'Position', [15, 15, fig_size(3) - 30, fig_size(4)*.2]); 
            open_google_sheet_button = uicontrol(self.fig, 'Style', 'pushbutton', 'String', 'Open Metadata Google Sheet', ...
                'units', 'pixels', 'Position', [metadata_pan.Position(1), metadata_pan.Position(2) - 30,...
                150, 25],'Callback', @self.open_gs);
            
            %Labels for status update showing current trial parameters
            current_trial = uicontrol(status_pan, 'Style', 'text', 'String', 'Current Trial:', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [0, 45, 70, 15]); 
            
            mode_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Mode', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [current_trial.Position(1) + current_trial.Position(3) + 5, current_trial.Position(2) + 25, 50, 15]);
            
            pat_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Pattern', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [mode_label.Position(1) + mode_label.Position(3) + 10, ...
                current_trial.Position(2) + 25, 50, 15]);
            
            pos_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Position', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [pat_label.Position(1) + pat_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);
            
            ao1_label = uicontrol(status_pan, 'Style', 'text', 'String', 'AO1', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [pos_label.Position(1) + pos_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);
            
            ao2_label = uicontrol(status_pan, 'Style', 'text', 'String', 'AO2', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [ao1_label.Position(1) + ao1_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);
            
            ao3_label = uicontrol(status_pan, 'Style', 'text', 'String', 'AO3', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [ao2_label.Position(1) + ao2_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);
            
            ao4_label = uicontrol(status_pan, 'Style', 'text', 'String', 'AO4', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [ao3_label.Position(1) + ao3_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);
            
            frameInd_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Fr. Index', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [ao4_label.Position(1) + ao4_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);
            
            frRate_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Fr. Rate', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [frameInd_label.Position(1) + frameInd_label.Position(3) + 10, current_trial.Position(2) + 25,50, 15]);
            
            gain_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Gain', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [frRate_label.Position(1) + frRate_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);
            
            off_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Offset', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [gain_label.Position(1) + gain_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);
            
            dur_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Duration', 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [off_label.Position(1) + off_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);
            
            exp_time_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Expected Experiment Length:', 'FontSize', ...
                10.5, 'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [0, 5, 200, 20]);
            
            elapsed_time_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Elapsed Time:', 'FontSize', ...
                10.5, 'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', [350, 5, 100, 20]);
            
            remaining_time_label = uicontrol(status_pan, 'Style', 'text', 'String', 'Remaining Time:', 'FontSize', ...
                10.5, 'HorizontalAlignment', 'center', 'units', 'pixels','Position', [590, 5, 120, 20]);
            
            
            %Parameter values in status panel which change with every trial
            
            self.current_mode_text =  uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_mode, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position',...
                [mode_label.Position(1) + 5, current_trial.Position(2), mode_label.Position(3) - 10, 15]);
            self.current_pat_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_pat, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [pat_label.Position(1) + 5, current_trial.Position(2), pat_label.Position(3) - 10, 15]);
            self.current_pos_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_pos, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [pos_label.Position(1) + 5, current_trial.Position(2), pos_label.Position(3) - 10, 15]);
            self.current_ao1_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_ao1, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [ao1_label.Position(1) + 5, current_trial.Position(2), ao1_label.Position(3) - 10, 15]);
            self.current_ao2_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_ao2, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [ao2_label.Position(1) + 5, current_trial.Position(2), ao2_label.Position(3) - 10, 15]);
            self.current_ao3_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_ao3, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [ao3_label.Position(1) + 5, current_trial.Position(2), ao3_label.Position(3) - 10, 15]);
            self.current_ao4_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_ao4, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [ao4_label.Position(1) + 5, current_trial.Position(2), ao4_label.Position(3) - 10, 15]);
             self.current_frInd_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_frInd, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [frameInd_label.Position(1) + 5, current_trial.Position(2), frameInd_label.Position(3) - 10, 15]);
            self.current_frRate_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_frRate, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [frRate_label.Position(1) + 5, current_trial.Position(2), frRate_label.Position(3) - 10, 15]);
            self.current_gain_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_gain, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [gain_label.Position(1) + 5, current_trial.Position(2), gain_label.Position(3) - 10, 15]);
            self.current_offset_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_offset, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [off_label.Position(1) + 5, current_trial.Position(2), off_label.Position(3) - 10, 15]);
            self.current_duration_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.current_duration, 'FontSize', 10.5, ...
                'HorizontalAlignment', 'center', 'units', 'pixels', 'Position', ...
                [dur_label.Position(1) + 5, current_trial.Position(2), dur_label.Position(3) - 10, 15]);
            self.expected_time_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.model.expected_time, 'FontSize', ...
                10.5, 'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', ...
                [exp_time_label.Position(1) + exp_time_label.Position(3) + 10, 5, 120, 20]);
            self.elapsed_time_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.elapsed_time, 'FontSize', ...
                10.5, 'HorizontalAlignment', 'left', 'Units', 'pixels', 'Position', ...
                [elapsed_time_label.Position(1) + elapsed_time_label.Position(3) + 10, 5, 120, 20]);
            self.remaining_time_text = uicontrol(status_pan, 'Style', 'text', 'String', self.con.remaining_time, 'FontSize', ...
                10.5, 'HorizontalAlignment', 'left', 'Units', 'pixels', 'Position', ...
                [remaining_time_label.Position(1) + remaining_time_label.Position(3) + 10, 5, 120, 20]);
            
            self.progress_axes = axes(self.fig, 'units','pixels', 'Position', [15, fig_size(4)*.2+30, fig_size(3) - 30 ,50]);
            self.axes_label = uicontrol(self.fig, 'Style', 'text', 'String', 'Progress:', 'FontSize', 13, ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [15, fig_size(4)*.2 + 85, 100, 20]);
            self.progress_bar = barh(0, 'Parent', self.progress_axes,'BaseValue', 0);
            self.progress_axes.XAxis.Limits = [0 1];
            self.progress_axes.YTickLabel = [];
            self.progress_axes.XTickLabel = [];
            self.progress_axes.XTick = [];
            self.progress_axes.YTick = [];
            reps = self.con.doc.repetitions;
            total_steps = self.con.doc.repetitions * length(self.con.doc.block_trials(:,1));
            if ~isempty(self.con.doc.intertrial{1})
                total_steps = total_steps + ((length(self.con.doc.block_trials(:,1)) - 1)*reps);
            end
           
            if ~isempty(self.con.doc.pretrial{1})
                total_steps = total_steps + 1;
            end
            if ~isempty(self.con.doc.posttrial{1})
                total_steps = total_steps + 1;
            end
            for i = 1:reps
                x = (i/reps);% + 1/total_steps;
                line('XData', [x, x], 'YDATA', [0,2]);
            end
            
            
            metadata_label_position = [10, metadata_pan.Position(4) - 45, 100, 15];
            metadata_box_position = [115, metadata_pan.Position(4) - 45, 150, 18];
            %Settings required from user
            experimenter_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Experimenter:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', metadata_label_position);
            
           self.experimenter_box = uicontrol(metadata_pan, 'Style', 'popupmenu', 'String', self.con.model.metadata_options.experimenter, ...
               'Value', 1, 'Position', metadata_box_position, 'Callback', @self.new_experimenter);

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;
            
            exp_name_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Experiment Name:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', metadata_label_position);
            
            self.exp_name_box = uicontrol(metadata_pan, 'Style', 'edit', 'String', self.con.doc.experiment_name, 'units', 'pixels', 'Position', ...
                metadata_box_position, 'Callback', @self.new_experiment_name);
            
            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;
            
            fly_name_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Fly Name:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', metadata_label_position);
            self.fly_name_box = uicontrol(metadata_pan, 'Style', 'edit', 'String', self.con.model.fly_name, ...
                'units', 'pixels', 'Position', metadata_box_position, 'Callback', @self.new_fly_name);
            
            
            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;
            
            fly_genotype_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Fly Genotype', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', metadata_label_position);
            
            self.fly_genotype_box = uicontrol(metadata_pan, 'Style', 'popupmenu', 'units', 'pixels', 'Value', 1, ...
                'String', self.con.model.metadata_options.fly_geno, 'Position', metadata_box_position, 'Callback', @self.new_genotype);
            
            
            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;
            
            fly_age_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Fly Age:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', metadata_label_position);
            self.age_box = uicontrol(metadata_pan, 'Style', 'popupmenu', 'units', 'pixels', 'Value', 1, ...
                'String', self.con.model.metadata_options.fly_age, 'Position', metadata_box_position, 'Callback', @self.new_age);
            
            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;
            
            fly_sex_label =  uicontrol(metadata_pan, 'Style', 'text', 'String', 'Fly Sex:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', metadata_label_position);
            self.sex_box = uicontrol(metadata_pan, 'Style', 'popupmenu', 'units', 'pixels', 'Value', 1, ...
                'String', self.con.model.metadata_options.fly_sex, 'Position', metadata_box_position, 'Callback', @self.new_sex);
            
            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;
            
            experiment_temp_label =  uicontrol(metadata_pan, 'Style', 'text', 'String', 'Experiment Temp:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', metadata_label_position);
            self.temperature_box = uicontrol(metadata_pan, 'Style', 'popupmenu', 'units', 'pixels', 'Value', 1, ...
                'String', self.con.model.metadata_options.exp_temp, 'Position', metadata_box_position, 'Callback', @self.new_temp);
            
            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;
            
            rearing_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Rearing Protocol:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', metadata_label_position);
            
            self.rearing_protocol_box = uicontrol(metadata_pan, 'Style', 'popupmenu', 'Value', 1, 'units', 'pixels', ...
                'String', self.con.model.metadata_options.rearing, 'Position', metadata_box_position, 'Callback', @self.new_rearing);
            
            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;
            
            lightCycle_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Light Cycle:', ...
                'HorizontalAlignment', 'left', 'Units', 'pixels', 'Position', metadata_label_position);
            
            self.light_cycle_box = uicontrol(metadata_pan, 'Style', 'popupmenu', 'Value', 1, 'units', 'pixels', ...
                'String', self.con.model.metadata_options.light_cycle, 'Position', metadata_box_position, 'Callback', @self.new_light_cycle);
            
            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;
            
            
            date_and_time_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Date and Time:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', metadata_label_position);
            self.date_and_time_box = uicontrol(metadata_pan, 'Style', 'edit', 'String', datestr(now, 'mm-dd-yyyy HH:MM:SS'), ...
                'units', 'pixels', 'Position', metadata_box_position);
            
            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;
            
            comments_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Comments:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', metadata_label_position);
            self.comments_box = uicontrol(metadata_pan, 'Style', 'edit', 'String', self.con.model.metadata_comments, ...
                'units', 'pixels', 'Position', metadata_box_position, 'Callback', @self.new_comments);

            exp_type_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Experiment Type:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 150, 100, 15]);
            self.exp_type_menu = uicontrol(settings_pan, 'Style', 'popupmenu', 'String', {'Flight','Camera walk', 'Chip walk'}, ...
                'units', 'pixels', 'Position', [115, 150, 150, 18], 'Callback', @self.new_experiment_type);
            test_button = uicontrol(settings_pan, 'Style', 'pushbutton', 'String', 'Run Test Protocol', ...
                'units', 'pixels', 'Position', [210, 120, 150, 20], 'Callback', @self.run_test_exp);
            plotting_checkbox_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Plotting?', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 120, 45, 15]);
            self.plotting_checkbox = uicontrol(settings_pan, 'Style', 'checkbox', 'Value', self.con.model.do_plotting, ...
                'units', 'pixels', 'Position', [60, 120, 15, 15], 'Callback', @self.new_do_plotting);
            plotting_filename_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Plotting Protocol:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 95, 105, 15]);
            self.plotting_textbox = uicontrol(settings_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.con.model.plotting_file, 'Position', [120, 95, 160, 18], 'Callback', @self.new_plotting_file);
            self.browse_button_plotting = uicontrol(settings_pan, 'Style', 'pushbutton', 'units', 'pixels', ...
                'String', 'Browse', 'Position', [285, 95, 65, 18], 'Callback', @self.plot_browse);
            
            processing_checkbox_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Processing?', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [90, 120, 65, 15]);
            self.processing_checkbox = uicontrol(settings_pan, 'Style', 'checkbox', 'Value', self.con.model.do_processing, ...
                'units', 'pixels', 'Position', [160, 120, 15, 15], 'Callback', @self.new_do_processing);
            processing_filename_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Processing Protocol:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 70, 105, 15]);
            self.processing_textbox = uicontrol(settings_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.con.model.processing_file, 'Position', [120, 70, 160, 18], 'Callback', @self.new_processing_file);
            self.browse_button_processing = uicontrol(settings_pan, 'Style', 'pushbutton', 'units', 'pixels', ...
                'String', 'Browse', 'Position', [285, 70, 65, 18], 'Callback', @self.proc_browse);
            
            run_filename_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Run Protocol:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 45, 105, 15]);
            self.run_textbox = uicontrol(settings_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.con.model.run_protocol_file, 'Position', [80, 45, 200, 18]);
            self.browse_button_run = uicontrol(settings_pan, 'Style', 'pushbutton', 'units', 'pixels', ...
                'String', 'Browse', 'Position', [285, 45, 65, 18], 'Callback', @self.run_browse);
            
            
            self.update_run_gui();
        end
        
        function update_run_gui(self)
           
            self.experimenter_box.Value = find(strcmp(self.con.model.metadata_options.experimenter,self.con.model.experimenter));
            self.exp_name_box.String = self.con.doc.experiment_name;
            self.fly_name_box.String = self.con.model.fly_name;
            self.fly_genotype_box.Value = find(strcmp(self.con.model.metadata_options.fly_geno,self.con.model.fly_genotype));
            self.date_and_time_box.String = datestr(now, 'mm-dd-yyyy HH:MM:SS');
            self.age_box.Value = find(strcmp(self.con.model.metadata_options.fly_age,self.con.model.fly_age));
            self.sex_box.Value = find(strcmp(self.con.model.metadata_options.fly_sex, self.con.model.fly_sex));
            self.temperature_box.Value = find(strcmp(self.con.model.metadata_options.exp_temp, self.con.model.experiment_temp));
            self.rearing_protocol_box.Value = find(strcmp(self.con.model.metadata_options.rearing, self.con.model.rearing_protocol));
            self.light_cycle_box.Value = find(strcmp(self.con.model.metadata_options.light_cycle, self.con.model.light_cycle));
            self.comments_box.String = self.con.model.metadata_comments;
            self.plotting_checkbox.Value = self.con.model.do_plotting;
            self.plotting_textbox.String = self.con.model.plotting_file;
            self.processing_checkbox.Value = self.con.model.do_processing;
            self.processing_textbox.String = self.con.model.processing_file;
            self.exp_type_menu.Value = self.con.model.experiment_type;
            self.run_textbox.String = self.con.model.run_protocol_file;
            self.set_expected_time();
            self.set_elapsed_time();
            self.set_remaining_time();
            self.current_mode_text.String = self.con.current_mode;
            self.current_pat_text.String = self.con.current_pat;
            self.current_pos_text.String = self.con.current_pos;
            self.current_ao1_text.String = self.con.current_ao1;
            self.current_ao2_text.String = self.con.current_ao2;
            self.current_ao3_text.String = self.con.current_ao3;
            self.current_ao4_text.String = self.con.current_ao4;
            self.current_frInd_text.String = self.con.current_frInd;
            self.current_frRate_text.String = self.con.current_frRate;
            self.current_gain_text.String = self.con.current_gain;
            self.current_offset_text.String = self.con.current_offset;
            self.current_duration_text.String = self.con.current_duration;
            self.set_recent_file_menu_items();
            
        end
        
        %% Callbacks
        % Most callback functions take the new value and send it to the
        % controller's update function. The controller will do any necessary
        % error checking, set the model or doc appropriately, then
        % the view will update itself.
        
         function new_fly_name(self, src, ~)

            self.con.update_fly_name(src.String);
            self.update_run_gui();
            
         end
        
        function new_experimenter(self, src, ~)

            self.con.update_experimenter(src.Value);
            self.update_run_gui();
            
        end
        
        function new_experiment_name(self, src, ~)
            
            self.con.update_experiment_name(src.String)
            self.update_run_gui();
        end
        
        function new_genotype(self, src, ~)
            
            self.con.update_genotype(src.Value)
            self.update_run_gui();
            
        end
        
        function new_do_plotting(self, src, ~)
            
            self.con.update_do_plotting(src.Value);
            self.update_run_gui();
            
        end
        
        function new_do_processing(self, src, ~)
            
            self.con.update_do_processing(src.Value);
            self.update_run_gui();
            
        end
        
        function new_plotting_file(self, src, ~)
            
            self.con.update_plotting_file(src.String);
            self.update_run_gui();
            
        end
        
        function new_processing_file(self, src, ~)
            
            self.con.update_processing_file(src.String);
            self.update_run_gui();
            
        end
        
        function new_experiment_type(self, src, ~)
            
            self.con.update_experiment_type(src.Value);
            self.update_run_gui();
            
        end
        function new_age(self, src, ~)
            
            self.con.update_age(src.Value)
            self.update_run_gui();
            
        end
        function new_sex(self, src, ~)
            
            self.con.update_sex(src.Value);
            self.update_run_gui();
            
        end
        
        function new_temp(self, src, ~)
            
            self.con.update_temp(src.Value);
            self.update_run_gui();
            
        end
        
        function new_rearing(self, src, ~)
            
            self.con.update_rearing(src.Value);
            self.update_run_gui();
            
        end
        
        function new_light_cycle(self, src, ~)
            
            self.con.update_light_cycle(src.Value);
            self.update_run_gui();
            
        end
        
        function new_comments(self, src, ~)
            
            self.con.update_comments(src.String);
            self.update_run_gui();
        end
        
        function open(self, ~, ~, filepath)
           
            self.con.open_g4p_file(filepath);
            self.update_run_gui();
            
        end
        
        function open_gs(self, ~, ~)
            self.con.open_google_sheet();
        end
        
        function abort(self, ~, ~)
            self.con.abort_experiment();
        end
        
        function run_exp(self, ~, ~)
            self.con.run();
        end
        
        function run_test_exp(self, ~, ~)
            self.con.run_test();
        end
        
        function run_browse(self, ~, ~)
           
            self.con.browse_file('run');
            self.update_run_gui();
            
        end
        
        function plot_browse(self, ~, ~)
            
            self.con.browse_file('plot');
            self.update_run_gui();
        end
        
        function proc_browse(self, ~, ~)
            
            self.con.browse_file('proc');
            self.update_run_gui();
            
        end
        
        function update_progress_bar(self, trial_type, data, varargin)

            if strcmp(trial_type, 'pre')
                
                self.progress_axes.Title.String = "Running Pretrial...";
                self.progress_bar.YData = data;
                
            elseif strcmp(trial_type, 'block')
                
                rep = varargin{1};
                reps = varargin{2};
                trial = varargin{3};
                trials = varargin{4};
                cond = varargin{5};
                self.progress_axes.Title.String = "Rep " + rep + " of " + reps +...
                    ", Trial " + trial + " of " + trials + ". Condition number: " + cond;
                self.progress_bar.YData = data;
                
            elseif strcmp(trial_type, 'inter')
                
                rep = varargin{1};
                reps = varargin{2};
                trial = varargin{3};
                trials = varargin{4};

                self.progress_axes.Title.String = "Rep " + rep + " of " + reps +...
                    ", Trial " + trial + " of " + trials + ": Running Intertrial..."; 
                self.progress_bar.YData = data; 
                
            elseif strcmp(trial_type, 'post')
                
                self.progress_axes.Title.String = "Running Posttrial...";
                self.progress_bar.YData = data; 
                %update using post text
            else
                disp("I can't update the progress bar.");
            end
            
            drawnow;
            
        end
        
        function set_progress_title(self, text)
           
            self.progress_axes.Title.String = text;
            
        end
        
        function set_recent_file_menu_items(self)
             for i = 1:length(self.con.doc.recent_g4p_files)
                 [path,filename] = fileparts(self.con.doc.recent_g4p_files{i});
                 if i > length(self.recent_file_menu_items)
                     self.recent_file_menu_items{end + 1} = uimenu(self.menu_open, 'Text', filename, 'MenuSelectedFcn', {@self.open, self.con.doc.recent_g4p_files{i}});
                 else
                
                    set(self.recent_file_menu_items{i},'Text',filename);
                    set(self.recent_file_menu_items{i}, 'MenuSelectedFcn', {@self.open, self.con.doc.recent_g4p_files{i}});
                 end

             end
        end
        
        function [text] = convert_time_format(self, time_in_s)
            
           mins = floor(time_in_s/60);
           secs = rem(time_in_s, 60);
           text = mins + "m " + secs + "s ";
           
        end
        
        function set_expected_time(self)
            
           text = self.convert_time_format(self.con.model.expected_time);
           self.expected_time_text.String = text;
            
        end
        
        function set_elapsed_time(self)
            
            text = self.convert_time_format(self.con.elapsed_time);
            self.elapsed_time_text.String = text;
            
        end
        
        function set_remaining_time(self)
            
            text = self.convert_time_format(self.con.remaining_time);
            self.remaining_time_text.String = text;
            
        end

        %% Getters
        
        function output = get.comments_box(self)
            output = self.comments_box_;
        end
        
        function output = get.light_cycle_box(self)
            output = self.light_cycle_box_;
        end
        
        function output = get.sex_box(self)
            output = self.sex_box_;
        end
        function output = get.temperature_box(self)
            output = self.temperature_box_;
        end
        function output = get.age_box(self)
            output = self.age_box_;
        end
        function output = get.rearing_protocol_box(self)
            output = self.rearing_protocol_box_;
        end
        
        function value = get.browse_button_plotting(self)
            value = self.browse_button_plotting_;
        end
        
        function value = get.browse_button_processing(self)
            value = self.browse_button_processing_;
        end
        
        function value = get.browse_button_run(self)
            value = self.browse_button_run_;
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
        
        function value = get.progress_axes(self)
            value = self.progress_axes_;
        end
        
        function value = get.progress_bar(self)
            value = self.progress_bar_;
        end
        
        function value = get.fig(self)
            value = self.fig_;
        end
        
        function value = get.current_mode_text(self)
            value = self.current_mode_text_;
        end
        
        function value = get.current_pat_text(self)
            value = self.current_pat_text_;
        end
        
        function value = get.current_pos_text(self)
            value = self.current_pos_text_;
        end
        
        function value = get.current_ao1_text(self)
            value = self.current_ao1_text_;
        end
        
        function value = get.current_ao2_text(self)
            value = self.current_ao2_text_;
        end
        
        function value = get.current_ao3_text(self)
            value = self.current_ao3_text_;
        end
        
        function value = get.current_ao4_text(self)
            value = self.current_ao4_text_;
        end
        
        function value = get.current_frInd_text(self)
            value = self.current_frInd_text_;
        end
        
        function value = get.current_frRate_text(self)
            value = self.current_frRate_text_;
        end
        
        function value = get.current_gain_text(self)
            value = self.current_gain_text_;
        end
        
        function value = get.current_offset_text(self)
            value = self.current_offset_text_;
        end
        
        function value = get.current_duration_text(self)
            value = self.current_duration_text_;
        end
        
        function value = get.menu_open(self)
            value = self.menu_open_;
        end
        
        function value = get.con(self)
            value = self.con_;
        end
        
        function value = get.expected_time_text(self)
            value = self.expected_time_text_;
        end
        
        function value = get.elapsed_time_text(self)
            value = self.elapsed_time_text_;
        end
        
        function value = get.remaining_time_text(self)
            value = self.remaining_time_text_;
        end
        
        function value = get.recent_file_menu_items(self)
             value = self.recent_file_menu_items_;
        end
        
        %% Setters
        
        function set.comments_box(self, value)
            self.comments_box_ = value;
        end
        
        function set.light_cycle_box(self, value)
            self.light_cycle_box_ = value;
        end
        function set.sex_box(self, value)
            self.sex_box_ = value;
        end
        function set.temperature_box(self, value)
            self.temperature_box_ = value;
        end
        
        function set.age_box(self, value)
            self.age_box_ = value;
        end
        
        function set.rearing_protocol_box(self, value)
            self.rearing_protocol_box_ = value;
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
        
        function set.progress_axes(self, value)
            self.progress_axes_ = value;
        end
        
        function set.progress_bar(self, value)
            self.progress_bar_ = value;
        end
        
        function set.fig(self, value)
            self.fig_ = value;
        end
        
        function set.current_mode_text(self, value)
            self.current_mode_text_ = value;
        end
        
        function set.current_pat_text(self, value)
            self.current_pat_text_ = value;
        end
        
        function set.current_pos_text(self, value)
            self.current_pos_text_ = value;
        end
        
        function set.current_ao1_text(self, value)
            self.current_ao1_text_ = value;
        end
        
        function set.current_ao2_text(self, value)
            self.current_ao2_text_ = value;
        end
        
        function set.current_ao3_text(self, value)
            self.current_ao3_text_ = value;
        end
        
        function set.current_ao4_text(self, value)
            self.current_ao4_text_ = value;
        end
        
        function set.current_frInd_text(self, value)
            self.current_frInd_text_ = value;
        end
        
        function set.current_frRate_text(self, value)
            self.current_frRate_text_ = value;
        end
        
        function set.current_gain_text(self, value)
            self.current_gain_text_ = value;
        end
        
        function set.current_offset_text(self, value)
            self.current_offset_text_ = value;
        end
        
        function set.current_duration_text(self, value)
            self.current_duration_text_ = value;
        end
        
        function set.menu_open(self, value)
            self.menu_open_ = value;
        end
        
        function set.con(self, value)
            self.con_ = value;
        end

        function set.expected_time_text(self, value)
            self.expected_time_text_ = value;
        end
        
        function set.elapsed_time_text(self, value)
            self.elapsed_time_text_ = value;
        end
        
        function set.remaining_time_text(self, value)
            self.remaining_time_text_ = value;
        end
        
        function set.recent_file_menu_items(self, value)
             self.recent_file_menu_items_ = value;
        end
        
        
    end
    
    
end
    