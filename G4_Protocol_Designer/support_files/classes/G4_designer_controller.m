classdef G4_designer_controller < handle %Made this handle class because was having trouble getting setters to work, especially with struct properties. 

    properties
        model_ %contains all data that does not persist with saving
        doc_ %contains all data that is stored in the saved file
        preview_con_ %controller for the fullscreen preview
        run_con_ %controller for the run window - can be opened independently
        
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

        %channel gui objects
        chan1_
        chan1_rate_box_
        chan2_
        chan2_rate_box_
        chan3_
        chan3_rate_box_
        chan4_
        chan4_rate_box_
        bg2_
 
        %Other gui objects
        isRandomized_radio_
        isSequential_radio_
        bg_
        repetitions_box_
        isSelect_all_box_
        f_
        preview_panel_
        hAxes_
        second_axes_
        num_rows_3_
        num_rows_4_
        exp_name_box_
        pageUp_button_
        pageDown_button_
        uneditable_cell_color_
        uneditable_cell_text_
        listbox_imported_files_
        recent_g4p_files_
        recent_files_filepath_
        recent_file_menu_items_
        menu_open_
        

        %is_ao_visible_
    end

    properties(Dependent)
        model
        preview_con
        run_con
        doc

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
        bg2
        num_rows_3
        num_rows_4
        isSelect_all
        isRandomized_radio
        isSequential_radio
        bg
        repetitions_box
        isSelect_all_box
        f
        preview_panel
        hAxes
        second_axes
        exp_name_box
        pageUp_button
        pageDown_button
        uneditable_cell_color
        uneditable_cell_text
        listbox_imported_files
        recent_g4p_files
        recent_files_filepath
        recent_file_menu_items
        menu_open

        
%         isRandomized_box
%         repetitions_box
%         isSelect_all_box

        %is_ao_visible

    end


    methods
        
        
        
%CONSTRUCTOR---------------------------------------------------------------

        function self = G4_designer_controller()
           
            self.model = G4_designer_model();
            self.doc = G4_document();
            
            %Get info from log of recently opened .g4p files - now done in
            %DOC
%             recent_files_filename = 'recently_opened_g4p_files.m';
%             filepath = fileparts(which(recent_files_filename));
%             self.recent_files_filepath = fullfile(filepath, recent_files_filename);
%             self.recent_g4p_files = strtrim(regexp( fileread(self.recent_files_filepath),'\n','split'));
%             self.recent_g4p_files = self.recent_g4p_files(~cellfun('isempty',self.recent_g4p_files));
%             
            %get screensize to calculate gui dimensions
            screensize = get(0, 'screensize');
            
            %set color and text for uneditable cells
            self.uneditable_cell_color = '#bdbdbd';
            self.uneditable_cell_text = '---------';
            
            %create figure
            self.f = figure('Name', 'Fly Experiment Designer', 'NumberTitle', 'off','units', 'pixels', 'MenuBar', 'none', ...
                'ToolBar', 'none', 'Resize', 'off', 'outerposition', [screensize(3)*.1, screensize(4)*.05, 1600, 1000]);
           
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
           self.set_bg2_selection();
        end

%GUI LAYOUT METHOD DECLARES ALL OBJECTS ON SCREEN--------------------------

        function layout_gui(self)


            %PARAMETERS ONLY USED IN LAYOUT

            column_names_ = {'Mode', 'Pattern Name' 'Position Function', ...
                'AO 1', 'AO 2', 'AO 3', 'AO 4', ...
                'Frame Index', 'Frame Rate', 'Gain', 'Offset', 'Duration' ...
                'Select'};
            columns_editable_ = true;
            column_format_ = {'numeric', 'char', 'char', 'char', 'char','char', ...
                'char', 'char', 'numeric', 'numeric', 'numeric', 'numeric', 'logical'};
            font_size = 10;
            positions.pre = [350, 870, 1035, 50];
            %pos_pre_ = [350, 870, 1035, 50];
            positions.inter = [350, 815, 1035, 50];
            %pos_inter_ = [350, 815, 1035, 50];
            positions.block = [350, 585, 1035, 200];
            %pos_block_ = [350, 585, 1035, 200];
            positions.post = [350, 525, 1035, 50];
            %pos_post_ = [350, 525, 1035, 50];
            pos_panel = [350, 190, 1035, 325];
            pos_menu_ = [15, 875, 105, 40];



            pretrial_label_ = uicontrol(self.f, 'Style', 'text', 'String', 'Pre-Trial', ...
               'Units', 'Pixels', 'FontSize', font_size, ...
           'Position', [positions.pre(1) - 85, positions.pre(2) + 15, 78, 20]);

            self.pretrial_table = uitable(self.f, 'data', self.doc.pretrial, 'columnname', column_names_, ...
            'units', 'pixels', 'Position', positions.pre, 'ColumnEditable', columns_editable_, 'ColumnFormat', column_format_, ...
           'CellEditCallback', @self.update_model_pretrial, 'CellSelectionCallback', {@self.preview_selection, positions});

            intertrial_label_ = uicontrol(self.f, 'Style', 'text', 'String', 'Inter-Trial', ...
               'units', 'pixels', 'FontSize', font_size, ...
           'Position', [positions.inter(1) - 85, positions.inter(2) + 15, 78, 20]);

            self.intertrial_table = uitable(self.f, 'data', self.doc.intertrial, 'columnname', column_names_, ...
            'units', 'pixels', 'Position', positions.inter, 'ColumnEditable', columns_editable_, 'ColumnFormat', column_format_, ...
            'CellEditCallback', @self.update_model_intertrial, 'CellSelectionCallback', {@self.preview_selection, positions});

            blocktrial_label_ = uicontrol(self.f, 'Style', 'text', 'String', 'Block Trials', ...
               'units', 'pixels', 'FontSize', font_size, ...
           'Position', [positions.block(1) - 85, positions.block(2) + .5*positions.block(4), 78, 20]);

            self.block_table = uitable(self.f, 'data', self.doc.block_trials, 'columnname', column_names_, ...
            'units', 'pixels', 'Position', positions.block, 'ColumnEditable', columns_editable_, 'ColumnFormat', column_format_, ...
            'CellEditCallback', @self.update_model_block_trials, 'CellSelectionCallback', {@self.preview_selection, positions});


            posttrial_label_ = uicontrol(self.f, 'Style', 'text', 'String', 'Post-Trial', ...
               'units', 'pixels', 'FontSize', font_size, ...
           'Position', [positions.post(1) - 85, positions.post(2) + 15, 78, 20]);

            self.posttrial_table = uitable(self.f, 'data', self.doc.posttrial, 'columnname', column_names_, ...
            'units', 'pixels', 'Position', positions.post, 'ColumnEditable', columns_editable_, 'ColumnFormat', column_format_, ...
            'CellEditCallback', @self.update_model_posttrial, 'CellSelectionCallback', {@self.preview_selection, positions});
            
%         %Create anonymous function which adds color to particular cells in
%         %the above tables based on mode. 
%             self.colorgen = @(color, text) ['<html><table border=0 width=400 bgcolor=',color,'><TR><TD>',text,'</TD></TR></table>'];

            add_trial_button = uicontrol(self.f, 'Style', 'pushbutton','String','Add Trial','units', ...
            'pixels','Position', [positions.block(1) + positions.block(3), ...
                positions.block(2) + 20, 75, 20], 'Callback',@self.add_trial);

            delete_trial_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Delete Trial', ...
                'units', 'pixels', 'Position', [positions.block(1) + positions.block(3), positions.block(2), ...
            75, 20], 'Callback', @self.delete_trial);

            self.isSelect_all_box = uicontrol(self.f, 'Style', 'checkbox', 'String', 'Select All', 'Value', self.model.isSelect_all, 'units', ...
                'pixels','FontSize', font_size, 'Position', [positions.block(1) + positions.block(3) - 45, ... 
                positions.block(2) + positions.block(4) + 2, 78, 22], 'Callback', @self.select_all);

            invert_selection = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Invert Selection', ...
                 'units', 'pixels', 'Position', [positions.block(1) + positions.block(3), ...
                positions.block(2) - 20, 75, 20], 'Callback', @self.invert_selection);

            up_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Shift up', 'units', ...
                'pixels', 'Position', [positions.block(1) + positions.block(3), positions.block(2) + .65*positions.block(4), ...
                75, 20], 'Callback', @self.move_trial_up);

            down_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Shift down', 'units', ...
                'pixels', 'Position', [positions.block(1) + positions.block(3), positions.block(2) + .35*positions.block(4), ...
                75, 20], 'Callback', @self.move_trial_down);
            
            clear_all_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Clear All','FontSize', 12, 'units', ...
                'pixels', 'Position', [positions.block(1) + 1.05*positions.block(3), positions.pre(2), ...
                85, positions.pre(4)], 'Callback', @self.clear_all);
            
            autofill_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Auto-Fill', ...
                'FontSize', 14, 'units', 'pixels', 'Position', [pos_panel(1), pos_panel(2) - 50, 100, 50], ...
                'Callback', @self.autofill);


            self.preview_panel = uipanel(self.f, 'Title', 'Preview', 'FontSize', font_size, 'units', 'pixels', ...
                'Position', pos_panel);
            
            listbox_files_label = uicontrol(self.f, 'Style', 'text', 'String', 'Imported files for selected cell:',...
                'units', 'pixels', 'Position', [pos_panel(1) + pos_panel(3) + 30, pos_panel(2) + pos_panel(4), ...
                150, 20], 'FontSize', font_size);
            
            self.listbox_imported_files = uicontrol(self.f, 'Style', 'listbox', 'String', {'Imported files here'},  ...
                'Position', [listbox_files_label.Position(1), listbox_files_label.Position(2) - 255, ...
                150, 250],'Callback', @self.preview_selection);
            
            select_imported_file_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Select', 'Position', ...
                [self.listbox_imported_files.Position(1) + .5*self.listbox_imported_files.Position(3), ...
                self.listbox_imported_files.Position(2) - 20, 75, 15], 'Callback', @self.select_new_file);
            

            %code to make the above panel transparent, so the preview image
            %can be seen.
            jPanel = self.preview_panel.JavaFrame.getPrintableComponent;
            jPanel.setOpaque(false)
            jPanel.getParent.setOpaque(false)
            jPanel.getComponent(0).setOpaque(false)
            jPanel.repaint

            preview_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Preview', 'Fontsize', ...
                font_size, 'units', 'pixels', 'Position', [pos_panel(1) + pos_panel(3) + 2, ...
                pos_panel(2), 75, 40], 'Callback', @self.full_preview);

            play_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Play', 'FontSize', ...
                font_size, 'units', 'pixels', 'Position', [pos_panel(1) + .5*pos_panel(3) - 120, ...
                pos_panel(2) - 35, 75, 20], 'Callback', @self.preview_play);

            pause_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Pause', 'FontSize', ...
                font_size, 'units', 'pixels', 'Position', [pos_panel(1) + .5*pos_panel(3) - 35, ...
                pos_panel(2) - 35, 75, 20], 'Callback', @self.preview_pause);

            stop_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Stop', 'FontSize', ...
                font_size, 'units', 'pixels', 'Position', [pos_panel(1) + .5*pos_panel(3) + 50, ...
                pos_panel(2) - 35, 75, 20], 'Callback', @self.preview_stop);

            frameBack_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Back Frame', 'FontSize', ...
                font_size, 'units', 'pixels', 'Position', [pos_panel(1) + .5*pos_panel(3) - 205, ...
                pos_panel(2) - 35, 75, 20], 'Callback', @self.frame_back);

            frameForward_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Forward Frame', ...
                'FontSize', font_size, 'units', 'pixels', 'Position', [pos_panel(1) + .5*pos_panel(3) ...
                + 135, pos_panel(2) - 35, 90, 20], 'Callback', @self.frame_forward);
            
            self.pageUp_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Page Up', ...
                'FontSize', font_size, 'units', 'pixels', 'Position', [pos_panel(1) + .5*pos_panel(3) + 235, ...
                pos_panel(2) - 35, 90, 20], 'Enable', 'off', 'Callback', @self.page_up_4d);
            
            self.pageDown_button = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Page Down', ...
                'FontSize', font_size, 'units', 'pixels', 'Position', [pos_panel(1) + .5*pos_panel(3) - 305, ...
                pos_panel(2) - 35, 90, 20], 'Enable', 'off', 'Callback', @self.page_down_4d);

           % self.hAxes = axes(self.f, 'units', 'pixels', 'OuterPosition', [245, 135, 1190 ,397], 'TickLength', [0,0],'XLim', [0 200], 'YLim', [0 65]);
            

%             self.second_axes = axes(self.f, 'units', 'pixels', 'OuterPosition', self.hAxes.OuterPosition, ...
%                 'XAxisLocation','top','YAxisLocation', 'right', 'TickLength',[0,0], 'XLim',[0 200], 'YLim', [0 65]);

            
            %linkaxes([self.hAxes, self.second_axes]);
            
            self.exp_name_box = uicontrol(self.f, 'Style', 'edit', ...
                'FontSize', 14, 'units', 'pixels', 'Position', ...
                [pos_panel(1)+ (pos_panel(3)/2) - 200, pos_panel(2) - 100, 400, 30], 'Callback', @self.update_experiment_name);
            
            exp_name_label = uicontrol(self.f, 'Style', 'text', 'String', 'Experiment Name: ', ...
                'FontSize', 16, 'units', 'pixels', 'Position', [pos_panel(1) + (pos_panel(3)/2) - 395, ...
                pos_panel(2) - 100, 180, 30]);


       %Drop down menu and associated labels and buttons
       

            menu = uimenu(self.f, 'Text', 'File');
            menu_import = uimenu(menu, 'Text', 'Import', 'Callback', @self.import);
            self.menu_open = uimenu(menu, 'Text', 'Open');
            menu_recent_files = uimenu(self.menu_open, 'Text', '.g4p file', 'Callback', {@self.open_file, ''});
            
                
            for i = 1:length(self.doc.recent_g4p_files)
                [path, filename] = fileparts(self.doc.recent_g4p_files{i});
                self.recent_file_menu_items{i} = uimenu(self.menu_open, 'Text', filename, 'Callback', {@self.open_file, self.doc.recent_g4p_files{i}});
            end
            
            if length(self.doc.recent_g4p_files) < 1
                self.recent_file_menu_items = {};
            end
      

            menu_saveas = uimenu(menu, 'Text', 'Save as', 'Callback', @self.saveas);
            %menu_save = uimenu(menu, 'Text', 'Save', 'Callback', @self.save);
            menu_copy = uimenu(menu, 'Text', 'Copy to...', 'Callback', @self.copy_to);
            menu_set = uimenu(menu, 'Text', 'Set Selected...', 'Callback', @self.set_selected);

       %Randomization
       
            self.bg = uibuttongroup(self.f, 'units', 'pixels', 'Position', [15, positions.block(2) + positions.block(4) - 10, 130, 55], 'SelectionChangedFcn', @self.update_randomize);
       
       
            self.isRandomized_radio = uicontrol(self.bg, 'Style', 'radiobutton', 'String', 'Randomize Trials', 'FontSize', font_size, ...
                'units', 'pixels', 'Position', [1, 29, 130, 20]);
            
            self.isSequential_radio = uicontrol(self.bg, 'Style', 'radiobutton', 'String', 'Sequential Trials', 'FontSize', font_size, ...
                'units', 'pixels', 'Position', [1,7, 130, 20]);

       %Repetitions

            self.repetitions_box = uicontrol(self.f, 'Style', 'edit', 'units', 'pixels', 'Position', ...
                [90, positions.block(2) + positions.block(4) - 45, 40, 20], 'Callback', @self.update_repetitions);

            repetitions_label = uicontrol(self.f, 'Style', 'text', 'String', 'Repetitions:', 'FontSize', font_size, ...
                'units', 'pixels', 'Position', [15, positions.block(2) + positions.block(4) - 45, 70, 20]);

       %Dry Run
            dry_run = uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Dry Run', 'FontSize', font_size, 'units', 'pixels', 'Position', ...
                [pos_panel(1) + pos_panel(3) + 2, pos_panel(2) - 40, 75, 40],'Callback',@self.dry_run);

       %Actual run button

            run_button =  uicontrol(self.f, 'Style', 'pushbutton', 'String', 'Run Trials', 'FontSize', font_size, 'units', 'pixels', 'Position', ...
                 [15, positions.block(2) + positions.block(4) - 110, 90, 50], 'Callback', @self.open_run_gui);

       %Channels to acquire

            chan_pan = uipanel(self.f, 'Title', 'Analog Input Channels', 'FontSize', font_size, 'units', 'pixels', ...
                'Position', [15, positions.block(2) + positions.block(4) - 240, 250, 120]);

            %self.chan1 = uicontrol(self.f, 'Style', 'checkbox', 'String', 'Channel 1', 'Value', self.doc.is_chan1, 'FontSize', font_size, ...
             %   'units', 'pixels', 'Position', [20, positions.block(2) + positions.block(4) - 160, 80, 20], 'Callback', @self.update_chan1);

            self.chan1_rate_box = uicontrol(chan_pan, 'Style', 'edit', 'String', num2str(self.doc.chan1_rate), 'units', 'pixels', 'Position', ...
                [170, 74, 40, 20],'Callback', @self.update_chan1_rate);

            chan1_rate_label = uicontrol(chan_pan, 'Style', 'text', 'String', 'Channel 1 Sample Rate', 'FontSize', font_size, ...
                'units', 'pixels', 'HorizontalAlignment', 'left', 'Position', [15, 74, 150, 20]);

            %self.chan2 = uicontrol(self.f, 'Style', 'checkbox', 'String', 'Channel 2', 'Value', self.doc.is_chan2, 'FontSize', font_size, ...
            %    'units', 'pixels', 'Position', [20, positions.block(2) + positions.block(4) - 180, 80, 20], 'Callback', @self.update_chan2);

            self.chan2_rate_box = uicontrol(chan_pan, 'Style', 'edit', 'String', num2str(self.doc.chan2_rate), 'units', 'pixels', 'Position', ...
                [170, 51, 40, 20], 'Callback', @self.update_chan2_rate);

            chan2_rate_label = uicontrol(chan_pan, 'Style', 'text', 'String', 'Channel 2 Sample Rate', 'FontSize', font_size, ...
                'units', 'pixels', 'HorizontalAlignment', 'left', 'Position', [15, 51, 150, 20]);

            %self.chan3 = uicontrol(self.f, 'Style', 'checkbox', 'String', 'Channel 3', 'Value', self.doc.is_chan3, 'FontSize', font_size, ...
             %   'units', 'pixels', 'Position', [20, positions.block(2) + positions.block(4) - 200, 80, 20], 'Callback', @self.update_chan3);

            self.chan3_rate_box = uicontrol(chan_pan, 'Style', 'edit', 'String', num2str(self.doc.chan3_rate), 'units', 'pixels', 'Position', ...
                [170, 28, 40, 20], 'Callback', @self.update_chan3_rate);

            chan3_rate_label = uicontrol(chan_pan, 'Style', 'text', 'String', 'Channel 3 Sample Rate', 'FontSize', font_size, ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [15, 28, 150, 20]);

            %self.chan4 = uicontrol(self.f, 'Style', 'checkbox', 'String', 'Channel 4', 'Value', self.doc.is_chan4, 'FontSize', font_size, ...
             %   'units', 'pixels', 'Position', [20, positions.block(2) + positions.block(4) - 220, 80, 20], 'Callback', @self.update_chan4);

            self.chan4_rate_box = uicontrol(chan_pan, 'Style', 'edit', 'String', num2str(self.doc.chan4_rate), 'units', 'pixels', 'Position', ...
                [170, 5, 40, 20], 'Callback', @self.update_chan4_rate);

            chan4_rate_label = uicontrol(chan_pan, 'Style', 'text', 'String', 'Channel 4 Sample Rate', 'FontSize', font_size, ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [15, 5, 150, 20]);

            self.bg2 = uibuttongroup(self.f, 'units', 'pixels', 'Position', [15, positions.block(2) + positions.block(4) - 270, 250, 25], 'SelectionChangedFcn', @self.update_rowNum);
       
       
            self.num_rows_3 = uicontrol(self.bg2, 'Style', 'radiobutton', 'String', '3 Row Screen', 'FontSize', font_size, ...
                'units', 'pixels', 'Position', [1, 3, 120, 19]);
            
            self.num_rows_4 = uicontrol(self.bg2, 'Style', 'radiobutton', 'String', '4 Row Screen', 'FontSize', font_size, ...
                'units', 'pixels', 'Position', [121,3, 120, 19]);
            
            key_pan = uipanel(self.f, 'Title', 'Mode Key:', 'BackgroundColor', [.75, .75, .75], 'BorderType', 'none', ...
                'FontSize', 13, 'units', 'pixels', 'Position', [15, positions.block(2) + positions.block(4) - 720, 280, 420]);
            
            mode_1_label = uicontrol(self.f, 'Style', 'text', 'String', 'Mode 1: Position Function', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left', 'FontSize', 11, 'units', 'pixels', 'Position', [25, positions.block(2) + positions.block(4) - 360, 250, 18]);
            
            mode_2_label = uicontrol(self.f, 'Style', 'text', 'String', 'Mode 2: Constant Rate', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'pixels', 'Position', [25, mode_1_label.Position(2) - 50, 250, 18]);
            
            mode_3_label = uicontrol(self.f, 'Style', 'text', 'String', 'Mode 3: Constant Index', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'pixels', 'Position', [25, mode_2_label.Position(2) - 50, 250, 18]);
            
            mode_4_label = uicontrol(self.f, 'Style', 'text', 'String', 'Mode 4: Closed-loop sets frame rate', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'pixels', 'Position', [25, mode_3_label.Position(2) - 50, 250, 18]);
            
            mode_5_label = uicontrol(self.f, 'Style', 'text', 'String', 'Mode 5: Closed-loop rate + offset', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'pixels', 'Position', [25, mode_4_label.Position(2) - 50, 250, 18]);
            
            mode_5_label_cont = uicontrol(self.f, 'Style', 'text', 'String', 'position function', 'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', ...
                'left', 'FontSize', 11, 'units', 'pixels', 'Position', [25, mode_5_label.Position(2) - 20, 200, 18]);
            
            mode_6_label = uicontrol(self.f, 'Style', 'text', 'String', 'Mode 6: Closed-loop rate X + position', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'pixels', 'Position', [25, mode_5_label_cont.Position(2) - 50, 250, 18]);
            
            mode_6_label_cont = uicontrol(self.f, 'Style', 'text', 'String', 'function Y', 'BackgroundColor', [.75,.75,.75], 'HorizontalAlignment', ...
                'left', 'FontSize', 11, 'units', 'pixels', 'Position', [25, mode_6_label.Position(2) - 20, 200, 18]);
            
            mode_7_label = uicontrol(self.f, 'Style', 'text', 'String', 'Mode 7: Closed-loop sets frame index', 'BackgroundColor', [.75,.75,.75], ...
                'HorizontalAlignment', 'left','FontSize', 11, 'units', 'pixels', 'Position', [25, mode_6_label_cont.Position(2) - 50, 250, 18]);

        end
        
%UPDATE THE GUI VALUES FROM UPDATED MODEL DATA-----------------------------

        function update_gui(self)


            self.set_pretrial_table_data();
            self.set_intertrial_table_data();
            self.set_block_table_data();
            self.set_posttrial_table_data();
            self.set_bg_selection();
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
            self.set_bg2_selection();
            self.set_exp_name();
            self.set_recent_file_menu_items();
            


        end
        
%         function update_gui_block(self, x, y)
%             
%             self.set_block_table_data_xy(x, y);
%             
%         end
     
%UPDATE MODEL DATA FROM USER INPUT-----------------------------------------

%Update pretrial model data

        function update_model_pretrial(self, src, event)

            mode = self.doc.pretrial{1};
            new = event.EditData;
            x = event.Indices(1);
            y = event.Indices(2);
            allow = self.check_editable(mode, y);
            %within_bounds = self.check_constraints(y, new); %Doesn't work
            %yet

            if allow == 1 %&& within_bounds == 1
                if y >= 2 && y <= 7

                    self.set_pretrial_files_(y, new);
                    self.doc.set_pretrial_property(y,new);
                elseif y ~= 13

                    self.doc.set_pretrial_property(y, new);

                else
                    self.doc.set_pretrial_property(y,new);
                end



    %             elseif within_bounds == 0
    %                 
    %                 self.create_error_box("The value you provided is out of bounds."));
    %                 self.layout_gui();

            else

                self.create_error_box("You cannot edit that field in this mode.");
                %self.layout_gui();


            end
            if y == 1
               
               self.clear_fields(str2num(new));
                
            end
            
             self.update_gui();
             %disp(self.pre_files);

        end
        
%Update block trials model data        
        
        function update_model_block_trials(self, src, event)
            
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
            
            if y == 1
                
                self.clear_fields(str2num(new));
            
            end
            

            self.update_gui();
            %disp(self.block_files);
            
        end
        
%Update intertrial model data        
        
        function update_model_intertrial(self, src, event)
            
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

        function update_model_posttrial(self, src, event)
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
        
        function update_repetitions(self, src, event)
        
            new = str2num(src.String);
            self.doc.repetitions = new;
            self.update_gui();
            %self.doc.repetitions
        
        end

%Update Randomization

        function update_randomize(self, src, event)
            
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
        
%Update channels being acquired (each separately)
        
%         function update_chan1(self, src, event)
%             
%             new = src.Value;
%             self.doc.is_chan1 = new;
%             self.update_gui();
%             %self.doc.is_chan1
%         
%         end
%         
%         function update_chan2(self, src, event)
% 
%             new = src.Value;
%             self.doc.is_chan2 = new;
%             self.update_gui();
%             %self.doc.is_chan2
% 
%         end
%         
%         function update_chan3(self, src, event)
% 
%             new = src.Value;
%             self.doc.is_chan3 = new;
%             self.update_gui();
%             %self.doc.is_chan3
% 
%         end
%         
%         function update_chan4(self, src, event)
% 
%             new = src.Value;
%             self.doc.is_chan4 = new;
%             self.update_gui();
%             %self.model.is_chan4
%         
%         end
 
%Update the frame rates of channels being collected        
        
        function update_chan1_rate(self, src, event)
            
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
        
        function update_chan2_rate(self, src, event)
            
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
        
        function update_chan3_rate(self, src, event)
            
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
        
        function update_chan4_rate(self, src, event)
            
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
        
%         function update_doc(self, new_value)
%             
%             self.doc = new_value;
%         end
%         
        function update_preview_con(self, new_value)
            self.preview_con = new_value;
        end
        
        function update_rowNum(self, src, event)
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
            self.set_bg2_selection();

%            self.update_gui();
        end
        
        function update_experiment_name(self, src, event)
            
            new_val = src.String;
           
            self.doc.experiment_name = new_val;
            self.set_exp_name();
            self.update_gui();
            if ~isempty(self.run_con)
                self.run_con.update_run_gui();
            end
            
        end
       
        
%         function update_config_file(self)
%             %open config file
%             %change appropriate rate
%             %save and close config file
%             configData = self.doc.configData;
% 
%             settings_data = strtrim(regexp( fileread('G4_Protocol_Designer_Settings.m'),'\n','split'));
%             filepath_line = find(contains(settings_data,'Configuration File Path:'));
%             exp = 'Path:';
%             startIndex = regexp(settings_data{filepath_line},exp);
%             start_filepath_index = startIndex + 6;
%             config_filepath = settings_data{filepath_line}(start_filepath_index:end);
%             fid = fopen(config_filepath,'w');
%             fprintf(fid, '%s\n', configData{:});
%             fclose(fid);
%             
%         end


        function select_new_file(self, src, event)
        
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
        
%CLEAR OUT ALL DATA TO START DESIGNING NEW EXPERIMENT----------------------

        function clear_all(self, src, event)
            
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
                    self.doc.experiment_name
                    

                    self.update_gui();
                    
                    
            end
            
        end
        
        function right_click(self, src, event)
           
            disp("You right clicked the cell!");
            
        end
        
%ADD ROW AND UPDATE MODEL DATA---------------------------------------------

        function add_trial(self, src, event)

            checkbox_column_data = horzcat(self.doc.block_trials(1:end, end));
            checked_list = find(cell2mat(checkbox_column_data));
            checked_count = length(checked_list);
            x = size(self.doc.block_trials,1) + 1;
            
          
            if checked_count == 0
                newRow = self.doc.block_trials(end,1:end);
                y = 1;
                self.doc.set_block_trial_property([x,y],newRow);
            elseif checked_count == 1
                newRow = self.doc.block_trials(checked_list(1),1:end-1);
                newRow{:,end+1} = false;
                %disp(newRow);
                y = 1;
                self.doc.set_block_trial_property([x,y], newRow);
                
                
            else 
                self.create_error_box("you can only have one row checked for this functionality");
                      
                  
                
            end    
            self.block_files.pattern(end + 1) = string(cell2mat(newRow(2)));
            self.block_files.position(end + 1) = string(cell2mat(newRow(3)));
            self.block_files.ao1(end + 1) = string(cell2mat(newRow(4)));
            self.block_files.ao2(end + 1) = string(cell2mat(newRow(5)));
            self.block_files.ao3(end + 1) = string(cell2mat(newRow(6)));
            self.block_files.ao4(end + 1) = string(cell2mat(newRow(7)));
            
%             for i = 1:13
%                 
%                 self.update_gui_block(x, i)
%                 
%             end

            self.update_gui();
            
            
        
        end

%DELETE ROW AND UPDATE MODEL DATA------------------------------------------

        function delete_trial(self, src, event)
        
            checkbox_column_data = horzcat(self.doc.block_trials(1:end, end));
            checked_list = find(cell2mat(checkbox_column_data));
            checked_count = length(checked_list);
            %disp(checked_list);
            
            if checked_count == 0
                self.create_error_box("You didn't select a trial to delete.");
            else
                
                for i = 1:checked_count
%                     for j = 1:13
%                          new = [];
%                
%                          x = checked_list(i) - (i - 1);
%                          self.doc.set_block_trial_property( ,new);
%                          self.doc.block_trials
%                     
                        self.doc.block_trials(checked_list(i) - (i-1),:) = [];
                        %disp(self.doc.block_trials);
%                     end
                
                end
                
            end
            
            self.update_gui();
                
        
        end
        
        
%MOVE TRIAL UP AND UPDATE MODEL DATA---------------------------------------

        function move_trial_up(self, src, event)
        
            checkbox_column_data = horzcat(self.doc.block_trials(1:end, end));
            checked = find(cell2mat(checkbox_column_data));
            checked_count = length(checked);
            
            if checked_count == 0
                self.create_error_box("Please select a trial to shift upward.");
            elseif checked_count > 1
                self.create_error_box("Please select only one trial to shift upward.");
            else 
            
                selected = self.doc.block_trials(checked, :);
                if checked == 1
                    self.create_error_box("I can't shift up any more.");
                    return;
                else
                    above_selected = self.doc.block_trials(checked - 1, :);
                end
 
               
                self.doc.block_trials(checked , :) = above_selected;
                self.doc.block_trials(checked - 1, :) = selected;

                
            end
            
%             for i = 1:13
%                 self.update_gui_block(checked, i);
%                 self.update_gui_block(checked - 1, i);
%             end
              self.update_gui();
            
      
        end
        
        
%MOVE TRIAL DOWN AND UPDATE MODEL DATA-------------------------------------

        function move_trial_down(self, src, event)

            
            checkbox_column_data = horzcat(self.doc.block_trials(1:end, end));
            checked = find(cell2mat(checkbox_column_data));
            checked_count = length(checked);
            
            if checked_count == 0
                self.create_error_box("Please select a trial to shift downward");
            elseif checked_count > 1
                self.create_error_box("Please select only one trial to shift downward");
            else 
                
                selected = self.doc.block_trials(checked, :);
                
                if checked == length(self.doc.block_trials(:,1))
                    self.create_error_box("I can't shift down any further.");
                    return;
                else
                    below_selected = self.doc.block_trials(checked + 1, :);
                end
                    

                
                self.doc.block_trials(checked, :) = below_selected;
                self.doc.block_trials(checked + 1, :) = selected;

                
            end
%             
%             for i = 1:13
%                 self.update_gui_block(checked, i);
%                 self.update_gui_block(checked + 1, i);
%             end
            self.update_gui();
                
        end
        
%Autopopulate button, to be pressed after importing.
    function autofill(self, src, event)
        
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

        pat1 = pat_names{pat_index};
        pat1_field = d.get_pattern_field_name(pat1);
        
        if length(d.Patterns.(pat1_field).pattern.Pats(:,1,1))/16 ~= self.doc.num_rows
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
            if length(d.Patterns.(pat1_field).pattern.Pats(1,1,:)) < ...
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
        d.set_pretrial_property(9, self.colorgen());
        d.set_pretrial_property(10, self.colorgen());
        d.set_pretrial_property(11, self.colorgen());
        
        d.set_intertrial_property(2, pat1);
        d.set_intertrial_property(3, pos1);
        d.set_intertrial_property(4, ao1);
        
        %disable appropriate cells for mode 1
        d.set_intertrial_property(9, self.colorgen());
        d.set_intertrial_property(10, self.colorgen());
        d.set_intertrial_property(11, self.colorgen());
        
        d.set_posttrial_property(2, pat1);
        d.set_posttrial_property(3, pos1);
        d.set_posttrial_property(4, ao1);
        
        d.set_posttrial_property(9, self.colorgen());
        d.set_posttrial_property(10, self.colorgen());
        d.set_posttrial_property(11, self.colorgen());
        
        d.set_block_trial_property([1,2], pat1);
        d.set_block_trial_property([1,3], pos1);
        d.set_block_trial_property([1,4], ao1);
        
        d.set_block_trial_property([1,9], self.colorgen());
        d.set_block_trial_property([1,10], self.colorgen());
        d.set_block_trial_property([1,11], self.colorgen());
        
       
        
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

        
%MAIN MENU CALLBACK FUNCTIONS----------------------------------------------

%Import
    function import(self, src, event)
       
       answer = questdlg('Would you like to import a folder or a file?',...
           'Import', 'Folder', 'File', 'Cancel', 'Folder');
       
       switch answer
           case 'Folder'
               self.import_folder();

           case 'File'
                self.import_file()

           case 'Cancel'
               %do nothing
       end
       


    end
    
    function import_folder(self)
        
        path = uigetdir;
        
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
    
    function import_file(self)
        
        [imported_file, path] = uigetfile;
        
        if isequal(imported_file,0)
            %do nothing
        else


            self.doc.import_single_file(imported_file, path);

            set(self.num_rows_3, 'Enable', 'off');
            set(self.num_rows_4, 'Enable', 'off');
            self.update_gui();

        end
     end
        
        
       
    
    
    
    

%Save As

    function saveas(self, src, event)
        
        cut_date_off_name = regexp(self.doc.experiment_name,'-','split');
        if length(cut_date_off_name) > 1
            exp_name = cut_date_off_name{1}(1:end-2);
        else
            exp_name = self.doc.experiment_name;
        end
        dateFormat = 'mm-dd-yy_HH-MM-SS';
        %dateFormat = 30; %ISO8601 format, yyyymmddTHHMMSS (year, month, date, T for time, hours, minutes, seconds) - see matlab docs
        dated_exp_name = strcat(exp_name, datestr(now, dateFormat));
        self.doc.experiment_name = dated_exp_name;
        [file, path] = uiputfile('*.mat','File Selection', self.doc.experiment_name);
        full_path = fullfile(path, file);
        
        if file == 0
            return;
        end
        
        prog = waitbar(0,'Please wait...');
        
        waitbar(.33,prog,'Saving...');
        self.doc.replace_greyed_cell_values();
        self.doc.saveas(full_path, prog);
        if ~isempty(self.run_con)
            self.run_con.update_run_gui();
        end
        self.insert_greyed_cells();
        self.update_gui();
        
        

    end
    
%Save

    function save(self, src, event)
    %Controller gets up to data data from the model, then sends to the
    %document to save the file.
        
    %Get up to date variables from the model.

        self.doc.save();

    end

%Open

    function open_file(self, src, event, filepath)
        %document open function opens the file, saves the data, and sends
        %data back to controller. 

        %controller then sends updated data to model and updates gui.
        
        %check if there is a doc_ - if not, import the parent folder of the
        %.g4p file.
        if strcmp(filepath,'')
            [filename, top_folder_path] = uigetfile('*.g4p');
            filepath = fullfile(top_folder_path, filename);
        else
            [top_folder_path, filename] = fileparts(filepath);
        end
       
        if isequal (top_folder_path,0)
            return;
        else

            self.doc.top_export_path = top_folder_path;
            self.doc.import_folder(top_folder_path);
            [exp_path, exp_name, ext] = fileparts(filepath);

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
            self.doc.pretrial
            self.doc.intertrial
            self.doc.posttrial
            self.doc.block_trials
            
            self.insert_greyed_cells();     
            self.doc.set_recent_files(filepath);
            self.doc.update_recent_files_file();
            self.update_gui();
            
            if ~isempty(self.run_con)
                self.run_con.update_run_gui();
            end
            set(self.num_rows_3, 'Enable', 'off');
            set(self.num_rows_4, 'Enable', 'off');
        end
    end
    
  
    
    
    
 
        
%Copy to        
        function copy_to(self, src, event)
        
            checkbox_column_data = horzcat(self.doc.block_trials(1:end, end));
            checked = find(cell2mat(checkbox_column_data));
            checked_count = length(checked);
            
            if checked_count == 0
            
                disp("You must select a trial to copy over");
            
            elseif checked_count == 1
                
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
                
            else
                disp("You can only select one trial for this functionality");
            end
            
        end
        
%Set selected values to new trials

        function set_selected(self, src, event)
            
        %Check if any rows in the block are checked, add indexes of any
        %checked ones into checked_block
            checkbox_block_data = horzcat(self.doc.block_trials(1:end, end));
            checked_block = find(cell2mat(checkbox_block_data));
            checked_block_count = length(checked_block);
        
            prompt = {'Trial Mode:', 'Pattern Name:', 'Position Function:', ...
                'AO1:', 'AO2:', 'AO3:', 'AO4:', 'Frame Index:', 'Frame Rate:', ...
                'Gain:', 'Offset:', 'Duration:'};
            title = 'Trial Values';
            dims = [1 30];
            definput = {'1', 'default', 'default', '', '', '', '', '1', '60', ...
                '1', '0', '3'};
            answer = inputdlg(prompt, title, dims, definput);
            if length(answer) == 0
                return;
            end
            
            answer{1} = str2num(answer{1});
            answer{8} = str2num(answer{8});
            answer{9} = str2num(answer{9});
            answer{10} = str2num(answer{10});
            answer{11} = str2num(answer{11});
            answer{12} = str2num(answer{12});

            answer{end+1} = false;

            
            for i = 1:length(answer)
                adjusted_answer{1,i} = answer{i};
            end
            
            
            if self.doc.pretrial{13} == true
                self.doc.pretrial = adjusted_answer;
            end

            if self.doc.intertrial{13} == true
                self.doc.intertrial = adjusted_answer;
            end

            if self.doc.posttrial{13} == true
                self.doc.posttrial = adjusted_answer;
            end

            if checked_block_count ~= 0
                for i = 1:checked_block_count
                    self.doc.block_trials(checked_block(i),:) = adjusted_answer;
                end

            end
            
            self.update_gui();
            %disp(self.doc.block_trials(2,13));
        end

%END OF MAIN MENU CALLBACKS------------------------------------------------

%SELECT ALL CALLBACK-------------------------------------------------------

      function select_all(self, src, event)
        %assuming here that the number parameters will never differ between
        %trials. 
        l = length(self.doc.block_trials(1,:));
        if src.Value == false  
        %disp(length(self.doc.block_trials(:,1)));
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
      
%INVERT SELECTION CALLBACK-------------------------------------------------

        function invert_selection(self, src, event)

            L = length(self.doc.block_trials(:,1));
            len = length(self.doc.block_trials(1,:));

            for i = 1:L
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
        
        function [file] = check_table_selected(self, src, event, positions)
        
            x_event_index = event.Indices(1);
            y_event_index = event.Indices(2);
            self.model.current_selected_cell.index = event.Indices;
            if y_event_index > 1 && y_event_index< 8

                file = string(src.Data(x_event_index, y_event_index));

            else

                file = '';

            end
            if src.Position == positions.pre
                self.model.current_selected_cell.table = "pre";
            elseif src.Position == positions.inter
                self.model.current_selected_cell.table = "inter";
            elseif src.Position == positions.block
                self.model.current_selected_cell.table = "block";
            elseif src.Position == positions.post
                self.model.current_selected_cell.table = "post";
            end
        
        end
        


%IN SCREEN PREVIEW OF SELECTED CELL----------------------------------------

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
            
            if ~strcmp(file,'')
                [frame_rate, dur, patfield, posfield, aofield, file_type] = get_preview_parameters(self, is_table);

            %Now actually display the preview of whatever file is
            %selected


                self.display_inscreen_preview(frame_rate, dur, patfield, posfield, aofield, file_type); 
            end

            

        end

       
        
      
        
        
        function page_up_4d(self, src, event)
        end
        
        function page_down_4d(self, src, event)
        end


%FORWARD ONE FRAME ON IN SCREEN PREVIEW------------------------------------

        function frame_forward(self, src, event)

            if ~strcmp(self.model.current_preview_file,'') && length(self.model.current_preview_file(1,1,:)) > 1
                
                self.model.auto_preview_index = self.model.auto_preview_index + 1;
                if self.model.auto_preview_index > length(self.model.current_preview_file(1,1,:))
                    self.model.auto_preview_index = 1;
                end
                preview_data = self.model.current_preview_file(:,:,self.model.auto_preview_index);
                
                xax = [0 length(preview_data(1,:))];
                yax = [0 length(preview_data(:,1))];
                 
                max_num = max(preview_data,[],[1 2]);    
                adjusted_matrix = preview_data ./ max_num;
                
          

                % black = [1 1 1];
                 %white = [0 0 0];

                %for i = 1:30
                im = imshow(adjusted_matrix(:,:), 'Colormap', gray);
                set(im, 'parent', self.hAxes);
                set(self.hAxes, 'XLim', xax, 'YLim', yax);

            end


        end

%ONE FRAME BACK ON IN SCREEN PREVIEW---------------------------------------        
        
        function frame_back(self, src, event)

            if ~strcmp(self.model.current_preview_file,'') && length(self.model.current_preview_file(1,1,:)) > 1
                self.model.auto_preview_index = self.model.auto_preview_index - 1;

                if self.model.auto_preview_index < 1
                    self.model.auto_preview_index = length(self.model.current_preview_file(1,1,:));
                end
                
                data = self.model.current_preview_file;
                preview_data = data(:,:,self.model.auto_preview_index);
                
                xax = [0 length(preview_data(1,:))];
                yax = [0 length(preview_data(:,1))];
                 
                max_num = max(preview_data,[],[1 2]);    
                adjusted_matrix = preview_data ./ max_num;

                im = imshow(adjusted_matrix(:,:), 'Colormap', gray);
                set(im, 'parent', self.hAxes);
                set(self.hAxes, 'XLim', xax, 'YLim', yax);
            end

        end

%PLAY THE IN SCREEN PREVIEW------------------------------------------------
        
        function preview_play(self, src, event)

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
                adjusted_file = zeros(yax(2), xax(2), len);
                for i = 1:len
                    adjusted_matrix = self.model.current_preview_file(:,:,i) ./ max_num(i);
                    adjusted_file(:,:,i) = adjusted_matrix(:,:,1);

                    
                end
                im = imshow(adjusted_file(:,:,self.model.auto_preview_index), 'Colormap', gray);
                set(im,'parent', self.hAxes);
                set(self.hAxes, 'XLim', xax, 'YLim', yax );

                %while self.model.is_paused == 0    
                    for i = 1:len
                        if self.model.is_paused == false
                            self.model.auto_preview_index = self.model.auto_preview_index + 1;
                            if self.model.auto_preview_index > len
                                self.model.auto_preview_index = 1;
                            end
                            %imagesc(self.model.current_preview_file.pattern.Pats(:,:,self.model.auto_preview_index), 'parent', hAxes);
                            set(im,'cdata',adjusted_file(:,:,self.model.auto_preview_index), 'parent', self.hAxes);
                            drawnow

                            pause(1/fr_rate);



                        end
                     end
            end
        end

%PAUSE THE CURRENTLY PLAYING IN SCREEN PREVIEW-----------------------------        
        
        function preview_pause(self, src, event)


            self.model.is_paused = true;

        end

%STOP THE CURRENTLY PLAYING IN SCREEN PREVIEW------------------------------
        
        function preview_stop(self,src,event)
            
            if strcmp(self.model.current_selected_cell.table, "")
                self.create_error_box("Please make sure you've selected a cell.");
                return;
            end

            self.model.is_paused = true;
            self.model.auto_preview_index = 1;

                        %hAxes = gca; 
            x = [0 length(self.model.current_preview_file(1,:,1))];
            y = [0 length(self.model.current_preview_file(:,1,1))];
     
            max_num = max(self.model.current_preview_file,[],[1 2]);    
            adjusted_matrix = self.model.current_preview_file(:,:,self.model.auto_preview_index) ./ max_num(self.model.auto_preview_index);

            im = imshow(adjusted_matrix(:,:), 'Colormap', gray);
            set(im, 'parent', self.hAxes);
            set(self.hAxes, 'XLim', x, 'YLim', y);
                        
        end


%OPEN A FULL PREVIEW WINDOW OF SELECTED TRIAL------------------------------

        function full_preview(self, src, event)
                
          data = self.check_one_selected();
           if isempty(data)
               %do nothing
           else
               
               minicon = G4_preview_controller(data, self.doc);
               self.update_preview_con(minicon);
               
               %For all cells that have a file, set the object in question
               %equal to a variable and get its size. If there's not one
               %there, set the size (for the axes) to
               %default [1,3] (for an x axis three times the length of y
               %axis)
           mode = data{1};
               if mode == 1
                   self.preview_con.preview_Mode1();
               elseif mode == 2
                   self.preview_con.preview_Mode2();
               elseif mode == 3
                   self.preview_con.preview_Mode3();
               elseif mode == 4
                   self.preview_con.preview_Mode4();
               elseif mode == 5
                   self.preview_con.preview_Mode4();
               elseif mode == 6
                   self.preview_con.preview_Mode6();
               elseif mode == 7
                   self.preview_con.preview_Mode4();
               else
                   self.create_error_box("Please make sure you have entered a valid mode and try again.");
               end

%At this point, all axes should have been created and all existing
%functions should have been plotted. May change plotting method later in
%order to have the AO functions draw themselves in time.



            end



        end
        
%RUN A SINGLE TRIAL ON THE LED SCREENS TO MAKE SURE ITS WORKING------------

        function dry_run(self, src, event)

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
            pause(15);
            Panel_com('change_root_directory', experiment_folder)
            pause(.5);
            start = questdlg('Start Dry Run?','Confirm Start','Start','Cancel','Start');
            switch start
                case 'Cancel'
                    Panel_com('stop_display')
                    disconnectHost;
                    return;
                case 'Start'
            
                    pattern_index = self.doc.get_pattern_index(trial{2});
                    func_index = self.doc.get_posfunc_index(trial{3});
                    
                    %ao_index = self.doc.get_ao_index(trial{4});
                    
                    Panel_com('set_control_mode', trial_mode);
                    pause(.1);
                    Panel_com('set_pattern_id', pattern_index); 
                    pause(.1);
                    
                   % Panel_com('set_gain_bias', [LmR_gain LmR_offset])
                   if func_index ~= 0
                        Panel_com('set_pattern_func_id', func_index);
                        pause(.1);
                       
                   end
                    %Panel_com('set_ao_function_id',[0, ao_index]);
                    if ~isempty(trial{10})
                        Panel_com('set_gain_bias',[LmR_gain LmR_offset]);
                        pause(.1);
                       
                    end
                    if trial_mode == 2
                        Panel_com('set_frame_rate', trial_fr_rate);
                        pause(.1);
                        
                    end
                    Panel_com('set_position_x', trial_frame_index);
                    pause(.1);
                    
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
                    %Panel_com('reset_display');
                    %end of trial portion
            end
                  
            
        end


        

%FULL PREVIEW FOR MODE 1---------------------------------------------------

        
        function animateMode1(self, src, event, data, pos_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos, f, pos_data, im, pat_obj)
            
             [pos, ao1, ao2, ao3, ao4] = self.create_preview_objects(data, pos_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos, f); %CREATE THIS FUNCTION TO RETURN AXES

            if pos == 0
                self.create_error_box("Please make sure you have entered a position function and try again.");
            else


                for i = self.model.auto_preview_index:length(pos_data)
                    
                    if self.model.is_paused == false

                        frame = pos_data(i);
                        disp(frame);
                        set(im,'cdata',pat_obj(:,:,frame));

                        pos.XData = [self.model.auto_preview_index + 1, self.model.auto_preview_index + 1];

                        if ao1 ~= 0
                            ao1.XData = [self.model.auto_preview_index + 1, self.model.auto_preview_index + 1];
                        end
                        if ao2 ~= 0
                            ao2.XData = [self.model.auto_preview_index + 1, self.model.auto_preview_index + 1];
                        end
                        if ao3 ~= 0
                            ao3.XData = [self.model.auto_preview_index + 1, self.model.auto_preview_index + 1];
                        end
                        if ao4 ~= 0
                            ao4.XData = [self.model.auto_preview_index + 1, self.model.auto_preview_index + 1];
                        end

                        drawnow limitrate nocallbacks
                        java.lang.Thread.sleep(17);
                        
                        self.model.auto_preview_index = self.model.auto_preview_index + 1;
                        
                    else
                        
                        self.model.auto_preview_index = i;
                        
                    end
                       


                end
            end
        end
        


%CHECK IF PARTICULAR FILE EXISTS-------------------------------------------

        function [loaded_file] = check_file_exists(self, filename)

            if isfile(filename) == 0
                self.create_error_box("This file doesn't exist");
                loaded_file = 0;
            else
                loaded_file = load(filename);
            end


        end

%PLOT A POSITION OR AO FUNCTION--------------------------------------------

        function [func_line] = plot_function(self, fig, func, position, graph_title, x_label, y_label)

                xlim = [0 length(func(1,:))];
                ylim = [min(func) max(func)];
                func_axes = axes(fig, 'units','pixels','Position', position, ...
                    'XLim', xlim, 'YLim', ylim);
                %title(func_axes, graph_title);
        %         xlabel(func_axes, x_label);
        %         ylabel(func_axes, y_label);
                p = plot(func);
                set(p, 'parent', func_axes);
                func_line = line('XData',[self.model.auto_preview_index,self.model.auto_preview_index],'YData',[ylim(1), ylim(2)]);
                title(graph_title);
                xlabel(x_label);
                ylabel(y_label);
                

        end
        
        function open_run_gui(self, src, event)
            
            self.run_con = G4_conductor_controller(self.doc);
            
        end
        
%PREVIEW SELECTED CELL ON IN-SCREEN PREVIEW--------------------------------        
        function display_inscreen_preview(self, frame_rate, dur, patfield, funcfield, aofield, file_type)  
    
            if strcmp(file_type, 'pat')

                self.model.auto_preview_index = self.check_pattern_dimensions(patfield);
                self.model.current_preview_file = self.doc.Patterns.(patfield).pattern.Pats;

                x = [0 length(self.model.current_preview_file(1,:,1))];
                y = [0 length(self.model.current_preview_file(:,1,1))];
                adjusted_file = zeros(y(2),x(2),length(self.model.current_preview_file(1,1,:)));
                max_num = max(max(self.model.current_preview_file,[],2));
                for i = 1:length(self.model.current_preview_file(1,1,:))

                    adjusted_matrix = self.model.current_preview_file(:,:,i) ./ max_num(i);
                    adjusted_file(:,:,i) = adjusted_matrix(:,:,1);
                end

                self.hAxes = axes(self.f, 'units', 'pixels', 'OuterPosition', [245, 135, 1190 ,397], 'XTick', [], 'YTick', [] ,'XLim', x, 'YLim', y);
                im = imshow(adjusted_file(:,:,self.model.auto_preview_index), 'Colormap',gray);

                set(im, 'parent', self.hAxes);



            elseif strcmp(file_type, 'pos')


                self.model.current_preview_file = self.doc.Pos_funcs.(funcfield).pfnparam.func;
                self.model.current_preview_file
                self.hAxes = axes(self.f,'units', 'pixels', 'OuterPosition', [245, 135, 1190 ,397]);
                self.second_axes = axes(self.f, 'units', 'pixels', 'OuterPosition', self.hAxes.OuterPosition, 'XAxisLocation', 'top', 'YAxisLocation', 'right');
                plot(self.model.current_preview_file, 'parent', self.hAxes);

                time_in_ms = length(self.model.current_preview_file(1,:));
                xax = [0 time_in_ms];
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

                if dur <= length(self.model.current_preview_file(1,:))
                    line('XData', [dur, dur], 'YData', [yax(1), yax(2)], 'Color', [1 0 0], 'LineWidth', 2);
                end

            elseif strcmp(file_type, 'ao')

                self.model.current_preview_file = self.doc.Ao_funcs.(aofield).afnparam.func;
                self.hAxes = axes(self.f,'units', 'pixels', 'OuterPosition', [245, 135, 1190 ,397]);
                self.second_axes = axes(self.f, 'units', 'pixels', 'OuterPosition', self.hAxes.OuterPosition, 'XAxisLocation', 'top', 'YAxisLocation', 'right');

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

            end



        end
        
%PROVIDES LIST OF IMPORTED FILES TO CHOOSE FROM WHEN EMPTY CELL IS SELECTED        
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
 
%PULLS PARAMETERS FROM TRIAL CONTAINING A SELECTED CELL FOR PREVIEWING-----        
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
                    else
                        aofile = self.doc.pretrial{index(2)};
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
                    else
                        frame_rate = 30;
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
                    end
                end
                if index(2) > 3 && index(2) < 8 
                    file_type = 'ao';
                    if is_table == 0
                        aofile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                    else
                        aofile = self.doc.intertrial{index(2)};
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
                    else
                        frame_rate = 30;
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
                    end
                end
                
                if index(2) > 3 && index(2) < 8 
                    file_type = 'ao';
                    if is_table == 0
                        aofile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                    else
                        aofile = self.doc.block_trials{index(1), index(2)};
                    end
                end
                
                patfield = self.doc.get_pattern_field_name(patfile);
                funcfield = self.doc.get_posfunc_field_name(funcfile);
                aofield = self.doc.get_aofunc_field_name(aofile);
                
                if mode == 2
                    frame_rate = self.doc.block_trials{index(1), 9};
                else
                    if ~strcmp(patfield,'')
                    
                        if self.doc.Patterns.(patfield).pattern.gs_val == 1
                            frame_rate = 1000;
                        else 
                            frame_rate = 500;
                        end
                    else
                        frame_rate = 30;
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
                    end
                end
                if index(2) > 3 && index(2) < 8 
                    file_type = 'ao';
                    if is_table == 0
                        aofile = self.listbox_imported_files.String{self.listbox_imported_files.Value};
                    else
                        aofile = self.doc.posttrial{index(2)};
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
                    else
                        frame_rate = 30;
                    end
                end

                dur = self.doc.posttrial{12}*1000;
            end
            
            
            
            

        end



%ERROR CATCHING FUNCTIONS--------------------------------------------------

%REFERENCE FOR Y INDEX VALUES
    %MODE y = 1, PAT NAME y = 2, POS FUNC y = 3, AO1-4 y = 4-7, Frame Ind y =
    %8, Frame Rate y = 9, Gain y = 10, Offset y = 11, Duration y = 12, Select y
    %= 13
    

%CHECK IF THE CELL IS EDITABLE---------------------------------------------

%Return true or false, on true the update function continues, on false the 
%gui is updated with the old data and an error message is displayed. 
        function [allow] = check_editable(self, mode_val, y) 


            allow = 1;
            if ~isnumeric(mode_val)
                mode_val = str2num(mode_val);
            end

            %check that the field is editable based on the mode
            if isempty(mode_val)
                return;
            elseif mode_val == 1 && (7 < y) && (12 > y)

                allow = 0;

            elseif mode_val == 2 && (y ==3 || ((y > 9) && (y < 12)))

                allow = 0;

            elseif mode_val == 3 && (y == 3 || ((y > 8) && (y < 12)))

                allow = 0;

            elseif mode_val == 4 && (y == 3 || y == 9 )

                allow = 0;

            elseif (mode_val == 5 || mode_val == 6) && (y == 9)

                allow = 0;

            elseif mode_val == 7 && ( y == 3 || ((y > 7) && (y < 12)))

                allow = 0;

            end

        end

%CHECK THAT THE VALUE ENTERED IS WITHIN BOUNDS-----------------------------        
        
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

%CHECK PATTERN BEING PREVIEWED FOR THREE OR FOUR DIMENSIONS----------------

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

%CLEAR GREY SPACE AND INSERT PATTERN INTO PATTERN CELL---------------------

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
%CLEAR APPROPRIATE FIELDS WHEN THE MODE IS CHANGED-------------------------

function clear_fields(self, mode)

    pos_fields = fieldnames(self.doc.Pos_funcs);
    pat_fields = fieldnames(self.doc.Patterns);
    pos = self.colorgen();
    indx = [];
    rate = self.colorgen();
    gain = self.colorgen();
    offset = self.colorgen();
    
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
        
        pos = self.colorgen();
        indx = self.colorgen();
        rate = self.colorgen();
        gain = self.colorgen();
        offset = self.colorgen();
        self.set_mode_dep_props(pos, indx, rate, gain, offset);
        if strcmp(self.model.current_selected_cell.table,"pre") == 1
            self.doc.set_pretrial_property(2, self.colorgen());
            for i = 4:7
                self.doc.set_pretrial_property(i,self.colorgen());
            end
            self.doc.set_pretrial_property(12,self.colorgen());
            
        elseif strcmp(self.model.current_selected_cell.table,"inter") == 1
            self.doc.set_intertrial_property(2, self.colorgen());
            for i = 4:7
                self.doc.set_intertrial_property(i,self.colorgen());
            end
            self.doc.set_intertrial_property(12,self.colorgen());
            
            
        elseif strcmp(self.model.current_selected_cell.table,"post") == 1
            self.doc.set_posttrial_property(2, self.colorgen());
            for i = 4:7
                self.doc.set_posttrial_property(i,self.colorgen());
            end
            self.doc.set_posttrial_property(12,self.colorgen());
            
            
        else
            x = self.model.current_selected_cell.index(1);
            self.doc.set_block_trial_property([x,2], self.colorgen());
            for i = 4:7
                self.doc.set_block_trial_property([x,i],self.colorgen());
            end
            self.doc.set_block_trial_property([x,12],self.colorgen());
        end
        
    end

end

function set_mode_dep_props(self, pos, indx, rate, gain, offset)

    if strcmp(self.model.current_selected_cell.table,"pre") == 1
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

function [c] = colorgen(self)
    color = self.uneditable_cell_color;
    text = self.uneditable_cell_text;
    c = ['<html><table border=0 width=400 bgcolor=',color,'><TR><TD>',text,'</TD></TR></table>'];
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
        post_indices_to_color = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    end
  
    
    for i = 1:length(pre_indices_to_color)
        self.doc.set_pretrial_property(pre_indices_to_color(i),self.colorgen());
       
    end
    for i = 1:length(inter_indices_to_color)
        self.doc.set_intertrial_property(inter_indices_to_color(i),self.colorgen());
    end
    for i = 1:length(post_indices_to_color)
        self.doc.set_posttrial_property(post_indices_to_color(i),self.colorgen());
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
            self.doc.set_block_trial_property([i,indices_to_color(j)],self.colorgen());
        end
    end
            


end

% function mismatched_sample_rates_dialog(self)
% 
%     d = dialog('Units','Normalized','Position',[.45,.45,.1,.1],'Name','Configuration File Mismatch');
%     warning = uicontrol('Parent',d,'Style','text','Units','Normalized','Position',[.1,.9,.75,.1],...
%         'String','The sample rates in the configuration file do not match those shown on the screen. Do you want to: ');
%     grp = uibuttongroup('Parent',d,'Units','Normalized','Position',[.1,.1,.75,.75],'SelectionChangedFcn',{@self.mismatched_sample_rates_response,d});
%     choice1 = uicontrol('Parent',grp,'Style','radiobutton','Units','Normalized','Position',[.1,.7,.75,.2],'String','Change configuration file to match screen.');
%     choice2 = uicontrol('Parent',grp,'Style','radiobutton','Units','Normalized','Position',[.1,.4,.75,.2],'String','Change screen to match configuration file.');
%     choice3 = uicontrol('Parent',grp,'Style','radiobutton','Units','Normalized','Position',[.1,.1,.75,.2],'String','Do nothing, will fix manually.');
% 
% end
% 
% function mismatched_sample_rates_response(self, src, event, d)
%     
%     if event.NewValue.Position(2) == .7
%         
%         self.doc.update_config_file(self.doc.chan1_rate, 1);
%         self.doc.update_config_file(self.doc.chan2_rate, 2);
%         self.doc.update_config_file(self.doc.chan3_rate, 3);
%         self.doc.update_config_file(self.doc.chan4_rate, 4);
%         
%     elseif event.NewValue.Position(2) == .4
%         
%         self.doc.set_chan1_rate(str2num(self.configData_{14}(end-3:end)));
%         self.doc.set_chan2_rate(str2num(self.configData_{15}(end-3:end)));
%         self.doc.set_chan3_rate(str2num(self.configData_{16}(end-3:end)));
%         self.doc.set_chan4_rate(str2num(self.configData_{17}(end-3:end)));
% 
%     else
%         %do nothing, they exited out of the dialog box
%         
%     end
%     
%     delete(d);
%     self.chan1_rate_box.String = num2str(self.doc.chan1_rate);
%     
% end





%CHECK THAT ONLY ONE TRIAL IS SELECTED-------------------------------------

%returns the data of the trial that is selected or an error if 0 or >1
%trials are selected

        function [data] = check_one_selected(self)

     %find selected rows in ALL tables

     %finds checked rows in block table
            checkbox_block_data = horzcat(self.doc.block_trials(1:end, end));
            checked_block = find(cell2mat(checkbox_block_data));
            checked_block_count = length(checked_block);

     %Figures out which table has the selected row and ensures no more than
     %one table has a selected row
            if checked_block_count ~= 0
                checked_trial = 'block';
            end


            if cell2mat(self.doc.pretrial(13)) == 1
                pretrial_checked = 1;
                checked_trial = 'pre';
            else 
                pretrial_checked = 0;

            end

            if cell2mat(self.doc.intertrial(13)) == 1
                intertrial_checked = 1;
                checked_trial = 'inter';
            else 
                intertrial_checked = 0;
            end

            if cell2mat(self.doc.posttrial(13)) == 1
                posttrial_checked = 1;
                checked_trial = 'post';
            else 
                posttrial_checked = 0;
            end

            all_checked = checked_block_count + pretrial_checked + intertrial_checked ...
                + posttrial_checked;

      %throw error if more or less than one is selected
            if all_checked == 0 
                self.create_error_box("You must selected a trial to preview");
                data = [];
            elseif all_checked > 1
                self.create_error_box("You can only select one trial at a time to preview");
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

        %SETTERS
        
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
         
         function set.bg2(self, value)
             self.bg2_ = value;
         end
         
         function set.num_rows_3(self, value)
             self.num_rows_3_ = value;
         end
         
         function set.num_rows_4(self, value)
             self.num_rows_4_ = value;
         end
         
         function set.bg(self, value)
             self.bg_ = value;
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
         
         function set.uneditable_cell_color(self, value)
             self.uneditable_cell_color_ = value;
         end
         
         function set.uneditable_cell_text(self, value)
             self.uneditable_cell_text_ = value;
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




% GETTERS

        
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
         
         function output = get.bg2(self)
             output = self.bg2_;
         end
         
         function output = get.num_rows_3(self)
             output = self.num_rows_3_;
         end
         
         function output = get.num_rows_4(self)
             output = self.num_rows_4_;
         end
         
         function output = get.bg(self)
             output = self.bg_;
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
         
         function output = get.uneditable_cell_color(self)
             output = self.uneditable_cell_color_;
         end
         
         function output = get.uneditable_cell_text(self)
             output = self.uneditable_cell_text_;
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

         
%SETTERS OF GUI OBJECT VALUES



         function set_pretrial_table_data(self)
            self.pretrial_table.Data = self.doc.pretrial;
         end

         function set_intertrial_table_data(self)
            self.intertrial_table.Data = self.doc.intertrial;
         end

         function set_posttrial_table_data(self)

            self.posttrial_table.Data = self.doc.posttrial;

         end

%          function set_block_table_data_xy(self, x, y)
 
%              
%              
%              %disp(self.doc.block_trials);
% 
%              
%             self.block_table_.Data{x, y} = self.doc.block_trials{x,y};
%             
%             
%             %set(self.block_table_, 'data', self.doc.block_trials);
%          end
         
         function set_block_table_data(self)
             
               %%%%%%%%%%%%%%%%%%THIS IS NOT A GOOD PERMANENT SOLUTION FOR
%              %%%%%%%%%%%%%%%%%%THE SCROLLBAR JUMPING ISSUE. USING PAUSE CAN
%              %%%%%%%%%%%%%%%%%%UNDER CERTAIN CIRCUMSTANCES HAVE WEIRD
%              %%%%%%%%%%%%%%%%%%RESULTS, AND JAVA INTERVENTIONS MAY STOP
%              %%%%%%%%%%%%%%%%%%WORKING WITH ANY RELEASE. FIGURE OUT WHY
%              %%%%%%%%%%%%%%%%%%ADAM'S TABLE DOESN'T JUMP. -- ITS A
%              %%%%%%%%%%%%%%%%%%DIFFERENCE BETWEEN RELEASES. DOWNLOAD 2019
%              %%%%%%%%%%%%%%%%%%and see if that fixes it, if not, ask Mike
                %%%%%%%%%%%%%%%%%%if they have a release preference. 
             
            jTable = findjobj(self.block_table);
            jScrollPane = jTable.getComponent(0);
            javaObjectEDT(jScrollPane);
            currentViewPos = jScrollPane.getViewPosition;
             
             self.block_table.Data = self.doc.block_trials;
             
                         
            pause(0);
            jScrollPane.setViewPosition(currentViewPos);
         end

         function set_bg_selection(self)
            if self.doc.is_randomized == 1
                set(self.bg,'SelectedObject',self.isRandomized_radio);
            else
                set(self.bg,'SelectedObject',self.isSequential_radio);
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
         
         function set_bg2_selection(self)
            
             value = get(self.num_rows_3, 'Enable');
             if strcmp(value,'off') == 1
                 %do nothing
             else
                if self.doc.num_rows == 3
                    set(self.bg2,'SelectedObject',self.num_rows_3);
                else
                    set(self.bg2,'SelectedObject',self.num_rows_4);
                end
             end
            
         end
         
         function set_exp_name(self)
             set(self.exp_name_box,'String', self.doc.experiment_name);
         end
         
         function set_recent_file_menu_items(self)
             for i = 1:length(self.doc.recent_g4p_files)
                 [path,filename] = fileparts(self.doc.recent_g4p_files{i});
                 if i > length(self.recent_file_menu_items)
                     self.recent_file_menu_items{end + 1} = uimenu(self.menu_open, 'Text', filename, 'MenuSelectedFcn', {@self.open_file, self.doc.recent_g4p_files{i}});
                 else
                
                    set(self.recent_file_menu_items{i},'Text',filename);
                    set(self.recent_file_menu_items{i}, 'MenuSelectedFcn', {@self.open_file, self.doc.recent_g4p_files{i}});
                 end

             end
         end
         

         
             
         
         
%          function [self] = setfield(self.pre_files,'pattern', new)
%          
%             self.pre_files.pattern = new;
%              
%          end
         
         
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
                %disp(self.block_files.pattern(x));
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
 
%          function self = set.pre_selected_index_(self, value)
%              self.pre_selected_index_ = value;
%          end
%          
%          function self = set.auto_preview_index_(self, value)
%              self.model.auto_preview_index_ = value;
%          end
%          


     end


end

