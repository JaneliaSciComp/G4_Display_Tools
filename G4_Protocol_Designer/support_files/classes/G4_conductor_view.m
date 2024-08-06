classdef G4_conductor_view < handle

    properties

        con
        fig
        fig_size
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
        run_dropDown
        num_attempts_textbox
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

        wbf_alert_text
        alignment_alert_text
        fly_position_line
        bad_trial_markers
        combine_tdms_checkbox
        convert_tdms_checkbox
        menu_config
    end

    methods

        %% Constructor
        function self = G4_conductor_view(con)
            self.fig = uifigure('Name', 'Fly Experiment Conductor', 'NumberTitle', 'off', 'units','pixels','MenuBar', 'none', ...
                'ToolBar', 'none', 'Resize', 'off', 'CloseRequestFcn', @self.close_application);
            set(self.fig, 'HandleVisibility', 'callback');
            self.con = con;
            % Layout the window
            pix = get(0, 'screensize');
            self.fig_size = [.1*pix(3), .1*pix(4), .85*pix(3), .65*pix(4)];
            set(self.fig,'Position',self.fig_size);

            menu = uimenu(self.fig, 'Text', 'File');
            self.menu_open = uimenu(menu, 'Text', 'Open');
            menu_recent_files = uimenu(self.menu_open, 'Text', '.g4p file', 'Callback', @self.open);
            %menu_settings = uimenu(menu, 'Text', 'Settings', 'Callback', @self.open_settings);
            self.menu_config = uimenu(menu, 'Text', 'Update Config File', 'Callback', @self.update_config_file);

            for i = 1:length(self.con.doc.recent_g4p_files)
                [~, filename] = fileparts(self.con.doc.recent_g4p_files{i});
                self.recent_file_menu_items{i} = uimenu(self.menu_open, 'Text', filename, 'Callback', {@self.open, self.con.doc.recent_g4p_files{i}});
            end

            start_button = uibutton(self.fig, 'Text', 'Run', 'Position', ...
                [15, self.fig_size(4)- 305, 115, 85],'ButtonPushedFcn', @self.run_exp);

            abort_button = uibutton(self.fig, 'Text', 'Abort Experiment', 'Position', ...
                [140, self.fig_size(4) - 305, 115, 85], 'ButtonPushedFcn', @self.abort);

            pause_button = uibutton(self.fig, 'state', 'Text', 'Pause',  'Position', ...
                [265, self.fig_size(4) - 305, 115, 85], 'ValueChangedFcn', @self.pause);

            end_button = uibutton(self.fig,  'Text', 'End Experiment', ...
                 'Position', [390, self.fig_size(4) - 305, 115, 85], 'ButtonPushedFcn', @self.end_early);

            settings_pan = uipanel(self.fig, 'Title', 'Settings', 'FontSize', 13, 'units', 'pixels', ...
                'Position', [15, self.fig_size(4) - 215, 415, 200]);
            metadata_pan = uipanel(self.fig, 'Title', 'Metadata', 'units', 'pixels', ...
                'FontSize', 13, 'Position', [settings_pan.Position(1) + settings_pan.Position(3) + 180, self.fig_size(4) - 305, 275, 305]);
            status_pan = uipanel(self.fig, 'Title', 'Status', 'FontSize', 13, 'units', 'pixels', ...
                'Position', [settings_pan.Position(1), self.fig_size(4)*.05, metadata_pan.Position(1) + metadata_pan.Position(3), self.fig_size(4)*.2]);
            open_google_sheet_button = uibutton(self.fig, 'Text', 'Open Metadata Google Sheet', ...
                'Position', [metadata_pan.Position(1), metadata_pan.Position(2) - 30,...
                180, 25],'ButtonPushedFcn', @self.open_gs);

            %Labels for status update showing current trial parameters
            current_trial = uilabel(status_pan, 'Text', 'Current Trial:', 'FontSize', 10.5, ...
                 'Position', [0, 50, 70, 15]);

            mode_label = uilabel(status_pan, 'Text', 'Mode', 'FontSize', 10.5, 'Position', ...
                [current_trial.Position(1) + current_trial.Position(3) + 5, current_trial.Position(2) + 25, 50, 15]);

            pat_label = uilabel(status_pan, 'Text', 'Pattern', 'FontSize', 10.5, 'Position', ...
                [mode_label.Position(1) + mode_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);

            pos_label = uilabel(status_pan, 'Text', 'Position', 'FontSize', 10.5, 'Position', ...
                [pat_label.Position(1) + pat_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);

            ao1_label = uilabel(status_pan, 'Text', 'AO2', 'FontSize', 10.5, 'Position', ...
                [pos_label.Position(1) + pos_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);

            ao2_label = uilabel(status_pan, 'Text', 'AO3', 'FontSize', 10.5, 'Position', ...
                [ao1_label.Position(1) + ao1_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);

            ao3_label = uilabel(status_pan, 'Text', 'AO4', 'FontSize', 10.5, 'Position', ...
                [ao2_label.Position(1) + ao2_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);

            ao4_label = uilabel(status_pan, 'Text', 'AO5', 'FontSize', 10.5, 'Position', ...
                [ao3_label.Position(1) + ao3_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);

            frameInd_label = uilabel(status_pan, 'Text', 'Fr. Index', 'FontSize', 10.5, 'Position', ...
                [ao4_label.Position(1) + ao4_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);

            frRate_label = uilabel(status_pan, 'Text', 'Fr. Rate', 'FontSize', 10.5, 'Position', ...
                [frameInd_label.Position(1) + frameInd_label.Position(3) + 10, current_trial.Position(2) + 25,50, 15]);

            gain_label = uilabel(status_pan, 'Text', 'Gain', 'FontSize', 10.5, 'Position', ...
                [frRate_label.Position(1) + frRate_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);

            off_label = uilabel(status_pan, 'Text', 'Offset', 'FontSize', 10.5, 'Position', ...
                [gain_label.Position(1) + gain_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);

            dur_label = uilabel(status_pan, 'Text', 'Duration', 'FontSize', 10.5, 'Position', ...
                [off_label.Position(1) + off_label.Position(3) + 10, current_trial.Position(2) + 25, 50, 15]);

            exp_time_label = uilabel(status_pan, 'Text', 'Expected Experiment Length:', 'FontSize', ...
                10.5, 'Position', [0, 5, 200, 20]);

            elapsed_time_label = uilabel(status_pan, 'Text', 'Elapsed Time:', 'FontSize', ...
                10.5, 'Position', [350, 5, 100, 20]);

            remaining_time_label = uilabel(status_pan, 'Text', 'Remaining Time:', 'FontSize', ...
                10.5, 'Position', [590, 5, 120, 20]);


            %Parameter values in status panel which change with every trial

            self.current_mode_text =  uilabel(status_pan, 'Text', self.con.current_mode, 'FontSize', 10.5, 'Position',...
                [mode_label.Position(1) + 5, current_trial.Position(2), mode_label.Position(3) - 10, 15]);
            self.current_pat_text = uilabel(status_pan, 'Text', self.con.current_pat, 'FontSize', 10.5, 'Position', ...
                [pat_label.Position(1) + 5, current_trial.Position(2), pat_label.Position(3) - 10, 15]);
            self.current_pos_text = uilabel(status_pan, 'Text', self.con.current_pos, 'FontSize', 10.5, 'Position', ...
                [pos_label.Position(1) + 5, current_trial.Position(2), pos_label.Position(3) - 10, 15]);
            self.current_ao1_text = uilabel(status_pan, 'Text', self.con.current_ao1, 'FontSize', 10.5, 'Position', ...
                [ao1_label.Position(1) + 5, current_trial.Position(2), ao1_label.Position(3) - 10, 15]);
            self.current_ao2_text = uilabel(status_pan, 'Text', self.con.current_ao2, 'FontSize', 10.5, 'Position', ...
                [ao2_label.Position(1) + 5, current_trial.Position(2), ao2_label.Position(3) - 10, 15]);
            self.current_ao3_text = uilabel(status_pan, 'Text', self.con.current_ao3, 'FontSize', 10.5, 'Position', ...
                [ao3_label.Position(1) + 5, current_trial.Position(2), ao3_label.Position(3) - 10, 15]);
            self.current_ao4_text = uilabel(status_pan, 'Text', self.con.current_ao4, 'FontSize', 10.5, 'Position', ...
                [ao4_label.Position(1) + 5, current_trial.Position(2), ao4_label.Position(3) - 10, 15]);
            self.current_frInd_text = uilabel(status_pan, 'Text', self.con.current_frInd, 'FontSize', 10.5, 'Position', ...
                [frameInd_label.Position(1) + 5, current_trial.Position(2), frameInd_label.Position(3) - 10, 15]);
            self.current_frRate_text = uilabel(status_pan, 'Text', self.con.current_frRate, 'FontSize', 10.5, 'Position', ...
                [frRate_label.Position(1) + 5, current_trial.Position(2), frRate_label.Position(3) - 10, 15]);
            self.current_gain_text = uilabel(status_pan, 'Text', self.con.current_gain, 'FontSize', 10.5, 'Position', ...
                [gain_label.Position(1) + 5, current_trial.Position(2), gain_label.Position(3) - 10, 15]);
            self.current_offset_text = uilabel(status_pan, 'Text', self.con.current_offset, 'FontSize', 10.5, 'Position', ...
                [off_label.Position(1) + 5, current_trial.Position(2), off_label.Position(3) - 10, 15]);
            self.current_duration_text = uilabel(status_pan, 'Text', self.con.current_duration, 'FontSize', 10.5, 'Position', ...
                [dur_label.Position(1) + 5, current_trial.Position(2), dur_label.Position(3) - 10, 15]);
            self.expected_time_text = uilabel(status_pan, 'Text', num2str(self.con.model.expected_time), 'FontSize', 10.5, 'Position', ...
                [exp_time_label.Position(1) + exp_time_label.Position(3) + 10, 5, 120, 20]);
            self.elapsed_time_text = uilabel(status_pan, 'Text', num2str(self.con.elapsed_time), 'FontSize', 10.5, 'Position', ...
                [elapsed_time_label.Position(1) + elapsed_time_label.Position(3) + 10, 5, 120, 20]);
            self.remaining_time_text = uilabel(status_pan, 'Text', num2str(self.con.remaining_time), 'FontSize', 10.5, 'Position', ...
                [remaining_time_label.Position(1) + remaining_time_label.Position(3) + 10, 5, 120, 20]);

            %Progress bar items
            self.progress_axes = axes(self.fig, 'units','pixels', 'Position', [15, status_pan.Position(2) + status_pan.Position(4) + 15, status_pan.Position(3) ,50]);
            self.axes_label = uilabel(self.fig, 'Text', 'Progress:', 'FontSize', 13, 'Position', ...
                [15, self.progress_axes.Position(2) + self.progress_axes.Position(4) + 10, 100, 20]);
            self.progress_bar = barh(0, 'Parent', self.progress_axes,'BaseValue', 0);
            self.progress_axes.XAxis.Limits = [0 1];
            self.progress_axes.YTickLabel = [];
            self.progress_axes.XTickLabel = [];
            self.progress_axes.XTick = [];
            self.progress_axes.YTick = [];
            self.set_repetition_lines();
            % reps = self.con.doc.repetitions;
            % total_steps = self.con.doc.repetitions * length(self.con.doc.block_trials(:,1));
            % if ~isempty(self.con.doc.intertrial{1})
            %     total_steps = total_steps + ((length(self.con.doc.block_trials(:,1)) - 1)*reps);
            % end
            % 
            % if ~isempty(self.con.doc.pretrial{1})
            %     total_steps = total_steps + 1;
            % end
            % if ~isempty(self.con.doc.posttrial{1})
            %     total_steps = total_steps + 1;
            % end
            % for i = 1:reps
            %     x = (i/reps);% + 1/total_steps;
            %     line('XData', [x, x], 'YDATA', [0,2]);
            % end

            %Metadata
            metadata_label_position = [10, metadata_pan.Position(4) - 45, 100, 15];
            metadata_box_position = [115, metadata_pan.Position(4) - 45, 150, 18];
            %Settings required from user
            experimenter_label = uilabel(metadata_pan, 'Text', 'Experimenter:', 'Position', metadata_label_position);

            self.experimenter_box = uidropdown(metadata_pan, 'Items', self.con.model.metadata_options.experimenter, ...
               'Value', self.con.model.metadata_options.experimenter{1}, 'Position', metadata_box_position, 'ValueChangedFcn', @self.new_experimenter);

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;

            exp_name_label = uilabel(metadata_pan, 'Text', 'Experiment Name:', ...
                'Position', metadata_label_position);

            self.exp_name_box = uieditfield(metadata_pan, 'Value', self.con.doc.experiment_name, 'Position', ...
                metadata_box_position, 'ValueChangedFcn', @self.new_experiment_name);
            set(self.exp_name_box, 'Editable', 'off');

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;

            fly_name_label = uilabel(metadata_pan, 'Text', 'Fly Name:', ...
                'Position', metadata_label_position);
            self.fly_name_box = uieditfield(metadata_pan, 'Value', self.con.model.fly_name, ...
                'Position', metadata_box_position, 'ValueChangedFcn', @self.new_fly_name);

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;

            fly_genotype_label = uilabel(metadata_pan, 'Text', 'Fly Genotype', ...
                'Position', metadata_label_position);

            self.fly_genotype_box = uidropdown(metadata_pan, 'Items', self.con.model.metadata_options.fly_geno, ...
                'Value', self.con.model.metadata_options.fly_geno{1}, ...
                'Position', metadata_box_position, 'ValueChangedFcn', @self.new_genotype);

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;

            fly_age_label = uilabel(metadata_pan, 'Text', 'Fly Age:', ...
                'Position', metadata_label_position);
            self.age_box = uidropdown(metadata_pan, 'Items', self.con.model.metadata_options.fly_age, ...
                'Value', self.con.model.metadata_options.fly_age{1}, ...
                'Position', metadata_box_position, 'ValueChangedFcn', @self.new_age);

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;

            fly_sex_label =  uilabel(metadata_pan, 'Text', 'Fly Sex:', ...
                'Position', metadata_label_position);
            self.sex_box = uidropdown(metadata_pan, 'Items', self.con.model.metadata_options.fly_sex,...
                'Value', self.con.model.metadata_options.fly_sex{1}, ...
                 'Position', metadata_box_position, 'ValueChangedFcn', @self.new_sex);

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;

            experiment_temp_label =  uilabel(metadata_pan, 'Text', 'Experiment Temp:', ...
                'Position', metadata_label_position);
            self.temperature_box = uidropdown(metadata_pan, 'Items', self.con.model.metadata_options.exp_temp, ...
                'Value', self.con.model.metadata_options.exp_temp{1}, ...
                'Position', metadata_box_position, 'ValueChangedFcn', @self.new_temp);

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;

            rearing_label = uilabel(metadata_pan, 'Text', 'Rearing Protocol:', ...
                'Position', metadata_label_position);

            self.rearing_protocol_box = uidropdown(metadata_pan, 'Items', self.con.model.metadata_options.rearing, ...
                'Value', self.con.model.metadata_options.rearing{1},  ...
                'Position', metadata_box_position, 'ValueChangedFcn', @self.new_rearing);

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;

            lightCycle_label = uilabel(metadata_pan, 'Text', 'Light Cycle:', ...
                'Position', metadata_label_position);

            self.light_cycle_box = uidropdown(metadata_pan, 'Items', self.con.model.metadata_options.light_cycle, ...
                'Value', self.con.model.metadata_options.light_cycle{1},  ...
                 'Position', metadata_box_position, 'ValueChangedFcn', @self.new_light_cycle);

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;


            date_and_time_label = uilabel(metadata_pan, 'Text', 'Date and Time:', ...
                'Position', metadata_label_position);
            self.date_and_time_box = uieditfield(metadata_pan, 'Value', self.con.model.timestamp, ...
                'Position', metadata_box_position, 'ValueChangedFcn', @self.new_timestamp);

            metadata_label_position(2) = metadata_label_position(2) - 25;
            metadata_box_position(2) = metadata_box_position(2) - 25;

            comments_label = uilabel(metadata_pan, 'Text', 'Comments:', ...
                'Position', metadata_label_position);
            self.comments_box = uieditfield(metadata_pan, 'Value', self.con.model.metadata_comments, ...
                'Position', metadata_box_position, 'ValueChangedFcn', @self.new_comments);

            % Experiment settings items
            exp_type_label = uilabel(settings_pan, 'Text', 'Experiment Type:', ...
                'Position', [10, 153, 100, 15]);
            self.exp_type_menu = uidropdown(settings_pan, 'Items', {'Flight','Camera walk', 'Chip walk'}, ...
                'Position', [115, 153, 150, 18], 'ValueChangedFcn', @self.new_experiment_type);

            test_button = uibutton(settings_pan, 'Text', 'Run Test Protocol', ...
                'Position', [290, 123, 120, 20], 'ButtonPushedFcn', @self.run_test_exp);
            
            tdms_checkbox_label = uilabel(settings_pan, 'Text', 'Convert TDMS?', ...
                'Position', [10, 123, 100, 15]);
            self.convert_tdms_checkbox = uicheckbox(settings_pan, 'Value', self.con.model.convert_tdms, ...
                'Position', [101, 123, 15, 15], 'ValueChangedFcn', @self.new_convert_tdms);
            
            processing_checkbox_label = uilabel(settings_pan, 'Text', 'Processing?', ...
                'Position', [120, 123, 75, 15]);
            self.processing_checkbox = uicheckbox(settings_pan, 'Value', self.con.model.do_processing, ...
                'Position', [196, 123, 15, 15], 'ValueChangedFcn', @self.new_do_processing);
            
            processing_filename_label = uilabel(settings_pan, 'Text', 'Processing Protocol:', ...
                'Position', [10, 73, 115, 15]);
            self.processing_textbox = uieditfield(settings_pan, 'Value', self.con.model.processing_file, ...
                'Position', [130, 73, 160, 18], 'ValueChangedFcn', @self.new_processing_file);
            self.browse_button_processing = uibutton(settings_pan, 'Text', 'Browse', ...
                'Position', [295, 73, 65, 18], 'ButtonPushedFcn', @self.proc_browse);
            
            
            plotting_checkbox_label = uilabel(settings_pan, 'Text', 'Plotting?', ...
                'Position', [215, 123, 55, 15]);
            self.plotting_checkbox = uicheckbox(settings_pan, 'Value', self.con.model.do_plotting, ...
                'Position', [271, 123, 15, 15], 'ValueChangedFcn', @self.new_do_plotting);
            
            plotting_filename_label = uilabel(settings_pan, 'Text', 'Plotting Protocol:', ...
                'Position', [10, 98, 115, 15]);
            self.plotting_textbox = uieditfield(settings_pan, 'Value', self.con.model.plotting_file, ...
                'Position', [130, 98, 160, 18], 'ValueChangedFcn', @self.new_plotting_file);
            self.browse_button_plotting = uibutton(settings_pan, 'Text', 'Browse', ...
                'Position', [295, 98, 65, 18], 'ButtonPushedFcn', @self.plot_browse);

            run_filename_label = uilabel(settings_pan, 'Text', 'Run Protocol:', ...
                'Position', [10, 48, 115, 15]);
            self.run_dropDown = uidropdown(settings_pan, 'Items', self.con.model.run_protocol_file_list, ...
                'Position', [130, 48, 200, 18],  'ValueChangedFcn', @self.select_run);

            num_attempts_label = uilabel(settings_pan, 'Text', 'Number times to re-attempt bad trials:', ...
                'Position', [10, 23, 210, 15]);
            self.num_attempts_textbox = uieditfield(settings_pan, 'numeric', 'Value', ...
                self.con.model.num_attempts_bad_conds, 'Limits', [0 5], 'Position', [225, 23, 50, 15], ...
                'ValueChangedFcn', @self.new_num_attempts);

            combine_tdms_label = uilabel(settings_pan, 'Text', ...
                'Combine multiple TDMS files into one?', 'Position', [10, 3, 210, 15]);

            self.combine_tdms_checkbox = uicheckbox(settings_pan, 'Value', ...
                self.con.get_combine_tdms(), 'Position', [225, 3, 15, 15], ...
               'ValueChangedFcn', @self.new_combine_tdms);

            self.bad_trial_markers = [];

            self.update_run_gui();
        end

        function update_run_gui(self)
            self.experimenter_box.Value = self.con.model.experimenter;
            self.exp_name_box.Value = self.con.doc.experiment_name;
            set(self.fig,'name',['Fly Experiment Conductor - ',self.con.doc.experiment_name]);
            self.fly_name_box.Value = self.con.model.fly_name;
            self.fly_genotype_box.Value = self.con.model.fly_genotype;
            self.date_and_time_box.Value = self.con.get_timestamp();
            self.age_box.Value = self.con.model.fly_age;
            self.sex_box.Value = self.con.model.fly_sex;
            self.temperature_box.Value = self.con.model.experiment_temp;
            self.rearing_protocol_box.Value = self.con.model.rearing_protocol;
            self.light_cycle_box.Value = self.con.model.light_cycle;
            self.comments_box.Value = self.con.model.metadata_comments;
            self.plotting_checkbox.Value = self.con.model.do_plotting;
            self.con.engage_plotting_textbox();
            if self.con.model.do_plotting == 1
                self.plotting_textbox.Value = self.con.model.plotting_file;
            end
            self.processing_checkbox.Value = self.con.model.do_processing;
            self.con.engage_processing_textbox();
            if self.con.model.do_processing == 1
                self.processing_textbox.Value = self.con.model.processing_file;
            end
            self.convert_tdms_checkbox.Value = self.con.model.convert_tdms;
            self.num_attempts_textbox.Value = self.con.get_num_attempts();
            self.exp_type_menu.Value = self.con.model.experiment_type;
            self.run_dropDown.Value = self.con.model.run_protocol_file_list{self.con.model.run_protocol_num};
            self.set_expected_time();
            self.set_elapsed_time();
            self.set_remaining_time();
            self.current_mode_text.Text = self.con.current_mode;
            self.current_pat_text.Text = self.con.current_pat;
            self.current_pos_text.Text = self.con.current_pos;
            self.current_ao1_text.Text = self.con.current_ao1;
            self.current_ao2_text.Text = self.con.current_ao2;
            self.current_ao3_text.Text = self.con.current_ao3;
            self.current_ao4_text.Text = self.con.current_ao4;
            self.current_frInd_text.Text = self.con.current_frInd;
            self.current_frRate_text.Text = self.con.current_frRate;
            self.current_gain_text.Text = self.con.current_gain;
            self.current_offset_text.Text = self.con.current_offset;
            self.current_duration_text.Text = self.con.current_duration;
            self.set_recent_file_menu_items();
            self.combine_tdms_checkbox.Value = self.con.get_combine_tdms();
            
        end

        %% Callbacks
        % Most callback functions take the new value and send it to the
        % controller's update function. The controller will do any necessary
        % error checking, set the model or doc appropriately, then
        % the view will update itself.

        function new_fly_name(self, src, ~)
            self.con.update_fly_name(src.Value);
            self.update_run_gui();
        end

        function new_experimenter(self, src, event)
            self.con.update_experimenter(event.Value); % Value is no longer an index but the actual value from the list. WIll need to update function to reflect this.
            self.update_run_gui();
        end

        function new_experiment_name(self, src, ~)
            self.con.update_experiment_name(src.Value)
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

        function new_convert_tdms(self, src, ~)
            self.con.update_convert_tdms(src.Value);
            self.update_run_gui();
        end

        function new_plotting_file(self, src, ~)
            self.con.update_plotting_file(src.Value);
            self.update_run_gui();
        end

        function new_processing_file(self, src, ~)
            self.con.update_processing_file(src.Value);
            self.update_run_gui();
        end

        function new_num_attempts(self, src, ~)
            self.con.update_num_attempts(src.Value)
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

        function new_timestamp(self, ~, ~)
            self.con.update_timestamp();
            self.update_run_gui();
        end

        function new_comments(self, src, ~)
            self.con.update_comments(src.Value);
            self.update_run_gui();
        end

        function new_combine_tdms(self, src, ~)
            self.con.update_combine_tdms(src.Value);
            self.update_run_gui();
        end

        function open(self, ~, ~, varargin)
            if ~isempty(varargin)
                self.con.open_g4p_file(varargin{1});
            else
                self.con.open_g4p_file();
            end

            self.update_run_gui();
        end

        function open_gs(self, ~, ~)
            self.con.open_google_sheet();
        end

        function abort(self, ~, ~)
            self.con.abort_experiment();
        end

        function pause(self, ~, event)
            val = event.Value;
            self.con.pause_experiment(val);
        end

        function end_early(self, ~, ~)
            self.con.end_early();
        end

        function run_exp(self, ~, ~)
            self.con.run();
            self.con.model.update_fly_save_name();
            %self.con.update_flyName_reminder();
        end

        function run_test_exp(self, ~, ~)
            self.con.prepare_test_exp();
            [original_filepath, original_fly_name] = self.con.run_test();
            repeat = self.con.check_if_repeat();
            while repeat > 0
                [~, ~] = self.con.run_test(original_filepath, original_fly_name);
                repeat = self.con.check_if_repeat();
            end
            self.con.reopen_original_experiment(original_filepath, original_fly_name);
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

        function select_run(self, src, ~)
            self.con.update_run_file(src.Value);
        end

        function update_progress_bar(self, trial_type, data, varargin)
            if strcmp(trial_type, 'pre')
                for bt = 1:length(self.bad_trial_markers)
                    delete(self.bad_trial_markers(bt));
                end
                self.bad_trial_markers = [];
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
            elseif strcmp(trial_type, 'rescheduled')
                cond = varargin{1};
                self.progress_axes.Title.String = "Running rescheduled condition #: " + cond;
            else
                disp("I can't update the progress bar.");
            end

            drawnow;
        end

        function set_progress_title(self, text)
            self.progress_axes.Title.String = text;
        end

        function add_bad_trial_marker(self, num_trials, trialNum)
            self.bad_trial_markers(end+1) = xline(self.progress_axes, trialNum/num_trials, 'Color', 'r');
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
            if time_in_s < 0
                mins = mins + 1;
            end
            secs = rem(time_in_s, 60);
            text = mins + "m " + secs + "s ";
        end

        function set_expected_time(self)
            text = self.convert_time_format(self.con.model.expected_time);
            self.expected_time_text.Text = text;
        end

        function set_elapsed_time(self)
            text = self.convert_time_format(self.con.elapsed_time);
            self.elapsed_time_text.Text = text;
        end

        function set_remaining_time(self)
            text = self.convert_time_format(self.con.remaining_time);
            self.remaining_time_text.Text = text;
        end

        function set_repetition_lines(self)
            %cla(self.progress_axes);
            reps = self.con.doc.repetitions;
            for i = 1:reps
                x = (i/reps);% + 1/total_steps;
                line(self.progress_axes, 'XData', [x, x], 'YDATA', [0,2]);
            end

        end

        function reset_progress_bar(self)
            
            cla(self.progress_axes);
            self.progress_bar = barh(0, 'Parent', self.progress_axes,'BaseValue', 0);
            self.progress_axes.XAxis.Limits = [0 1];
            self.progress_axes.YTickLabel = [];
            self.progress_axes.XTickLabel = [];
            self.progress_axes.XTick = [];
            self.progress_axes.YTick = [];
            self.set_repetition_lines();

        end

        function update_config_file(self, ~, ~)
            
            self.con.update_config_file();
            self.update_run_gui();
    
        end

        function close_application(self, src, event)

            clear('run_con');
            delete(src);
            evalin('base', 'clear run_con');

        end

    end
end
