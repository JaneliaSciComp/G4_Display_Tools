classdef G4_designer_controller < handle %Made this handle class because was having trouble getting setters to work, especially with struct properties. 

%% Properties
    properties
        model_ %contains all data that does not persist with saving
        doc_ %contains all data that is stored in the saved file
        preview_con_ %controller for the fullscreen preview
        run_con_ %controller for the run window - can be opened independently
        settings_con_ %controller (containing the view and model) for the settings panel
        
%tables that show the trial data        
        pretrial_table_
        intertrial_table_
        block_table_
        posttrial_table_
        
%structs in which to load files as they are entered
        pre_files_
        block_files_
        inter_files_
        post_files_

        %GUI parts
        f_
        preview_panel_
        hAxes_
        second_axes_
        inscreen_plot_
        
        %channel gui objects
        chan1_
        chan1_rate_box_
        chan2_
        chan2_rate_box_
        chan3_
        chan3_rate_box_
        chan4_
        chan4_rate_box_
        
        %Settings GUI objects
        num_rows_buttonGrp_
        num_rows_3_
        num_rows_4_
        randomize_buttonGrp_
        isRandomized_radio_
        isSequential_radio_        
        repetitions_box_
        exp_name_box_
        
        %GUI Manipulation
        isSelect_all_box_
        pageUp_button_
        pageDown_button_
        exp_length_display_       
        listbox_imported_files_
        recent_g4p_files_
        recent_files_filepath_
        recent_file_menu_items_
        menu_open_
    end

    properties(Dependent)
        model
        preview_con
        run_con
        doc
        settings_con

        pretrial_table
        intertrial_table
        posttrial_table
        block_table
        
        pre_files
        inter_files
        block_files
        post_files
        
        %Tracking which cell is selected in each table
        pre_selected_index
        inter_selected_index
        post_selected_index
        block_selected_index
        
        current_preview_file
        current_selected_cell
        
        %Tracking position in in-window preview
        auto_preview_index
        is_paused
       
        chan1
        chan1_rate_box
        chan2
        chan2_rate_box
        chan3
        chan3_rate_box
        chan4
        chan4_rate_box
        num_rows_buttonGrp
        num_rows_3
        num_rows_4
        isSelect_all
        isRandomized_radio
        isSequential_radio
        randomize_buttonGrp
        repetitions_box
        isSelect_all_box
        f
        preview_panel
        hAxes
        second_axes
        exp_name_box
        pageUp_button
        pageDown_button
        exp_length_display
        
        listbox_imported_files
        recent_g4p_files
        recent_files_filepath
        recent_file_menu_items
        menu_open
        inscreen_plot
    end

%% Methods
    methods 
        
%% CONSTRUCTOR-------------------------------------------------------------

        function self = G4_designer_controller()
           
            self.model = G4_designer_model();
            self.doc = G4_document();
            self.settings_con = G4_settings_controller();
            self.preview_con = G4_preview_controller(self.doc);
          
            %get screensize to calculate gui dimensions
            screensize = get(0, 'screensize');

            %create figure
            self.f = figure('Name', 'Fly Experiment Designer', 'NumberTitle', 'off','units', 'normalized', 'MenuBar', 'none', ...
                'ToolBar', 'none', 'outerposition', [.05 .05, .9, .9]);
            
            %, 'Resize', 'off'

            %ALL REST OF PROPERTIES ARE DEFINED IN LAYOUT         
          self.pre_files = struct('pattern', self.doc.pretrial(2),...
               'position',self.doc.pretrial(3),'ao1',self.doc.pretrial(4),...
               'ao2',self.doc.pretrial(5),'ao3',self.doc.pretrial(6),...
               'ao4',self.doc.pretrial(7));
           self.block_files = struct('pattern', string(self.doc.block_trials(2)),...
               'position',string(self.doc.block_trials(3)),'ao1',string(self.doc.block_trials(4)),...
               'ao2',string(self.doc.block_trials(5)),'ao3',string(self.doc.block_trials(6)),...
               'ao4',string(self.doc.block_trials(7)));
           self.inter_files = struct('pattern', self.doc.intertrial(2),...
               'position',self.doc.intertrial(3),'ao1',self.doc.intertrial(4),...
               'ao2',self.doc.intertrial(5),'ao3',self.doc.intertrial(6),...
               'ao4',self.doc.intertrial(7));
           self.post_files = struct('pattern', self.doc.posttrial(2),...
               'position',self.doc.posttrial(3),'ao1',self.doc.posttrial(4),...
               'ao2',self.doc.posttrial(5),'ao3',self.doc.posttrial(6),...
               'ao4',self.doc.posttrial(7));

           self.layout_gui() ;
           self.update_gui() ;
           self.set_num_rows_buttonGrp_selection();
        end

%% GUI LAYOUT METHOD DECLARES ALL OBJECTS ON SCREEN------------------------

        function layout_gui(self)


            %LAYOUT PARAMETERS TO BE EDITED

            column_names = {'Mode', 'Pattern Name' 'Position Function', ...
                'AO 1', 'AO 2', 'AO 3', 'AO 4', ...
                'Frame Index', 'Frame Rate', 'Gain', 'Offset', 'Duration' ...
                'Select'};
            columns_editable = true;
            column_format = {'numeric', 'char', 'char', 'char', 'char','char', ...
                'char', 'char', 'numeric', 'numeric', 'numeric', 'numeric', 'logical'};
            font_size = 10;
            
            positions.pre = [.2, .92, .682, .06];
            positions.inter = [.2, .84, .682, .06];
            positions.block = [.2, .45, .682, .35];
            positions.post = [.2, .37, .682, .06];
            pos_panel = [.2, .08, .682, .27];
            left_margin = .003;
            chan_label_height = .1;
            chan_label_margin = .05;
            chan_label_width = .9;
            
            %NO FURTHER EDITING PARAMETERS

            %pretrial_label
            uicontrol(self.f, 'Style', 'text', 'String', 'Pre-Trial', ...
               'Units', 'normalized', 'FontSize', font_size, 'Position', ...
               [positions.pre(1) - .04, positions.pre(2) + .025, .04, .015]);

            self.pretrial_table = uitable(self.f, 'data', self.doc.pretrial, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.pre, 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
           'CellEditCallback', @self.update_model_pretrial, 'CellSelectionCallback', {@self.preview_selection, positions});

            % intertrial_label
            uicontrol(self.f, 'Style', 'text', 'String', 'Inter-Trial', ...
               'units', 'normalized', 'FontSize', font_size, 'Position', ...
               [positions.inter(1) - .04, positions.inter(2) + .025, .04, .015]);

            self.intertrial_table = uitable(self.f, 'data', self.doc.intertrial, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.inter, 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'CellEditCallback', @self.update_model_intertrial, 'CellSelectionCallback', {@self.preview_selection, positions});

            %blocktrial_label
            uicontrol(self.f, 'Style', 'text', 'String', 'Block Trials', ...
               'units', 'normalized', 'FontSize', font_size, 'Position', ...
               [positions.block(1) - .04, positions.block(2) + .5*positions.block(4), .04, .015]);

            self.block_table = uitable(self.f, 'data', self.doc.block_trials, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.block, 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'CellEditCallback', @self.update_model_block_trials, 'CellSelectionCallback', {@self.preview_selection, positions});

            %posttrial_label
            uicontrol(self.f, 'Style', 'text', 'String', 'Post-Trial', ...
               'units', 'normalized', 'FontSize', font_size, ...
               'Position', [positions.post(1) - .04, positions.post(2) + .025, .04, .015]);

            self.posttrial_table = uitable(self.f, 'data', self.doc.posttrial, 'columnname', column_names, ...
            'units', 'normalized', 'Position', positions.post, 'ColumnEditable', columns_editable, 'ColumnFormat', column_format, ...
            'CellEditCallback', @self.update_model_posttrial, 'CellSelectionCallback', {@self.preview_selection, positions});

            %add_trial_button
            uicontrol(self.f, 'Style', 'pushbutton','String','Add Trial','units', ...
                'normalized','Position', [positions.block(1) + positions.block(3) + left_margin, ...
                positions.block(2) + .02, .05, .02], 'Callback',@self.add_trials_callback);

            %delete_trial_button
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Delete Trial', ...
                'units', 'normalized', 'Position', [positions.block(1) + positions.block(3) + left_margin, positions.block(2), ...
                .05, .02], 'Callback', @self.delete_trial);

            self.isSelect_all_box = uicontrol(self.f, 'Style', 'checkbox', 'String', 'Select All', 'Value', self.model.isSelect_all, 'units', ...
                'normalized','FontSize', font_size, 'Position', [positions.block(1) + positions.block(3) - .03, ... 
                positions.block(2) + positions.block(4) + .0015, .05, .02], 'Callback', @self.select_all);

            %invert_selection
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Invert Selection', ...
                 'units', 'normalized', 'Position', [positions.block(1) + positions.block(3) + left_margin, ...
                positions.block(2) - .021, .05, .02], 'Callback', @self.invert_selection);

            %up_button
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Shift up', 'units', ...
                'normalized', 'Position', [positions.block(1) + positions.block(3) + left_margin, positions.block(2) + .65*positions.block(4), ...
                .05, .02], 'Callback', @self.shift_up_callback);

            %down_button
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Shift down', 'units', ...
                'normalized', 'Position', [positions.block(1) + positions.block(3) + left_margin, positions.block(2) + .35*positions.block(4), ...
                .05, .02], 'Callback', @self.shift_down_callback);
            
            % clear_all_button
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Clear All','FontSize', 12, 'units', ...
                'normalized', 'Position', [positions.block(1) + 1.03*positions.block(3), positions.pre(2), ...
                .054, positions.pre(4)], 'Callback', @self.clear_all);
            
            %autofill_button
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Auto-Fill', ...
                'FontSize', 14, 'units', 'normalized', 'Position', [pos_panel(1), pos_panel(2) - .05, .07, .05], ...
                'Callback', @self.autofill);


            self.preview_panel = uipanel(self.f, 'Title', 'Preview', 'FontSize', font_size, 'units', 'normalized', ...
                'Position', pos_panel);
            
            listbox_files_label = uicontrol(self.f, 'Style', 'text', 'String', 'Imported files for selected cell:',...
                'units', 'normalized', 'Position', [pos_panel(1) + pos_panel(3) + .01, pos_panel(2) + pos_panel(4) + .02, ...
                .09, .04], 'FontSize', font_size);
            
            self.listbox_imported_files = uicontrol(self.f, 'Style', 'listbox', 'String', {'Imported files here'},  ...
                'units', 'normalized', 'Position', [listbox_files_label.Position(1), listbox_files_label.Position(2) - .24, ...
                .09, .24],'Callback', @self.preview_selection);
            
             %select_imported_file_button
             uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Select', 'units', 'normalized', 'Position', ...
                [self.listbox_imported_files.Position(1) + .5*self.listbox_imported_files.Position(3), ...
                self.listbox_imported_files.Position(2) - .02, .045, .016], 'Callback', @self.select_new_file);
            

            %code to make the above panel transparent, so the preview image
            %can be seen.
            jPanel = self.preview_panel.JavaFrame.getPrintableComponent;
            jPanel.setOpaque(false)
            jPanel.getParent.setOpaque(false)
            jPanel.getComponent(0).setOpaque(false)
            jPanel.repaint

            %preview_button
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Preview', 'Fontsize', ...
                font_size, 'units', 'normalized', 'Position', [pos_panel(1) + pos_panel(3), ...
                pos_panel(2), .05, .045], 'Callback', @self.full_preview);

            %play_button
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Play', 'FontSize', ...
                font_size, 'units', 'normalized', 'Position', [pos_panel(1) + .5*pos_panel(3) - .08, ...
                pos_panel(2) - .03, .05, .02], 'Callback', @self.preview_play);

            %pause_button
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Pause', 'FontSize', ...
                font_size, 'units', 'normalized', 'Position', [pos_panel(1) + .5*pos_panel(3) - .025, ...
                pos_panel(2) - .03, .05, .02], 'Callback', @self.preview_pause);

            %stop_button = 
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Stop', 'FontSize', ...
                font_size, 'units', 'normalized', 'Position', [pos_panel(1) + .5*pos_panel(3) + .03, ...
                pos_panel(2) - .03, .05, .02], 'Callback', @self.preview_stop);

            %frameBack_button
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Back Frame', 'FontSize', ...
                font_size, 'units', 'normalized', 'Position', [pos_panel(1) + .5*pos_panel(3) - .135, ...
                pos_panel(2) - .03, .05, .02], 'Callback', @self.frame_back);

            %frameForward_button = 
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Forward Frame', ...
                'FontSize', font_size, 'units', 'normalized', 'Position', [pos_panel(1) + .5*pos_panel(3) ...
                + .085, pos_panel(2) - .03, .07, .02], 'Callback', @self.frame_forward);
            
            self.pageUp_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Page Up', ...
                'FontSize', font_size, 'units', 'normalized', 'Position', [pos_panel(1) + .5*pos_panel(3) + .16, ...
                pos_panel(2) - .03, .07, .02], 'Enable', 'off', 'Callback', @self.page_up_4d);
            
            self.pageDown_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Page Down', ...
                'FontSize', font_size, 'units', 'normalized', 'Position', [pos_panel(1) + .5*pos_panel(3) - .21, ...
                pos_panel(2) - .03, .07, .02], 'Enable', 'off', 'Callback', @self.page_down_4d);
            
            self.exp_name_box = uicontrol(self.f, 'Style', 'edit', ...
                'FontSize', 14, 'units', 'normalized', 'Position', ...
                [pos_panel(1)+ (pos_panel(3)/2) - .125, pos_panel(2) - .07, .25, .03], 'Callback', @self.update_experiment_name);
            
            %exp_name_label
            uicontrol(self.f, 'Style', 'text', 'String', 'Experiment Name: ', ...
                'FontSize', 16, 'units', 'normalized', 'Position', [pos_panel(1) + (pos_panel(3)/2) - .25, ...
                pos_panel(2) - .07, .1, .03]);


       %Drop down menu and associated labels and buttons
       

            menu = uimenu(self.f, 'Text', 'File');
            %menu_import
            uimenu(menu, 'Text', 'Import', 'Callback', @self.import);
            self.menu_open = uimenu(menu, 'Text', 'Open');
            %menu_recent_files
            uimenu(self.menu_open, 'Text', '.g4p file', 'Callback', {@self.open_file, ''});
            
                
            for i = 1:length(self.doc.recent_g4p_files)
                [~, filename] = fileparts(self.doc.recent_g4p_files{i});
                self.recent_file_menu_items{i} = uimenu(self.menu_open, 'Text', filename, 'Callback', {@self.open_file, self.doc.recent_g4p_files{i}});
            end
            
            if length(self.doc.recent_g4p_files) < 1
                self.recent_file_menu_items = {};
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
       
            exp_length_button = uicontrol(self.f, 'Style', 'pushbutton', 'units', 'normalized', 'Position', ...
                [left_margin, positions.block(2) + positions.block(4) + .04, .09,.02],'String', ...
                'Calculate Experiment Length', 'Callback', @self.calculate_experiment_length);
            
            self.exp_length_display = uicontrol(self.f, 'Style', 'text', 'units', 'normalized', 'Position', ...
                [exp_length_button.Position(1) + exp_length_button.Position(3) + left_margin, ...
                exp_length_button.Position(2), .07, .02], 'FontSize', 12, 'String', '');
                

       %Randomization
       
            self.randomize_buttonGrp = uibuttongroup(self.f, 'units', 'normalized', 'Position', ...
                [left_margin, positions.block(2) + positions.block(4) - .05, .08, .06], ...
                'SelectionChangedFcn', @self.update_randomize);
       
       
            self.isRandomized_radio = uicontrol(self.randomize_buttonGrp, 'Style', 'radiobutton', ...
                'String', 'Randomize Trials', 'FontSize', font_size, ...
                'units', 'normalized', 'Position', [.001, .55, .95, .4]);
            
            self.isSequential_radio = uicontrol(self.randomize_buttonGrp, 'Style', 'radiobutton', ...
                'String', 'Sequential Trials', 'FontSize', font_size, ...
                'units', 'normalized', 'Position', [.001,.1, .95, .4]);
% 
       %Repetitions

            self.repetitions_box = uicontrol(self.f, 'Style', 'edit', 'units', ...
                'normalized', 'Position', [.05, positions.block(2) + positions.block(4) - .08, ...
                .035, .02], 'Callback', @self.update_repetitions);

            %repetitions_label
            uicontrol(self.f, 'Style', 'text', 'String', ...
                'Repetitions:', 'FontSize', font_size, 'units', 'normalized', ...
                'Position', [left_margin, positions.block(2) + positions.block(4) - .08, .04, .02]);

%        %Dry Run
            %dry_run
            uicontrol(self.f, 'Style', 'pushbutton', 'String', ...
                'Dry Run', 'FontSize', font_size, 'units', 'normalized', 'Position', ...
                [pos_panel(1) + pos_panel(3), pos_panel(2) - .04, .05, .045],'Callback',@self.dry_run);

       %Actual run button
            uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Run Trials', 'FontSize', font_size, 'units', 'normalized', 'Position', ...
                 [left_margin, positions.block(2) + positions.block(4) - .15, .06, .06], 'Callback', @self.open_run_gui);

       %Channels to acquire

            chan_pan = uipanel(self.f, 'Title', 'Analog Input Channels', 'FontSize', font_size, 'units', 'normalized', ...
                'Position', [left_margin, positions.block(2) + positions.block(4) - .31, .15, .13]);

            self.chan1_rate_box = uicontrol(chan_pan, 'Style', 'edit', 'String', num2str(self.doc.chan1_rate), 'units', 'normalized', 'Position', ...
                [.65, .72, .25, .15],'Callback', @self.update_chan1_rate);

            %chan1_rate_label
            uicontrol(chan_pan, 'Style', 'text', 'String', 'Channel 1 Sample Rate', 'FontSize', font_size, ...
                'units', 'normalized', 'HorizontalAlignment', 'left', 'Position', [.05, .7, .5, .17]);

            self.chan2_rate_box = uicontrol(chan_pan, 'Style', 'edit', 'String', num2str(self.doc.chan2_rate), 'units', 'normalized', 'Position', ...
                [.65, .52, .25, .17], 'Callback', @self.update_chan2_rate);

            %chan2_rate_label
            uicontrol(chan_pan, 'Style', 'text', 'String', 'Channel 2 Sample Rate', 'FontSize', font_size, ...
                'units', 'normalized', 'HorizontalAlignment', 'left', 'Position', [.05, .5, .5, .17]);

            self.chan3_rate_box = uicontrol(chan_pan, 'Style', 'edit', 'String', num2str(self.doc.chan3_rate), 'units', 'normalized', 'Position', ...
                [.65, .32, .25, .17], 'Callback', @self.update_chan3_rate);

            %chan3_rate_label
            uicontrol(chan_pan, 'Style', 'text', 'String', 'Channel 3 Sample Rate', 'FontSize', font_size, ...
                'HorizontalAlignment', 'left', 'units', 'normalized', 'Position', [.05, .3, .5, .17]);

            self.chan4_rate_box = uicontrol(chan_pan, 'Style', 'edit', 'String', num2str(self.doc.chan4_rate), 'units', 'normalized', 'Position', ...
                [.65, .12, .25, .17], 'Callback', @self.update_chan4_rate);

            %chan4_rate_label
            uicontrol(chan_pan, 'Style', 'text', 'String', 'Channel 4 Sample Rate', 'FontSize', font_size, ...
                'HorizontalAlignment', 'left', 'units', 'normalized', 'Position', [.05, .1, .5, .17]);

            self.num_rows_buttonGrp = uibuttongroup(self.f, 'units', 'normalized', ...
                'Position', [left_margin, chan_pan.Position(2) - .05, chan_pan.Position(3), .04], 'SelectionChangedFcn', @self.update_rowNum);
       
       
            self.num_rows_3 = uicontrol(self.num_rows_buttonGrp, 'Style', ...
                'radiobutton', 'String', '3 Row Screen', 'FontSize', font_size, ...
                'units', 'normalized', 'Position', [.05, .05, .45, .9]);
            
            self.num_rows_4 = uicontrol(self.num_rows_buttonGrp, 'Style', 'radiobutton', 'String', '4 Row Screen', 'FontSize', font_size, ...
                'units', 'normalized', 'Position', [.5, .05, .45, .9]);
            
             
            key_pan = uipanel(self.f, 'Title', 'Mode Key:', 'BackgroundColor', [.75, .75, .75], ...
                'BorderType', 'none', 'FontSize', 13, 'units', 'normalized', ...
                'Position', [left_margin, self.num_rows_buttonGrp.Position(2) - .41, ...
                self.num_rows_buttonGrp.Position(3), .4]);
            
            
            mode_1_label = uicontrol(key_pan, 'Style', 'text', 'String', ...
                'Mode 1: Position Function', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left', 'FontSize', 11, 'units', 'normalized', ...
                'Position', [chan_label_margin, .85, chan_label_width, chan_label_height]);
            
            mode_2_label = uicontrol(key_pan, 'Style', 'text', 'String', 'Mode 2: Constant Rate', ...
                'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', 'left',...
                'FontSize', 11, 'units', 'normalized', 'Position', [chan_label_margin, ...
                mode_1_label.Position(2) - chan_label_height, chan_label_width, chan_label_height]);
            
            mode_3_label = uicontrol(key_pan, 'Style', 'text', 'String', 'Mode 3: Constant Index', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'normalized', 'Position', ...
                [chan_label_margin, mode_2_label.Position(2) - chan_label_height, chan_label_width, chan_label_height]);
            
            mode_4_label = uicontrol(key_pan, 'Style', 'text', 'String', 'Mode 4: Closed-loop sets frame rate', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'normalized', 'Position', ...
                [chan_label_margin, mode_3_label.Position(2) - chan_label_height, chan_label_width, chan_label_height]);
            
            mode_5_label = uicontrol(key_pan, 'Style', 'text', 'String', 'Mode 5: Closed-loop rate + offset', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'normalized', 'Position', ...
                [chan_label_margin, mode_4_label.Position(2) - chan_label_height/2, chan_label_width, chan_label_height/2]);
            
            mode_5_label_cont = uicontrol(key_pan, 'Style', 'text', 'String', 'position function', 'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', ...
                'left', 'FontSize', 11, 'units', 'normalized', 'Position', ...
                [chan_label_margin, mode_5_label.Position(2) - chan_label_height, chan_label_width, chan_label_height]);
            
            mode_6_label = uicontrol(key_pan, 'Style', 'text', 'String', 'Mode 6: Closed-loop rate X + position', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'normalized', 'Position', ...
                [chan_label_margin, mode_5_label_cont.Position(2) - chan_label_height/2, chan_label_width, chan_label_height/2]);
            
            mode_6_label_cont = uicontrol(key_pan, 'Style', 'text', 'String', 'function Y', 'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', ...
                'left', 'FontSize', 11, 'units', 'normalized', 'Position', ... 
                [chan_label_margin, mode_6_label.Position(2) - chan_label_height, chan_label_width, chan_label_height]);
            
            mode_7_label = uicontrol(key_pan, 'Style', 'text', 'String', 'Mode 7: Closed-loop sets frame index', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'normalized', 'Position', ...
                [chan_label_margin, mode_6_label_cont.Position(2) - chan_label_height, chan_label_width, chan_label_height]);

        end
        
%% CALLBACK FUNCTIONS------------------------------------------------------
    %% Edit callbacks to update values in the model
        %(Update functions which do not serve as a callback toward end)
    
        %Update pretrial model data

        function update_model_pretrial(self, ~, event)

            mode = self.doc.pretrial{1};
            new = event.EditData;
            y = event.Indices(2);
            allow = self.check_editable(mode, y);

            if allow == 1 %&& within_bounds == 1
                if y >= 2 && y <= 7

                    self.set_pretrial_files_(y, new);
                    self.doc.set_pretrial_property(y,new);
                elseif y ~= 13

                    self.doc.set_pretrial_property(y, new);

                else
                    self.doc.set_pretrial_property(y,new);
                end

            else

                self.create_error_box("You cannot edit that field in this mode.");

            end
            if y == 1
               
               self.clear_fields(str2num(new));
                
            end
            
             self.update_gui();
        end
        
        %Update block trials model data        
        
        function update_model_block_trials(self, ~, event)
            
            new = event.EditData;
            x = event.Indices(1);
            y = event.Indices(2);
            mode = self.doc.block_trials{x, 1};
            allow = self.check_editable(mode, y);
            
            
            if allow == 1
                if y >= 2 && y <= 7
     
                    self.set_blocktrial_files_(x, y, new);
                    self.doc.set_block_trial_property([x,y], new);
                    %src.Data{x,y} = new;
                
                else
                    self.doc.set_block_trial_property([x,y], new);
                end
                %self.doc.block_trials
            else
                
                self.create_error_box("You cannot edit that field in this mode.");

            end
            
            if y == 13 && new == 0
                self.deselect_selectAll();
            end
                
            
            if y == 1
                
                self.clear_fields(str2num(new));
            
            end
            

            self.update_gui();
            %disp(self.block_files);
            
        end
        
        %Update intertrial model data        
        
        function update_model_intertrial(self, ~, event)
            
            new = event.EditData;
            x = event.Indices(1);
            y = event.Indices(2);
            mode = self.doc.intertrial{1};
            allow = self.check_editable(mode, y);
            
            if allow == 1
                
                if y >= 2 && y <= 7
          
                    self.set_intertrial_files_(y,new);
                    self.doc.set_intertrial_property(y, new);
                elseif y~=13
                    self.doc.set_intertrial_property(y, new);
                %self.doc.intertrial;
                else
                    self.doc.set_intertrial_property(y, new);
                end
            else
                
                self.create_error_box("You cannot edit that field in this mode.");
                %self.layout_gui();
            end
            
            if y == 1
               
                self.clear_fields(str2num(new));
                
            end
            self.update_gui();
            %disp(self.inter_files);
        end
        
        %Update posttrial model data

        function update_model_posttrial(self, ~, event)
            new = event.EditData;
            x = event.Indices(1);
            y = event.Indices(2);
            mode = self.doc.posttrial{x, 1};
            allow = self.check_editable(mode, y);
            
            if allow == 1
                
                if y >= 2 && y <= 7
          
                    self.set_posttrial_files_(y,new);
                    self.doc.set_posttrial_property(y, new);
                elseif y~=13
                    self.doc.set_posttrial_property(y, new);
                %self.doc.intertrial;
                else
                    self.doc.set_posttrial_property(y, new);
                end

            else
                
                self.create_error_box("You cannot edit that field in this mode.");
                %self.layout_gui();
            end
            if y == 1
               
                self.clear_fields(str2num(new));
                
            end
            self.update_gui();
            %disp(self.post_files);
        
        end
        
        %Update repetitions        
        
        function update_repetitions(self, src, ~)
        
            new = str2num(src.String);
            self.doc.repetitions = new;
            self.update_gui();
            %self.doc.repetitions
        
        end

        %Update Randomization

        function update_randomize(self, ~, event)
            
            new = event.NewValue.String;
            if strcmp(new, 'Randomize Trials') == 1
                new_val = 1;
            else
                new_val = 0;
            end
            self.doc.is_randomized = new_val;
            self.update_gui();
            %self.doc.is_randomized
            
        end
       
        %Update channel sample rates
        function update_chan1_rate(self, src, ~)
            
            new = str2num(src.String);
            if rem(new,1000) ~= 0 && new ~= 0
                self.create_error_box("The value you've entered is not a multiple of 1000. Please double check your entry.");
            end
            self.doc.chan1_rate = new;
            if new == 0
                self.doc.is_chan1 = 0;
            else
                self.doc.is_chan1 = 1;
            end
            self.doc.set_config_data(new, 1);
            self.doc.update_config_file();
            self.update_gui();
            %self.doc.chan1_rate
            
        end
        
        function update_chan2_rate(self, src, ~)
            
            new = str2num(src.String);
            if rem(new,1000) ~= 0
                self.create_error_box("The value you've entered is not a multiple of 1000. Please double check your entry.");
            end
            self.doc.set_config_data(new,2);
            self.doc.chan2_rate = new;
            if new == 0
                self.doc.is_chan2 = 0;
            else
                self.doc.is_chan2 = 1;
            end
            self.doc.update_config_file();
            self.update_gui();
            %self.doc.chan2_rate
            
        end
        
        function update_chan3_rate(self, src, ~)
            
            new = str2num(src.String);
            if rem(new,1000) ~= 0
                self.create_error_box("The value you've entered is not a multiple of 1000. Please double check your entry.");
            end
            self.doc.chan3_rate = new;
            if new == 0
                self.doc.is_chan3 = 0;
            else
                self.doc.is_chan3 = 1;
            end
            self.doc.set_config_data(new, 3);
            self.doc.update_config_file();
            self.update_gui();
            %self.doc.chan3_rate
            
        end
        
        function update_chan4_rate(self, src, ~)
            
            new = str2num(src.String);
            if rem(new,1000) ~= 0
                self.create_error_box("The value you've entered is not a multiple of 1000. Please double check your entry.");
            end
            self.doc.chan4_rate = new;
            if new == 0
                self.doc.is_chan4 = 0;
            else
                self.doc.is_chan4 = 1;
            end
            self.doc.set_config_data(new, 4);
            self.doc.update_config_file();
            self.update_gui();
            %self.doc.chan4_rate
            
        end
        
        
        %Update the screen type (3 or 4 rows)
        function update_rowNum(self, ~, event)
            new = event.NewValue.String;
            if strcmp(new, '3 Row Screen') == 1
                new_val = 3;
            else
                new_val = 4;
            end
            %Check to make sure the number in the config file now matches
            %this new value
                
            self.doc.num_rows = new_val;%do this for other config updating
            self.doc.set_config_data(new_val, 0);
            self.doc.update_config_file();
            self.set_num_rows_buttonGrp_selection();

%            self.update_gui();
        end
        
        %Update the experiment name
        function update_experiment_name(self, src, ~)
            
            new_val = src.String;
           
            self.doc.experiment_name = new_val;
            self.set_exp_name();
            self.update_gui();
            if ~isempty(self.run_con)
                self.run_con.view.update_run_gui();
            end
            
        end
        
        
      %% Table manipulation callback functions  
       
        % Add a new row to the block trials table
        function add_trials_callback(self, ~, ~)
        
            [checked_count, checked_list] = self.check_num_trials_selected();
            
            if checked_count == 0
                self.add_trial(0)
            elseif checked_count == 1
                self.add_trial(checked_list(1));
            else
                for i = 1:length(checked_list)
                    self.add_trial(checked_list(i));
                end
            end
                
                
        
        end


        
        % Delete a row from the block trials table

        function delete_trial(self, ~, ~)
            
            [checked_count, checked_list] = self.check_num_trials_selected();
      
            if checked_count == 0
                self.create_error_box("You didn't select a trial to delete.");
            else
                
                for i = 1:checked_count
                     
                     self.doc.block_trials(checked_list(i) - (i-1),:) = [];

                end
                
            end
            
            self.update_gui();
 
        end
        
        %Shift one or more trials up in the block trials table

        function shift_up_callback(self, ~, ~)
            
            [checked_count, checked_rows] = self.check_num_trials_selected();
            
            if checked_count == 0
                
                self.create_error_box("Please select a trial to shift upward");
                
            elseif checked_count == 1
                
                self.move_trial_up(checked_rows);
                
            else
                
                for i = 1:length(checked_rows)
                    
                    self.move_trial_up(checked_rows(i));
                
                end
            end
        end

        % Shift one or more trials down in the block trials table

        function shift_down_callback(self, ~, ~)

            [checked_count, checked_rows] = self.check_num_trials_selected();
            
            if checked_count == 0
                
                self.create_error_box("Please select a trial to shift downward");
                
            elseif checked_count == 1
                
                self.move_trial_down(checked_rows);
                
            else
                
                for i = 0:length(checked_rows) - 1
                    
                    index = length(checked_rows) - i;
                    self.move_trial_down(checked_rows(index));
                
                end
            end
        end
        
        % Select (or deselect) all trials in the block trials table

        function select_all(self, src, ~)
          %assuming here that the number parameters will never differ between
          %trials. 
        
            l = length(self.doc.block_trials(1,:));
            if src.Value == false  
                for i = 1:length(self.doc.block_trials(:,1))
                    if self.doc.block_trials{i, l} == 1
                        self.doc.set_block_trial_property([i, l], false);
                    end
                end

            else
                for i = 1:length(self.doc.block_trials(:,1))
                    if cell2mat(self.doc.block_trials(i, l)) == 0
                        self.doc.set_block_trial_property([i, l], true);
                    end
                end

            end
            self.model.isSelect_all = src.Value;
            self.update_gui();
        
        end
        
        % Invert which trials in the block trial are selected

        function invert_selection(self, ~, ~)

            num = length(self.doc.block_trials(:,1));
            len = length(self.doc.block_trials(1,:));

            for i = 1:num
                if cell2mat(self.doc.block_trials(i,len)) == 0
                    self.doc.set_block_trial_property([i, len], true);
                elseif cell2mat(self.doc.block_trials(i,len)) == 1
                    self.doc.set_block_trial_property([i,len], false);
                else
                    disp('There has been an error, the selected value must be true or false');
                end
            end

            self.update_gui();

        end
        
        % Button to auto populate tables with the imported files in a
        % semi-intelligent way
        
%%%%%%%%%%%%%TO DO - AUTOFILL FUNCTION IS LARGE, BREAK IT UP        
        function autofill(self, ~, ~)

            pat_index = 1; %Keeps track of the indices of patterns that are actually displayed (not cut due to screen size discrepancy)
            pat_indices = []; %A record of all pattern indices that match the screen size.

            d = self.doc;

            pat_fields = fieldnames(d.Patterns);
            %Create an array of ID values from each pattern field
            for i = 1:length(pat_fields)
                pattern_ids{i} = d.Patterns.(pat_fields{i}).pattern.param.ID;
            end

            %Create an array of actual pattern names in order by ID, so if you
            %imported pattern0008, then pattern0001, then pattern0003, it will
            %still autofill 0001, 0003, 0008.
            pat_names = cell(length(pat_fields),1);
            for k = 1:length(pat_fields)
                [val, idx] = min(cell2mat(pattern_ids));
                pat_names{k} = d.Patterns.(pat_fields{idx}).filename;
                pattern_ids{idx} = 100000;

            end

            if ~isempty(fieldnames(d.Pos_funcs))

                pos_fields = fieldnames(d.Pos_funcs);
                pos_names = cell(length(pos_fields),1);
                for i = 1:length(pos_fields)
                    pos_ids{i} = d.Pos_funcs.(pos_fields{i}).pfnparam.ID;
                end
                for j = 1:length(pos_fields)
                    [val, idx] = min(cell2mat(pos_ids));
                    pos_names{j} = d.Pos_funcs.(pos_fields{idx}).filename;
                    pos_ids{idx} = 100000;
                end

            else
                pos_names = [];
            end
            if ~isempty(fieldnames(d.Ao_funcs))

                ao_fields = fieldnames(d.Ao_funcs);
                ao_names = cell(length(ao_fields),1);
                for i = 1:length(ao_fields)
                    ao_ids{i} = d.Ao_funcs.(ao_fields{i}).afnparam.ID;
                end
                for j = 1:length(ao_fields)
                    [val, idx] = min(cell2mat(ao_ids));
                    ao_names{j} = d.Ao_funcs.(ao_fields{idx}).filename;
                    ao_ids{idx} = 100000;
                end
            else
                ao_names = [];
            end

            num_pats = length(pat_names);
            num_pos = length(pos_names);
            num_ao = length(ao_names);

            if num_pats == 0
                pat1 = ''
            else
                pat1 = pat_names{pat_index};
                pat1_field = d.get_pattern_field_name(pat1);
            end

            if num_pats ~= 0 && length(d.Patterns.(pat1_field).pattern.Pats(:,1,1))/16 ~= self.doc.num_rows
                while length(d.Patterns.(pat1_field).pattern.Pats(:,1,1)) ~= self.doc.num_rows && pat_index < length(pat_names)
                    pat_index = pat_index + 1;
                    pat1 = pat_names{pat_index};
                end                          
            end

            if pat_index == length(pat_names) && length(d.Patterns.(pat1_field).pattern.Pats(:,1,1))/16 ~= self.doc.num_rows
                self.create_error_box("None of the patterns imported match the screen size selected. Please import a different folder or select a new screen size");
                return;
            end

            pat_indices(1) = pat_index;
            if pat_index <= num_pos
                pos_index = pat_index;
            else 
                pos_index = 1;
            end
            if pat_index <= num_ao
                ao_index = pat_index;
            else
                ao_index = 1;
            end
            
            if num_pos ~= 0
                pos1 = pos_names{pos_index}; %Set initial position and ao functions to correspond to initial pattern.
                pos1_field = d.get_posfunc_field_name(pos1);
                if num_pats ~=0 && length(d.Patterns.(pat1_field).pattern.Pats(1,1,:)) < ...
                    max(d.Pos_funcs.(pos1_field).pfnparam.func)
                pos1 = '';
                end
            else
                pos1 = '';

            end
            if num_ao ~= 0
                ao1 = ao_names{ao_index};
                ao1_field = d.get_aofunc_field_name(ao1);
            else
                ao1 = '';
            end    

            d.set_pretrial_property(2, pat1);
            d.set_pretrial_property(3, pos1);
            d.set_pretrial_property(4, ao1);

            %disable appropriate cells for mode 1
            d.set_pretrial_property(9, self.doc.colorgen());
            d.set_pretrial_property(10, self.doc.colorgen());
            d.set_pretrial_property(11, self.doc.colorgen());

            d.set_intertrial_property(2, pat1);
            d.set_intertrial_property(3, pos1);
            d.set_intertrial_property(4, ao1);

            %disable appropriate cells for mode 1
            d.set_intertrial_property(9, self.doc.colorgen());
            d.set_intertrial_property(10, self.doc.colorgen());
            d.set_intertrial_property(11, self.doc.colorgen());

            d.set_posttrial_property(2, pat1);
            d.set_posttrial_property(3, pos1);
            d.set_posttrial_property(4, ao1);

            d.set_posttrial_property(9, self.doc.colorgen());
            d.set_posttrial_property(10, self.doc.colorgen());
            d.set_posttrial_property(11, self.doc.colorgen());
            
            if num_pos ~= 0
                block_dur = d.Pos_funcs.(pos1_field).pfnparam.size/1000;
                d.set_block_trial_property([1,12], block_dur);
            end
            d.set_block_trial_property([1,2], pat1);
            d.set_block_trial_property([1,3], pos1);
            d.set_block_trial_property([1,4], ao1);
            

            d.set_block_trial_property([1,9], self.doc.colorgen());
            d.set_block_trial_property([1,10], self.doc.colorgen());
            d.set_block_trial_property([1,11], self.doc.colorgen());

            j = 1; %will end up as the count of how many patterns are used. Acts as the indices to "pat_indices"
            pat_index = pat_index + 1;
            pos_index = pos_index + 1;
            ao_index = ao_index + 1;

            if pat_index < num_pats

                for i = pat_index:num_pats

                    pat = pat_names{pat_index};
                    pat_field = d.get_pattern_field_name(pat);
                    if num_pos ~= 0
                        if pos_index > num_pos %Make sure indices are in range 
                            pos_index = 1;
                        end
                        pos = pos_names{pos_index};
                        pos_field = d.get_posfunc_field_name(pos);
                        dur = d.Pos_funcs.(pos_field).pfnparam.size/1000;
                    else

                        pos = '';
                    end

                    if num_ao ~= 0

                        if ao_index > num_ao
                            ao_index = 1;
                        end
                        ao = ao_names{ao_index};
                        ao_field = d.get_aofunc_field_name(ao);
                    else
                        ao = '';
                    end


                    if length(d.Patterns.(pat_field).pattern.Pats(:,1,1))/16 ~= d.num_rows
                        pat_index = pat_index + 1;
                        pos_index = pos_index + 1;
                        ao_index = ao_index + 1;

                        continue;
                    end
                    %Only executes if previous if statement did not. Sets new row's pattern
                    newrow = self.doc.block_trials(end, 1:end);
                    newrow{2} = pat; 

                    newrow{3} = pos; 

                    newrow{4} = ao; 
                    newrow{12} = dur;
                    pat_indices(j) = pat_index;
                    j = j + 1;
                    pat_index = pat_index + 1;
                    pos_index = pos_index + 1;
                    ao_index = ao_index + 1;

                    if ~strcmp(newrow{3},'')
                        if length(d.Patterns.(pat_field).pattern.Pats(1,1,:)) < ...
                               max(d.Pos_funcs.(pos_field).pfnparam.func)
                            newrow{3} = '';
                        end
                    end

                    d.set_block_trial_property([j,1],newrow);
                    self.block_files.pattern(end + 1) = string(newrow{2});
                    self.block_files.position(end + 1) = string(newrow{3});


                end
            end
            self.update_gui();
        end
        
        %Replace the currently selected cell in the tables with the
        %currently selected file in the imported files list.
        
        function select_new_file(self, ~, ~)
        
            new_file = self.listbox_imported_files.String{self.listbox_imported_files.Value};

            if strcmp(self.model.current_selected_cell.table, "pre")
                self.doc.set_pretrial_property(self.model.current_selected_cell.index(2), new_file);
            elseif strcmp(self.model.current_selected_cell.table, "inter")
                self.doc.set_intertrial_property(self.model.current_selected_cell.index(2), new_file);            
            elseif strcmp(self.model.current_selected_cell.table, "post")
                self.doc.set_posttrial_property(self.model.current_selected_cell.index(2), new_file);
            else
                self.doc.set_block_trial_property(self.model.current_selected_cell.index, new_file);
            end
            
            self.update_gui();
        end
        
        %Callback upon right click of table cell (does nothing atm)
        function right_click(self, src, event)
           
            disp("You right clicked the cell!");
            
        end
        
     %% File menu callback functions
        
        %Import a folder or file
        function import(self, ~, ~)

           options = {'Folder', 'File', 'Filtered File'};
           answer = listdlg('PromptString', 'Would you like to import a folder or a file?',...
               'SelectionMode', 'Single', 'ListString', options, 'ListSize', [180,60]);

           if answer == 1
               self.import_folder('');

           elseif answer == 2
               self.import_file('')

           elseif answer == 3
               str_to_match = self.get_filter_string();
               self.import_file(str_to_match);

           else
               %do nothing
           end
        end
        
        %Open a .g4p file. Optionally input a filepath
        function open_file(self, ~, ~, filepath)
            
            %Get filepath if one has not been inputted
            if strcmp(filepath,'')
                [filename, top_folder_path] = uigetfile('*.g4p');
                filepath = fullfile(top_folder_path, filename);
            else
                [top_folder_path, ~] = fileparts(filepath);
            end

            if isequal (top_folder_path,0)
                return; %Return if user canceled
            else

                self.doc.top_export_path = top_folder_path;
                self.doc.import_folder(top_folder_path);
                [~, exp_name, ~] = fileparts(filepath);

                if isempty(fieldnames(self.doc.Patterns))
                    %no patterns were successfully imported, so don't autofill
                    return;
                end

                data = self.doc.open(filepath);
                m = self.doc;
                d = data.exp_parameters;

                %Set parameters outside tables
                self.doc.experiment_name = exp_name;
                self.set_exp_name();
                m.repetitions = d.repetitions;
                m.is_randomized = d.is_randomized;
                m.is_chan1 = d.is_chan1;
                m.is_chan2 = d.is_chan2;
                m.is_chan3 = d.is_chan3;
                m.is_chan4 = d.is_chan4;
                m.chan1_rate = d.chan1_rate;
                m.set_config_data(d.chan1_rate, 1);
                m.chan2_rate = d.chan2_rate;
                m.set_config_data(d.chan2_rate, 2);
                m.chan3_rate = d.chan3_rate;
                m.set_config_data(d.chan3_rate, 3);
                m.chan4_rate = d.chan4_rate;
                m.set_config_data(d.chan4_rate, 4);
                m.num_rows = d.num_rows;
                m.set_config_data(d.num_rows, 0);
                self.doc.update_config_file();


                for k = 1:13

                    m.set_pretrial_property(k, d.pretrial{k});
                    m.set_intertrial_property(k, d.intertrial{k});
                    m.set_posttrial_property(k, d.posttrial{k});

                end

                for i = 2:length(m.block_trials(:, 1))
                    m.block_trials((i-(i-2)),:) = [];
                end
                block_x = length(d.block_trials(:,1));
                block_y = 1;

                for j = 1:block_x
                    if j > length(m.block_trials(:,1))
                        newrow = d.block_trials(j,1:end);
                        m.set_block_trial_property([j, block_y], newrow);
                    else
                        for n = 1:13
                            m.set_block_trial_property([j, n], d.block_trials{j,n});
                        end
                    end

                end

                self.insert_greyed_cells();     
                self.doc.set_recent_files(filepath);
                self.doc.update_recent_files_file();
                self.update_gui();

                if ~isempty(self.run_con)
                    self.run_con.view.update_run_gui();
                end
                set(self.num_rows_3, 'Enable', 'off');
                set(self.num_rows_4, 'Enable', 'off');
            end
        end
        
        %Save current experiment as a .g4p file and export necessary files

        function saveas(self, ~, ~)

            cut_date_off_name = regexp(self.doc.experiment_name,'-','split');
            
            if length(cut_date_off_name) > 1
                exp_name = cut_date_off_name{1}(1:end-2);
            else
                exp_name = self.doc.experiment_name;
            end
            
            dateFormat = 'mm-dd-yy_HH-MM-SS';
            dated_exp_name = strcat(exp_name, datestr(now, dateFormat));
            self.doc.experiment_name = dated_exp_name;
            [file, path] = uiputfile('*.g4p','File Selection', self.doc.experiment_name);
            full_path = fullfile(path, file);

            if file == 0
                return;
            end

            prog = waitbar(0,'Please wait...');

            waitbar(.33,prog,'Saving...');
            
            self.doc.replace_greyed_cell_values();
            self.doc.saveas(full_path, prog);
            
            if ~isempty(self.run_con)
                self.run_con.view.update_run_gui();
            end
            
            [path, file] = fileparts(full_path);
            file = [file,'.g4p'];
            g4p_path = fullfile(path, self.doc.experiment_name, file);
            self.insert_greyed_cells();
            self.doc.set_recent_files(g4p_path);
            self.doc.update_recent_files_file();
            self.update_gui();



        end
        
        %Copy selected block trial cell to the pretrial, intertrial, and/or posttrial       
        function copy_to(self, ~, ~)
            [checked_count, checked] = self.check_num_trials_selected();
            
            if checked_count == 0
            
                self.create_error_box("You must select a trial to copy over");
                
            elseif checked_count > 1
                
                self.create_error_box("You can only select one trial to copy");
                
            else 
                
                selected = self.doc.block_trials(checked,1:end-1);
                selected{:,end+1} = false;
                list = {'Pre-Trial', 'Inter-Trial', 'Post-Trial'};
                
                [indx,tf] = listdlg('ListString', list, 'PromptString', 'Select all desired locations');
                
                if tf == 0
                    %do nothing     
                else
                    
                    for i = 1:length(indx)
                    
                        if indx(i) == 1
                           
                            self.doc.pretrial = selected;
                            
                        elseif indx(i) == 2
                            
                            self.doc.intertrial = selected;
                            
                        elseif indx(i) == 3
                            
                            self.doc.posttrial = selected;
                            
                        else
                            disp("There has been an error, please try again.");
                        end
                    end
                end
                
                self.update_gui();
            end 
        end
        
        %Prompt the users for parameter values with which to populate all
        %selected trials

        function set_selected(self, ~, ~)
            
        %Check if any rows in the block are checked, add indexes of any
        %checked ones into checked_block
        
            [checked_block_count, checked_block] = self.check_num_trials_selected();
        
            prompt = {'Trial Mode:', 'Pattern Name:', 'Position Function:', ...
                'AO1:', 'AO2:', 'AO3:', 'AO4:', 'Frame Index:', 'Frame Rate:', ...
                'Gain:', 'Offset:', 'Duration:'};
            title = 'Trial Values';
            dims = [1 30];
            definput = {'1', 'default', 'default', '', '', '', '', '', '', ...
                '', '', '3'};
            answer = inputdlg(prompt, title, dims, definput);
            if isempty(answer)
                return;
            end
            
            answer{1} = str2double(answer{1});
            answer{8} = str2double(answer{8});
            answer{9} = str2double(answer{9});
            answer{10} = str2double(answer{10});
            answer{11} = str2double(answer{11});
            answer{12} = str2double(answer{12});

            answer{end+1} = false;

            %converts all data types properly
            for i = 1:length(answer)
                adjusted_answer{1,i} = answer{i};
            end
            
            
            if self.doc.pretrial{13} == true
                for i = length(adjusted_answer)
                    self.doc.set_pretrial_property(i, adjusted_answer{i});
                end
               
            end

            if self.doc.intertrial{13} == true
                for i = length(adjusted_answer)
                    self.doc.set_intertrial_property(i, adjusted_answer{i});
                end
            end

            if self.doc.posttrial{13} == true
                for i = length(adjusted_answer)
                    self.doc.set_posttrial_property(i, adjusted_answer{i});
                end
            end

            if checked_block_count ~= 0
                for i = 1:checked_block_count
                    for k = 1:length(adjusted_answer)
                        self.doc.set_block_trial_property([checked_block(i),k], adjusted_answer{k}) 
                    end
                end

            end
            
            self.update_gui();
            %disp(self.doc.block_trials(2,13));
        end
        
        function open_settings(self, ~, ~)
           
            self.settings_con.layout_view();
            
        end
        
        %% In screen preview related callbacks
        
         % Display preview of file when an appropriate table cell is
         % selected

        function preview_selection(self, varargin)
            
        %When a new cell is selected, first delete the current preview axes if
        %there
        
            delete(self.hAxes);
            delete(self.second_axes);
            
            src = varargin{1};
            event = varargin{2};
            if length(varargin) >= 3
                positions = varargin{3};
            end
            
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
                
                %get index of selected cell, table it resides in, and
                %string of the file in the cell if its index is 2-7
                 file = self.check_table_selected(src, event, positions);
   
                %Fill embedded list with imported files appropriate for the
                %selected cell
                 self.provide_file_list(event);
                 
            else
                
                file = self.listbox_imported_files.String{self.listbox_imported_files.Value};
             

            end

            %Get all parameters that might be needed for preview from
            %the trial the selected cell belongs to.
            
            if ~strcmp(file,'') && ~strncmp(file, '<html>',6) && ~isnan(is_table)
                [frame_rate, dur, patfield, posfield, aofield, file_type] = get_preview_parameters(self, is_table);

            %Now actually display the preview of whatever file is
            %selected


                self.display_inscreen_preview(frame_rate, dur, patfield, posfield, aofield, file_type); 
            end

            

        end
        
        
        %Play through the pattern library in in-screen preview
        
        function preview_play(self, ~, ~)

            self.model.is_paused = false;

            if strcmp(self.model.current_selected_cell.table, "pre")
                
                mode = self.doc.pretrial{1};
                if mode == 2
                    fr_rate = self.doc.pretrial{9};
                else
                    fr_rate = 30;
                end
                
            elseif strcmp(self.model.current_selected_cell.table, "inter")
               
                mode = self.doc.intertrial{1};
                if mode == 2
                    fr_rate = self.doc.intertrial{9};
                else
                    fr_rate = 30;
                end
                
            elseif strcmp(self.model.current_selected_cell.table, "block")
               
                mode = self.doc.block_trials{self.model.current_selected_cell.index(1), 1};
                if mode == 2
                    fr_rate = self.doc.block_trials{self.model.current_selected_cell.index(1), 9};
                else
                    fr_rate = 30;
                end

            elseif strcmp(self.model.current_selected_cell.table, "post")
                
                mode = self.doc.posttrial{1};
                if mode == 2
                    fr_rate = self.doc.posttrial{9};
                else
                    fr_rate = 30;
                end
                
            else
                self.create_error_box("Please make sure you have selected a cell and try again");
                return;
            end

            if ~strcmp(self.model.current_preview_file,'') && length(self.model.current_preview_file(1,1,:)) > 1
                len = length(self.model.current_preview_file(1,1,:));
                xax = [0 length(self.model.current_preview_file(1,:,1))];
                yax = [0 length(self.model.current_preview_file(:,1,1))];
                max_num = max(self.model.current_preview_file,[],[1 2]);
%                 adjusted_file = zeros(yax(2), xax(2), len);
%                 
%                 for i = 1:len
%                     adjusted_matrix = self.model.current_preview_file(:,:,i) ./ max_num(i);
%                     adjusted_file(:,:,i) = adjusted_matrix(:,:,1);
%                 end
                
                im = imshow(self.model.current_preview_file(:,:,self.model.auto_preview_index), 'Colormap', gray);
                set(im,'parent', self.hAxes);
                set(self.hAxes, 'XLim', xax, 'YLim', yax );
  
                for i = 1:len
                    if self.model.is_paused == false
                        self.model.auto_preview_index = self.model.auto_preview_index + 1;
                        if self.model.auto_preview_index > len
                            self.model.auto_preview_index = 1;
                        end
                        %imagesc(self.model.current_preview_file.pattern.Pats(:,:,self.model.auto_preview_index), 'parent', hAxes);
                        set(im,'cdata',self.model.current_preview_file(:,:,self.model.auto_preview_index), 'parent', self.hAxes);
                        drawnow

                        pause(1/fr_rate);



                    end
                 end
            end
        end
        
        %Pause the currently playing in-screen preview      
        
        function preview_pause(self, ~, ~)

            self.model.is_paused = true;

        end
        
        %Stop the currently playing in-screen preview (returns to frame 1)
        
        function preview_stop(self, ~, ~)
            
            if strcmp(self.model.current_selected_cell.table, "")
                self.create_error_box("Please make sure you've selected a cell.");
                return;
            end

            self.model.is_paused = true;
            self.model.auto_preview_index = 1;

                        %hAxes = gca; 
            x = [0 length(self.model.current_preview_file(1,:,1))];
            y = [0 length(self.model.current_preview_file(:,1,1))];
     
%             max_num = max(self.model.current_preview_file,[],[1 2]);    
%             adjusted_matrix = self.model.current_preview_file(:,:,self.model.auto_preview_index) ./ max_num(self.model.auto_preview_index);

            im = imshow(self.model.current_preview_file(:,:), 'Colormap', gray);
            set(im, 'parent', self.hAxes);
            set(self.hAxes, 'XLim', x, 'YLim', y);
                        
        end

        %Move forward a single frame through pattern library in in-screen
        %preview

        function frame_forward(self, ~, ~)

            if ~strcmp(self.model.current_preview_file,'') && length(self.model.current_preview_file(1,1,:)) > 1
                
                self.model.auto_preview_index = self.model.auto_preview_index + 1;
                if self.model.auto_preview_index > length(self.model.current_preview_file(1,1,:))
                    self.model.auto_preview_index = 1;
                end
                preview_data = self.model.current_preview_file(:,:,self.model.auto_preview_index);
                
                xax = [0 length(preview_data(1,:))];
                yax = [0 length(preview_data(:,1))];
                 
%                 max_num = max(preview_data,[],[1 2]);    
%                 adjusted_matrix = preview_data ./ max_num;

                im = imshow(preview_data(:,:), 'Colormap', gray);
                set(im, 'parent', self.hAxes);
                set(self.hAxes, 'XLim', xax, 'YLim', yax);

            end


        end
        
        %Move backward a single frame through pattern library in in-screen preview     
        
        function frame_back(self, ~, ~)

            if ~strcmp(self.model.current_preview_file,'') && length(self.model.current_preview_file(1,1,:)) > 1
                self.model.auto_preview_index = self.model.auto_preview_index - 1;

                if self.model.auto_preview_index < 1
                    self.model.auto_preview_index = length(self.model.current_preview_file(1,1,:));
                end
                
                data = self.model.current_preview_file;
                preview_data = data(:,:,self.model.auto_preview_index);
                
                xax = [0 length(preview_data(1,:))];
                yax = [0 length(preview_data(:,1))];
                 
%                 max_num = max(preview_data,[],[1 2]);    
%                 adjusted_matrix = preview_data ./ max_num;

                im = imshow(preview_data(:,:), 'Colormap', gray);
                set(im, 'parent', self.hAxes);
                set(self.hAxes, 'XLim', xax, 'YLim', yax);
            end

        end
        
        %Page up in fourth dimension through 4D pattern library (not yet
        %working)
        function page_up_4d(self, src, event)
        end
        
        %Page down in fourth dimension through 4D pattern library (not yet
        %working)
        function page_down_4d(self, src, event)
        end

        % Open a full, cohesive preview of the selected trial

        function full_preview(self, src, event)
                
          data = self.check_one_selected();
           if isempty(data)
               %do nothing
           else
               self.preview_con.model.update_trial_data(data);
               self.preview_con.layout_view();
           end
        end
        
        
     %% General experiment callbacks
        %Clear out all current data to design a new experiment

        function clear_all(self, ~, ~)
            
            question = "Make sure you have saved your experiment, or it will be lost.";
            answer = questdlg(question, 'Confirm Clear All', 'Continue', 'Cancel', 'Cancel');
            switch answer
                case 'Cancel'
                    return;
                case 'Continue'
                    
                     %keep instances of each class but clear all data
                    clear self.model;
                    delete(self.doc);
                    self.doc = G4_document();
                    self.settings_con = G4_settings_controller();
                    self.preview_con = G4_preview_controller(self.doc);
                    self.update_gui();
                    
                    
            end
            
        end
        
        %Calculate the approximate length of the current experiment and
        %display on the designer
        
        function calculate_experiment_length(self, ~, ~)
        
            total_dur = self.doc.pretrial{12} + self.doc.posttrial{12};
            for i = 1:length(self.doc.block_trials(:,1))
                total_dur = total_dur + (self.doc.block_trials{i,12} + self.doc.intertrial{12})*self.doc.repetitions;
            end
            total_dur = total_dur - self.doc.intertrial{12};
            self.update_exp_length(total_dur);
            
        
        end
        
        %Run a single trial on the screens (no analog input/output)

        function dry_run(self, ~, ~)
            self.doc.replace_greyed_cell_values();
            trial = self.check_one_selected;
            %block_trials = self.doc.block_trials();
            trial_mode = trial{1};
            trial_duration = trial{12};
            pat_field = self.doc.get_pattern_field_name(trial{2});
            if isempty(trial{8})
                trial_frame_index = 1;
            elseif strcmp(trial{8},'r')
                num_frames = length(self.doc.Patterns.(pat_field).pattern.Pats(1,1,:));
                trial_frame_index = randperm(num_frames,1);
            else
                trial_frame_index = str2num(trial{8});
            end
            
            trial_fr_rate = trial{9};
           
            
            %intertrial = self.doc.intertrial();
            if isempty(trial{10}) == 0
                LmR_gain = trial{10};
                LmR_offset = trial{11};
            else
                LmR_gain = 0;
                LmR_offset = 0;
            end
            %pre_start = 0;
            if strcmp(self.doc.top_export_path,'') == 1
                self.create_error_box("You must save the experiment before you can test it on the screens.");
                return;
            end
            experiment_folder = self.doc.top_export_path;
            answer = questdlg("If you have imported from multiple locations, you must save your experiment" + ...
                " before you can test it on the screens.", 'Confirm Save', 'Continue', 'Go back', 'Continue');
            
            if strcmp(answer, 'Go back')
                return;
            end
            
            connectHost;
            pause(10);
            
            Panel_com('change_root_directory', experiment_folder)
            start = questdlg('Start Dry Run?','Confirm Start','Start','Cancel','Start');
            switch start
                case 'Cancel'
                    
                    Panel_com('stop_display')
                    disconnectHost;
                    return;
                    
                case 'Start'
            
                    pattern_index = self.doc.get_pattern_index(trial{2});
                    func_index = self.doc.get_posfunc_index(trial{3});
                    
                    Panel_com('set_control_mode', trial_mode);
                    Panel_com('set_pattern_id', pattern_index); 
                    
                   if func_index ~= 0
                        Panel_com('set_pattern_func_id', func_index);
   
                   end
                    
                    if ~isempty(trial{10})
                        Panel_com('set_gain_bias',[LmR_gain LmR_offset]);
                       
                    end
                    
                    if trial_mode == 2
                        Panel_com('set_frame_rate', trial_fr_rate);
                        
                    end
                    
                    Panel_com('set_position_x', trial_frame_index);
                    
                    if trial_duration ~= 0
  
                        Panel_com('start_display', (trial_duration*10)); %duration expected in 100ms units
                        pause(trial_duration + 0.01)
                        
                    else
                        
                        Panel_com('start_display', 2000);
                        w = waitforbuttonpress; %If pretrial duration is set to zero, this
                        %causes it to loop until a button is press or
                        %mouse clicked

                    end
                    Panel_com('stop_display');
                    disconnectHost;

            end
        end
        
        %Open the conductor to run an experiment
        function open_run_gui(self, ~, ~)
            
            self.run_con = G4_conductor_controller(self.doc, self.settings_con);
            self.run_con.layout();
            
        end
        
%% Additional Table Manipulation Functions
        
        %Add a trial which is a copy of the inputted index (index of 0
        %defaults to adding a copy of the last trial)
        function add_trial(self, index)

            x = size(self.doc.block_trials,1) + 1; %vertical index of new trial
            y = 1;
            if index == 0
                newRow = self.doc.block_trials(end,1:end-1);
            else
                newRow = self.doc.block_trials(index,1:end-1);
            end
            newRow{end+1} = false;
            self.doc.set_block_trial_property([x,y],newRow);

   
            self.block_files.pattern(end + 1) = string(cell2mat(newRow(2)));
            self.block_files.position(end + 1) = string(cell2mat(newRow(3)));
            self.block_files.ao1(end + 1) = string(cell2mat(newRow(4)));
            self.block_files.ao2(end + 1) = string(cell2mat(newRow(5)));
            self.block_files.ao3(end + 1) = string(cell2mat(newRow(6)));
            self.block_files.ao4(end + 1) = string(cell2mat(newRow(7)));

            self.update_gui();
            
            
        
        end

        % Moves a single trial up in the block table
        function move_trial_up(self, index)

            
            selected = self.doc.block_trials(index, :);
            if index == 1
                self.create_error_box("I can't shift up any more.");
                return;
            else
                above_selected = self.doc.block_trials(index - 1, :);
            end


            self.doc.block_trials(index, :) = above_selected;
            self.doc.block_trials(index - 1, :) = selected;

            self.update_gui();
            
      
        end
        
        % Moves a single trial down in the block table
        function move_trial_down(self, index)
            
            %index = first index of selected row in the block trials
            %cell array
            selected = self.doc.block_trials(index, :);

            if index == length(self.doc.block_trials(:,1))
                self.create_error_box("I can't shift down any further.");
                return;
            else
                below_selected = self.doc.block_trials(index + 1, :);
            end

            self.doc.block_trials(index,:) = below_selected;
            self.doc.block_trials(index + 1, :) = selected;

            self.update_gui();
                
        end
        
        % Deselect the "Select All" box when any trial is deselected
        function deselect_selectAll(self)

            self.model.isSelect_all = 0;

        end
        
        % When a table cell is selected, this populates the imported files box with
        % all imported files available to fill that cell
        function provide_file_list(self, event)

            if event.Indices(2) == 2

                pats = self.doc.Patterns;
                fields = fieldnames(pats);
                if isempty(fields)
                    self.listbox_imported_files.String = {''};
                    
                    return;
                end

                for i = 1:length(fields)
                    filenames{i} = self.doc.Patterns.(fields{i}).filename;
                end
                self.listbox_imported_files.String = filenames;


            elseif event.Indices(2) == 3
                
                if strcmp(self.model.current_selected_cell.table, "pre")
                    mode = self.doc.pretrial{1};
                    
                elseif strcmp(self.model.current_selected_cell.table, "inter")
                    mode = self.doc.intertrial{1};
                elseif strcmp(self.model.current_selected_cell.table, "post")
                    mode = self.doc.posttrial{1};
                else
                    mode = self.doc.block_trials{event.Indices(1),1};
                end
                

                edit = self.check_editable(mode, 3);
                
                if edit == 0
                    self.create_error_box("You cannot edit the position function in this mode.");
  
                    return;
                end
                
                funcs = self.doc.Pos_funcs;
                fields = fieldnames(funcs);
                
                if isempty(fields)
                    self.listbox_imported_files.String = {''};
                    return;
                end

                for i = 1:length(fields)
                    filenames{i} = self.doc.Pos_funcs.(fields{i}).filename;
                end
                
                self.listbox_imported_files.String = filenames;
               

           elseif event.Indices(2) > 3 && event.Indices(2) < 8

                ao = self.doc.Ao_funcs;
                fields = fieldnames(ao);
                if isempty(fields)
                    self.listbox_imported_files.String = {''};
                    return;
                end

                for i = 1:length(fields)
                    filenames{i} = self.doc.Ao_funcs.(fields{i}).filename;
                end
                
                self.listbox_imported_files.String = filenames;
                

            else

                return;

            end
            
            if strcmp(self.model.current_selected_cell.table,"pre")
                selected_file = self.doc.pretrial{event.Indices(2)};
                ind = find(strcmp(filenames, selected_file));
                
            elseif strcmp(self.model.current_selected_cell.table,"inter")
                selected_file = self.doc.intertrial{event.Indices(2)};
                ind = find(strcmp(filenames, selected_file));
              
            elseif strcmp(self.model.current_selected_cell.table, "block")
                selected_file = self.doc.block_trials{event.Indices(1), event.Indices(2)};
                ind = find(strcmp(filenames, selected_file));
            else
                selected_file = self.doc.posttrial{event.Indices(2)};
                ind = find(strcmp(filenames, selected_file));
              
            end
            
            if ~isempty(ind)
                self.listbox_imported_files.Value = ind;
            else
                self.listbox_imported_files.Value = 1;
            end


        end
        
        % When the mode is changed, clear and disable appropriate fields
        function clear_fields(self, mode)
            
            pos_fields = fieldnames(self.doc.Pos_funcs);
            pat_fields = fieldnames(self.doc.Patterns);
            pos = self.doc.colorgen();
            indx = [];
            rate = self.doc.colorgen();
            gain = self.doc.colorgen();
            offset = self.doc.colorgen();

            if mode == 1

                pat_field = self.get_or_insert_pattern();
                index_of_pat = find(strcmp(pat_fields(:), pat_field));

                if index_of_pat > length(pos_fields)
                    index_of_pat = rem(length(pos_fields), index_of_pat);
                end
                if ~isempty(index_of_pat)
                    pos_field = pos_fields{index_of_pat};
                    pos = self.doc.Pos_funcs.(pos_field).filename;

                end
                self.set_mode_dep_props(pos, indx, rate, gain, offset);

            elseif mode == 2

                pat_field = self.get_or_insert_pattern();
                rate = 60;
                self.set_mode_dep_props(pos, indx, rate, gain, offset);
                %frame rate, clear others


            elseif mode == 3

                pat_field = self.get_or_insert_pattern();

                indx = 1;
                self.set_mode_dep_props(pos, indx, rate, gain, offset);
                %frame index, clear others

            elseif mode == 4
                pat_field = self.get_or_insert_pattern();
                gain = 1;
                offset = 0;
                self.set_mode_dep_props(pos, indx, rate, gain, offset);
                %gain, offset, clear others

            elseif mode == 5
                pat_field = self.get_or_insert_pattern();
                index_of_pat = find(strcmp(pat_fields(:), pat_field));
                if index_of_pat > length(pos_fields)
                    index_of_pat = rem(length(pos_fields), index_of_pat);
                end
                pos_field = pos_fields{index_of_pat};
                pos = self.doc.Pos_funcs.(pos_field).filename;
                gain = 1;
                offset = 0;
                self.set_mode_dep_props(pos, indx, rate, gain, offset);
                %pos, gain, offset, clear others

            elseif mode == 6

                pat_field = self.get_or_insert_pattern();
                index_of_pat = find(strcmp(pat_fields(:), pat_field));
                if index_of_pat > length(pos_fields)
                    index_of_pat = rem(length(pos_fields), index_of_pat);
                end
                pos_field = pos_fields{index_of_pat};
                pos = self.doc.Pos_funcs.(pos_field).filename;
                gain = 1;
                offset = 0;
                self.set_mode_dep_props(pos, indx, rate, gain, offset);
                %pos, gain, offset, clear others

            elseif mode == 7
                pat_field = self.get_or_insert_pattern();
                self.set_mode_dep_props(pos, indx, rate, gain, offset);
                %clear all

            elseif isempty(mode)

                pos = self.doc.colorgen();
                indx = self.doc.colorgen();
                rate = self.doc.colorgen();
                gain = self.doc.colorgen();
                offset = self.doc.colorgen();
                self.set_mode_dep_props(pos, indx, rate, gain, offset);
                if strcmp(self.model.current_selected_cell.table,"pre")
                    self.doc.set_pretrial_property(2, self.doc.colorgen());
                    for i = 4:7
                        self.doc.set_pretrial_property(i,self.doc.colorgen());
                    end
                    self.doc.set_pretrial_property(12,self.doc.colorgen());

                elseif strcmp(table,'inter') || strcmp(self.model.current_selected_cell.table,"inter") == 1
                    self.doc.set_intertrial_property(2, self.doc.colorgen());
                    for i = 4:7
                        self.doc.set_intertrial_property(i,self.doc.colorgen());
                    end
                    self.doc.set_intertrial_property(12,self.doc.colorgen());


                elseif strcmp(table, 'post') || strcmp(self.model.current_selected_cell.table,"post") == 1
                    self.doc.set_posttrial_property(2, self.doc.colorgen());
                    for i = 4:7
                        self.doc.set_posttrial_property(i,self.doc.colorgen());
                    end
                    self.doc.set_posttrial_property(12,self.doc.colorgen());


                else
                    x = self.model.current_selected_cell.index(1);
                    self.doc.set_block_trial_property([x,2], self.doc.colorgen());
                    for i = 4:7
                        self.doc.set_block_trial_property([x,i],self.doc.colorgen());
                    end
                    self.doc.set_block_trial_property([x,12],self.doc.colorgen());
                end

            end

        end
        
        % Set all properties dependent on the mode
        function set_mode_dep_props(self, pos, indx, rate, gain, offset, varargin)

            if strcmp(self.model.current_selected_cell.table,"pre") 
                self.doc.set_pretrial_property(3, pos);
                self.doc.set_pretrial_property(8, indx);
                self.doc.set_pretrial_property(9, rate);
                self.doc.set_pretrial_property(10, gain);
                self.doc.set_pretrial_property(11, offset);
                self.set_pretrial_files_(3, pos);

                if ~isempty(self.doc.pretrial{1})
                    self.doc.set_pretrial_property(4,'');
                    self.doc.set_pretrial_property(5,'');
                    self.doc.set_pretrial_property(6,'');
                    self.doc.set_pretrial_property(7,'');
                    self.doc.set_pretrial_property(12,self.doc.trial_data.trial_array{12});
                end

            elseif strcmp(self.model.current_selected_cell.table,"inter") == 1
                self.doc.set_intertrial_property(3, pos);
                self.doc.set_intertrial_property(8, indx);
                self.doc.set_intertrial_property(9, rate);
                self.doc.set_intertrial_property(10, gain);
                self.doc.set_intertrial_property(11, offset);
                self.set_intertrial_files_(3,pos);

                if ~isempty(self.doc.intertrial{1})
                    self.doc.set_intertrial_property(4,'');
                    self.doc.set_intertrial_property(5,'');
                    self.doc.set_intertrial_property(6,'');
                    self.doc.set_intertrial_property(7,'');
                    self.doc.set_intertrial_property(12,self.doc.trial_data.trial_array{12});
                end

            elseif strcmp(self.model.current_selected_cell.table,"post") == 1
                self.doc.set_posttrial_property(3, pos);
                self.doc.set_posttrial_property(8, indx);
                self.doc.set_posttrial_property(9, rate);
                self.doc.set_posttrial_property(10, gain);
                self.doc.set_posttrial_property(11, offset);
                self.set_posttrial_files_(3,pos);

                if ~isempty(self.doc.posttrial{1})
                    self.doc.set_posttrial_property(4,'');
                    self.doc.set_posttrial_property(5,'');
                    self.doc.set_posttrial_property(6,'');
                    self.doc.set_posttrial_property(7,'');
                    self.doc.set_posttrial_property(12,self.doc.trial_data.trial_array{12});
                end


            else
                x = self.model.current_selected_cell.index(1);
                self.doc.set_block_trial_property([x,3], pos);
                self.doc.set_block_trial_property([x,8], indx);
                self.doc.set_block_trial_property([x,9], rate);
                self.doc.set_block_trial_property([x,10], gain);
                self.doc.set_block_trial_property([x,11], offset);
                self.set_blocktrial_files_(self.model.current_selected_cell.index(1),3,pos);

                if ~isempty(self.doc.block_trials{x,1})
                    self.doc.set_block_trial_property([x,4],'');
                    self.doc.set_block_trial_property([x,5],'');
                    self.doc.set_block_trial_property([x,6],'');
                    self.doc.set_block_trial_property([x,7],'');
                    self.doc.set_block_trial_property([x,12],self.doc.trial_data.trial_array{12});
                end
            end
            self.update_gui();
        end
        
        % Check which and how many block trials are selected
        function [num_checked, checked_rows] = check_num_trials_selected(self)

            checkbox_data = horzcat(self.doc.block_trials(1:end,end));
            checked_rows = find(cell2mat(checkbox_data));
            num_checked = length(checked_rows);

        end
        
        % Check which table the currently selected cell belongs to
        function [file] = check_table_selected(self, src, event, positions)
        
            x_event_index = event.Indices(1);
            y_event_index = event.Indices(2);
            self.model.current_selected_cell.index = event.Indices;
            if y_event_index > 1 && y_event_index< 8

                file = string(src.Data(x_event_index, y_event_index));

            else

                file = '';

            end

            if round(src.Position,4) - round(positions.pre,4) == 0
                self.model.current_selected_cell.table = "pre";
            elseif round(src.Position,4) - round(positions.inter,4) == 0
                self.model.current_selected_cell.table = "inter";
            elseif round(src.Position,4) - round(positions.block,4) == 0
                self.model.current_selected_cell.table = "block";
            elseif round(src.Position,4) - round(positions.post,4) == 0
                self.model.current_selected_cell.table = "post";
            end
        
        end
        
        % Get data from selected trial or throw error if more than one
        % trial is selected

        function [data] = check_one_selected(self)

            [checked_block_count,checked_block] = self.check_num_trials_selected();

             %Figures out which table has the selected row and ensures no more than
             %one table has a selected row
            if checked_block_count ~= 0
                checked_trial = 'block';
            end


            if self.doc.pretrial{13} == 1
                pretrial_checked = 1;
                checked_trial = 'pre';
            else 
                pretrial_checked = 0;

            end

            if self.doc.intertrial{13} == 1
                intertrial_checked = 1;
                checked_trial = 'inter';
            else 
                intertrial_checked = 0;
            end

            if self.doc.posttrial{13} == 1
                posttrial_checked = 1;
                checked_trial = 'post';
            else 
                posttrial_checked = 0;
            end

            all_checked = checked_block_count + pretrial_checked + intertrial_checked ...
                + posttrial_checked;

      %throw error if more or less than one is selected
            if all_checked == 0 
                self.create_error_box("You must selected a trial for this functionality");
                data = [];
            elseif all_checked > 1
                self.create_error_box("You can only select one trial for this functionality");
                data = [];
            else
      %set data to correct table
                if strcmp(checked_trial,'pre')
                    data = self.doc.pretrial;
                elseif strcmp(checked_trial,'inter')
                    data = self.doc.intertrial;
                elseif strcmp(checked_trial, 'block')
                    data = self.doc.block_trials(checked_block(1),:);
                elseif strcmp(checked_trial, 'post')
                    data = self.doc.posttrial;
                else
                    self.create_error_box("Something went wrong. Please make sure you have exactly one trial selected and try again.");
                end
            end
        end


        
%% Additional Previewing Functions
    
        % Plot a position or AO function
        function [func_line] = plot_function(self, fig, func, position, graph_title, x_label, y_label)

                xlim = [0 length(func(1,:))];
                ylim = [min(func) max(func)];
                func_axes = axes(fig, 'units','normalized','Position', position, ...
                    'XLim', xlim, 'YLim', ylim);
                p = plot(func);
                set(p, 'parent', func_axes);
                func_line = line('XData',[self.model.auto_preview_index,self.model.auto_preview_index],'YData',[ylim(1), ylim(2)]);
                title(graph_title);
                xlabel(x_label);
                ylabel(y_label);
        end
        
        % Display the in-screen preview
%%%%%%TO DO: THIS FUNCTION IS LONG, SEE IF YOU CAN BREAK IT UP    
        function display_inscreen_preview(self, frame_rate, dur, patfield, funcfield, aofield, file_type)  
    
            if strcmp(file_type, 'pat') && ~strcmp(patfield,'')
                
                self.model.auto_preview_index = self.check_pattern_dimensions(patfield);
                self.model.current_preview_file = self.doc.Patterns.(patfield).pattern.Pats;
                grayscale_val = self.doc.Patterns.(patfield).pattern.gs_val;

                x = [0 length(self.model.current_preview_file(1,:,1))];
                y = [0 length(self.model.current_preview_file(:,1,1))];
                adjusted_file = zeros(y(2),x(2),length(self.model.current_preview_file(1,1,:)));
                %max_num = max(max(self.model.current_preview_file,[],2));
                max_num = (2^grayscale_val) - 1;
                
                for i = 1:length(self.model.current_preview_file(1,1,:))

                    adjusted_matrix = self.model.current_preview_file(:,:,i) ./ max_num;
                    adjusted_file(:,:,i) = adjusted_matrix(:,:,1);
                end
                self.model.current_preview_file = adjusted_file;
                
                
                self.hAxes = axes(self.preview_panel, 'units', 'normalized', 'OuterPosition', [.1, .04, .8 ,.9], 'XTick', [], 'YTick', [] ,'XLim', x, 'YLim', y);
                im = imshow(adjusted_file(:,:,self.model.auto_preview_index), 'Colormap',gray);

                set(im, 'parent', self.hAxes);

            elseif strcmp(file_type, 'pos') && ~strcmp(funcfield,'')
                
                self.model.current_preview_file = self.doc.Pos_funcs.(funcfield).pfnparam.func;
                
                self.second_axes = axes(self.preview_panel, 'units', 'normalized', 'Position', [.1, .15, .8 ,.7], 'XAxisLocation', 'top', 'YAxisLocation', 'right');
                self.hAxes = axes(self.preview_panel,'units', 'normalized', 'Position', self.second_axes.Position);
                
                timeLabel = 'Time (ms)';
                patLabel = 'Pattern';
                frameLabel = 'Frame Number';
                yax = [min(self.model.current_preview_file) max(self.model.current_preview_file)];
                
                if frame_rate == 1000
                    time_in_ms = length(self.model.current_preview_file(1,:));
                    num_frames = frame_rate*(1/1000)*time_in_ms;
                    
                else
                    time_in_ms = length(self.model.current_preview_file(1,:))*2;
                    num_frames = frame_rate*(1/1000)*time_in_ms;
                    
                end
                
                xax = [0 num_frames];
                xax2 = [0 time_in_ms];

                self.inscreen_plot = plot(self.model.current_preview_file, 'parent', self.hAxes);
                self.hAxes.XLabel.String = frameLabel;
                self.second_axes.XLabel.String = timeLabel;
                set(self.hAxes, 'XLim', xax, 'YLim', yax, 'TickLength',[0,0]);
                self.hAxes.YLabel.String = patLabel;
                yax2 = yax;
                set(self.second_axes, 'Position', self.hAxes.Position, 'XLim', xax2, 'YLim', yax2, 'TickLength', [0,0], 'Color', 'none');

                if dur <= xax2(2)
                    if frame_rate == 1000
                        linedur = [dur, dur];
                        
                    else
                        linedur = [dur/2, dur/2];
                    end

                    line('XData', linedur, 'YData', yax, 'parent', self.hAxes, 'Color', [1 0 0], 'LineWidth', 2);

                end
                datacursormode on;
                

            elseif strcmp(file_type, 'ao') && ~strcmp(aofield,'')

                self.model.current_preview_file = self.doc.Ao_funcs.(aofield).afnparam.func;
                self.second_axes = axes(self.preview_panel, 'units', 'normalized', 'OuterPosition', [.1, .04, .8 ,.9], 'XAxisLocation', 'top', 'YAxisLocation', 'right');

                self.hAxes = axes(self.preview_panel,'units', 'normalized', 'OuterPosition', [.1, .04, .8 ,.9]);
                
                plot(self.model.current_preview_file, 'parent', self.hAxes);
                time_in_ms = length(self.model.current_preview_file(1,:));

                xax = [0 length(self.model.current_preview_file(1,:))];
                yax = [min(self.model.current_preview_file) max(self.model.current_preview_file)];

                timeLabel = 'Time (ms)';
                patLabel = 'Pattern';
                frameLabel = 'Frame Number';
                set(self.hAxes, 'XLim', xax, 'YLim', yax, 'TickLength',[0,0]);
                self.hAxes.XLabel.String = timeLabel;
                self.hAxes.YLabel.String = patLabel;

                num_frames = frame_rate*(1/1000)*time_in_ms;
                xax2 = [0 num_frames];
                yax2 = yax;
                set(self.second_axes, 'Position', self.hAxes.Position, 'XLim', xax2, 'YLim', yax2, 'TickLength', [0,0], 'Color', 'none');
                self.second_axes.XLabel.String = frameLabel;
                
                 datacursormode on;
 

            end
        end
        
        function mouse_over_plot(self, src, ~)
            fig = src;
            obj = hittest(fig);

            
            
            if isprop(obj, 'Position') && length(obj.Position) == 4
                
                tol = eps(obj.Position);
  
                if obj.Position - self.hAxes.Position <= tol
                        
                    point = get(self.f, 'currentpoint');
                    pause(.1);
                    point2 = get(self.f,'currentpoint');
                    
                    if point == point2
                        xclick = point(1,1,1);
                        yclick = point(1,2,1);
                        [xidx, yidx] = self.findclosestpoint2D(xclick,yclick);
                        
                        %make a "tool tip" that displays this animal.
                        xoffset=5;
                        yoffset=2;

                        delete(findobj(self.f,'tag','mytooltip')); %delete last tool tip
                        text(yidx + xoffset,self.model.current_preview_file(yidx)...
                        + yoffset, ['Point: ',yidx, ', ', self.model.current_preview_file(yidx)]);
                    %,'backgroundcolor',[1 1 .8],'tag','mytooltip', 'edgecolor',[0 0 0]
                        
                    end


                    
                  
                else
                    delete(findobj(fig,'tag','mytooltip')); %delete last tool tip

                end
            end
            
        end
        
        function [thispointx, thispointy] = findclosestpoint2D(self, xclick,yclick)
            %this function checks which point in the plotted line "datasource"
            %is closest to the point specified by xclick/yclick. It's kind of 
            %complicated, but this isn't really what this demo is about...
            xclick_adjusted = xclick - ...
                (self.preview_panel.Position(3)*self.hAxes.Position(1) + self.preview_panel.Position(1));
            yclick_adjusted = yclick - ...
                (self.preview_panel.Position(4)*self.hAxes.Position(2) + self.preview_panel.Position(2));
            total_pix = getpixelposition(self.f);
            xclick_pixels = xclick*total_pix(3);
            yclick_pixels = yclick*total_pix(4);
            xclick_pixels_adjusted = xclick_pixels - ((xclick - xclick_adjusted)*total_pix(3));
            yclick_pixels_adjusted = yclick_pixels - ((yclick-yclick_adjusted)*total_pix(4));
            
            datasource = self.inscreen_plot;
            xdata=get(datasource,'xdata');
            ydata=get(datasource,'ydata');

            activegraph=get(datasource,'parent');

            pos = getpixelposition(activegraph);
            xlim=get(activegraph,'xlim');
            ylim=get(activegraph,'ylim');

            %make conversion factors, units to pixels:
            xconvert=(xlim(2)-xlim(1))/pos(3);
            yconvert=(ylim(2)-ylim(1))/pos(4);

            Xdata=(xdata-xlim(1))/xconvert;
            Ydata=(ydata-ylim(1))/yconvert;

            Xdiff=Xdata-xclick_pixels_adjusted;
            Ydiff=Ydata-yclick_pixels_adjusted;

            distnce=sqrt(Xdiff.^2+Ydiff.^2);

            index=distnce==min(distnce);

            index=index(:); %make sure it's a column.
            [thispointx, thispointy] = find(distnce==min(distnce),1);

            if sum(index)>=1
                thispoint=find(distnce==min(distnce),1);
                index=false(size(distnce));
                index(thispoint)=true;
            end
        end
        % Pulls parameters from trial containing currently selected cell to inform the
        % in screen preview
        function [frame_rate, dur, patfield, funcfield, aofield, file_type] = get_preview_parameters(self, is_table)
            index = self.model.current_selected_cell.index;
            table = self.model.current_selected_cell.table;
            file_type = '';
            patfile = '';
            funcfile = '';
            aofile = '';
            
            
            if strcmp(table, "pre")

                mode = self.doc.pretrial{1};
                
                if index(2) == 2 
                    file_type = 'pat';
                    if is_table == 0
                        patfile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                    else
                        patfile = self.doc.pretrial{2};
                    end
                end
                
                if index(2) == 3 
                    file_type = 'pos';
                    
                    if is_table == 0
                        funcfile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                        
                    else
                        funcfile = self.doc.pretrial{3};
                        
                    end
                end
                if index(2) > 3 && index(2) < 8 
                    file_type = 'ao';
                    if is_table == 0
                        aofile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                        patfile = self.doc.pretrial{2};
                    else
                        aofile = self.doc.pretrial{index(2)};
                        patfile = self.doc.pretrial{2};
                    end
                end
                
                patfield = self.doc.get_pattern_field_name(patfile);
                funcfield = self.doc.get_posfunc_field_name(funcfile);
                aofield = self.doc.get_aofunc_field_name(aofile);
                
                if mode == 2
                    frame_rate = self.doc.pretrial{9};
                else
                    if ~strcmp(patfield,'')
                        if self.doc.Patterns.(patfield).pattern.gs_val == 1
                            frame_rate = 1000;
                        else 
                            frame_rate = 500;
                        end
                    elseif ~strcmp(funcfield,'')
                        if self.doc.Pos_funcs.(funcfield).pfnparam.gs_val == 1
                            
                            frame_rate = 1000;
                        else
                            frame_rate = 500;
                        end
                    else
                        frame_rate = 1000;
                    end
                end
                
                dur = self.doc.pretrial{12}*1000;

            elseif strcmp(table,"inter")

                mode = self.doc.intertrial{1};
                
                if index(2) == 2 
                    file_type = 'pat';
                    if is_table == 0
                        patfile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                    else
                        patfile = self.doc.intertrial{2};
                    end
                end
                
                if index(2) == 3 
                    file_type = 'pos';
                    
                    if is_table == 0
                        funcfile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                    else
                        funcfile = self.doc.intertrial{3};
                        patfile = self.doc.intertrial{2};
                    end
                    
                   
                end
                if index(2) > 3 && index(2) < 8 
                    file_type = 'ao';
                    if is_table == 0
                        aofile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                        patfile = self.doc.intertrial{2};
                    else
                        aofile = self.doc.intertrial{index(2)};
                        patfile = self.doc.intertrial{2};
                    end
                end
                
                patfield = self.doc.get_pattern_field_name(patfile);
                funcfield = self.doc.get_posfunc_field_name(funcfile);
                aofield = self.doc.get_aofunc_field_name(aofile);
                
                if mode == 2
                    frame_rate = self.doc.intertrial{9};
                else
                    if ~strcmp(patfield,'')
                        if self.doc.Patterns.(patfield).pattern.gs_val == 1
                            frame_rate = 1000;
                        else 
                            frame_rate = 500;
                        end
                    elseif ~strcmp(funcfield,'')
                        if self.doc.Pos_funcs.(funcfield).pfnparam.gs_val == 1
                            
                            frame_rate = 1000;
                        else
                            frame_rate = 500;
                        end
                    else
                        frame_rate = 1000;
                    end
                end

                dur = self.doc.intertrial{12}*1000;

            elseif strcmp(table,"block")

                mode = self.doc.block_trials{index(1), 1};
                
                if index(2) == 2 
                    file_type = 'pat';
                    if is_table == 0
                        patfile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                    else
                        patfile = self.doc.block_trials{index(1), 2};
                    end
                end
                
                if index(2) == 3 
                    file_type = 'pos';
                    
                    if is_table == 0
                        funcfile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                    else
                        funcfile = self.doc.block_trials{index(1), 3};
                        patfile = self.doc.block_trials{index(1), 2};
                    end
                end
                
                if index(2) > 3 && index(2) < 8 
                    file_type = 'ao';
                    if is_table == 0
                        aofile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                        patfile = self.doc.block_trials{index(1), 2};
                    else
                        aofile = self.doc.block_trials{index(1), index(2)};
                        patfile = self.doc.block_trials{index(1), 2};
                    end
                end
                
                patfield = self.doc.get_pattern_field_name(patfile);
                funcfield = self.doc.get_posfunc_field_name(funcfile);
                aofield = self.doc.get_aofunc_field_name(aofile);
                
               if mode == 2
                    frame_rate = self.doc.block_trials{index(1),9};
                else
                    if ~strcmp(patfield,'')
                        if self.doc.Patterns.(patfield).pattern.gs_val == 1
                            frame_rate = 1000;
                        else 
                            frame_rate = 500;
                        end
                    elseif ~strcmp(funcfield,'')
                        if self.doc.Pos_funcs.(funcfield).pfnparam.gs_val == 1
                            
                            frame_rate = 1000;
                        else
                            frame_rate = 500;
                        end
                    else
                        frame_rate = 1000;
                    end
                end

                dur = self.doc.block_trials{index(1),12}*1000;

            elseif strcmp(table,"post")

                mode = self.doc.posttrial{1};
                
                if index(2) == 2 
                    file_type = 'pat';
                    if is_table == 0
                        patfile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                    else
                        patfile = self.doc.posttrial{2};
                    end
                end
                
                if index(2) == 3 
                    file_type = 'pos';
                    
                    if is_table == 0
                        funcfile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                    else
                        funcfile = self.doc.posttrial{3};
                        patfile = self.doc.posttrial{2};
                    end
                end
                if index(2) > 3 && index(2) < 8 
                    file_type = 'ao';
                    if is_table == 0
                        aofile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                        patfile = self.doc.posttrial{2};
                    else
                        aofile = self.doc.posttrial{index(2)};
                        patfile = self.doc.posttrial{2};
                    end
                end
                
                patfield = self.doc.get_pattern_field_name(patfile);
                funcfield = self.doc.get_posfunc_field_name(funcfile);
                aofield = self.doc.get_aofunc_field_name(aofile);
                
                 if mode == 2
                    frame_rate = self.doc.posttrial{9};
                else
                    if ~strcmp(patfield,'')
                        if self.doc.Patterns.(patfield).pattern.gs_val == 1
                            frame_rate = 1000;
                        else 
                            frame_rate = 500;
                        end
                    elseif ~strcmp(funcfield,'')
                        if self.doc.Pos_funcs.(funcfield).pfnparam.gs_val == 1
                            
                            frame_rate = 1000;
                        else
                            frame_rate = 500;
                        end
                    else
                        frame_rate = 1000;
                    end
                end
                dur = self.doc.posttrial{12}*1000;
            end
        end
        
        %Check the pattern being previewed for three or four dimensions
        function [start_index] = check_pattern_dimensions(self, pat_field)
            if ~strcmp(pat_field,'')
               num_dim = ndims(self.doc.Patterns.(pat_field).pattern.Pats);
               if num_dim == 3
                   start_index = 1;
               elseif num_dim == 4
                   start_index = [1,1];
                   set(self.pageUp_button, 'Enable', 'on');
                   set(self.pageDown_button, 'Enable', 'on');
               else
                   start_index = 0;
               end
            end

        end

%% Error handling Functions
        
        %display an error box to the user
        function create_error_box(self, varargin)
            if isempty(varargin)
                return;
            else
                msg = varargin{1};
                if length(varargin) >= 2
                    title = varargin{2};
                else
                    title = "";
                end

                e = errordlg(msg, title);
                set(e, 'Resize', 'on');
                waitfor(e);

            end

        end
        
        %check that the parameter the user is trying to edit is allowed to
        %be edited
        function [allow] = check_editable(self, mode_val, y) 


            allow = 1;
            if ~isnumeric(mode_val)
                mode_val = str2num(mode_val);
            end

            %check that the field is editable based on the mode
            if isempty(mode_val)
                return;
            elseif mode_val == 1 && (8 < y) && (12 > y)

                allow = 0;

            elseif mode_val == 2 && (y ==3 || ((y > 9) && (y < 12)))

                allow = 0;

            elseif mode_val == 3 && (y == 3 || ((y > 8) && (y < 12)))

                allow = 0;

            elseif mode_val == 4 && (y == 3 || y == 9 )

                allow = 0;

            elseif (mode_val == 5 || mode_val == 6) && (y == 9)

                allow = 0;

            elseif mode_val == 7 && ( y == 3 || ((y > 8) && (y < 12)))

                allow = 0;

            end

        end
        
        %Checks if a file exists before loading it
        function [loaded_file] = check_file_exists(self, filename)

            if isfile(filename) == 0
                self.create_error_box("This file doesn't exist");
                loaded_file = 0;
            else
                loaded_file = load(filename);
            end


        end
        
        %Check that the value entered is within bounds       
        function [within_bounds] = check_constraints(self, y, new)
        %Something's wrong with this function, get error with correct values, not
        %sure why yet
            within_bounds = 1;
            if y == 1
                if new > 7 || new < 1
                    within_bounds = 0;
                end
            elseif y == 8
                if new < 1
                    within_bounds = 0;
                end
            elseif y == 9 
                %can you check the input for non-numeric characters somehow?
            elseif y == 10
                %same as above
            elseif y == 11
                %same as above
            elseif y == 12
                if new < 1
                    within_bounds = 0;
                end
            end
        end
        
         %After saving or running an experiment, convert uneditable cells back to being greyed out       
        function insert_greyed_cells(self)

            pretrial_mode = self.doc.pretrial{1};
            intertrial_mode = self.doc.intertrial{1};
            posttrial_mode = self.doc.posttrial{1};
            pre_indices_to_color = [];
            inter_indices_to_color = [];
            post_indices_to_color = [];
            indices_to_color = [];
            if ~isempty(pretrial_mode)
                if pretrial_mode == 1
                    pre_indices_to_color = [9, 10, 11];
                elseif pretrial_mode == 2
                    pre_indices_to_color = [3, 10, 11];
                elseif pretrial_mode == 3
                    pre_indices_to_color = [3, 9, 10, 11];
                elseif pretrial_mode == 4
                    pre_indices_to_color = [3, 9];
                elseif pretrial_mode == 5 || pretrial_mode == 6
                    pre_indices_to_color = 9;
                elseif pretrial_mode == 7
                    pre_indices_to_color = [3, 9, 10, 11];
                end
            else
%                 self.model.current_selected_cell.table = "pre";
%                 self.model.current_selected_cell.index = [1,1];
%                 self.clear_fields(pretrial_mode)
                pre_indices_to_color = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];


            end
            
            if ~isempty(intertrial_mode)

                if intertrial_mode == 1
                    inter_indices_to_color = [9, 10, 11];
                elseif intertrial_mode == 2
                    inter_indices_to_color = [3, 10, 11];
                elseif intertrial_mode == 3
                    inter_indices_to_color = [3, 9, 10, 11];
                elseif intertrial_mode == 4
                    inter_indices_to_color = [3, 9];
                elseif intertrial_mode == 5 || intertrial_mode == 6
                    inter_indices_to_color = 9;
                elseif intertrial_mode == 7
                    inter_indices_to_color = [3, 9, 10, 11];
                end
                
            else
%                 self.model.current_selected_cell.table = "inter";
%                 self.model.current_selected_cell.index = [1,1];
%                 self.clear_fields(intertrial_mode);
                inter_indices_to_color = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
                
            end
            
            if ~isempty(posttrial_mode)

                if posttrial_mode == 1
                    post_indices_to_color = [9, 10, 11];
                elseif posttrial_mode == 2
                    post_indices_to_color = [3, 10, 11];
                elseif posttrial_mode == 3
                    post_indices_to_color = [3, 9, 10, 11];
                elseif posttrial_mode == 4
                    post_indices_to_color = [3, 9];
                elseif posttrial_mode == 5 || posttrial_mode == 6
                    post_indices_to_color = 9;
                elseif posttrial_mode == 7
                    post_indices_to_color = [3, 9, 10, 11];
                end
            else
%                 self.model.current_selected_cell.table = "post";
%                 self.model.current_selected_cell.index = [1,1];
%                 self.clear_fields(posttrial_mode);
                post_indices_to_color = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
                
            end


            for i = 1:length(pre_indices_to_color)
                self.doc.set_pretrial_property(pre_indices_to_color(i),self.doc.colorgen());

            end
            for i = 1:length(inter_indices_to_color)
                self.doc.set_intertrial_property(inter_indices_to_color(i),self.doc.colorgen());
            end
            for i = 1:length(post_indices_to_color)
                self.doc.set_posttrial_property(post_indices_to_color(i),self.doc.colorgen());
            end

            for i = 1:length(self.doc.block_trials(:,1))
                mode = self.doc.block_trials{i,1};
                if mode == 1
                    indices_to_color = [9, 10, 11];
                elseif mode == 2
                    indices_to_color = [3, 10, 11];
                elseif mode == 3
                    indices_to_color = [3, 9, 10, 11];
                elseif mode == 4
                    indices_to_color = [3, 9];
                elseif mode == 5 || mode == 6
                    indices_to_color = 9;
                elseif mode == 7
                    indices_to_color = [3, 9, 10, 11];
                end
                for j = 1:length(indices_to_color)
                    self.doc.set_block_trial_property([i,indices_to_color(j)],self.doc.colorgen());
                end
            end



        end

        
%% Additional Menu functions
        
        % Get the string by which the user wants to filter their file
        % options during Import
        function [answer] = get_filter_string(self)

            answer = inputdlg("Please enter the whole or partial filename you wish to match.",...
                "Filter Import Results");
            answer = answer{1};
        end
        
        % Import a folder
        function import_folder(self, str_to_match)

            if strcmp(str_to_match,'')

                path = uigetdir;

            else
                path = uigetdir(['*',str_to_match,'*']);
            end

            if isequal(path, 0)
                %do nothing
            else

                self.doc.import_folder(path);
                self.set_exp_name();
                set(self.num_rows_3, 'Enable', 'off');
                set(self.num_rows_4, 'Enable', 'off');

                self.update_gui();
            end
        end
        
        % Import a file
        function import_file(self, str_to_match)
            if strcmp(str_to_match,'')
                [imported_file, path] = uigetfile('*.mat');
            else
                [imported_file, path] = uigetfile(['*',str_to_match,'*.mat']);
            end

            if isequal(imported_file,0)
                %do nothing
            else
                self.doc.import_single_file(imported_file, path);

                set(self.num_rows_3, 'Enable', 'off');
                set(self.num_rows_4, 'Enable', 'off');
                self.update_gui();
            end
        end
        
        % Save over current file (Not currently in use)
        function save(self, ~, ~)

            self.doc.save();

        end

        
%% Additional General Functions
    
        % Get pattern field associated with selected cell, or clear grey 
        % space and insert first pattern

        function [pat_field] = get_or_insert_pattern(self)

            pat_fields = fieldnames(self.doc.Patterns);

            if strcmp(self.model.current_selected_cell.table,"pre")
                if ~isempty(self.doc.pretrial{2}) && ~self.doc.check_if_cell_disabled(self.doc.pretrial{2})
                    pat_field = self.doc.get_pattern_field_name(self.doc.pretrial{2});
                elseif ~isempty(self.doc.imported_pattern_names)
                    pat_field = pat_fields{1};
                    self.doc.set_pretrial_property(2,self.doc.Patterns.(pat_field).filename);
                else
                    pat_field = '';
                end

            elseif strcmp(self.model.current_selected_cell.table,"inter")
                if ~isempty(self.doc.intertrial{2}) && ~self.doc.check_if_cell_disabled(self.doc.intertrial{2})
                    pat_field = self.doc.get_pattern_field_name(self.doc.intertrial{2});
                elseif ~isempty(self.doc.imported_pattern_names)
                    pat_field = pat_fields{1};
                    self.doc.set_intertrial_property(2,self.doc.Patterns.(pat_field).filename);
                else
                    pat_field = '';
                end
            elseif strcmp(self.model.current_selected_cell.table,"post")
                if ~isempty(self.doc.posttrial{2}) && ~self.doc.check_if_cell_disabled(self.doc.posttrial{2})
                    pat_field = self.doc.get_pattern_field_name(self.doc.posttrial{2});
                elseif ~isempty(self.doc.imported_pattern_names)
                    pat_field = pat_fields{1};
                    self.doc.set_posttrial_property(2,self.doc.Patterns.(pat_field).filename);
                else
                    pat_field = '';
                end
            else
                if ~isempty(self.doc.block_trials{self.model.current_selected_cell.index(1),2}) && ...
                        ~self.doc.check_if_cell_disabled(self.doc.block_trials{self.model.current_selected_cell.index(1),2})
                    pat_field = self.doc.get_pattern_field_name(self.doc.block_trials{self.model.current_selected_cell.index(1),2});            
                elseif ~isempty(self.doc.imported_pattern_names)
                    pat_field = pat_fields{1};
                    self.doc.set_block_trial_property([self.model.current_selected_cell.index(1),2],self.doc.Patterns.(pat_field).filename);
                else
                    pat_field = '';
                end

            end

        end

%% Additional Update functions

        %Update the preview controller property
        function update_preview_con(self, new_value)
            self.preview_con = new_value;
        end
        
         %Update the predicted experiment length
        function update_exp_length(self, new)
            self.doc.est_exp_length = new;
            self.update_gui();
        end
                
        % Update the GUI to reflect the up to date model values
        function update_gui(self)


            self.set_pretrial_table_data();
            self.set_intertrial_table_data();
            self.set_block_table_data();
            self.set_posttrial_table_data();
            self.set_randomize_buttonGrp_selection();
            self.set_repetitions_box_val();
            self.set_isSelect_all_box_val();
            self.set_chan1_val();
            self.set_chan2_val();
            self.set_chan3_val();
            self.set_chan4_val();
            self.set_chan1_rate_box_val();
            self.set_chan2_rate_box_val();
            self.set_chan3_rate_box_val();
            self.set_chan4_rate_box_val();
            self.set_num_rows_buttonGrp_selection();
            self.set_exp_name();
            self.set_recent_file_menu_items();
            self.set_exp_length_text();
            


        end

 %% Functions to set the value of each GUI object       

         function set_pretrial_table_data(self)
            self.pretrial_table.Data = self.doc.pretrial;
         end

         function set_intertrial_table_data(self)
            self.intertrial_table.Data = self.doc.intertrial;
         end

         function set_posttrial_table_data(self)

            self.posttrial_table.Data = self.doc.posttrial;

         end

         function set_block_table_data(self)
             
               %%%%%%%%%%%%%%%%%%THIS IS NOT A GOOD PERMANENT SOLUTION FOR
%              %%%%%%%%%%%%%%%%%%THE SCROLLBAR JUMPING ISSUE. USING PAUSE CAN
%              %%%%%%%%%%%%%%%%%%UNDER CERTAIN CIRCUMSTANCES HAVE WEIRD
%              %%%%%%%%%%%%%%%%%%RESULTS, AND JAVA INTERVENTIONS MAY STOP
%              %%%%%%%%%%%%%%%%%%WORKING WITH ANY RELEASE. CHECK NEW
%              RELEASES TO SEE IF THIS BUG HAS BEEN FIXED

            jTable = findjobj(self.block_table);
            jScrollPane = jTable.getComponent(0);
            javaObjectEDT(jScrollPane);
            currentViewPos = jScrollPane.getViewPosition;
             
             self.block_table.Data = self.doc.block_trials;
   
            pause(0);
            jScrollPane.setViewPosition(currentViewPos);
         end

         function set_randomize_buttonGrp_selection(self)
            if self.doc.is_randomized == 1
                set(self.randomize_buttonGrp,'SelectedObject',self.isRandomized_radio);
            else
                set(self.randomize_buttonGrp,'SelectedObject',self.isSequential_radio);
            end
         end

         function set_repetitions_box_val(self)
            self.repetitions_box.String = num2str(self.doc.repetitions);
         end
         
         function set_isSelect_all_box_val(self)
             self.isSelect_all_box.Value = self.model.isSelect_all;
         end

         function set_chan1_val(self)
            self.chan1.Value = self.doc.is_chan1;
         end
         
         function set_chan2_val(self)
            self.chan2.Value = self.doc.is_chan2;
         end
         
         function set_chan3_val(self)
            self.chan3.Value = self.doc.is_chan3;
         end
         
         function set_chan4_val(self)
            self.chan4.Value = self.doc.is_chan4;
         end
         
         function set_chan1_rate_box_val(self)
            self.chan1_rate_box.String = num2str(self.doc.chan1_rate);
         end
         
         function set_chan2_rate_box_val(self)
            self.chan2_rate_box.String = num2str(self.doc.chan2_rate);

         end

         function set_chan3_rate_box_val(self)
            self.chan3_rate_box.String = num2str(self.doc.chan3_rate);
         end
         
         function set_chan4_rate_box_val(self)
            self.chan4_rate_box.String = num2str(self.doc.chan4_rate);
         end
         
         function set_num_rows_buttonGrp_selection(self)
            
             value = get(self.num_rows_3, 'Enable');
             if strcmp(value,'off') == 1
                 %do nothing
             else
                if self.doc.num_rows == 3
                    set(self.num_rows_buttonGrp,'SelectedObject',self.num_rows_3);
                else
                    set(self.num_rows_buttonGrp,'SelectedObject',self.num_rows_4);
                end
             end
            
         end
         
         function set_exp_name(self)
             set(self.exp_name_box,'String', self.doc.experiment_name);
         end
         
         function set_recent_file_menu_items(self)
             for i = 1:length(self.doc.recent_g4p_files)
                 [~,filename] = fileparts(self.doc.recent_g4p_files{i});
                 if i > length(self.recent_file_menu_items)
                     self.recent_file_menu_items{end + 1} = uimenu(self.menu_open, 'Text', filename, 'MenuSelectedFcn', {@self.open_file, self.doc.recent_g4p_files{i}});
                 else
                
                    set(self.recent_file_menu_items{i},'Text',filename);
                    set(self.recent_file_menu_items{i}, 'MenuSelectedFcn', {@self.open_file, self.doc.recent_g4p_files{i}});
                 end
             end
         end
         
         function set_exp_length_text(self)
            self.exp_length_display.String = [num2str(round(self.doc.est_exp_length/60, 2)), ' minutes'];
         end
         
         function  set_pretrial_files_(self, y, new_value)
            
             new_value = string(new_value);
              
            if y == 2
                self.pre_files.pattern = new_value;
            end
            if y == 3
                self.pre_files.position = new_value;
            end
            if y == 4
                self.pre_files.ao1 = new_value;
            end
            if y == 5
                self.pre_files.ao2 = new_value;
            end
            if y == 6
                self.pre_files.ao3 = new_value;
            end
            if y == 7
                self.pre_files.ao4 = new_value;
            end
         end

         
         function  set_intertrial_files_(self, y, new_value)
             
             new_value = string(new_value);
            
            if y == 2
                self.inter_files.pattern = new_value;
            end
            if y == 3
                self.inter_files.position = new_value;
            end
            if y == 4
                self.inter_files.ao1 = new_value;
            end
            if y == 5
                self.inter_files.ao2 = new_value;
            end
            if y == 6
                self.inter_files.ao3 = new_value;
            end
            if y == 7
                self.inter_files.ao4 = new_value;
            end
         end
         
         
         function  set_posttrial_files_(self, y, new_value)
             
             new_value = string(new_value);
            
            if y == 2
                self.post_files.pattern = new_value;
            end
            if y == 3
                self.post_files.position = new_value;
            end
            if y == 4
                self.post_files.ao1 = new_value;
            end
            if y == 5
                self.post_files.ao2 = new_value;
            end
            if y == 6
                self.post_files.ao3 = new_value;
            end
            if y == 7
                self.post_files.ao4 = new_value;
            end
         end
         
         function  set_blocktrial_files_(self, x, y, new_value)
             
             new_value = string(new_value);
            
            if y == 2
                self.block_files.pattern(x) = new_value;
            end
            if y == 3
                self.block_files.position(x) = new_value;
            end
            if y == 4
                self.block_files.ao1(x) = new_value;
            end
            if y == 5
                self.block_files.ao2(x) = new_value;
            end
            if y == 6
                self.block_files.ao3(x) = new_value;
            end
            if y == 7
                self.block_files.ao4(x) = new_value;
            end
         end

%% SETTERS
        
         function set.model(self, value)
            self.model_ = value;
        end
        
        function set.preview_con(self, value)
            self.preview_con_ = value;
        end
        
        function set.run_con(self, value)
            self.run_con_ = value;
        end
        
         function set.pretrial_table(self, value)
            self.pretrial_table_ = value;
         end

         function set.intertrial_table(self, value)
            self.intertrial_table_ = value;
         end

         function set.posttrial_table(self, value)
            self.posttrial_table_ = value;
         end

         function set.block_table(self, value)
            self.block_table_ = value;
         end
         
         function set.pre_files(self, value)
             self.pre_files_ = value;
         end
         
         function set.block_files(self, value)
             self.block_files_ = value;
         end
         
         function set.inter_files(self, value)
             self.inter_files_ = value;
         end
         
         function set.post_files(self, value)
             self.post_files_ = value;
         end

         function set.chan1(self, value)
            self.chan1_ = value;
         end

         function set.chan2(self, value)
            self.chan2_ = value;
         end

         function set.chan3(self, value)
            self.chan3_ = value;
         end
         
         function set.chan4(self, value)
            self.chan4_ = value;
         end
         
         function set.chan1_rate_box(self, value)
            self.chan1_rate_box_ = value;
         end
         
         function set.chan2_rate_box(self, value)
            self.chan2_rate_box_ = value;
         end
         
         function set.chan3_rate_box(self, value)
            self.chan3_rate_box_ = value;
         end
         
         function set.chan4_rate_box(self, value)
            self.chan4_rate_box_ = value;
         end

         
         function set.isRandomized_radio(self, value)
            self.isRandomized_radio_ = value;
         end
         
         function set.isSequential_radio(self, value)
             self.isSequential_radio_ = value;
         end
         
         function set.repetitions_box(self, value)
            self.repetitions_box_ = value;
         end
         
         function set.num_rows_buttonGrp(self, value)
             self.num_rows_buttonGrp_ = value;
         end
         
         function set.num_rows_3(self, value)
             self.num_rows_3_ = value;
         end
         
         function set.num_rows_4(self, value)
             self.num_rows_4_ = value;
         end
         
         function set.randomize_buttonGrp(self, value)
             self.randomize_buttonGrp_ = value;
         end
         
         function set.isSelect_all_box(self, value)
             self.isSelect_all_box_ = value;
         end
         
         function set.f(self, value)
             self.f_ = value;
         end
         
         function set.preview_panel(self, value)
             self.preview_panel_ = value;
         end
         
         function set.hAxes(self, value)
             self.hAxes_ = value;
         end
         
         function set.exp_name_box(self, value)
             self.exp_name_box_ = value;
         end
         
         function set.doc(self, value)
            self.doc_ = value;
         end
         
         function set.second_axes(self, value)
             self.second_axes_ = value;
         end
         
         function set.pageUp_button(self, value)
             self.pageUp_button_ = value;
         end
         
         function set.pageDown_button(self, value)
             self.pageDown_button_ = value;
         end

         function set.listbox_imported_files(self, value)
             self.listbox_imported_files_ = value;
         end

         function set.recent_file_menu_items(self, value)
             self.recent_file_menu_items_ = value;
         end
         
         function set.menu_open(self, value)
             self.menu_open_ = value;
         end
         
         function set.exp_length_display(self, value)
             self.exp_length_display_ = value;
         end
         
         function set.inscreen_plot(self, value)
             self.inscreen_plot_ = value;
         end
         
         function set.settings_con(self, value)
             self.settings_con_ = value;
         end

%% GETTERS

        function output = get.model(self)
            output = self.model_;
        end
        
        function output = get.preview_con(self)
            output = self.preview_con_;
        end
        
        function output = get.run_con(self)
            output = self.run_con_;
        end
        
         function output = get.pretrial_table(self)
            output = self.pretrial_table_;
         end

         function output = get.intertrial_table(self)
            output = self.intertrial_table_;
         end

         function output = get.posttrial_table(self)
            output = self.posttrial_table_;
         end

         function output = get.block_table(self)
            output = self.block_table_;
         end
         
         function output = get.pre_files(self)
             output = self.pre_files_;
         end
         
         function output = get.block_files(self)
             output = self.block_files_;
         end
         
         function output = get.inter_files(self)
             output = self.inter_files_;
         end
         
         function output = get.post_files(self)
             output = self.post_files_;
         end

         function output = get.chan1(self)
            output = self.chan1_;
         end

         function output = get.chan2(self)
            output = self.chan2_;
         end

         function output = get.chan3(self)
            output = self.chan3_;
         end
         
         function output = get.chan4(self)
            output = self.chan4_;
         end
         
         function output = get.chan1_rate_box(self)
            output = self.chan1_rate_box_;
         end
         
         function output = get.chan2_rate_box(self)
            output = self.chan2_rate_box_;
         end
         
         function output = get.chan3_rate_box(self)
            output = self.chan3_rate_box_;
         end
         
         function output = get.chan4_rate_box(self)
            output = self.chan4_rate_box_;
         end

         function output = get.isRandomized_radio(self)
            output = self.isRandomized_radio_;
         end
         
         function output = get.isSequential_radio(self)
             output = self.isSequential_radio_;
         end
         
         function output = get.repetitions_box(self)
            output = self.repetitions_box_;
         end
         
         function output = get.num_rows_buttonGrp(self)
             output = self.num_rows_buttonGrp_;
         end
         
         function output = get.num_rows_3(self)
             output = self.num_rows_3_;
         end
         
         function output = get.num_rows_4(self)
             output = self.num_rows_4_;
         end
         
         function output = get.randomize_buttonGrp(self)
             output = self.randomize_buttonGrp_;
         end
         
         function output = get.isSelect_all_box(self)
             output = self.isSelect_all_box_;
         end
         
         function output = get.f(self)
             output = self.f_;
         end
         
         function output = get.preview_panel(self)
             output = self.preview_panel_;
         end
         
         function output = get.hAxes(self)
             output = self.hAxes_;
         end
         
         function output = get.exp_name_box(self)
             output = self.exp_name_box_;
         end
         
         function output = get.doc(self)
            output = self.doc_;
         end
         
         function output = get.second_axes(self)
             output = self.second_axes_;
         end
         
         function output = get.pageUp_button(self)
             output = self.pageUp_button_;
         end
         
         function output = get.pageDown_button(self)
             output = self.pageDown_button_;
         end

         function output = get.listbox_imported_files(self)
             output = self.listbox_imported_files_;
         end

         function output = get.recent_file_menu_items(self)
             output = self.recent_file_menu_items_;
         end
         
         function output = get.menu_open(self)
             output = self.menu_open_;
         end
         
         function output = get.exp_length_display(self)
             output = self.exp_length_display_;
         end
         
         function output = get.inscreen_plot(self)
             output = self.inscreen_plot_;
         end
         
         function output = get.settings_con(self)
             output = self.settings_con_;
         end

         



     end


end

