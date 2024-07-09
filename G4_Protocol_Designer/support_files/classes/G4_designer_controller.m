classdef G4_designer_controller < handle %Made this handle class because was having trouble getting setters to work, especially with struct properties.

%% Properties
    properties

        ctlr % contains the panels controller when its opened
        model %contains all data that does not persist with saving
        view %contains all GUI objects
        preview_con %controller for the fullscreen preview
        run_con %controller for the run window - can be opened independently
        doc %contains all data that is stored in the saved file
        settings_con %controller (containing the view and model) for the settings panel


        %structs in which to load files as they are entered
        pre_files
        inter_files
        block_files
        post_files
        hAxes
        second_axes
        listbox_imported_files
        menu_open
        inscreen_plot
        preview_on_arena

        
    end

%% Methods
    methods

%% CONSTRUCTOR-------------------------------------------------------------

        function self = G4_designer_controller()
            self.set_model(G4_designer_model());
            self.set_doc(G4_document());
            self.set_settings_con(G4_settings_controller());
            self.set_preview_con(G4_preview_controller(self.doc));
            self.set_preview_on_arena(0);

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

           self.view = G4_designer_view(self);
           self.update_gui() ;
        end


%% CALLBACK FUNCTIONS------------------------------------------------------
    %% Edit callbacks to update values in the model
        %(Update functions which do not serve as a callback toward end)

        %Update pretrial model data

        function update_trial_doc(self, new, x, y, trialtype)

            % if we are adding an entire new trial to the block, add all
            % new files to the files list
            if strcmp(trialtype,'block') && x > size(self.doc.block_trials, 1)
                for i = 2:7
                    self.set_files(x, i, new{i}, 'block');
                end
            end

            %if we are only updating one cell but it is a file cell, update
            %the files list
            if y >= 2 && y <= 7
                self.set_files(x, y, new, trialtype)
            end

            %set the property (or add entire new trial)
            self.doc.set_trial_property(x, y, new, trialtype);
            if y == 1
                self.clear_fields(str2num(new));
            end
            if strcmp(trialtype, 'block')
                if y == 13 && new == 0
                    self.deselect_selectAll();
                end
            end
        end


        %Update repetitions
        function update_repetitions(self, new)
            
            self.doc.set_repetitions(new);

        end

        %Update Randomization

        function update_randomize(self, new)
            
            if strcmp(new, 'Randomize Trials') == 1
                new_val = 1;
            else
                new_val = 0;
            end
            self.doc.set_is_randomized(new_val);
    
        end

        %Update channel sample rates
        function update_chan1_rate(self, new)

            self.doc.set_chan1_rate(new);         
            self.doc.set_config_data(new, 1);
            self.doc.update_config_file();
            
        end

        function update_chan2_rate(self, new)

            self.doc.set_chan2_rate(new);
            self.doc.set_config_data(new,2);
            self.doc.update_config_file();

        end

        function update_chan3_rate(self, new)
            self.doc.set_chan3_rate(new);
            self.doc.set_config_data(new,3);
            self.doc.update_config_file();
        end

        function update_chan4_rate(self, new)
            self.doc.set_chan4_rate(new);
            self.doc.set_config_data(new,4);
            self.doc.update_config_file();

        end

        %Update the screen type (3 or 4 rows)
        function update_rowNum(self, new_val)

            self.doc.set_num_rows(new_val);%do this for other config updating
            self.doc.set_config_data(new_val, 0);
            self.doc.update_config_file();

        end

        %Update the experiment name
        function update_experiment_name(self, new_val)
            self.doc.set_experiment_name(new_val);
            if ~isempty(self.run_con)
                self.run_con.view.update_run_gui();
            end
        end

        % Set pre, inter, and post trial to default values
        function reset_defaults(self)

            % Make default be that there is no pretrial
            
            newData = '';
            x = 1;
            y = 1;
            curr_cell.table = "pre";
            curr_cell.index = [1,1];
            self.set_current_selected_cell(curr_cell);
            self.update_trial_doc(newData, x, y, 'pre');

            % Make default be that there is no intertrial
            curr_cell.table = "inter";
            curr_cell.index = [1,1];
            self.set_current_selected_cell(curr_cell);
            self.update_trial_doc(newData, x, y, 'inter');

            % Make default be that there is no posttrial
            curr_cell.table = "post";
            curr_cell.index = [1,1];
            self.set_current_selected_cell(curr_cell);
            self.update_trial_doc(newData, x, y, 'post');

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
                    self.doc.set_block_trial(checked_list(i) - (i-1), []);
                     %self.doc.block_trials(checked_list(i) - (i-1),:) = [];
                end
            end
            
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
                        self.update_trial_doc(false, i, l, 'block');
                    end
                end
            else
                for i = 1:length(self.doc.block_trials(:,1))
                    if cell2mat(self.doc.block_trials(i, l)) == 0
                        self.update_trial_doc(true, i, l, 'block');
                    end
                end
            end
            self.model.set_isSelect_all(src.Value);
            
        end

        % Invert which trials in the block trial are selected
        function invert_selection(self, ~, ~)
            num = length(self.doc.block_trials(:,1));
            len = length(self.doc.block_trials(1,:));

            for i = 1:num
                if cell2mat(self.doc.block_trials(i,len)) == 0
                    self.update_trial_doc(true, i, len, 'block');
                elseif cell2mat(self.doc.block_trials(i,len)) == 1
                    self.update_trial_doc(false, i,len, 'block');
                else
                    disp('There has been an error, the selected value must be true or false');
                end
            end

            

        end

        % Button to auto populate tables with the imported files in a
        % semi-intelligent way

%%%%%%%%%%%%%TO DO - AUTOFILL FUNCTION IS LARGE, BREAK IT UP
        function autofill(self, ~, ~)

            pat_index = 1; %Keeps track of the indices of patterns that are actually displayed (not cut due to screen size discrepancy)
            pat_indices = []; %A record of all pattern indices that match the screen size.

            d = self.doc;
            default_mode = 1;
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
                pat1 = '';
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

            self.update_trial_doc(default_mode, 1, 1, 'pre');
            self.update_trial_doc(pat1, 2, 1, 'pre');
            self.update_trial_doc(pos1, 3, 1, 'pre');
            self.update_trial_doc(ao1, 4, 1, 'pre');

            %disable appropriate cells for mode 1
            self.update_trial_doc(self.doc.colorgen(), 9, 1, 'pre');
            self.update_trial_doc(self.doc.colorgen(), 10, 1, 'pre');
            self.update_trial_doc(self.doc.colorgen(), 11, 1, 'pre');

            self.update_trial_doc(default_mode, 1, 1, 'inter');
            self.update_trial_doc(pat1, 2, 1, 'inter');
            self.update_trial_doc(pos1, 3, 1, 'inter');
            self.update_trial_doc(ao1, 4, 1, 'inter');

            %disable appropriate cells for mode 1
            self.update_trial_doc(self.doc.colorgen(), 9, 1, 'inter');
            self.update_trial_doc(self.doc.colorgen(), 10, 1, 'inter');
            self.update_trial_doc(self.doc.colorgen(), 11, 1, 'inter');

            self.update_trial_doc(default_mode, 1, 1, 'post');
            self.update_trial_doc(pat1, 2, 1, 'post');
            self.update_trial_doc(pos1, 3, 1, 'post');
            self.update_trial_doc(ao1, 4, 1, 'post');

            %disable appropriate cells for mode 1
            self.update_trial_doc(self.doc.colorgen(), 9, 1, 'post');
            self.update_trial_doc(self.doc.colorgen(), 10, 1, 'post');
            self.update_trial_doc(self.doc.colorgen(), 11, 1, 'post');

            if num_pos ~= 0
                if d.Pos_funcs.(pos1_field).pfnparam.gs_val == 1

                    block_dur = round(d.Pos_funcs.(pos1_field).pfnparam.size/2000,1);
                else
                    block_dur = round(d.Pos_funcs.(pos1_field).pfnparam.size/1000,1);
                end
                self.update_trial_doc(block_dur, 1, 12, 'block');
            end
            self.update_trial_doc(default_mode, 1, 1, 'block');
            self.update_trial_doc(pat1, 2, 1, 'block');
            self.update_trial_doc(pos1, 3, 1, 'block');
            self.update_trial_doc(ao1, 4, 1, 'block');

            %disable appropriate cells for mode 1
            self.update_trial_doc(self.doc.colorgen(), 9, 1, 'block');
            self.update_trial_doc(self.doc.colorgen(), 10, 1, 'block');
            self.update_trial_doc(self.doc.colorgen(), 11, 1, 'block');

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
                        if d.Pos_funcs.(pos_field).pfnparam.gs_val == 1
                            dur = round(d.Pos_funcs.(pos_field).pfnparam.size/2000,1);
                        else
                            dur = round(d.Pos_funcs.(pos_field).pfnparam.size/1000,1);
                        end
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
                    self.update_trial_doc(newrow, j, 1, 'block')

                end
            end
            
        end

        %Replace the currently selected cell in the tables with the
        %currently selected file in the imported files list.

        function select_new_file(self, new_file)

            curr_cell = self.get_current_selected_cell();
            x = curr_cell.index(1);
            y = curr_cell.index(2);
            trialtype = curr_cell.table;
            self.update_trial_doc(new_file, x, y, trialtype)
            
        end

        %Callback upon right click of table cell (does nothing atm)
        function right_click(self, src, event)
            disp("You right clicked the cell!");
        end

    %% File menu callback functions

        %Import a folder or file
        function import(self)
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
        function open_file(self, filepath)
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
                self.doc.set_top_export_path(top_folder_path);
                import_success = self.doc.import_folder(top_folder_path);
                waitfor(msgbox(import_success, 'Import successful!'));
                [~, exp_name, ~] = fileparts(filepath);

                if isempty(fieldnames(self.doc.Patterns))
                    %no patterns were successfully imported, so don't autofill
                    return;
                end

                data = self.doc.open(filepath);
                m = self.doc;
                d = data.exp_parameters;

                %Set parameters outside tables
                self.update_experiment_name(exp_name);
                m.set_repetitions(d.repetitions);
                m.set_is_randomized(d.is_randomized);
                m.set_is_chan1(d.is_chan1);
                m.set_is_chan2(d.is_chan2);
                m.set_is_chan3(d.is_chan3);
                m.set_is_chan4(d.is_chan4);
                m.set_chan1_rate(d.chan1_rate);
                m.set_config_data(d.chan1_rate, 1);
                m.set_chan2_rate(d.chan2_rate);
                m.set_config_data(d.chan2_rate, 2);
                m.set_chan3_rate(d.chan3_rate);
                m.set_config_data(d.chan3_rate, 3);
                m.set_chan4_rate(d.chan4_rate);
                m.set_config_data(d.chan4_rate, 4);
                m.set_num_rows(d.num_rows);
                m.set_config_data(d.num_rows, 0);
                self.doc.update_config_file();

                for k = 1:13
                    self.update_trial_doc(d.pretrial{k}, 1, k, 'pre');
                    self.update_trial_doc(d.intertrial{k}, 1, k, 'inter');
                    self.update_trial_doc(d.posttrial{k}, 1, k, 'post');

                end

                for i = 2:length(m.block_trials(:, 1))
                    m.block_trials((i-(i-2)),:) = [];
                end
                block_x = length(d.block_trials(:,1));
                block_y = 1;

                for j = 1:block_x
                    if j > length(m.block_trials(:,1))
                        newrow = d.block_trials(j,1:end);
                        self.update_trial_doc(newrow, j, block_y, 'block');
           
                    else
                        for n = 1:13
                            self.update_trial_doc(d.block_trials{j,n}, j, n, 'block');
                       
                        end
                    end
                end

                self.insert_greyed_cells();
                self.doc.set_recent_files(filepath);
                self.doc.update_recent_files_file();
                

                if ~isempty(self.run_con)
                    self.run_con.view.update_run_gui();
                end
                
            end
        end

        %Save current experiment as a .g4p file and export necessary files

        function saveas(self)
            %gets the current experiment name without the timestamp
            exp_name = self.doc.get_experiment_name();   
            %adds current timestamp before saving the experiment name
            self.doc.set_experiment_name(exp_name);
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
            
        end

        %Copy selected block trial cell to the pretrial, intertrial, and/or posttrial
        function copy_to(self)
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
                            for p = 1:length(selected)
                                self.update_trial_doc(selected{p},1,p,'pre');
                            end
                        elseif indx(i) == 2
                            for p = 1:length(selected)
                                self.update_trial_doc(selected{p}, 1, p, 'inter');
                            end
                        elseif indx(i) == 3
                            for p = 1:length(selected)
                                self.update_trial_doc(selected{p}, 1, p, 'post');
                            end
                        else
                            disp("There has been an error, please try again.");
                        end
                    end
                end
                
            end
        end

        %Prompt the users for parameter values with which to populate all
        %selected trials

        function set_selected(self)
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
                    self.update_trial_doc(adjusted_answer{i}, 1, i, 'pre');
                end
            end

            if self.doc.intertrial{13} == true
                for i = length(adjusted_answer)
                    self.update_trial_doc(adjusted_answer{i}, 1, i, 'inter');
                end
            end

            if self.doc.posttrial{13} == true
                for i = length(adjusted_answer)
                    self.update_trial_doc(adjusted_answer{i}, 1, i, 'post');
                end
            end

            if checked_block_count ~= 0
                for i = 1:checked_block_count
                    for k = 1:length(adjusted_answer)
                        self.update_trial_doc(adjusted_answer{k}, checked_block(i),k, 'block');

                    end
                end
            end

        end

        function open_settings(self)
            self.settings_con.layout_view();
        end

        %% In screen preview related callbacks

        % Display preview of file when an appropriate table cell is
        % selected

        function update_preview_on_arena(self)
            if self.preview_on_arena == 1
                self.preview_on_arena = 0;
                self.turn_off_screen();
                self.close_host();
            else
                self.preview_on_arena = 1;
            end
        end

        function close_host(self)
            if self.model.host_connected
                self.ctlr.close();
                self.model.set_host_connected(0);
            end
        end

        function preview_selection(self, is_table)

            %Get all parameters that might be needed for preview from
            %the trial the selected cell belongs to.

            [frame_rate, dur, patfield, posfield, aofield, file_type] = get_preview_parameters(self, is_table);
            %Now actually display the preview of whatever file is
            %selected
            if strcmp(file_type, 'pat') && ~strcmp(patfield,'')
                self.inscreen_pattern_preview(patfield);
            elseif strcmp(file_type, 'pos') && ~strcmp(funcfield,'')
                self.inscreen_pos_preview(frame_rate, dur, posfield);
            elseif strcmp(file_type, 'ao') && ~strcmp(aofield,'')
                self.inscreen_ao_preview(frame_rate, aofield);

            else 
                self.inscreen_function_preview(frame_rate, dur, posfield, aofield, file_type);
            end
            
        end


        %Play through the pattern library in in-screen preview

        function fr_rate = prepare_preview_play(self)
            self.model.set_is_paused(false);
            curr_cell = self.get_current_selected_cell();
            trialtype = curr_cell.table;
            x = curr_cell.index(1);
            y = curr_cell.index(2);
            mode = self.get_trial_component(trialtype, x, 1);
            if mode == 2
                fr_rate = self.get_trial_component(trialtype, x, 9);
            else
                fr_rate = 30;
            end

        end

        %Pause the currently playing in-screen preview

        function preview_pause(self)

            self.model.set_is_paused(true);

        end

        %Stop the currently playing in-screen preview (returns to frame 1)

        function preview_stop_reset(self)
           
            self.model.set_is_paused(true);
            self.model.set_auto_preview_index(1);

        end

        % Open a full, cohesive preview of the selected trial

        function full_preview(self)
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

        function clear_all(self)
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
                self.reset_defaults();
                
            end
        end

        %Calculate the approximate length of the current experiment and
        %display on the designer

        function calculate_experiment_length(self)
            total_dur = 0;
            if ~ischar(self.doc.pretrial{12})
                total_dur = total_dur + self.doc.pretrial{12};
            end
            if ~ischar(self.doc.posttrial{12})
                total_dur = total_dur + self.doc.posttrial{12};
            end
            if ~ischar(self.doc.intertrial{12})
                for i = 1:length(self.doc.block_trials(:,1))
                    total_dur = total_dur + (self.doc.block_trials{i,12} + self.doc.intertrial{12})*self.doc.repetitions;
                end
                total_dur = total_dur - self.doc.intertrial{12};
            else
                for i = 1:length(self.doc.block_trials(:,1))
                    total_dur = total_dur + (self.doc.block_trials{i,12}*self.doc.repetitions);
                end
            end
            self.doc.set_est_exp_length(total_dur);
            
        end

        %Run a single trial on the screens (no analog input/output)

        function dry_run(self)
            self.doc.replace_greyed_cell_values();
            trial = self.check_one_selected;
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

            if isempty(trial{10}) == 0
                LmR_gain = trial{10};
                LmR_offset = trial{11};
            else
                LmR_gain = 0;
                LmR_offset = 0;
            end
            %pre_start = 0;
            if strcmp(self.doc.top_export_path,'')
                pat_location = self.doc.pattern_locations.(pat_field);
                if ~isempty(trial{3}) && ~contains(trial{3}, '<html>')
                    func_field = self.doc.get_posfunc_field_name(trial{3});
                    func_location = self.doc.function_locations.(func_field);
                else
                    func_field = [];
                    func_location = [];
                end
            else
                pat_location = self.doc.get_top_export_path();
                func_location = self.doc.get_top_export_path();
            end

            if isempty(self.ctlr)
                self.ctlr = PanelsController();
            end
            self.ctlr.open(true);
            pause(10);
            self.model.host_connected = 1;
           
            start = questdlg('Start Dry Run?','Confirm Start','Start','Cancel','Start');
            switch start
            case 'Cancel'
                return;

            case 'Start'
                self.model.set_screen_on(1);
                pattern_index = self.doc.get_pattern_index(trial{2});
                func_index = self.doc.get_posfunc_index(trial{3});
                
                [patRootDir, ~] = fileparts(pat_location);
                self.ctlr.setRootDirectory(patRootDir)

                self.ctlr.setControlMode(trial_mode);
                self.ctlr.setPatternID(pattern_index);

                if func_index ~= 0
                    [funcRootDir, ~] = fileparts(func_location);
                    self.ctlr.setRootDirectory(funcRootDir);
                    self.ctlr.setPatternFunctionID(func_index);
                end

                if ~isempty(trial{10})
                    self.ctlr.setGain(LmR_gain, LmR_offset);
                end

                if trial_mode == 2
                    self.ctlr.setFrameRate(trial_fr_rate);
                end

                self.ctlr.setPositionX(trial_frame_index);

                if trial_duration ~= 0
                    self.ctlr.startDisplay(trial_duration*10); %duration expected in 100ms units
                    self.model.set_screen_on(0);
                else
                    self.ctlr.startDisplay(2000, false);
                    w = waitforbuttonpress; %If pretrial duration is set to zero, this
                    %causes it to loop until a button is press or
                    %mouse clicked
                    self.ctlr.stopDisplay();
                    self.model.screen_on = 0;
                end
            end
            self.ctlr.close(true);
        end

        %Open the conductor to run an experiment
        function open_run_gui(self)
            self.check_and_disconnect_host();
            if ~isempty(self.doc.save_filename)
                evalin('base', 'G4_Experiment_Conductor()');
                evalin('base', 'run_con.open_g4p_file(con.doc.save_filename)');
            else
                warndlg("Please save your experiment before running.");
            end

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
            self.update_trial_doc(newRow, x, y, 'block');

%             self.block_files.pattern(end + 1) = string(cell2mat(newRow(2)));
%             self.block_files.position(end + 1) = string(cell2mat(newRow(3)));
%             self.block_files.ao1(end + 1) = string(cell2mat(newRow(4)));
%             self.block_files.ao2(end + 1) = string(cell2mat(newRow(5)));
%             self.block_files.ao3(end + 1) = string(cell2mat(newRow(6)));
%             self.block_files.ao4(end + 1) = string(cell2mat(newRow(7)));

            
        end

        % Moves a single trial up in the block table
        function move_trial_up(self, index)

            selected = self.get_single_blocktrial(index);
            if index == 1
                self.create_error_box("I can't shift up any more.");
                return;
            else
                above_selected = self.get_single_blocktrial(index-1);
            end

            self.doc.set_block_trial(index, above_selected);
            self.doc.set_block_trial(index - 1, selected);
            
        end

        % Moves a single trial down in the block table
        function move_trial_down(self, index)
            %index = first index of selected row in the block trials
            %cell array
            selected = self.get_single_blocktrial(index);

            if index == length(self.doc.block_trials(:,1))
                self.create_error_box("I can't shift down any further.");
                return;
            else
                below_selected = self.get_single_blocktrial(index + 1);
            end

            self.doc.set_block_trial(index,below_selected);
            self.doc.set_block_trial(index + 1, selected);

        end

        % Deselect the "Select All" box when any trial is deselected
        function deselect_selectAll(self)
            self.model.isSelect_all = 0;
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
                trialtype = convertStringsToChars(self.model.current_selected_cell.table);
                x = self.model.current_selected_cell.index(1);

                self.update_trial_doc(self.doc.colorgen(),x,2,trialtype);
                for i = 4:7
                    self.update_trial_doc(self.doc.colorgen(), x, i, trialtype);
                end
                self.update_trial_doc(self.doc.colorgen(), x, 12, trialtype);

            end
        end

        % Set all properties dependent on the mode
        function set_mode_dep_props(self, pos, indx, rate, gain, offset, varargin)

            trialtype = convertStringsToChars(self.model.current_selected_cell.table);
            x = self.model.current_selected_cell.index(1);
            if strcmp(trialtype, 'pre')
                trial_var = 'pretrial';
            elseif strcmp(trialtype, 'inter')
                trial_var = 'intertrial';
            elseif strcmp(trialtype, 'post')
                trial_var = 'posttrial';
            elseif strcmp(trialtype, 'block')
                trial_var = 'block_trials';
            end

            self.update_trial_doc(pos, x, 3, trialtype);
            self.update_trial_doc(indx, x, 8, trialtype);
            self.update_trial_doc(rate, x, 9, trialtype);
            self.update_trial_doc(gain, x, 10, trialtype);
            self.update_trial_doc(offset, x, 11, trialtype);
            if ~isempty(self.doc.(trial_var){1})
                self.update_trial_doc('', x, 4, trialtype);
                self.update_trial_doc('', x, 5, trialtype);
                self.update_trial_doc('', x, 6, trialtype);
                self.update_trial_doc('', x, 7, trialtype);
                self.update_trial_doc(self.doc.trial_data.trial_array{12}, x, 12, trialtype);
            end

            self.update_gui();
        end

        % Check which and how many block trials are selected
        function [num_checked, checked_rows] = check_num_trials_selected(self)
            checkbox_data = horzcat(self.doc.block_trials(1:end,end));
            checked_rows = find(cell2mat(checkbox_data));
            num_checked = length(checked_rows);
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

        function turn_off_screen(self)
            if self.model.screen_on
                self.ctlr.stopDisplay();
                self.model.set_screen_on(0);
            end
        end

        % Display the in-screen preview of a position or ao function

        function inscreen_function_preview(frame_rate, dur, posfield, aofield, file_type)
            
            self.turn_off_screen();
            labels.timeLabel = 'Time (ms)';
            labels.patLabel = 'Pattern';
            labels.frameLabel = 'Frame Number';

            if strcmp(file_type, 'pos') && ~strcmp(posfield,'')
                self.model.set_current_preview_file(self.doc.Pos_funcs.(posfield).pfnparam.func);
                axis_position = [.1, .15, .8 ,.7];

            elseif strcmp(file_type, 'ao') && ~strcmp(aofield,'')
                self.model.set_current_preview_file(self.doc.Ao_funcs.(aofield).afnparam.func);
                axis_position = [.1, .04, .8 ,.9];

            else
                warning("Cannot preview this file, unrecognized type");
                return;

            end
   
            yax = [min(self.model.current_preview_file) max(self.model.current_preview_file)];
            if yax(1) == yax(2)
                yax = [yax(1)-1 yax(2) + 1];
            end
            if frame_rate == 1000
                time_in_ms = length(self.model.current_preview_file(1,:));
            else
                time_in_ms = length(self.model.current_preview_file(1,:))*2;
            end
            num_frames = frame_rate*(1/1000)*time_in_ms;
            xax = [0 num_frames]; %As long as frame rate is 1000 (always true for ao funcs), time in ms and num frames are equal.
            xax2 = [0 time_in_ms];

            if dur <= xax2(2)
                if frame_rate == 1000
                    linedur = [dur, dur];

                else
                    linedur = [dur/2, dur/2];
                end
            else
                linedur = 0;
            end

            self.view.set_preview_axes_function(axis_position, labels, yax, xax, xax2, linedur);

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
        function inscreen_pattern_preview(self, patfield)

            self.model.set_auto_preview_index(self.check_pattern_dimensions(patfield));
            self.model.set_current_preview_file(self.doc.Patterns.(patfield).pattern.Pats);
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
            self.model.set_current_preview_file(adjusted_file);
            axis_position  = [.1, .04, .8 ,.9];

            self.view.set_preview_axes_pattern(axis_position)

            if self.preview_on_arena == 1
                self.display_pattern_arena(patfield);
            end
        end

        function display_pattern_arena(self, patfield)
            if strcmp(self.doc.top_export_path,'')
                self.create_error_box("You must save the experiment before you can preview a pattern on the screen.");
                return;
            end

            patfile = self.doc.Patterns.(patfield).filename;
            patindex = self.doc.get_pattern_index(patfile);
            disp(patindex);

            if ~self.model.host_connected
                self.ctlr = PanelsController();
                self.ctlr.open(true);
                self.model.host_connected = self.ctlr.isOpen;
            end

            self.ctlr.setRootDirectory(self.doc.top_export_path);
            self.ctlr.setPatternID(patindex);
            self.ctlr.setControlMode(3);
            self.ctlr.setPositionX(self.model.auto_preview_index);

            self.model.screen_on = 1;

            %submit mode, pattern, and display commands (mode 3?)

            %give a field to set how many frames you want to skip by each
            %time you click next.
        end

        function check_and_disconnect_host(self)
            if self.model.host_connected
                self.ctlr.stopDisplay();
                self.ctlr.close();
                self.model.host_connected = 0;
            end
        end

        function update_arena_pattern_index(self)
            if self.model.host_connected
                self.ctlr.setPositionX(self.model.auto_preview_index);
            end
        end

        function [frame_rate, dur, patfield, funcfield, aofield, file_type] = get_preview_parameters(self, is_table)
            curr_cell = self.get_current_selected_cell();
            index = curr_cell.index;
            table = curr_cell.table;
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
                    if ~strcmp(funcfield,'')
                        if self.doc.Pos_funcs.(funcfield).pfnparam.gs_val == 1
                            frame_rate = 1000;
                        else
                            frame_rate = 500;
                        end

                    elseif ~strcmp(patfield,'')
                        if self.doc.Patterns.(patfield).pattern.gs_val == 1
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
                     if ~strcmp(funcfield,'')
                        if self.doc.Pos_funcs.(funcfield).pfnparam.gs_val == 1

                            frame_rate = 1000;
                        else
                            frame_rate = 500;
                        end
                    elseif ~strcmp(patfield,'')
                        if self.doc.Patterns.(patfield).pattern.gs_val == 1
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
                    if ~strcmp(funcfield,'')
                        if self.doc.Pos_funcs.(funcfield).pfnparam.gs_val == 1
                            frame_rate = 1000;
                        else
                            frame_rate = 500;
                        end
                    elseif ~strcmp(patfield,'')
                        if self.doc.Patterns.(patfield).pattern.gs_val == 1
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
                    if ~strcmp(funcfield,'')
                        if self.doc.Pos_funcs.(funcfield).pfnparam.gs_val == 1
                            frame_rate = 1000;
                        else
                            frame_rate = 500;
                        end
                    elseif ~strcmp(patfield,'')
                        if self.doc.Patterns.(patfield).pattern.gs_val == 1
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

                e = errordlg(msg, title, 'modal');
                set(e, 'Resize', 'on');
                
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
            elseif mode_val == 1 && (8 < y) && (y < 12)
                allow = 0;
            elseif mode_val == 2 && (y ==3 || ((9 < y) && (y < 12)))
                allow = 0;
            elseif mode_val == 3 && (y == 3 || ((8 < y) && (y < 12)))
                allow = 0;
            elseif mode_val == 4 && (y == 3 || y == 9 )
                allow = 0;
            elseif (mode_val == 5 || mode_val == 6) && (y == 9)
                allow = 0;
            elseif mode_val == 7 && ( y == 3 || ((8 < y ) && (y < 12)))
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
%               self.model.current_selected_cell.table = "inter";
%               self.model.current_selected_cell.index = [1,1];
%               self.clear_fields(intertrial_mode);
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
%               self.model.current_selected_cell.table = "post";
%               self.model.current_selected_cell.index = [1,1];
%               self.clear_fields(posttrial_mode);
                post_indices_to_color = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
            end

            for i = 1:length(pre_indices_to_color)
                self.update_trial_doc(self.doc.colorgen(), 1, pre_indices_to_color(i), 'pre');

            end
            for i = 1:length(inter_indices_to_color)
                self.update_trial_doc(self.doc.colorgen(), 1, inter_indices_to_color(i), 'inter');

            end
            for i = 1:length(post_indices_to_color)
                self.update_trial_doc(self.doc.colorgen(), 1, post_indices_to_color(i), 'post');

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
                    self.update_trial_doc(self.doc.colorgen(), i, indices_to_color(j), 'block');
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
                import_success = self.doc.import_folder(path);
                waitfor(msgbox(import_success, 'Import Successful!'));
                
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
                    self.update_trial_doc(self.doc.Patterns.(pat_field).filename, 1, 2, 'pre');
                else
                    pat_field = '';
                end

            elseif strcmp(self.model.current_selected_cell.table,"inter")
                if ~isempty(self.doc.intertrial{2}) && ~self.doc.check_if_cell_disabled(self.doc.intertrial{2})
                    pat_field = self.doc.get_pattern_field_name(self.doc.intertrial{2});
                elseif ~isempty(self.doc.imported_pattern_names)
                    pat_field = pat_fields{1};
                    self.update_trial_doc(self.doc.Patterns.(pat_field).filename, 1, 2, 'inter');
                else
                    pat_field = '';
                end
            elseif strcmp(self.model.current_selected_cell.table,"post")
                if ~isempty(self.doc.posttrial{2}) && ~self.doc.check_if_cell_disabled(self.doc.posttrial{2})
                    pat_field = self.doc.get_pattern_field_name(self.doc.posttrial{2});
                elseif ~isempty(self.doc.imported_pattern_names)
                    pat_field = pat_fields{1};
                    self.update_trial_doc(self.doc.Patterns.(pat_field).filename, 1, 2, 'post');
                else
                    pat_field = '';
                end
            else
                if ~isempty(self.doc.block_trials{self.model.current_selected_cell.index(1),2}) && ...
                        ~self.doc.check_if_cell_disabled(self.doc.block_trials{self.model.current_selected_cell.index(1),2})
                    pat_field = self.doc.get_pattern_field_name(self.doc.block_trials{self.model.current_selected_cell.index(1),2});
                elseif ~isempty(self.doc.imported_pattern_names)
                    pat_field = pat_fields{1};
                    self.update_trial_doc(self.doc.Patterns.(pat_field).filename, self.model.current_selected_cell.index(1), 2, 'block');
                else
                    pat_field = '';
                end
            end
        end

        function output = get_trial_component(self, trialtype, trialnum, comp_ind)

            if strcmp(trialtype, 'pre')
                output = self.doc.pretrial{comp_ind};
            elseif strcmp(trialtype, 'inter')
                output = self.doc.intertrial{comp_ind};
            elseif strcmp(trialtype, 'post')
                output = self.doc.posttrial{comp_ind};
            elseif strcmp(trialtype, 'block')
                output = self.doc.block_trials{trialnum, comp_ind};
            end
        end


%% Additional Update functions

        %Update the preview controller property
        function update_preview_con(self, new_value)
            self.preview_con = new_value;
        end

        % Update the GUI to reflect the up to date model values
        function update_gui(self)

            self.view.update_gui();
          
        end

 %% Functions to set the value of each GUI object

  %% Save this code until I confirm it's no longer needed with the uifigure      
%         function set_block_table_data(self)
% %              %%%%%%%%%%%%%%%%%%THIS IS NOT A GOOD PERMANENT SOLUTION FOR
% %              %%%%%%%%%%%%%%%%%%THE SCROLLBAR JUMPING ISSUE. USING PAUSE CAN
% %              %%%%%%%%%%%%%%%%%%UNDER CERTAIN CIRCUMSTANCES HAVE WEIRD
% %              %%%%%%%%%%%%%%%%%%RESULTS, AND JAVA INTERVENTIONS MAY STOP
% %              %%%%%%%%%%%%%%%%%%WORKING WITH ANY RELEASE. CHECK NEW
% %              RELEASES TO SEE IF THIS BUG HAS BEEN FIXED
% 
% %% findjob citation
% %% Yair Altman (2024). findjobj - find java handles of Matlab graphic objects (https://www.mathworks.com/matlabcentral/fileexchange/14317-findjobj-find-java-handles-of-matlab-graphic-objects), 
% %% MATLAB Central File Exchange. Retrieved June 4, 2024. 
%             jTable = findjobj(self.block_table);
%             jScrollPane = jTable.getComponent(0);
%             javaObjectEDT(jScrollPane);
%             currentViewPos = jScrollPane.getViewPosition;
% 
%             self.block_table.Data = self.doc.block_trials;
%             pause(0);
%             jScrollPane.setViewPosition(currentViewPos);
%         end

        function doc_replace_grey_cells(self)
            self.doc.replace_greyed_cell_values();
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


        function set_files(self, x, y, new_value, trialtype)
            if isempty(new_value)
                return;
            else
                new_value = string(new_value);
                %If it is files for  block trial, the code is slightly
                %different.
                
                if strcmp(trialtype, 'pre')
                    filesVar = 'pre_files';
                elseif strcmp(trialtype, 'inter')
                    filesVar = 'inter_files';
                elseif strcmp(trialtype, 'post')
                    filesVar = 'post_files';
                end
                if strcmp(trialtype, 'block')
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
                else
                    if y == 2
                        self.(filesVar).pattern = new_value;
                    end
                    if y == 3
                        self.(filesVar).position = new_value;
                    end
                    if y == 4
                        self.(filesVar).ao1 = new_value;
                    end
                    if y == 5
                        self.(filesVar).ao2 = new_value;
                    end
                    if y == 6
                        self.(filesVar).ao3 = new_value;
                    end
                    if y == 7
                        self.(filesVar).ao4 = new_value;
                    end
                end
            end

        end

        

%% SETTERS

% Setting values in the model
        function set_current_selected_cell(self, table, index)
              self.model.set_current_selected_cell(table, index);
        end
        function set_auto_preview_index(self, new_val)
            self.model.set_auto_preview_index(new_val);
        end

                
        function set_ctlr(self, value)
            self.ctlr = value;
        end

        function set_model(self, value)
            self.model = value;
        end

        function set_preview_con(self, value)
            self.preview_con = value;
        end

        function set_run_con(self, value)
            self.run_con = value;
        end

        function set_pretrial_table(self, value)
            self.pretrial_table = value;
        end

        function set_intertrial_table(self, value)
            self.intertrial_table = value;
        end

        function set_posttrial_table(self, value)
            self.posttrial_table = value;
        end

        function set_block_table(self, value)
            self.block_table = value;
        end

        function set_pre_files(self, value)
            self.pre_files = value;
        end

        function set_block_files(self, value)
            self.block_files = value;
        end

        function set_inter_files(self, value)
            self.inter_files = value;
        end

        function set_post_files(self, value)
            self.post_files = value;
        end

        function set_chan1(self, value)
            self.chan1 = value;
        end

        function set_chan2(self, value)
            self.chan2 = value;
        end

        function set_chan3(self, value)
            self.chan3 = value;
        end

        function set_chan4(self, value)
            self.chan4 = value;
        end

        function set_chan1_rate_box(self, value)
            self.chan1_rate_box = value;
        end

        function set_chan2_rate_box(self, value)
            self.chan2_rate_box = value;
        end

        function set_chan3_rate_box(self, value)
            self.chan3_rate_box = value;
        end

        function set_chan4_rate_box(self, value)
            self.chan4_rate_box = value;
        end

        function set_isRandomized_radio(self, value)
            self.isRandomized_radio = value;
        end

        function set_isSequential_radio(self, value)
            self.isSequential_radio = value;
        end

        function set_repetitions_box(self, value)
            self.repetitions_box = value;
        end

        function set_num_rows_buttonGrp(self, value)
            self.num_rows_buttonGrp = value;
        end

        function set_num_rows_3(self, value)
            self.num_rows_3 = value;
        end

        function set_num_rows_4(self, value)
            self.num_rows_4 = value;
        end

        function set_randomize_buttonGrp(self, value)
            self.randomize_buttonGrp = value;
        end

        function set_isSelect_all_box(self, value)
            self.isSelect_all_box = value;
        end

        function set_f(self, value)
            self.f = value;
        end

        function set_preview_panel(self, value)
            self.preview_panel = value;
        end

        function set_hAxes(self, value)
            self.hAxes = value;
        end

        function set_exp_name_box(self, value)
            self.exp_name_box = value;
        end

        function set_doc(self, value)
            self.doc = value;
        end

        function set_second_axes(self, value)
            self.second_axes = value;
        end

        function set_pageUp_button(self, value)
            self.pageUp_button = value;
        end

        function set_pageDown_button(self, value)
            self.pageDown_button = value;
        end

        function set_listbox_imported_files(self, value)
            self.listbox_imported_files = value;
        end

        % function set_recent_file_menu_items(self, value)
        %     self.recent_file_menu_items = value;
        % end

        function set_menu_open(self, value)
            self.menu_open = value;
        end

        function set_exp_length_display(self, value)
            self.exp_length_display = value;
        end

        function set_inscreen_plot(self, value)
            self.inscreen_plot = value;
        end

        function set_settings_con(self, value)
            self.settings_con = value;
        end

        function set_preview_on_arena(self, value)
            self.preview_on_arena = value;
        end

%% GETTERS

        %Getting stuff from the document object
        function output =  get_pretrial_data(self)
            output = self.doc.get_pretrial();
        end
        function output = get_blocktrial_data(self)
            output = self.doc.get_block_trials();
        end
        function output = get_single_blocktrial(self, index)
            output = self.doc.block_trials(index,:);
        end
        function output = get_intertrial_data(self)
            output = self.doc.get_intertrial();
        end
        function output = get_posttrial_data(self)
            output = self.doc.get_posttrial();
        end
        function output = get_is_randomized(self)
            output = self.doc.get_is_randomized();
        end
        function output = get_repetitions(self)
            output = self.doc.get_repetitions();
        end
        function output = get_is_chan1(self)
            output =  self.doc.get_is_chan1();
        end
        function output = get_is_chan2(self)
            output =  self.doc.get_is_chan2();
        end
        function output = get_is_chan3(self)
            output = self.doc.get_is_chan3();
        end
        function output = get_is_chan4(self)
            output = self.doc.get_is_chan4();
        end
        function output = get_chan1_rate(self)
            output = self.doc.get_chan1_rate();
        end
        function  output = get_chan2_rate(self)
            output = self.doc.get_chan2_rate();
        end
        function output = get_chan3_rate(self)
            output =  self.doc.get_chan3_rate();
        end
        function output = get_chan4_rate(self)
            output = self.doc.get_chan4_rate();
        end
        function output = get_num_rows(self)
            output = self.doc.get_num_rows();
        end
        function output = get_experiment_name(self)
            output = self.doc.get_experiment_name();
        end
        function output = get_recent_g4p_files(self)
            output = self.doc.get_recent_g4p_files();
        end
        function output = get_est_exp_length(self)
            output = self.doc.get_est_exp_length();
        end
        function output = get_patterns(self)
            output = self.doc.Patterns;
        end
        function output = get_pos_funcs(self)
            output = self.doc.Pos_funcs;
        end
        function output  = get_ao_funcs(self)
            output = self.doc.Ao_funcs;
        end
         

% Get stuff from the model object
        function output =  get_isSelect_all(self)
            output =  self.model.isSelect_all;
        end
        function output = get_current_selected_cell(self)
            output = self.model.current_selected_cell;
        end
        function output = get_current_preview_file(self)
            output = self.model.current_preview_file;
        end
        function output = get_auto_preview_index(self)
            output = self.model.auto_preview_index;
        end
        function output = get_is_paused(self)
            output = self.model.is_paused;
        end

        

        function output = get_model(self)
            output = self.model;
        end

        function output = get_preview_con(self)
            output = self.preview_con;
        end

        function output = get_run_con(self)
            output = self.run_con;
        end

        function output = get_pretrial_table(self)
           output = self.pretrial_table;
        end

        function output = get_intertrial_table(self)
            output = self.intertrial_table;
        end

        function output = get_posttrial_table(self)
            output = self.posttrial_table;
        end

        function output = get_block_table(self)
            output = self.block_table;
        end

        function output = get_pre_files(self)
            output = self.pre_files;
        end

        function output = get_block_files(self)
            output = self.block_files;
        end

        function output = get_inter_files(self)
            output = self.inter_files;
        end

        function output = get_post_files(self)
            output = self.post_files;
        end

        function output = get_chan1(self)
            output = self.chan1;
        end

        function output = get_chan2(self)
            output = self.chan2;
        end

        function output = get_chan3(self)
            output = self.chan3;
        end

        function output = get_chan4(self)
            output = self.chan4;
        end

        function output = get_chan1_rate_box(self)
            output = self.chan1_rate_box;
        end

        function output = get_chan2_rate_box(self)
            output = self.chan2_rate_box;
        end

        function output = get_chan3_rate_box(self)
            output = self.chan3_rate_box;
        end

        function output = get_chan4_rate_box(self)
            output = self.chan4_rate_box;
        end

        function output = get_isRandomized_radio(self)
            output = self.isRandomized_radio;
        end

        function output = get_isSequential_radio(self)
            output = self.isSequential_radio;
        end

        function output = get_repetitions_box(self)
            output = self.repetitions_box;
        end

        function output = get_num_rows_buttonGrp(self)
            output = self.num_rows_buttonGrp;
        end

        function output = get_num_rows_3(self)
            output = self.num_rows_3;
        end

        function output = get_num_rows_4(self)
            output = self.num_rows_4;
        end

        function output = get_randomize_buttonGrp(self)
            output = self.randomize_buttonGrp;
        end

        function output = get_isSelect_all_box(self)
            output = self.isSelect_all_box;
        end

        function output = get_f(self)
            output = self.f;
        end

        function output = get_preview_panel(self)
            output = self.preview_panel;
        end

        function output = get_hAxes(self)
            output = self.hAxes;
        end

        function output = get_exp_name_box(self)
            output = self.exp_name_box;
        end

        function output = get_doc(self)
           output = self.doc;
        end

        function output = get_second_axes(self)
            output = self.second_axes;
        end

        function output = get_pageUp_button(self)
            output = self.pageUp_button;
        end

        function output = get_pageDown_button(self)
            output = self.pageDown_button;
        end

        function output = get_listbox_imported_files(self)
            output = self.listbox_imported_files;
        end

        function output = get_recent_file_menu_items(self)
            output = self.recent_file_menu_items;
        end

        function output = get_menu_open(self)
            output = self.menu_open;
        end

        function output = get_exp_length_display(self)
            output = self.exp_length_display;
        end

        function output = get_inscreen_plot(self)
            output = self.inscreen_plot;
        end

        function output = get_settings_con(self)
            output = self.settings_con;
        end

        function output = get_preview_on_arena(self)
            output = self.preview_on_arena;
        end

        
     end
end

