classdef G4_designer_view < handle

    properties
        con
        f
        pretrial_table
        intertrial_table
        block_table
        posttrial_table
        isSelect_all_box
        preview_panel
        listbox_imported_files
        pageUp_button
        pageDown_button
        exp_name_box
        menu_open
        exp_length_display
        randomize_buttonGrp
        isRandomized_radio
        isSequential_radio
        repetitions_box
        chan1_rate_box
        chan2_rate_box
        chan3_rate_box
        chan4_rate_box
        num_rows_buttonGrp
        num_rows_3
        num_rows_4

    end

    methods
        function self = G4_designer_view(con)
            self.con = con;
             %get screensize to calculate gui dimensions
            screensize = get(0, 'screensize');

            %create figure
            self.f = uifigure('Name', 'Fly Experiment Designer', 'Position',...
                [.05, .05, .9, .9].*screensize);
            self.f.CloseRequestFcn = @self.close_application;
            

            column_names = {'Mode', 'Pattern Name' 'Position Function', ...
                'AO 2', 'AO 3', 'AO 4', 'AO 5', ...
                'Frame Index', 'Frame Rate', 'Gain', 'Offset', 'Duration' ...
                'Select'};
            columns_editable = true;
            column_format = {'numeric', 'char', 'char', 'char', 'char','char', ...
                'char', 'char', 'numeric', 'numeric', 'numeric', 'numeric', 'logical'};
            column_widths = {'auto', 'auto', 'auto', 'auto', 'auto', 'auto', ...
                'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 'auto',};
            font_size = 10; 
            
            % position values as percentages of parent size (converted to
             % pixels at time of use)
            positions.pre = [.2, .92, .682, .06];
            positions.inter = [.2, .84, .682, .06];
            positions.block = [.2, .45, .682, .35];
            positions.post = [.2, .37, .682, .06];
            pos_panel = [.2, .08, .682, .27];
            left_margin = .003;
            chan_label_height = .1; 
            chan_label_margin = .05;
            chan_label_bottom = .85;
            chan_label_width = .9;

            %NO FURTHER EDITING PARAMETERS

            %Sizes of parent windows/panels
            fSize = [self.f.Position(3), self.f.Position(4)];            

            %pretrial_label
            uilabel(self.f, 'Text', 'Pre-Trial', 'FontSize', font_size, 'Position', ...
                [positions.pre(1) - .04, positions.pre(2) + .025, .04, .015].*[fSize, fSize]);

            self.pretrial_table = uitable(self.f, 'data', self.con.doc.pretrial, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.pre, 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'ColumnWidth', column_widths, 'CellEditCallback', @self.update_model_pretrial, 'CellSelectionCallback', {@self.preview_selection, positions});
            

            % intertrial_label
            uilabel(self.f, 'Text', 'Inter-Trial', 'FontSize', font_size, 'Position', ...
               [positions.inter(1) - .04, positions.inter(2) + .025, .04, .015].*[fSize, fSize]);

            self.intertrial_table = uitable(self.f, 'data', self.con.doc.intertrial, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.inter, 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'ColumnWidth', column_widths, 'CellEditCallback', @self.update_model_intertrial, 'CellSelectionCallback', {@self.preview_selection, positions});

            %blocktrial_label
            uilabel(self.f, 'Text', 'Block Trials', 'FontSize', font_size, 'Position', ...
               [positions.block(1) - .04, positions.block(2) + .5*positions.block(4), .04, .015].*[fSize, fSize]);

            self.block_table = uitable(self.f, 'data', self.con.doc.block_trials, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.block, 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'ColumnWidth', column_widths, 'CellEditCallback', @self.update_model_block_trials, 'CellSelectionCallback', {@self.preview_selection, positions});

            %posttrial_label
            uilabel(self.f, 'Text', 'Post-Trial', 'FontSize', font_size, 'Position', ...
                [positions.post(1) - .04, positions.post(2) + .025, .04, .015].*[fSize, fSize]);

            self.posttrial_table = uitable(self.f, 'data', self.con.doc.posttrial, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.post, 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'ColumnWidth', column_widths, 'CellEditCallback', @self.update_model_posttrial, 'CellSelectionCallback', {@self.preview_selection, positions});

            %add_trial_button
            uibutton(self.f, 'Text','Add Trial','Position', [positions.block(1) + positions.block(3) + left_margin, ...
                positions.block(2) + .02, .05, .02].*[fSize, fSize], 'ButtonPushedFcn',@self.add_trials_callback);

            %delete_trial_button
            uibutton(self.f, 'Text', 'Delete Trial', 'Position', [positions.block(1) + positions.block(3) + left_margin, ...
                positions.block(2), .05, .02].*[fSize, fSize], 'ButtonPushedFcn', @self.delete_trial);

            self.isSelect_all_box = uicheckbox(self.f, 'Text', 'Select All', 'Value', self.con.model.isSelect_all,'FontSize', font_size, ...
                'Position', [positions.block(1) + positions.block(3) - .03, positions.block(2) + positions.block(4) + .0015, ...
                .05, .02].*[fSize, fSize], 'ValueChangedFcn', @self.select_all);

            %invert_selection
            uibutton(self.f, 'Text', 'Invert Selection', 'Position', [positions.block(1) + positions.block(3) + left_margin, ...
                positions.block(2) - .021, .05, .02].*[fSize, fSize], 'ButtonPushedFcn', @self.invert_selection);

            %up_button
            uibutton(self.f, 'Text', 'Shift up', 'Position', [positions.block(1) + positions.block(3) + left_margin, ...
                positions.block(2) + .65*positions.block(4), .05, .02].*[fSize, fSize], 'ButtonPushedFcn', @self.shift_up_callback);

            %down_button
            uibutton(self.f, 'Text', 'Shift down', 'Position', [positions.block(1) + positions.block(3) + left_margin, positions.block(2) + .35*positions.block(4), ...
                .05, .02].*[fSize, fSize], 'ButtonPushedFcn', @self.shift_down_callback);

            % clear_all_button
            uibutton(self.f, 'Text', 'Clear All','FontSize', 12, 'Position', [positions.block(1) + 1.03*positions.block(3), ...
                positions.pre(2), .054, positions.pre(4)].*[fSize, fSize], 'ButtonPushedFcn', @self.clear_all);

            %autofill_button
            uibutton(self.f, 'Text', 'Auto-Fill', 'FontSize', 14, 'Position', [pos_panel(1), pos_panel(2) - .05, ...
                .07, .05].*[fSize, fSize], 'ButtonPushedFcn', @self.autofill);

            self.preview_panel = uipanel(self.f, 'Title', 'Preview', 'FontSize', font_size, 'units', 'normalized', ...
                'Position', pos_panel);

            listbox_files_label = uilabel(self.f, 'Text', 'Imported files for selected cell:',...
                'Position', [pos_panel(1) + pos_panel(3) + .01, pos_panel(2) + pos_panel(4) + .02, ...
                .09, .04].*[fSize, fSize], 'FontSize', font_size);

            self.listbox_imported_files = uilistbox(self.f, 'Items', {'Imported files here'},  ...
                'Position', [listbox_files_label.Position(1), listbox_files_label.Position(2) - .24*fSize(2), ...
                .09*fSize(1), .24*fSize(2)],'ValueChangedFcn', @self.preview_selection);

             %select_imported_file_button
             uibutton(self.f, 'Text', 'Select', 'Position',  [self.listbox_imported_files.Position(1) + .5*self.listbox_imported_files.Position(3), ...
                self.listbox_imported_files.Position(2) - .02*fSize(2), .045*fSize(1), .016*fSize(2)], 'ButtonPushedFcn', @self.select_new_file);

            %code to make the above panel transparent, so the preview image
            %can be seen.
            jPanel = self.preview_panel.JavaFrame.getPrintableComponent;
            jPanel.setOpaque(false)
            jPanel.getParent.setOpaque(false)
            jPanel.getComponent(0).setOpaque(false)
            jPanel.repaint

            %preview_button
            uibutton(self.f, 'Text', 'Preview', 'Fontsize', font_size, 'Position', [pos_panel(1) + pos_panel(3), ...
                pos_panel(2), .05, .045].*[fSize, fSize], 'ButtonPushedFcn', @self.full_preview);

            %Checkbox to turn on/off displaying inscreen previews on the
            %arena.
            uicheckbox(self.f, 'Text', 'Arena preview', 'Value', self.con.preview_on_arena, 'Position', ...
                [pos_panel(1) + pos_panel(3) + .05, pos_panel(2) - .04, .07, .045].*[fSize, fSize], ...
                'ValueChangedFcn', @self.update_preview_on_arena);

            %play_button
            uibutton(self.f, 'Text', 'Play', 'FontSize', font_size,'Position', [pos_panel(1) + .5*pos_panel(3) - .08, ...
                pos_panel(2) - .03, .05, .02].*[fSize, fSize], 'ButtonPushedFcn', @self.preview_play);

            %pause_button
            uibutton(self.f, 'Text', 'Pause', 'FontSize', font_size, 'Position', [pos_panel(1) + .5*pos_panel(3) - .025, ...
                pos_panel(2) - .03, .05, .02].*[fSize, fSize], 'ButtonPushedFcn', @self.preview_pause);


            %stop_button 
            uibutton(self.f, 'Text', 'Stop', 'FontSize', font_size, 'Position', [pos_panel(1) + .5*pos_panel(3) + .03, ...
                pos_panel(2) - .03, .05, .02].*[fSize, fSize], 'ButtonPushedFcn', @self.preview_stop);

            %frameBack_button
            uibutton(self.f, 'Text', 'Back Frame', 'FontSize', font_size, 'Position', [pos_panel(1) + .5*pos_panel(3) - .135, ...
                pos_panel(2) - .03, .05, .02].*[fSize, fSize], 'ButtonPushedFcn', @self.frame_back);

            %frameForward_button =
            uibutton(self.f, 'Text', 'Forward Frame', 'FontSize', font_size, 'Position', [pos_panel(1) + .5*pos_panel(3) ...
                + .085, pos_panel(2) - .03, .07, .02].*[fSize, fSize], 'ButtonPushedFcn', @self.frame_forward);

            self.pageUp_button = uibutton(self.f, 'Text', 'Page Up', 'FontSize', font_size, 'Position', ...
                [pos_panel(1) + .5*pos_panel(3) + .16, pos_panel(2) - .03, .07, .02].*[fSize, fSize], ...
                'Enable', 'off', 'ButtonPushedFcn', @self.page_up_4d);

            self.pageDown_button = uibutton(self.f, 'Text', 'Page Down', 'FontSize', font_size, 'Position', ...
                [pos_panel(1) + .5*pos_panel(3) - .21, pos_panel(2) - .03, .07, .02].*[fSize, fSize], ...
                'Enable', 'off', 'ButtonPushedFcn', @self.page_down_4d);

            self.exp_name_box = uieditfield(self.f,  'FontSize', 14, 'Position', ...
                [pos_panel(1)+ (pos_panel(3)/2) - .125, pos_panel(2) - .07, .25, .03].*[fSize, fSize], ...
                'ValueChangedFcn', @self.update_experiment_name);

            %exp_name_label
            uilabel(self.f, 'Text', 'Experiment Name: ', 'FontSize', 16, 'Position',...
                [pos_panel(1) + (pos_panel(3)/2) - .25, pos_panel(2) - .07, .1, .03].*[fSize, fSize]);

        %Drop down menu and associated labels and buttons

            menu = uimenu(self.f, 'Text', 'File');
            %menu_import
            uimenu(menu, 'Text', 'Import', 'Callback', @self.import);
            self.menu_open = uimenu(menu, 'Text', 'Open');
            %menu_recent_files
            uimenu(self.menu_open, 'Text', '.g4p file', 'Callback', {@self.open_file, ''});

            for i = 1:length(self.con.doc.recent_g4p_files)
                [~, filename] = fileparts(self.con.doc.recent_g4p_files{i});
                self.con.recent_file_menu_items{i} = uimenu(self.menu_open, 'Text', filename, 'Callback', {@self.open_file, self.con.doc.recent_g4p_files{i}});
            end

            if length(self.con.doc.recent_g4p_files) < 1
                self.con.recent_file_menu_items = {};
            end

            %menu_saveas
            uimenu(menu, 'Text', 'Save as', 'Callback', @self.saveas);
            %menu_copy
            uimenu(menu, 'Text', 'Copy to...', 'Callback', @self.copy_to);
            %menu_set
            uimenu(menu, 'Text', 'Set Selected...', 'Callback', @self.set_selected);
            %menu_settings
            uimenu(menu, 'Text', 'Settings', 'Callback', @self.open_settings);

        %Button to calculate estimated length of experiment

            exp_length_button = uibutton(self.f, 'Text', 'Calculate Experiment Length', 'Position', ...
                [left_margin, positions.block(2) + positions.block(4) + .04, .09,.02].*[fSize, fSize], ...
                 'ButtonPushedFcn', @self.calculate_experiment_length);

            self.exp_length_display = uilabel(self.f, 'Text', '', 'Position', ...
                [exp_length_button.Position(1) + exp_length_button.Position(3) + left_margin, ...
                exp_length_button.Position(2), .07, .02].*[fSize, fSize], 'FontSize', 12);

        %Randomization

            self.randomize_buttonGrp = uibuttongroup(self.f, 'units', 'normalized', 'Position', ...
                [left_margin, positions.block(2) + positions.block(4) - .05, .08, .06], ...
                'SelectionChangedFcn', @self.update_randomize);
            grpSize = [self.randomize_buttonGrp.Position(3), self.randomize_buttonGrp.Position(4)];


            self.isRandomized_radio = uiradiobutton(self.randomize_buttonGrp, 'Text', ...
                'Randomize Trials', 'FontSize', font_size, 'Position', [.001, .55, .95, .4].*[grpSize, grpSize]);

            self.isSequential_radio = uiradiobutton(self.randomize_buttonGrp, 'Text', 'Sequential Trials', ...
                'FontSize', font_size, 'Position', [.001,.1, .95, .4].*[grpSize, grpSize]);
        %Repetitions

            self.repetitions_box = uieditfield(self.f, "numeric", 'Position', [.05, positions.block(2) + positions.block(4) - .08, ...
                .035, .02].*[fSize, fSize], 'ValueChangedFcn', @self.update_repetitions);

            %repetitions_label
            uilabel(self.f, 'Text','Repetitions:', 'FontSize', font_size, 'Position', ...
                [left_margin, positions.block(2) + positions.block(4) - .08, .04, .02].*[fSize, fSize]);

%        %Dry Run
            %dry_run
            uibutton(self.f, 'Text', 'Dry Run', 'FontSize', font_size, 'Position', ...
                [pos_panel(1) + pos_panel(3), pos_panel(2) - .04, .05, .045].*[fSize, fSize],...
                'ButtonPushedFcn',@self.dry_run);

        %Actual run button
            uibutton(self.f, 'Text', 'Run Trials', 'FontSize', font_size, 'Position', ...
                 [left_margin, positions.block(2) + positions.block(4) - .15, .06, .06].*[fSize, fSize], ...
                 'ButtonPushedFcn', @self.open_run_gui);

        %Channels to acquire

            chan_pan = uipanel(self.f, 'Title', 'Analog Input Channels', 'FontSize', font_size, 'units', 'normalized', ...
                'Position', [left_margin, positions.block(2) + positions.block(4) - .31, .15, .13]);
            chan_pan_size = [chan_pan.Position(3), chan_pan.Position(4)];

            self.chan1_rate_box = uieditfield(chan_pan, "numeric", 'Value', num2str(self.con.doc.chan1_rate), 'Position', ...
                [.65, .72, .25, .15].*[chan_pan_size, chan_pan_size],'ValueChangedFcn', @self.update_chan1_rate);

            %chan1_rate_label
            uilabel(chan_pan, 'Text', 'Channel 1 Sample Rate', 'FontSize', font_size, ...
                'Position', [.05, .7, .5, .17].*[chan_pan_size, chan_pan_size]);

            self.chan2_rate_box = uieditfield(chan_pan, "numeric", 'Value', num2str(self.con.doc.chan2_rate), 'Position', ...
                [.65, .52, .25, .17].*[chan_pan_size, chan_pan_size], 'ValueChangedFcn', @self.update_chan2_rate);

            %chan2_rate_label
            uilabel(chan_pan, 'Text', 'Channel 2 Sample Rate', 'FontSize', font_size, ...
                'Position', [.05, .5, .5, .17].*[chan_pan_size, chan_pan_size]);

            self.chan3_rate_box = uieditfield(chan_pan, "numeric", 'Value', num2str(self.con.doc.chan3_rate), 'Position', ...
                [.65, .32, .25, .17].*[chan_pan_size, chan_pan_size], 'ValueChangedFcn', @self.update_chan3_rate);

            %chan3_rate_label
            uilabel(chan_pan, 'Text', 'Channel 3 Sample Rate', 'FontSize', font_size, ...
                'Position', [.05, .3, .5, .17].*[chan_pan_size, chan_pan_size]);

            self.chan4_rate_box = uieditfield(chan_pan, "numeric", 'Value', num2str(self.con.doc.chan4_rate), 'Position', ...
                [.65, .12, .25, .17].*[chan_pan_size, chan_pan_size], 'ValueChangedFcn', @self.update_chan4_rate);

            %chan4_rate_label
            uilabel(chan_pan, 'Text', 'Channel 4 Sample Rate', 'FontSize', font_size, ...
                'Position', [.05, .1, .5, .17].*[chan_pan_size, chan_pan_size]);

            self.num_rows_buttonGrp = uibuttongroup(self.f, 'units', 'normalized', ...
                'Position', [left_margin, chan_pan.Position(2) - .05, chan_pan.Position(3), .04], 'SelectionChangedFcn', @self.update_rowNum);
            rowGrpSize = [self.num_rows_buttonGrp.Position(3), self.num_rows_buttonGrp.Position(4)];

            self.num_rows_3 = uiradiobutton(self.num_rows_buttonGrp, 'Text', '3 Row Screen', ...
                'FontSize', font_size, 'Position', [.05, .05, .45, .9].*[rowGrpSize, rowGrpSize]);

            self.num_rows_4 = uiradiobutton(self.num_rows_buttonGrp, 'Text', '4 Row Screen', ...
                'FontSize', font_size, 'Position', [.5, .05, .45, .9].*[rowGrpSize, rowGrpSize]);


            key_pan = uipanel(self.f, 'Title', 'Mode Key:', 'BackgroundColor', [.75, .75, .75], ...
                'BorderType', 'none', 'FontSize', 13, 'units', 'normalized', ...
                'Position', [left_margin, self.num_rows_buttonGrp.Position(2) - .41, ...
                self.num_rows_buttonGrp.Position(3), .4]);
            key_pan_size = [key_pan.Position(3), key_pan.Position(4)];

            mode_1_label = uilabel(key_pan, 'Text', 'Mode 1: Position Function', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left', 'FontSize', 11, 'Position', ...
                [chan_label_margin, chan_label_bottom, chan_label_width, chan_label_height].*[key_pan_size, key_pan_size]);

            mode_2_label = uilabel(key_pan, 'Text', 'Mode 2: Constant Rate', ...
                'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', 'left',...
                'FontSize', 11, 'Position', [chan_label_margin*key_pan_size(1), ...
                mode_1_label.Position(2) - chan_label_height*key_pan_size(2), ...
                chan_label_width*key_pan_size(1), chan_label_height*key_pan_size(2)]);

            mode_3_label = uilabel(key_pan, 'Text', 'Mode 3: Constant Index', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'Position', [chan_label_margin*key_pan_size(1), ...
                mode_2_label.Position(2) - chan_label_height*key_pan_size(2), chan_label_width*key_pan_size(1), ...
                chan_label_height*key_pan_size(2)]);

            mode_4_label = uilabel(key_pan, 'Text', 'Mode 4: Closed-loop sets frame rate', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'Position', [chan_label_margin*key_pan_size(1), ...
                mode_3_label.Position(2) - chan_label_height*key_pan_size(2), chan_label_width*key_pan_size(1), ...
                chan_label_height*key_pan_size(2)]);

            mode_5_label = uilabel(key_pan, 'Text', 'Mode 5: Closed-loop rate + offset', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'Position', [chan_label_margin*key_pan_size(1), ...
                mode_4_label.Position(2) - (chan_label_height/2)*key_pan_size(2), chan_label_width*key_pan_size(1), ...
                (chan_label_height/2)*key_pan_size(2)]);

            mode_5_label_cont = uilabel(key_pan, 'Text', 'position function', 'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', ...
                'left', 'FontSize', 11, 'Position', [chan_label_margin*key_pan_size(1), mode_5_label.Position(2) - chan_label_height*key_pan_size(2), ...
                chan_label_width*key_pan_size(1), chan_label_height*key_pan_size(2)]);

            mode_6_label = uilabel(key_pan, 'Text', 'Mode 6: Closed-loop rate X + position', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'Position', [chan_label_margin*key_pan_size(1), ...
                mode_5_label_cont.Position(2) - (chan_label_height/2)*key_pan_size(2), chan_label_width*key_pan_size(1), ...
                (chan_label_height/2)*key_pan_size(2)]);

            mode_6_label_cont = uilabel(key_pan, 'Text', 'function Y', 'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', ...
                'left', 'FontSize', 11, 'Position', [chan_label_margin*key_pan_size(1), mode_6_label.Position(2) - chan_label_height*key_pan_size(2), ...
                chan_label_width*key_pan_size(1), chan_label_height*key_pan_size(2)]);

            mode_7_label = uilabel(key_pan, 'Text', 'Mode 7: Closed-loop sets frame index', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'Position', [chan_label_margin*key_pan_size(1), ...
                mode_6_label_cont.Position(2) - chan_label_height*key_pan_size(2), chan_label_width*key_pan_size(1), chan_label_height*key_pan_size(2)]);
            
            self.reset_defaults();
        end

        function update_gui(self)


        end

        function close_application(self)


        end

        function update_model_pretrial(self, ~, event)

            new = event.EditData;
            y = event.Indices(2);


        end

        function update_model_intertrial(self)


        end

        function update_model_posttrial(self)


        end

        function update_model_block_trials(self)


        end

        function preview_selection(self, positions)

        end

        function add_trials_callback(self)

        end

        function delete_trial(self)

        end

        function select_all(self)

        end

        function invert_selection(self)

        end

        function shift_up_callback(self)

        end

        function shift_down_callback(self)

        end

        function clear_all(self)

        end

        function autofill(self)

        end

        function select_new_file(self)

        end

        function full_preview(self)

        end

        function update_preview_on_arena(self)


        end
        
        function preview_play(self)

        end

        function preview_pause(self)

        end

        function preview_stop(self)

        end

        function frame_back(self)

        end

        function frame_forward(self)

        end

        function page_up_4d(self)

        end

        function page_down_4d(self)

        end

        function update_experiment_name(self)

        end

        function import(self)

        end

        function open_file(self)

        end

        function saveas(self)

        end

        function copy_to(self)

        end

        function set_selected(self)

        end

        function open_settings(self)

        end

        function calculate_experiment_length(self)

        end

        function update_randomize(self)

        end

        function update_repetitions(self)

        end
        function dry_run(self)

        end
        function open_run_gui(self)

        end
        function update_chan1_rate(self)

        end
        function update_chan2_rate(self)

        end
        function update_chan3_rate(self)

        end
        function update_chan4_rate(self)

        end
        function update_rowNum(self)

        end
        function reset_defaults(self)

        end
        

    end


end
