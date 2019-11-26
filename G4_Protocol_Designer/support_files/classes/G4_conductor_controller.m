classdef G4_conductor_controller < handle
   
    properties
        model_
        doc_
        settings_con_
        view_
        
        %Time tracking

        elapsed_time_
        remaining_time_
        is_aborted_

        %These values are updated every trial
        
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
        model
        doc
        settings_con
        view

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
        
        elapsed_time
        remaining_time
        
        is_aborted

        
        
        
    end
    
    
    
    methods
        
        %constructor
        function self = G4_conductor_controller(varargin)
           
            self.model = G4_conductor_model();
            self.elapsed_time = 0;
            

            if ~isempty(varargin)
                
                self.doc = varargin{1};
                self.model.fly_name = self.model.create_fly_name(self.doc.top_export_path);
                self.settings_con = varargin{2};
                
            else
                
                self.doc = G4_document();
                self.settings_con = G4_settings_controller();
                
            end
            
            exp_time = self.doc.calc_exp_length();
            self.model.set_expected_time(exp_time);
            self.remaining_time = self.model.expected_time;
            
            self.current_mode = '';
            self.current_pat = '';
            self.current_pos = '';
            self.current_ao1 = '';
            self.current_ao2 = '';
            self.current_ao3 = '';
            self.current_ao4 = '';
            self.current_frInd = '';
            self.current_frRate = '';
            self.current_gain = '';
            self.current_offset = '';
            self.current_duration = '';
            self.is_aborted = 0;

        end
        
        function layout(self)
            
            self.view = G4_conductor_view(self);
            
        end

        
        function update_fly_name(self, new_val)
            
            % no error checking
            self.model.set_fly_name(new_val);
            
        end
        
        function update_experimenter(self, new_val)
            
            % no error checking
            self.model.set_experimenter(new_val);
            
        end
        
        function update_experiment_name(self, ~)
            
            % Experiment name presently cannot be changed from conductor.
            errormsg = "The experiment has already been saved under this name. " ...
                + "If you would like to change the experiment name, close this window " ...
                + "and save it under the new name in the designer view.";
            self.create_error_box(errormsg);
            %Do not update the model.

        end
        
        function update_genotype(self, new_val)
            
            % no error checking
            self.model.set_fly_genotype(new_val);

        end
        
        function update_do_plotting(self, new_val)
            
            % no error checking
            self.model.set_do_plotting(new_val);
            self.engage_plotting_textbox();

        end
        
        function update_do_processing(self, new_val)
            
            self.model.set_do_processing(new_val);
            self.engage_processing_textbox();

        end

        function update_plotting_file(self, filepath)
            
            %check to make sure file exists
            if isfile(filepath)
                self.model.set_plotting_file(filepath)
            else
                errormsg = "This plotting file does not exist. Please check the path.";
                self.create_error_box(errormsg);
            end
            
        end
        
        function update_processing_file(self, filepath)
            
            %check to make sure file exists
            if isfile(filepath)
                self.model.set_processing_file(filepath);
            else
                errormsg = "This processing file does not exist. Please check the path.";
                self.create_error_box(errormsg);
            end

        end
        
        function update_experiment_type(self, new_val)
            
            %Make sure the number falls within range
            %%%%%%%%%%TODO right now the types are hardcoded into the view
            %%%%%%%%%%- switch this to the model!
            self.model.set_experiment_type(new_val);

        end
        
        function update_age(self, new_val)
            
            %make sure number falls within range
            if new_val > length(self.model.metadata_options.fly_age) || new_val < 1
                errormsg = "There are only " + length(self.model.metadata_options.fly_age) + ...
                    " items in the list of possible fly ages. Please make sure your entry is between " + ...
                    "one and this number.";
                self.create_error_box(errormsg);
            else
                self.model.set_fly_age(new_val);
            end
            
        end
        
        function update_sex(self, new_val)
            if new_val > length(self.model.metadata_options.fly_sex) || new_val < 1
                errormsg = "There are only " + length(self.model.metadata_options.fly_sex) + ...
                    " items in the list of possible fly sexes. Please make sure your entry is between " + ...
                    "one and this number.";
                self.create_error_box(errormsg);
            else
                self.model.set_fly_sex(new_val);
            end
        end
        function update_temp(self, new_val)
            
            if new_val > length(self.model.metadata_options.exp_temp) || new_val < 1
                errormsg = "There are only " + length(self.model.metadata_options.exp_temp) + ...
                    " items in the list of possible experiment temperatures. Please make sure your entry is between " + ...
                    "one and this number.";
                self.create_error_box(errormsg);
            else
                self.model.set_temp(new_val);
            end

        end
        
        function update_rearing(self, new_val)
            
            if new_val > length(self.model.metadata_options.rearing) || new_val < 1
                errormsg = "There are only " + length(self.model.metadata_options.rearing) + ...
                    " items in the list of possible rearing protocols. Please make sure your entry is between " + ...
                    "one and this number.";
                self.create_error_box(errormsg);
            else
                self.model.set_rearing(new_val);
            end
        end
        
        function update_light_cycle(self, new_val)
            
            if new_val > length(self.model.metadata_options.light_cycle) || new_val < 1
                errormsg = "There are only " + length(self.model.metadata_options.light_cycle) + ...
                    " items in the list of possible light cycles. Please make sure your entry is between " + ...
                    "one and this number.";
                self.create_error_box(errormsg);
            else
                self.model.set_light_cycle(new_val);
            end

        end
        
        function update_comments(self, new_val)
            
            %no error checking
            self.model.set_metadata_comments(new_val)

        end
        
        function update_elapsed_time(self, new_val)
            
            self.elapsed_time = new_val;
            self.remaining_time = self.model.expected_time - new_val;
            self.update_view_if_exists();
            
        end
        
        
        
        function update_progress(self, trial_type, varargin)
            
            trials = length(self.doc.block_trials(:,1)) * self.doc.repetitions;
            if ~isempty(self.doc.intertrial{1})
                trials = trials*2 - 1;
            end
            if ~isempty(self.doc.pretrial{1})
                trials = trials + 1;
            end
            if ~isempty(self.doc.posttrial{1})
                trials = trials + 1;
            end

            
            if strcmp(trial_type, 'pre')

                data = 1/trials;
                if ~isempty(self.view)
                    self.view.update_progress_bar(trial_type, data);
                end
                
            elseif strcmp(trial_type, 'block')
                rep = varargin{1};
                reps = varargin{2};
                block_trial = varargin{3};
                num_cond = varargin{4};
                cond = varargin{5};
                total_trial = varargin{6};
                
                data = total_trial/trials;
                if ~isempty(self.view)
                    self.view.update_progress_bar(trial_type, data, rep, reps, ...
                        block_trial, num_cond, cond)
                end
                
                
            elseif strcmp(trial_type, 'inter')

                rep = varargin{1};
                reps = varargin{2};
                block_trial = varargin{3};
                num_cond = varargin{4};
                total_trial = varargin{5};
                data = total_trial/trials;
                if ~isempty(self.view)
                    self.view.update_progress_bar(trial_type, data, rep, reps, block_trial, num_cond);
                end
            elseif strcmp(trial_type, 'post')
                
                total_trial = varargin{1};
                data = total_trial/trials;
                if ~isempty(self.view)
                    self.view.update_progress_bar(trial_type, data);
                end
            else
                disp("I couldn't update the progress bar");
                return
            end
         
            
        end
        
        function update_current_trial_parameters(self, mode, pat, pos, active_channels, ...
                ao_inds, frInd, frRate, gain, offset, dur)
           
            for i = 1:length(active_channels) %This figures out which ao channel to put the ao function index under.
                if active_channels(i) == 0
                    self.current_ao1 = num2str(ao_inds(i));
                elseif active_channels(i) == 1
                    self.current_ao2 = num2str(ao_inds(i));
                elseif active_channels(i) == 2
                    self.current_ao3 = num2str(ao_inds(i));
                else
                    self.current_ao4 = num2str(ao_inds(i));
                end
            end
             
            self.current_mode = num2str(mode);
            self.current_pat = num2str(pat);
            self.current_pos = num2str(pos);
            self.current_frInd = num2str(frInd);
            self.current_frRate = num2str(frRate);
            self.current_gain = num2str(gain);
            self.current_offset = num2str(offset);
            self.current_duration = num2str(dur);
            
            self.update_view_if_exists();
            
        end
        
        function open_settings(self, ~, ~)
        
            self.settings_con.layout_view();
        
        end
        
        function engage_plotting_textbox(self)
            if self.model.do_plotting == 1
                if ~isempty(self.view)
                    set(self.view.plotting_textbox, 'enable', 'on');
                    set(self.view.browse_button_plotting, 'enable','on');
                end
            elseif self.model.do_plotting == 0
                if ~isempty(self.view)
                    set(self.view.plotting_textbox, 'enable', 'off');
                    set(self.view.browse_button_plotting, 'enable','off');
                end

            end
        end
        
        function engage_processing_textbox(self)
            if self.model.do_processing == 1
                if ~isempty(self.view)
                    set(self.view.processing_textbox,'enable', 'on');
                    set(self.view.browse_button_processing, 'enable','on');
                end
            elseif self.model.do_processing == 0
                if ~isempty(self.view)
                    set(self.view.processing_textbox, 'enable', 'off');
                    set(self.view.browse_button_processing, 'enable', 'off');
                end

            end
        end
        
        function create_error_box(~, varargin)
  
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
        
        function open_g4p_file(self, varargin)
            
            if ~isempty(varargin)
                filepath = varargin{1};
                [top_folder_path, filename] = fileparts(filepath);
            else
                [filename, top_folder_path] = uigetfile('*.g4p');
                filepath = fullfile(top_folder_path, filename);
            end
       
            if isequal (top_folder_path,0)
            
                %They hit cancel, do nothing
                return;
            else
                
                self.doc.import_folder(top_folder_path);
                [exp_path, exp_name, ext] = fileparts(filepath);
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
                
                self.doc.block_trials{1,2} = '';
                self.doc.block_trials{1,3} = '';

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
                
                self.doc.set_recent_files(filepath);
                self.doc.update_recent_files_file();
                self.model.fly_name = self.model.create_fly_name(top_folder_path);

                self.update_view_if_exists();
                
                
            end

            
        end

        %% Open  Google Sheet in browser
        %
        % Uses GoogleSheet key from Settings
        function open_google_sheet(self)
            base_url = 'https://docs.google.com/spreadsheets/d/';
            full_link = [base_url,self.model.google_sheet_key,'/edit?usp=sharing'];
            web(full_link, '-browser');
        end
        
        function [aborted] = check_if_aborted(self)
            aborted = self.is_aborted;
        end
        
        function abort_experiment(self)
        
            self.is_aborted = 1;

        end

        function run(self)
            
            self.is_aborted = false; %change aborted back to zero in case the experiment was aborted earlier. 
            
            
            %Before creating the data and sending you to the run script,
            %check to make sure there are no issues that will disrupt the
            %run:--------------------------------------------------------
            
            %returns if you forgot to save the experiment.
            if strcmp(self.doc.save_filename,'') == 1
                self.create_error_box("You didn't save this experiment. Please go back and save then run the experiment again.", "Please save.");
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
                self.create_error_box('unsorted files present in "Log Files" folder, remove before restarting experiment\n');
                return;
            end
            if exist(fullfile(experiment_folder, 'Results', self.model.fly_name),'dir')
                items = dir(fullfile(experiment_folder, 'Results', self.model.fly_name));
                for i = 1:length(items)
                    itemnames{i} = items(i).name;
                end
                for i = 1:length(items)
                    folders(i) = items(i).isdir;
                end
                folders(~folders) = [];
                
                if length(itemnames) > length(folders)
                    
                    self.create_error_box('Results folder of that fly name already has data in it\n');
                    return;
                end
            end
            
            %create .mat file of metadata
            
            
            %-------------------------------------------------------------
            %Go through and replace all the greyed out parameters with
            %appropriate values to be sent to panel_com
            
            self.doc.replace_greyed_cell_values();

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
                prepat_field = self.doc.get_pattern_field_name(pretrial{2});
                parameters.num_pretrial_frames = length(self.doc.Patterns.(prepat_field).pattern.Pats(1,1,:));
            end
            if ~isempty(intertrial{1})
                interpat_field = self.doc.get_pattern_field_name(intertrial{2});
                parameters.num_intertrial_frames = length(self.doc.Patterns.(interpat_field).pattern.Pats(1,1,:));
            end
            if ~isempty(posttrial{1})
                postpat_field = self.doc.get_pattern_field_name(posttrial{2});
                parameters.num_posttrial_frames = length(self.doc.Patterns.(postpat_field).pattern.Pats(1,1,:));
            end
            for i = 1:length(block_trials(:,1))
                blockpat_field = self.doc.get_pattern_field_name(block_trials{i,2});
                parameters.num_block_frames(i) = length(self.doc.Patterns.(blockpat_field).pattern.Pats(1,1,:));
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
                self.create_error_box("Please make sure you've entered a valid .m file to run the experiment.");
                return;
            end
            
            %Get function name of the script which will run the experiment
            [run_path, run_name, ext] = fileparts(self.model.run_protocol_file);
            
            %Create the full command
            run_command = "success = " + run_name + "(self, parameters);";
            
            %run script
            eval(run_command);
            pause(3);
            
            if self.check_if_aborted()
                [logs_removed, msg] = rmdir([experiment_folder '\Log Files\'], 's');
                if logs_removed == 0
                    self.create_error_box("Matlab was unable to delete the log files. Please delete manually.");
                    disp(msg);
                else
                    self.create_error_box("Experiment aborted successfully.");
                end
                self.is_aborted = 0;
                    
                return;
            end
            
            if success == 0
                return;
            end
            
            %Move the log files to the results file under the fly name
            movefile(fullfile(experiment_folder,'Log Files','*'),fullfile(experiment_folder,'Results',self.model.fly_name));
            self.create_metadata_file();
                        
            if self.model.do_processing == 1 || self.model.do_plotting == 1
                if ~isempty(self.view)
                    self.view.set_progress_title("Experiment Completed. Running post-processing.");
                    drawnow;
                end
            else
                if ~isempty(self.view)
                    self.view.set_progress_title("Skipping post-processing.");
                    drawnow;
                end
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
                self.create_error_box("Processing script was not run because the processing file could not be found. Please run manually.");
     
            elseif self.model.do_processing == 1 && isfile(self.model.processing_file)
                [proc_path, proc_name, proc_ext] = fileparts(self.model.processing_file);
                processing_command = proc_name + "(fly_results_folder, trial_options)";

                eval(processing_command);
            
            end
            
            if self.model.do_plotting == 1 && (strcmp(self.model.plotting_file,'') || ~isfile(self.model.plotting_file))
                self.create_error_box("Plotting script was not run because the plotting file could not be found. Please run manually.");
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
                if ~isempty(self.view)
                    metadata.timestamp = self.view.date_and_time_box.String;
                else
                    metadata.timestamp = datestr(now, 'mm-dd-yyyy HH:MM:SS');
                end
                metadata.fly_age = self.model.fly_age;
                metadata.fly_sex = self.model.fly_sex;
                metadata.experiment_temp = self.model.experiment_temp;
                metadata.rearing_protocol = self.model.rearing_protocol;
                
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
                metadata.comments = self.model.metadata_comments;
                metadata.light_cycle = self.model.light_cycle;
                
                
                
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
            if ~isempty(self.view)
                self.view.set_progress_title('Finished.');
                drawnow;
            end
            
            waitfor(errordlg("Please remember to update the fly name before attempting to run your next experiment."));

        end

        function run_test(self)
            
            self.model.num_tests_conducted = self.model.num_tests_conducted + 1;
            repeat = 1;
            [real_exp_path, real_experiment_name, real_ext] =  fileparts(self.doc.save_filename);
            real_file = [real_experiment_name, real_ext];
            real_fly_name = self.model.fly_name;

            %Get filepath to the test protocol
            if self.model.experiment_type == 1
                %Get the flight filepath from settings
                line_to_match = 'Flight test protocol file: ';
                
            elseif self.model.experiment_type == 2
                %Get path to camera test file
                line_to_match = 'Camera walk test protocol file: ';
                
               
            else
                %Get path to chip test file
                line_to_match = 'Chip walk test protocol file: ';
            end
            
            [settings_data, line_path, index] = self.model.get_setting(line_to_match);
            path_to_experiment = strtrim(settings_data{line_path}(index:end));
            
            % Open test g4p file
            self.open_g4p_file(path_to_experiment);
            
            
            line_to_match = 'Default test run protocol file: ';
            %Get default run protocol file for tests
            [settingsData, linePath, idx] = self.model.get_setting(line_to_match);
            path_to_run_protocol = strtrim(settingsData{linePath}(idx:end));
            
            line_to_match = 'Default test processing file: ';
            
            %Get default processing file for tests
            [settingsData, linePath, idx] = self.model.get_setting(line_to_match);
            path_to_proc_protocol = strtrim(settingsData{linePath}(idx:end));
            
            line_to_match = 'Default test plotting file: ';
            
            %Get default plotting file for tests
            [settingsData, linePath, idx] = self.model.get_setting(line_to_match);
            path_to_plot_protocol = strtrim(settingsData{linePath}(idx:end));
            
            %Set test specific values
            self.model.fly_name = ['trial',num2str(self.model.num_tests_conducted)];
            self.model.set_run_file(path_to_run_protocol);
            self.model.set_plot_file(path_to_plot_protocol);
            self.model.set_proc_file(path_to_proc_protocol);
            
            
            if ~isempty(self.view)
                self.update_view_if_exists();
            end
            
            while repeat == 1
                self.run();

                [test_exp_path, ~, ~] = fileparts(self.doc.save_filename);
                if exist(fullfile(test_exp_path,'Results',self.model.fly_name))
                    movefile(fullfile(test_exp_path,'Results',self.model.fly_name,'*'),fullfile(real_exp_path,'Results',real_fly_name,self.model.fly_name));
                    rmdir(fullfile(test_exp_path,'Results', self.model.fly_name));
                    rmdir(fullfile(test_exp_path,'Results'));

                else
                    self.model.num_tests_conducted = self.model.num_tests_conducted - 1;

                end
                if exist(fullfile(test_exp_path,'Log Files'))
                    rmdir(fullfile(test_exp_path,'Log Files'), 's');
                end
                
                answer = questdlg('Would you like to repeat the test protocol?', 'Repeat', 'Yes', 'No', 'No');
                if strcmp(answer, 'Yes')
                    self.model.num_tests_conducted = self.model.num_tests_conducted + 1;
                    self.model.fly_name = ['trial',num2str(self.model.num_tests_conducted)];
                else
                    repeat = 0;
                end
            end
                
            original_exp_path = fullfile(real_exp_path, real_file);
            self.open_g4p_file(original_exp_path);
            self.model.fly_name = real_fly_name;
            self.update_view_if_exists();

        end
        
        function browse_file(self, which_file)
           
            [file, path] = uigetfile('*.m');
            filepath = fullfile(path,file);
            if ~isfile(filepath)
                errormsg = "The file you entered does not exist.";
                self.create_error_box(errormsg);
                return;
            end
            if strcmp(which_file, 'run')
                self.model.set_run_file(filepath);
            elseif strcmp(which_file, 'plot')
                self.model.set_plot_file(filepath);
            elseif strcmp(which_file, 'proc')
                self.model.set_proc_file(filepath);
            else
                errormsg = 'You must tell me which file this is. Please enter run, plot, or proc.';
                self.create_error_box(errormsg);
            end

        end
        
        function update_view_if_exists(self)

            if ~isempty(self.view)
                self.view.update_run_gui();
            end

        end

        function create_metadata_file(self)
        
            metadata_names = {"experimenter", "experiment_name", "timestamp", "fly_name", "fly_genotype", "fly_age", "fly_sex", "experiment_temp", ...
                "experiment_type", "rearing_protocol", "light_cycle", "do_plotting", "do_processing", "plotting_file", "processing_file", "run_protocol_file", ...
                "comments"};
            model_metadata = {self.model.experimenter, self.doc.experiment_name, self.view.date_and_time_box.String, self.model.fly_name, self.model.fly_genotype, ...
                self.model.fly_age, self.model.fly_sex, self.model.experiment_temp, ...
                self.model.experiment_type, self.model.rearing_protocol, self.model.light_cycle, self.model.do_plotting, self.model.do_processing, ...
                self.model.plotting_file, self.model.processing_file, self.model.run_protocol_file, self.model.metadata_comments};

        
            metadata = struct;
            
            for i = 1:length(metadata_names)
                metadata.(metadata_names{i}) = model_metadata{i};
            end
            
            [experiment_path, g4p_filename, ext] = fileparts(self.doc.save_filename);
            fly_folder = fullfile(experiment_path, 'Results', self.model.fly_name);
            metadata_save_filename = fullfile(fly_folder, 'metadata.mat');
            save(metadata_save_filename, 'metadata');
            
            
        end

        %SETTERS

        
        function set.model(self, value)
            self.model_ = value;
        end
        
        function set.doc(self, value)
            self.doc_ = value;
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
        
        function set.is_aborted(self, value)
            self.is_aborted_ = value;
        end
        
        function set.elapsed_time(self, value)
            self.elapsed_time_ = value;
        end
        
        function set.remaining_time(self, value)
            self.remaining_time_ = value;
        end

        function set.settings_con(self, value)
            self.settings_con_ = value;
        end
        
        function set.view(self, value)
            self.view_ = value;
        end


        %GETTERS
        
        function value = get.model(self)
           value = self.model_;
        end

        function value = get.doc(self)
            value = self.doc_;
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

        function value = get.is_aborted(self)
            value = self.is_aborted_;
        end
        
        function output = get.elapsed_time(self)
            output = self.elapsed_time_;
        end
        
        function output = get.remaining_time(self)
            output = self.remaining_time_;
        end

        function output = get.settings_con(self)
            output = self.settings_con_;
        end
        function output = get.view(self)
            output = self.view_;
        end

   
        
%         function [output] = get_fly_name(self)
%             output = self.model.fly_name_;
%         end
        
        
        
       
        
    end
    
    
    
end