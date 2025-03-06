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
        num_rows_1
        num_rows_2
        num_rows_3
        num_rows_4
        recent_file_menu_items
        hAxes
        second_axes
        inscreen_plot
        uneditableStyle
        editableStyle


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
            'units', 'normalized', 'Position', positions.pre, 'Tag', 'pre', 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'ColumnWidth', column_widths, 'CellEditCallback', @self.update_trial, 'CellSelectionCallback', @self.preview_selection);
            

            % intertrial_label
            uilabel(self.f, 'Text', 'Inter-Trial', 'FontSize', font_size, 'Position', ...
               [positions.inter(1) - .04, positions.inter(2) + .025, .04, .015].*[fSize, fSize]);

            self.intertrial_table = uitable(self.f, 'data', self.con.doc.intertrial, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.inter, 'Tag', 'inter', 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'ColumnWidth', column_widths, 'CellEditCallback', @self.update_trial, 'CellSelectionCallback', @self.preview_selection);

            %blocktrial_label
            uilabel(self.f, 'Text', 'Block Trials', 'FontSize', font_size, 'Position', ...
               [positions.block(1) - .04, positions.block(2) + .5*positions.block(4), .04, .015].*[fSize, fSize]);

            self.block_table = uitable(self.f, 'data', self.con.doc.block_trials, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.block, 'Tag', 'block', 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'ColumnWidth', column_widths, 'CellEditCallback', @self.update_trial, 'CellSelectionCallback', @self.preview_selection);

            %posttrial_label
            uilabel(self.f, 'Text', 'Post-Trial', 'FontSize', font_size, 'Position', ...
                [positions.post(1) - .04, positions.post(2) + .025, .04, .015].*[fSize, fSize]);

            self.posttrial_table = uitable(self.f, 'data', self.con.doc.posttrial, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.post, 'Tag', 'post', 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'ColumnWidth', column_widths, 'CellEditCallback', @self.update_trial,'CellSelectionCallback', @self.preview_selection);

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
%             jPanel = self.preview_panel.JavaFrame.getPrintableComponent;
%             jPanel.setOpaque(false)
%             jPanel.getParent.setOpaque(false)
%             jPanel.getComponent(0).setOpaque(false)
%             jPanel.repaint

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


            if length(self.con.doc.recent_g4p_files) < 1
                self.recent_file_menu_items = {};
            else
                self.set_recent_file_menu_items();
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
                [exp_length_button.Position(1) + exp_length_button.Position(3) + (left_margin*fSize(1)), ...
                exp_length_button.Position(2), (.07*fSize(1)), (.02*fSize(2))], 'FontSize', 12);

        %Randomization

            self.randomize_buttonGrp = uibuttongroup(self.f, 'units', 'normalized', 'Position', ...
                [left_margin, positions.block(2) + positions.block(4) - .05, .08, .06], ...
                'SelectionChangedFcn', @self.update_randomize);
            grpSize = [self.randomize_buttonGrp.Position(3), self.randomize_buttonGrp.Position(4)];
            grpSize_pix = grpSize .* self.f.Position(3:4);


            self.isRandomized_radio = uiradiobutton(self.randomize_buttonGrp, 'Text', ...
                'Randomize Trials', 'FontSize', font_size, 'Position', [.001, .55, .95, .4].*[grpSize_pix, grpSize_pix]);

            self.isSequential_radio = uiradiobutton(self.randomize_buttonGrp, 'Text', 'Sequential Trials', ...
                'FontSize', font_size, 'Position', [.001,.1, .95, .4].*[grpSize_pix, grpSize_pix]);
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
            chan_pan_size_pix = chan_pan_size .* self.f.Position(3:4);

%             self.chan1_rate_box = uieditfield(chan_pan, "numeric", 'Value', self.con.doc.chan1_rate, 'Position', ...
%                 [.65, .72, .25, .15].*[chan_pan_size, chan_pan_size],'ValueChangedFcn', @self.update_chan1_rate);

            self.chan1_rate_box = uieditfield(chan_pan, "numeric", 'Position', ...
                [.65, .72, .25, .15].*[chan_pan_size_pix, chan_pan_size_pix],'ValueChangedFcn', @self.update_chan1_rate);

            %chan1_rate_label
            uilabel(chan_pan, 'Text', 'Channel 1 Sample Rate', 'FontSize', font_size, ...
                'Position', [.05, .7, .5, .17].*[chan_pan_size_pix, chan_pan_size_pix]);

            self.chan2_rate_box = uieditfield(chan_pan, "numeric", 'Position', ...
                [.65, .52, .25, .17].*[chan_pan_size_pix, chan_pan_size_pix], 'ValueChangedFcn', @self.update_chan2_rate);

            %chan2_rate_label
            uilabel(chan_pan, 'Text', 'Channel 2 Sample Rate', 'FontSize', font_size, ...
                'Position', [.05, .5, .5, .17].*[chan_pan_size_pix, chan_pan_size_pix]);

            self.chan3_rate_box = uieditfield(chan_pan, "numeric", 'Position', ...
                [.65, .32, .25, .17].*[chan_pan_size_pix, chan_pan_size_pix], 'ValueChangedFcn', @self.update_chan3_rate);

            %chan3_rate_label
            uilabel(chan_pan, 'Text', 'Channel 3 Sample Rate', 'FontSize', font_size, ...
                'Position', [.05, .3, .5, .17].*[chan_pan_size_pix, chan_pan_size_pix]);

            self.chan4_rate_box = uieditfield(chan_pan, "numeric", 'Position', ...
                [.65, .12, .25, .17].*[chan_pan_size_pix, chan_pan_size_pix], 'ValueChangedFcn', @self.update_chan4_rate);

            %chan4_rate_label
            uilabel(chan_pan, 'Text', 'Channel 4 Sample Rate', 'FontSize', font_size, ...
                'Position', [.05, .1, .5, .17].*[chan_pan_size_pix, chan_pan_size_pix]);

            self.num_rows_buttonGrp = uibuttongroup(self.f, 'units', 'normalized', ...
                'Position', [left_margin, chan_pan.Position(2) - .1, chan_pan.Position(3), .08], 'SelectionChangedFcn', @self.update_rowNum);
            rowGrpSize = [self.num_rows_buttonGrp.Position(3), self.num_rows_buttonGrp.Position(4)];
            rowGrpSize_pix = rowGrpSize .* self.f.Position(3:4);

            self.num_rows_1 = uiradiobutton(self.num_rows_buttonGrp, 'Text', '1 Row Screen', ...
                'FontSize', font_size, 'Position', [.05, .55, .45, .45].*[rowGrpSize_pix, rowGrpSize_pix]);

            self.num_rows_2 = uiradiobutton(self.num_rows_buttonGrp, 'Text', '2 Row Screen', ...
                'FontSize', font_size, 'Position', [.5, .55, .45, .45].*[rowGrpSize_pix, rowGrpSize_pix]);

            self.num_rows_3 = uiradiobutton(self.num_rows_buttonGrp, 'Text', '3 Row Screen', ...
                'FontSize', font_size, 'Position', [.05, .05, .45, .45].*[rowGrpSize_pix, rowGrpSize_pix]);

            self.num_rows_4 = uiradiobutton(self.num_rows_buttonGrp, 'Text', '4 Row Screen', ...
                'FontSize', font_size, 'Position', [.5, .05, .45, .45].*[rowGrpSize_pix, rowGrpSize_pix]);


            key_pan = uipanel(self.f, 'Title', 'Mode Key:', 'BackgroundColor', [.75, .75, .75], ...
                'BorderType', 'none', 'FontSize', 13, 'units', 'normalized', ...
                'Position', [left_margin, self.num_rows_buttonGrp.Position(2) - .41, ...
                self.num_rows_buttonGrp.Position(3), .4]);
            key_pan_size = [key_pan.Position(3), key_pan.Position(4)];
            key_pan_size_pix = key_pan_size .* self.f.Position(3:4);

            mode_1_label = uilabel(key_pan, 'Text', 'Mode 1: Position Function', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left', 'FontSize', 11, 'Position', ...
                [chan_label_margin, chan_label_bottom, chan_label_width, chan_label_height].*[key_pan_size_pix, key_pan_size_pix]);

            mode_2_label = uilabel(key_pan, 'Text', 'Mode 2: Constant Rate', ...
                'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', 'left',...
                'FontSize', 11, 'Position', [chan_label_margin*key_pan_size_pix(1), ...
                mode_1_label.Position(2) - chan_label_height*key_pan_size_pix(2), ...
                chan_label_width*key_pan_size_pix(1), chan_label_height*key_pan_size_pix(2)]);

            mode_3_label = uilabel(key_pan, 'Text', 'Mode 3: Constant Index', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'Position', [chan_label_margin*key_pan_size_pix(1), ...
                mode_2_label.Position(2) - chan_label_height*key_pan_size_pix(2), chan_label_width*key_pan_size_pix(1), ...
                chan_label_height*key_pan_size_pix(2)]);

            mode_4_label = uilabel(key_pan, 'Text', 'Mode 4: Closed-loop sets frame rate', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'Position', [chan_label_margin*key_pan_size_pix(1), ...
                mode_3_label.Position(2) - chan_label_height*key_pan_size_pix(2), chan_label_width*key_pan_size_pix(1), ...
                chan_label_height*key_pan_size_pix(2)]);

            mode_5_label = uilabel(key_pan, 'Text', 'Mode 5: Closed-loop rate + offset', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'Position', [chan_label_margin*key_pan_size_pix(1), ...
                mode_4_label.Position(2) - (chan_label_height/2)*key_pan_size_pix(2), chan_label_width*key_pan_size_pix(1), ...
                (chan_label_height/2)*key_pan_size_pix(2)]);

            mode_5_label_cont = uilabel(key_pan, 'Text', 'position function', 'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', ...
                'left', 'FontSize', 11, 'Position', [chan_label_margin*key_pan_size_pix(1), mode_5_label.Position(2) - chan_label_height*key_pan_size_pix(2), ...
                chan_label_width*key_pan_size_pix(1), chan_label_height*key_pan_size_pix(2)]);

            mode_6_label = uilabel(key_pan, 'Text', 'Mode 6: Closed-loop rate X + position', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'Position', [chan_label_margin*key_pan_size_pix(1), ...
                mode_5_label_cont.Position(2) - (chan_label_height/2)*key_pan_size_pix(2), chan_label_width*key_pan_size_pix(1), ...
                (chan_label_height/2)*key_pan_size_pix(2)]);

            mode_6_label_cont = uilabel(key_pan, 'Text', 'function Y', 'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', ...
                'left', 'FontSize', 11, 'Position', [chan_label_margin*key_pan_size_pix(1), mode_6_label.Position(2) - chan_label_height*key_pan_size_pix(2), ...
                chan_label_width*key_pan_size_pix(1), chan_label_height*key_pan_size_pix(2)]);

            mode_7_label = uilabel(key_pan, 'Text', 'Mode 7: Closed-loop sets frame index', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'Position', [chan_label_margin*key_pan_size_pix(1), ...
                mode_6_label_cont.Position(2) - chan_label_height*key_pan_size_pix(2), chan_label_width*key_pan_size_pix(1), chan_label_height*key_pan_size_pix(2)]);

            self.uneditableStyle = uistyle;
            self.editableStyle = uistyle;
            self.update_uneditable_style();
            

        end

        function update_gui(self)

            self.pretrial_table.Data = self.con.get_pretrial_data();
            self.intertrial_table.Data = self.con.get_intertrial_data();
            self.block_table.Data = self.con.get_blocktrial_data();
            self.posttrial_table.Data = self.con.get_posttrial_data();
            self.set_randomize_buttonGrp_selection();
            self.repetitions_box.Value = self.con.get_repetitions();
            self.isSelect_all_box.Value = self.con.get_isSelect_all();
            self.chan1_rate_box.Value = self.con.get_chan1_rate();
            self.chan2_rate_box.Value = self.con.get_chan2_rate();
            self.chan3_rate_box.Value = self.con.get_chan3_rate();
            self.chan4_rate_box.Value = self.con.get_chan4_rate();
            self.set_num_rows_buttonGrp_selection();
            set(self.exp_name_box,'Value', self.con.get_experiment_name());
            self.set_recent_file_menu_items();
            self.set_exp_length_display();
            self.con.doc_replace_grey_cells();
            self.update_column_widths();
            self.update_uneditable_style();

        end


        function close_application(self, src, event)

            clear('con');
            delete(src);
            evalin('base', 'clear con');

        end

        function set_randomize_buttonGrp_selection(self)
            if self.con.get_is_randomized()
                set(self.randomize_buttonGrp,'SelectedObject',self.isRandomized_radio);
            else
                set(self.randomize_buttonGrp,'SelectedObject',self.isSequential_radio);
            end
        end

        function set_num_rows_buttonGrp_selection(self)
            value = get(self.num_rows_3, 'Enable');
            if strcmp(value,'off') == 1
                %do nothing
            else
                if self.con.get_num_rows() == 1
                    set(self.num_rows_buttonGrp,'SelectedObject',self.num_rows_1);
                elseif self.con.get_num_rows() == 2
                    set(self.num_rows_buttonGrp,'SelectedObject',self.num_rows_2);
                elseif self.con.get_num_rows() == 3
                    set(self.num_rows_buttonGrp,'SelectedObject',self.num_rows_3);
                else
                    set(self.num_rows_buttonGrp,'SelectedObject',self.num_rows_4);
                end
            end
        end

        function set_recent_file_menu_items(self)
            files = self.con.get_recent_g4p_files();
            for i = 1:length(files)
                 [~,filename] = fileparts(files{i});
                if i > length(self.recent_file_menu_items)
                    self.recent_file_menu_items{end + 1} = uimenu(self.menu_open, 'Text', filename, 'MenuSelectedFcn', {@self.open_file, files{i}});
                else

                    set(self.recent_file_menu_items{i},'Text',filename);
                    set(self.recent_file_menu_items{i}, 'MenuSelectedFcn', {@self.open_file, files{i}});
                end
            end
        end

        function set_exp_length_display(self)
            
            length = self.con.get_est_exp_length();
            self.exp_length_display.Text = [num2str(round(length/60, 2)), ' minutes'];

        end

        function update_column_widths(self)

            %establish minimum width for each column
            max_len = cell(4,13);
            for i = 1:size(max_len,1)
                for j = 1:size(max_len,2)
                    if j == 2 || j == 3
                        max_len{i,j} = 20;
                    elseif j == 8 || j == 9 || j == 12
                        max_len{i,j} = 15;
                    else
                        max_len{i,j} = 10;
                    end
                end
            end

            tables = {self.pretrial_table, self.intertrial_table, self.posttrial_table, self.block_table};
            data = {self.con.get_pretrial_data(), self.con.get_intertrial_data(), self.con.get_posttrial_data(), self.con.get_blocktrial_data()};

            % get max width for each column in pretrial
            for table = 1:length(tables)
                for col = 1:size(data{table},2)
                    for row = 1:size(data{table},1)
                        width = length(data{table}{row, col});
                        if width > max_len{table,col}
                            max_len{table,col} = width;
                        end
                    end
                end
           end

            %convert from length in characters to pixels
            for i = 1:size(max_len,1)
                for j = 1:size(max_len,2)
                    max_len{i,j} = max_len{i,j}*5;
                end
            end

            self.pretrial_table.ColumnWidth = max_len(1,:);
            self.intertrial_table.ColumnWidth = max_len(2,:);
            self.posttrial_table.ColumnWidth = max_len(3,:);
            self.block_table.ColumnWidth = max_len(4,:);
        end


        function update_trial(self, src, event, a)

            new = event.NewData;
            x = event.Indices(1);
            y = event.Indices(2);
            trialtype = src.Tag;
            self.con.set_current_selected_cell(trialtype, event.Indices);
            if y == 1
                allow = 1;                
            else
                mode = self.con.get_trial_component(trialtype, x, 1);
                allow = self.con.check_editable(mode, y);              
            end
            if allow == 1
                self.con.update_trial_doc(new, x, y, trialtype);
            else
                self.con.create_error_box("You cannot edit that field in this mode.");
            end
            if y == 1
                self.con.clear_fields(new);
            end
            self.con.insert_greyed_cells();
            self.update_gui();

        end

        function preview_selection(self, src, event)
            %When a new cell is selected, first delete the current preview axes if
        %there

            delete(self.hAxes);
            delete(self.second_axes);

      %Determine whether we are previewing a file from a table or from the
      %listbox

            if src.Position == self.listbox_imported_files.Position
                is_table = 0;
            else
                if ~isempty(event.Indices)
                    is_table = 1;
                else
                    is_table = NaN;
                end
            end

            if is_table == 1

                 %Fill embedded list with imported files appropriate for the
                %selected cell
                self.provide_file_list(event);

                %get index of selected cell, table it resides in, and
                %string of the file in the cell if its index is 2-7
                file = self.check_table_selected(src, event);
       
            else
                file = self.listbox_imported_files.Value;
            end

            if ~strcmp(file,'') && ~strcmp(file, self.con.get_uneditable_text()) && ~isnan(is_table)
                self.con.preview_selection(is_table, file);
            else
                self.con.turn_off_screen();
            end


        end

        function [file] = check_table_selected(self, src, event)

            x_event_index = event.Indices(1);
            y_event_index = event.Indices(2);
            tag = src.Tag;
            if y_event_index > 1 && y_event_index< 8
                file = string(src.Data(x_event_index, y_event_index));
                if strcmp(file, "")
                    file = self.listbox_imported_files.Items{1};
                end
            else
                file = '';
            end

            if strcmp(tag, 'pre')
                table = "pre";
            elseif strcmp(tag, 'inter')
                table = "inter";
            elseif strcmp(tag, 'block')
                table = "block";
            elseif strcmp(tag, 'post')
                table = "post";
            end

            self.con.set_current_selected_cell(table, event.Indices);

        end

        % When a table cell is selected, this populates the imported files box with
        % all imported files available to fill that cell
        function provide_file_list(self, event)

            if event.Indices(2) == 2
                pats = self.con.get_patterns();
                fields = fieldnames(pats);
                if isempty(fields)
                    self.listbox_imported_files.Items = {''};
                    return;
                end

                for i = 1:length(fields)
                    filenames{i} = pats.(fields{i}).filename;
                end
                self.listbox_imported_files.Items = filenames;

            elseif event.Indices(2) == 3
                curr_cell = self.con.get_current_selected_cell();
                if strcmp(curr_cell.table, "pre")
                    mode = self.con.get_trial_component('pre', 1, 1);
                elseif strcmp(curr_cell.table, "inter")
                    mode = self.con.get_trial_component('inter', 1, 1);
                elseif strcmp(curr_cell.table, "post")
                    mode = self.con.get_trial_component('post', 1, 1);
                else
                    mode = self.con.get_trial_component('block', event.Indices(1), 1);
                end

                edit = self.con.check_editable(mode, 3);

                if edit == 0
                    self.con.create_error_box("You cannot edit the position function in this mode.");
                    return;
                end

                funcs = self.con.get_pos_funcs();
                fields = fieldnames(funcs);

                if isempty(fields)
                    self.listbox_imported_files.Items = {''};
                    return;
                end

                for i = 1:length(fields)
                    filenames{i} = funcs.(fields{i}).filename;
                end

                self.listbox_imported_files.Items = filenames;

           elseif event.Indices(2) > 3 && event.Indices(2) < 8

                ao = self.con.get_ao_funcs();
                fields = fieldnames(ao);
                if isempty(fields)
                    self.listbox_imported_files.Items = {''};
                    return;
                end

                for i = 1:length(fields)
                    filenames{i} = ao.(fields{i}).filename;
                end

                self.listbox_imported_files.Items = filenames;
            else
                return;
            end

            curr_cell = self.con.get_current_selected_cell();
            if strcmp(curr_cell.table,"pre")
                selected_file = self.con.get_trial_component('pre', 1, event.Indices(2));
                ind = find(strcmp(filenames, selected_file));
            elseif strcmp(curr_cell.table,"inter")
                selected_file = self.con.get_trial_component('inter', 1, event.Indices(2));
                ind = find(strcmp(filenames, selected_file));
            elseif strcmp(curr_cell.table, "block")
                selected_file = self.con.get_trial_component('block', event.Indices(1), event.Indices(2));
                ind = find(strcmp(filenames, selected_file));
            else
                selected_file = self.con.get_trial_component('post', 1, event.Indices(2));
                ind = find(strcmp(filenames, selected_file));
            end

            if ~isempty(ind)
                self.listbox_imported_files.Value = self.listbox_imported_files.Items{ind};
            else
                self.listbox_imported_files.Value = self.listbox_imported_files.Items{1};
            end

           
        end

        function set_preview_axes_function(self, axis_position, labels, yax, xax, xax2, linedur)

            self.second_axes = axes(self.preview_panel, 'Position', axis_position, 'XAxisLocation', 'top', 'YAxisLocation', 'right');
            self.hAxes = axes(self.preview_panel,'Position', self.second_axes.Position);
            plot_data = self.con.get_current_preview_file();

            self.inscreen_plot = plot(plot_data, 'parent', self.hAxes);
            self.hAxes.XLabel.String = labels.frameLabel;
            self.second_axes.XLabel.String = labels.timeLabel;
            set(self.hAxes, 'XLim', xax, 'YLim', yax, 'TickLength',[0,0]);
            self.hAxes.YLabel.String = labels.patLabel;
            yax2 = yax;
            set(self.second_axes, 'Position', self.hAxes.Position, 'XLim', xax2, 'YLim', yax2, 'TickLength', [0,0], 'Color', 'none');
            
            if linedur ~= 0
                line('XData', linedur, 'YData', yax, 'parent', self.hAxes, 'Color', [1 0 0], 'LineWidth', 2);
            end
            
            datacursormode(self.f, 'on');
 %           datacursormode(self.second_axes, 'on');

        end

        function set_preview_axes_pattern(self, axis_position, x, y)
            

            self.hAxes = axes(self.preview_panel, 'Position', axis_position, 'XTick', [], 'YTick', [] ,'XLim', x, 'YLim', y);
            ind = self.con.get_auto_preview_index();
            file =  self.con.get_current_preview_file();
            im = imshow(file(:,:,ind), 'parent', self.hAxes, 'Colormap',gray);

     %       set(im, 'parent', self.hAxes);

        end

        function add_trials_callback(self, ~, ~)

            self.con.add_trials_callback();
            self.update_gui();

        end

        function delete_trial(self, ~, ~)

            self.con.delete_trial();
            self.update_gui();

        end

        function select_all(self, src, ~)

            self.con.select_all(src);
            self.update_gui();

        end

        function invert_selection(self, ~, ~)

            self.con.invert_selection();
            self.update_gui();

        end

        function shift_up_callback(self, ~, ~)

            self.con.shift_up_callback();
            self.update_gui();

        end

        function shift_down_callback(self, ~, ~)

            self.con.shift_down_callback();
            self.update_gui();

        end

        function clear_all(self, ~, ~)

            self.con.clear_all();
            self.update_gui();

        end

        function autofill(self, ~, ~)

            self.con.autofill();
            self.update_gui();

        end

        function select_new_file(self, ~, ~)

            new_file = self.listbox_imported_files.Value;
            self.con.select_new_file(new_file);
            self.update_gui();

        end

        function full_preview(self, ~, ~)

            self.con.full_preview();

        end

        function update_preview_on_arena(self, ~, ~)

            self.con.update_preview_on_arena();
        end

        function preview_play(self, ~, ~)
            fr_rate = self.con.prepare_preview_play();
            curr_file = self.con.get_current_preview_file();
            index = self.con.get_auto_preview_index();
            if ~strcmp(curr_file,'') && length(curr_file(1,1,:)) > 1
                len = length(curr_file(1,1,:))-(index-1);
                xax = [0 length(curr_file(1,:,1))];
                yax = [0 length(curr_file(:,1,1))];

                im = imshow(curr_file(:,:,index), 'parent', self.hAxes, 'Colormap', gray);
     %           set(im,'parent', self.hAxes);
                set(self.hAxes, 'XLim', xax, 'YLim', yax );
                % is_paused = self.con.get_is_paused();

                for i = 1:len
                    is_paused = self.con.get_is_paused();
                    if is_paused == false
                        index = index + 1;
                        self.con.set_auto_preview_index(index);
                        if index > length(curr_file(1,1,:))
                            index = 1;
                            self.con.set_auto_preview_index(index);
                        end
                        %imagesc(self.model.current_preview_file.pattern.Pats(:,:,self.model.auto_preview_index), 'parent', hAxes);
                        set(im,'cdata',curr_file(:,:,index), 'parent', self.hAxes);
                        drawnow

                        pause(1/fr_rate);
                    end
                end
            end
            

        end

        function preview_pause(self, ~, ~)

            self.con.preview_pause();

        end
 %Stop the currently playing in-screen preview (returns to frame 1)
        function preview_stop(self, ~, ~)

            curr_cell = self.con.get_current_selected_cell();
            curr_file = self.con.get_current_preview_file();
            if strcmp(curr_cell.table, "")
                self.con.create_error_box("Please make sure you've selected a cell.");
                return;
            end
            % sets pause to true and resets the viewing index
            self.con.preview_stop_reset();

            %hAxes = gca;
            x = [0 length(curr_file(1,:,1))];
            y = [0 length(curr_file(:,1,1))];

            im = imshow(curr_file(:,:), 'parent', self.hAxes, 'Colormap', gray);
  %          set(im, 'parent', self.hAxes);
            set(self.hAxes, 'XLim', x, 'YLim', y);

        end
 %Move backward a single frame through pattern library in in-screen preview
        function frame_back(self, ~, ~)

            curr_file = self.con.get_current_preview_file();
            index = self.con.get_auto_preview_index();
            if ~strcmp(curr_file,'') && length(curr_file(1,1,:)) > 1
                self.con.set_auto_preview_index(index - 1);
                index = self.con.get_auto_preview_index();
                if index < 1
                    self.con.set_auto_preview_index(length(curr_file(1,1,:)));
                end

                self.plot_pattern();
                
            end
        end
 %Move forward a single frame through pattern library in in-screen
        %preview
        function frame_forward(self, ~, ~)
            curr_file = self.con.get_current_preview_file();
            index = self.con.get_auto_preview_index();
            if ~strcmp(curr_file,'') && length(curr_file(1,1,:)) > 1
                self.con.set_auto_preview_index(index + 1);
                index = self.con.get_auto_preview_index();
                if index > length(curr_file(1,1,:))
                    self.con.set_auto_preview_index(1);
                end

                self.plot_pattern();

            end
        end

        function plot_pattern(self)

            data = self.con.get_current_preview_file();
            index = self.con.get_auto_preview_index();
            preview_data = data(:,:,index);

            xax = [0 length(preview_data(1,:))];
            yax = [0 length(preview_data(:,1))];

            im = imshow(preview_data(:,:), 'parent', self.hAxes, 'Colormap', gray);
     %       set(im, 'parent', self.hAxes);
            set(self.hAxes, 'XLim', xax, 'YLim', yax);
            self.con.update_arena_pattern_index();

        end
        %Page up/down in fourth dimension through 4D pattern library (not yet
        %working)
        function page_up_4d(self, src, event)

        end

        function page_down_4d(self, src, event)

        end

        function update_experiment_name(self, src, ~)

            new_val = src.Value;
            self.con.update_experiment_name(new_val);
            self.update_gui();

        end

        function import(self, ~, ~)

            self.con.import();
            set(self.num_rows_1, 'Enable', 'off');
            set(self.num_rows_2, 'Enable', 'off');
            set(self.num_rows_3, 'Enable', 'off');
            set(self.num_rows_4, 'Enable', 'off');

            self.update_gui();

        end

        function open_file(self, ~, ~, filepath)
            self.con.open_file(filepath);
            self.update_gui();
            set(self.num_rows_1, 'Enable', 'off');
            set(self.num_rows_2, 'Enable', 'off');
            set(self.num_rows_3, 'Enable', 'off');
            set(self.num_rows_4, 'Enable', 'off');

        end

        function saveas(self, ~, ~)

            self.con.saveas();
            self.update_gui();

        end

        function copy_to(self, ~, ~)

            self.con.copy_to();
            self.update_gui();

        end

        function set_selected(self, ~, ~)

            self.con.set_selected();
            self.update_gui();

        end

        function open_settings(self, ~, ~)

            self.con.open_settings();

        end

        function calculate_experiment_length(self, ~, ~)

            self.con.calculate_experiment_length();
            self.update_gui();

        end

        function update_randomize(self, ~, event)

            new = event.NewValue.Text;
            self.con.update_randomize(new);
            self.update_gui();

        end

        function update_repetitions(self, src, ~)

            new = src.Value;
            self.con.update_repetitions(new);
            self.update_gui();

        end
        function dry_run(self, ~, ~)

            self.con.dry_run();

        end
        function open_run_gui(self, ~, ~)

            self.con.open_run_gui();

        end
        function update_chan1_rate(self, src, ~)

            new = src.Value;
            self.con.update_chan1_rate(new);
            self.update_gui();

        end
        function update_chan2_rate(self, src, ~)
            new = src.Value;
            self.con.update_chan2_rate(new);
            self.update_gui();

        end
        function update_chan3_rate(self, src, ~)
            new = src.Value;
            self.con.update_chan3_rate(new);
            self.update_gui();

        end
        function update_chan4_rate(self, src, ~)
            new = src.Value;
            self.con.update_chan4_rate(new);
            self.update_gui();

        end
        function update_rowNum(self, ~, event)
            new = event.NewValue.Text;
            if strcmp(new, '1 Row Screen')
                new_val = 1;
            elseif strcmp(new, '2 Row Screen')
                new_val = 2;
            elseif strcmp(new, '3 Row Screen') 
                new_val = 3;
            else
                new_val = 4;
            end
            self.con.update_rowNum(new_val);
            self.update_gui();

        end

        function update_uneditable_style(self)

            ue_color = self.con.get_uneditable_color();
            self.uneditableStyle.BackgroundColor = ue_color;

        end

        function style_cell(self, row, col, table, editable)
            
            table_handle = get_table_handle(self, table);
            configs = table_handle.StyleConfigurations;
            if editable

                numStyles =  1;
                targ = [];
                for c = 1:length(col)
                    for r = 1:size(configs,1)
                        if configs.TargetIndex{r} == [row col(c)]
                            targ(numStyles) = r;
                            numStyles = numStyles + 1;
                        end
                    end
                    if ~isempty(targ)
                        removeStyle(table_handle, targ);
                        targ = [];
                        numStyles =  1;
                        configs = table_handle.StyleConfigurations;
                    end
                end

            else
                for c = 1:length(col)
                    targ = [];
                    
                    for r = 1:size(configs,1)
                        if configs.TargetIndex{r} == [row col(c)]
                            targ(end+1) = 1;
                        else
                            targ(end+1) = 0;
                        end
                    end
                    if sum(targ) == 0 || isempty(targ)
                                                    
                        addStyle(table_handle, self.uneditableStyle, "cell", [row, col(c)]);
                    end
                
                end
            end
            

        end

        function table_handle = get_table_handle(self, trialtype)

            if strcmp(trialtype, 'pre')
                table_handle =  self.pretrial_table;
            elseif strcmp(trialtype, 'inter')
                table_handle = self.intertrial_table;
            elseif strcmp(trialtype, 'block')
                table_handle = self.block_table;
            elseif strcmp(trialtype, 'post')
                table_handle =  self.posttrial_table;
            end


        end


    end


end
