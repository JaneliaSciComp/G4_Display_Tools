classdef G4_conductor_controller < handle

    properties

        model
        doc
        settings_con
        view
        fb_model
        fb_view

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
        is_paused
        settings
        is_ended_early
    end

    methods

        %% constructor
        function self = G4_conductor_controller(varargin)
            self.set_model(G4_conductor_model());
            self.set_elapsed_time(0);
            if ~isempty(varargin)
                self.set_doc(varargin{1});
                self.model.set_fly_name(self.model.create_fly_name(self.doc.get_top_export_path()));
                self.set_settings_con(varargin{2});
            else
                self.set_doc(G4_document());
                self.set_settings_con(G4_settings_controller());
            end

            self.set_settings(G4_Protocol_Designer_Settings());
            fn = fieldnames(self.settings());
            for i = 1:numel(fn)
                if isstring(self.settings.(fn{i}))
                    self.settings.(fn{i}) = convertStringsToChars(self.settings.(fn{i}));
                end
            end

            exp_time = self.doc.calc_exp_length();
            self.model.set_expected_time(exp_time);
            self.set_remaining_time(self.model.get_expected_time());
            self.set_is_paused(0);


            self.set_current_mode('');
            self.set_current_pat('');
            self.set_current_pos('');
            self.set_current_ao1('');
            self.set_current_ao2('');
            self.set_current_ao3('');
            self.set_current_ao4('');
            self.set_current_frInd('');
            self.set_current_frRate('');
            self.set_current_gain('');
            self.set_current_offset('');
            self.set_current_duration('');
            self.set_is_aborted(0);
            self.set_is_ended_early(0);


            self.set_fb_model(feedback_model(self.doc));
        end

        function layout(self)
            self.set_view(G4_conductor_view(self));
            self.set_fb_view(feedback_view(self, [910 17]));
        end

        function update_timestamp(self)
            %No error checking
            self.model.set_timestamp();
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
            
        end

        function update_do_processing(self, new_val)
            self.model.set_do_processing(new_val);
            
        end

        function update_convert_tdms(self, new_val)
            self.model.set_convert_tdms(new_val);
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

        function update_run_file(self, dd_string)
            self.model.set_run_file(dd_string);
        end

        function update_experiment_type(self, new_val)
            %Make sure the number falls within range
            %%%%%%%%%%TODO right now the types are hardcoded into the view
            %%%%%%%%%%- switch this to the model!
            self.model.set_experiment_type(new_val);
        end

        function update_age(self, new_val)
           
           self.model.set_fly_age(new_val);
            
        end

        function update_sex(self, new_val)
            
            self.model.set_fly_sex(new_val);
            
        end

        function update_temp(self, new_val)
            
            self.model.set_experiment_temp(new_val);
            
        end

        function update_rearing(self, new_val)
            
            self.model.set_rearing_protocol(new_val);
            
        end

        function update_light_cycle(self, new_val)
            
            self.model.set_light_cycle(new_val);
           
        end

        function update_comments(self, new_val)
            %no error checking
            self.model.set_metadata_comments(new_val)
        end

        function update_elapsed_time(self, new_val)
            self.set_elapsed_time(new_val);
            self.set_remaining_time(self.model.get_expected_time() - new_val);
            self.update_view_if_exists();
        end

        function update_expected_time(self)
            if isempty(self.fb_model.bad_trials)
                new_val = self.doc.calc_exp_length();
                self.model.set_expected_time(new_val);
                self.model.set_orig_expected_time(new_val);
            else
                new_val = self.calc_rescheduled_time();
                self.model.set_expected_time(new_val);
            end
        end

        function update_num_attempts(self, new_val)
            self.model.set_num_attempts_bad_conds(new_val);
        end

        function update_config_file(self)
            clear('self.doc');
            self.set_doc(G4_document());
            self.fb_model.update_model_channels(self.doc)

        end

        function add_bad_trial_marker_progress(self, trialNum)
            num_trials = self.get_num_trials();
            if ~isempty(self.view)
                self.view.add_bad_trial_marker(num_trials, trialNum);
            end
        end

        function add_bad_trial_marker_rerun(self, progPercentage)
            
            if ~isempty(self.view)
                self.view.add_bad_trial_marker_rerun(progPercentage);
            end
        end

        function new_exp_length = calc_rescheduled_time(self)

            orig_exp_length = self.model.get_expected_time();
            add_time = 0;
            for trial = 1:length(self.fb_model.bad_trials)
                cond = self.fb_model.bad_trials{trial}(1);
                add_time = add_time + self.doc.block_trials{cond,12};
            end
            if ~isempty(self.doc.intertrial{1})
                add_time = add_time + self.doc.intertrial{12}*(length(self.fb_model.bad_trials)-1);
            end

            new_exp_length = orig_exp_length + add_time;


        end

        function add_to_exp_length(self, cond)
            if self.get_num_attempts() ~= 0
                curr_exp_length = self.model.get_expected_time();
                add_time = self.doc.block_trials{cond,12};
                if ~isempty(self.doc.intertrial{1})
                    add_time = add_time + self.doc.intertrial{12};
                end
                self.model.set_expected_time(curr_exp_length + add_time);
            end
        end

        function add_pretrial_to_exp_length(self, preLength)
            
            curr_exp_length = self.model.get_expected_time();
            self.model.set_expected_time(curr_exp_length + preLength);
            
        end

        function reset_exp_length(self)

            exp_time = self.doc.calc_exp_length();
            self.model.set_expected_time(exp_time);
            self.set_remaining_time(self.model.get_expected_time());

        end


        function update_progress(self, trial_type, varargin)
            trials = self.get_num_trials();
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
            elseif strcmp(trial_type, 'rescheduled')
                cond = varargin{1};
                data = varargin{2};
                % data = trial num/total rescheduled trials;
                if ~isempty(self.view)
                    self.view.update_progress_bar(trial_type, data, cond);
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
                    self.set_current_ao1(num2str(ao_inds(i)));
                elseif active_channels(i) == 1
                    self.set_current_ao2(num2str(ao_inds(i)));
                elseif active_channels(i) == 2
                    self.set_current_ao3(num2str(ao_inds(i)));
                else
                    self.set_current_ao4(num2str(ao_inds(i)));
                end
            end

            self.set_current_mode(num2str(mode));
            self.set_current_pat(num2str(pat));
            self.set_current_pos(num2str(pos));
            self.set_current_frInd(num2str(frInd));
            self.set_current_frRate(num2str(frRate));
            self.set_current_gain(num2str(gain));
            self.set_current_offset(num2str(offset));
            self.set_current_duration(num2str(dur));
            self.update_view_if_exists();
        end

        function update_custom_OL_analysis(self, new_val)
            if isfile(new_val) || isempty(new_val)
                self.fb_model.set_OL_analysis(new_val);
            else
                errormsg = "This file does not exist. Please check the path.";
                self.create_error_box(errormsg);
            end
            self.fb_view.update_custom_OL_function();
        end

        function update_custom_CL_analysis(self, new_val)
             if isfile(new_val) || isempty(new_val)
                self.fb_model.set_CL_analysis(new_val);
            else
                errormsg = "This file does not exist. Please check the path.";
                self.create_error_box(errormsg);
             end
             self.fb_view.update_custom_CL_function();
        end

        function open_settings(self, ~, ~)
            self.settings_con.layout_view();
        end

        function engage_plotting_textbox(self)
            if self.model.get_do_plotting() == 1
                if ~isempty(self.view)
                    set(self.view.plotting_textbox, 'enable', 'on');
                    set(self.view.browse_button_plotting, 'enable','on');
                end
            elseif self.model.get_do_plotting() == 0
                if ~isempty(self.view)
                    set(self.view.plotting_textbox, 'enable', 'off');
                    set(self.view.browse_button_plotting, 'enable','off');
                end
            end
        end

        function engage_processing_textbox(self)
            if self.model.get_do_processing() == 1
                if ~isempty(self.view)
                    set(self.view.processing_textbox,'enable', 'on');
                    set(self.view.browse_button_processing, 'enable','on');
                end
            elseif self.model.get_do_processing() == 0
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

                e = errordlg(msg, title, 'modal');
                set(e, 'Resize', 'on');
                
            end
        end

        function open_g4p_file(self, varargin)
            if ~isempty(varargin)
                filepath = varargin{1};
                [top_folder_path, filename] = fileparts(filepath);
            else
                %% fixfocus citation
            %% Jorg Woehl (2024). fixfocus (https://github.com/JorgWoehl/fixfocus/releases/tag/v1.2), GitHub. Retrieved June 4, 2024. 
                ff = fixfocus();
                [filename, top_folder_path] = uigetfile('*.g4p');
                delete(ff);
                filepath = fullfile(top_folder_path, filename);
                
            end

            if isequal (top_folder_path,0)
                %They hit cancel, do nothing
                return;
            else
                import_success = self.doc.import_folder(top_folder_path);
%                 if ~isempty(self.view)
%                     waitfor(msgbox(import_success, 'Import successful!'));
%                 end
                disp(import_success);

                if isempty(fieldnames(self.doc.get_Patterns()))
                    %no patterns were successfully imported, so don't load
                    %experiment. 
                    return;
                end

                [~, exp_name, ~] = fileparts(filepath);
                self.doc.set_experiment_name(exp_name);
                self.doc.set_save_filename(top_folder_path);
                self.doc.set_top_export_path(top_folder_path);

                data = self.doc.open(filepath);
                p = data.exp_parameters();

                self.doc.set_repetitions(p.repetitions);
                self.doc.set_is_randomized(p.is_randomized);
                self.doc.set_is_chan1(p.is_chan1);
                self.doc.set_is_chan2(p.is_chan2);
                self.doc.set_is_chan3(p.is_chan3);
                self.doc.set_is_chan4(p.is_chan4);
                self.doc.set_chan1_rate(p.chan1_rate);
                self.doc.set_config_data(p.chan1_rate, 1);
                self.doc.set_chan2_rate(p.chan2_rate);
                self.doc.set_config_data(p.chan2_rate, 2);
                self.doc.set_chan3_rate(p.chan3_rate);
                self.doc.set_config_data(p.chan3_rate, 3);
                self.doc.set_chan4_rate(p.chan4_rate);
                self.doc.set_config_data(p.chan4_rate, 4);
                self.doc.set_num_rows(p.num_rows);
                self.doc.set_config_data(p.num_rows, 0);
                self.doc.update_config_file();
                self.fb_model.update_model_channels(self.doc);

                for k = 1:13
                    self.doc.set_trial_property(1, k, p.pretrial{k}, 'pre');
                    self.doc.set_trial_property(1, k, p.intertrial{k}, 'inter');
                    self.doc.set_trial_property(1, k, p.posttrial{k}, 'post');
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
                      
                        self.doc.set_trial_property(j, block_y, newrow, 'block');
                    else
                        for n = 1:13
                            self.doc.set_trial_property(j, n, p.block_trials{j,n}, 'block');

                        end
                    end
                end

                self.doc.set_recent_files(filepath);
                self.doc.update_recent_files_file();
                self.model.set_fly_name(self.model.create_fly_name(top_folder_path));
                self.update_expected_time();
                self.update_elapsed_time(0);
                if ~isempty(self.view)
                    self.view.reset_progress_bar();
                end

                self.update_view_if_exists();
            end
        end

        %% Open  Google Sheets in browser
        %
        % Uses Google Sheets key from Settings
        function open_google_sheet(self)
            base_url = 'https://urldefense.com/v3/__https://docs.google.com/spreadsheets/d/__;!!Eh6p8Q!EXK_mCBTDtN5rHLw11EVnkP4ic03xv1V6cRmunrWCY1Y1cSp3J3g_hmKnqHAh_J6341UCMKmpGlhotDhEdTqXw$ ';
            full_link = [base_url,self.model.get_google_sheet_key(),'/edit?usp=sharing'];
            web(full_link, '-browser');
        end

        function [aborted] = check_if_aborted(self)
            aborted = self.is_aborted;
        end

        function abort_experiment(self)
            self.is_aborted = 1;
        end

        function pause_experiment(self, val)
            self.is_paused = val;
%             if self.is_paused == 0
%                 self.is_paused = 1;
%             elseif self.is_paused == 1
%                 self.is_paused = 0;
%             else
%                 self.is_paused = 0;
%                 disp("There was an error with the pause feature");
%             end
        end

        function end_early(self)
            self.set_is_ended_early(1);
        end

        function [ended] = check_if_ended(self)
            ended = self.get_is_ended_early();
        end

        function yes = check_if_paused(self)
            if self.is_paused == 1
                yes = 1;
            else
                yes = 0;
            end
        end

        function pause(self)
            waitfor(self, 'is_paused');
        end

        function run(self)

            self.set_is_aborted(false); %change aborted back to zero in case the experiment was aborted earlier.
            self.set_is_ended_early(0);
            if ~isempty(self.view)
                self.view.clear_progress_bars();
            end
            self.reset_exp_length();

            % Update timestamp to reflect actual start time of experiment
            self.update_timestamp();

            %get path to experiment folder
            [experiment_path, ~, ~] = fileparts(self.doc.save_filename);
            experiment_folder = experiment_path;
            self.model.update_fly_save_name();

            %Path to save all results for this fly
            fly_results_folder = fullfile(experiment_folder, self.model.get_date_folder(), self.model.get_fly_save_name());

            %create Log Files folder if it doesn't exist
            if ~exist(fullfile(experiment_folder,'Log Files'),'dir')
                mkdir(experiment_folder,'Log Files');
            end

            %create Aborted Experiments folder if it doesn't exist
            if ~exist(fullfile(experiment_folder,'Aborted_Experiments'),'dir')
                mkdir(experiment_folder,'Aborted_Experiments');
            end

            %Check for issues that might disrupt the run

            %returns if you forgot to save the experiment.
            if ~self.check_if_saved
                return;
            end

            %check if log files already present or if a fly by that name
            %already has results in this experiment folder.
            if length(dir(fullfile(experiment_folder, 'Log Files')))>2
                if ~isempty(self.view)
                    self.create_error_box('unsorted files present in "Log Files" folder, remove before restarting experiment\n');
                else
                    disp('Failed: There are unsorted files in the "Log Files" folder. Please remove them and try again.');
                end
                return;
            end

%             %Make sure the run file entered exists
%             if ~isfile(self.model.get_run_protocol_file())
%                 if ~isempty(self.view)
%                     self.create_error_box("Please make sure you've entered a valid .m file to run the experiment.");
%                 else
%                     disp('Failed: The run protocol is not a valid .m file.');
%                 end
%                 return;
%             end

            %Check if the date folder exists - if not, create it.
            if ~exist(fullfile(experiment_folder, self.model.get_date_folder()),'dir')
                self.create_folder(experiment_folder, self.model.get_date_folder());
                self.create_folder(fullfile(experiment_folder, self.model.get_date_folder()), self.model.get_fly_save_name());

            else
                %if so, check if the fly folder exists. if not, create it.
                if ~exist(fullfile(experiment_folder, self.model.get_date_folder(), self.model.get_fly_save_name()),'dir')
                    self.create_folder(fullfile(experiment_folder, self.model.get_date_folder()), self.model.get_fly_save_name());
                else
                    %if so, make sure there are not already results in it.
                    if self.check_for_files(fullfile(experiment_folder, self.model.get_date_folder(), self.model.get_fly_save_name()))

                        %experimental data already exists in this fly folder
                        return;
                    end
                end
            end

            %Go through and replace all the greyed out parameters with
            %appropriate values to be sent to the controller
            self.doc.replace_greyed_cell_values();

            %If the user has provided processing settings, set the wing
            %beat frequency limitations so data being streamed back in
            %real time can provide wbf alerts. If no processing, default
            %values are used.

            if self.model.get_do_processing() && isfile(self.model.get_processing_file())
                self.fb_model.get_wbf_limits(self.model.get_processing_file());
            end

            %get_parameters_struct creates a struct of all parameters so they
            %can easily be passed to the run protocol. It calls a number of
            %other functions in order to determine parameter values. It handles getting the
            %active ao channels, indices for various functions, creating
            %exp_order, etc. Check this subfunction for details on how each
            %parameter is calculated.
            parameters = self.get_parameters_struct();

            parameters.experiment_folder = experiment_folder;
            parameters.fly_results_folder = fly_results_folder;

            %save the experiment order
            exp_order = parameters.exp_order;
            save(fullfile(experiment_folder,'Log Files','exp_order.mat'),'exp_order')

            % Update gui
            self.update_view_if_exists();

            %Get function name of the script which will run the experiment
            [~, run_name, ~] = fileparts(self.model.get_run_protocol_file());

            %Create the full command
            run_command = "success = " + run_name + "(self, parameters);";

            %run script
            eval(run_command);
            pause(3);

            if self.check_if_aborted()
                %experiment has been aborted
                self.model.set_aborted_count(self.model.get_aborted_count() + 1);
                aborted_filename = ['Aborted_exp_data',self.get_timestamp()];
                aborted_results_folder = fullfile(experiment_folder, 'Aborted_Experiments');
                [logs_removed, logs_msg] = movefile(fullfile(experiment_folder,'Log Files','*'),fullfile(aborted_results_folder,aborted_filename));
                pause(.5);

                self.create_metadata_file();

                 %Clear out live feedback panel
                self.fb_model = feedback_model(self.doc);
                if ~isempty(self.fb_view)
                    self.fb_view.clear_view(self.fb_model);
                end

%                 [logs_removed, msg] = rmdir(fullfile(experiment_folder, 'Log Files'), 's');
%                 pause(1);
                if logs_removed == 0
                    if ~isempty(self.view)
                        self.create_error_box("Matlab was unable to move the log files. Please move manually.");
                    else
                        disp('Failed to move the log files from the Log Files folder when aborting experiment. Please move them manually.');
                    end
                    disp(logs_msg);
                else
                    if ~isempty(self.view)
                        self.view.set_progress_title("Experiment aborted successfully.");
                        drawnow;
                    else
                        disp('Experiment aborted succesfully');
                    end

                end
                self.set_is_aborted(0);
                return;
            end

            if success == 0
                if isempty(self.view)
                    disp('Experiment failed for unknown reason.');
                else
                    self.create_error_box("Experiment failed for unknown reason.");
                end
                movefile(fullfile(experiment_folder,'Log Files','*'),fullfile(fly_results_folder,'Failed_exp_data'));
                pause(.5);
                return;
            end

            %Move the log files to the results file under the fly name
            movefile(fullfile(experiment_folder,'Log Files','*'),fly_results_folder);
            pause(.5);

            %create .mat file of metadata
            self.create_metadata_file();

             %Clear out live feedback panel
            self.set_fb_model(feedback_model(self.doc));
            if ~isempty(self.fb_view)
                self.fb_view.clear_view(self.fb_model);
            end

            if self.model.get_do_processing() == 1 || self.model.get_do_plotting() == 1
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

            % Convert TDMS files to matlab only if the option is selected
            % on the Conductor
            if self.get_convert_tdms()

                % Check how many tdms folders are in the fly folder
                num_logs = self.check_number_logs(fly_results_folder);
    
                % If there's one, convert like normal. if there's more than
                % one, convert all Logs to matlab structs separately. Display
                % message to user if there are no logs found.
    
                if num_logs == 1
                    G4_TDMS_folder2struct(fly_results_folder);
                elseif num_logs > 1
                    self.convert_multiple_logs(fly_results_folder);
                    if self.get_combine_tdms == 1
    
                        %consolidate multiple resulting structs into one struct
                        Log = self.consolidate_log_structs(fly_results_folder);
                        LogFinalName = 'G4_TDMS_Logs_Final.mat';
                        save(fullfile(fly_results_folder, LogFinalName),'Log');
                    else
                        disp('TDMS files were not combined into one.');
                    end
                else
                    disp("No tdms folders could be found from this experiment.");
                end

            else
                disp("TDMS files were not converted to a matlab struct. Please do this manually later.");
            end

            %Get array indicating the presence of pretrial, intertrial, and
            %posttrial
            trial_options = self.get_trial_options();

            %Run post processing and data analysis if selected
            if self.model.get_do_processing() == 1 && (strcmp(self.model.get_processing_file(),'') || ~isfile(self.model.get_processing_file()))
                %the processing file provided is empty or doesn't exist.
                if ~isempty(self.view)
                    self.create_error_box("Processing script was not run because the processing file could not be found. Please run manually.");
                else
                    disp('Processing file could not be found. Please run manually.');
                end
            elseif self.model.get_do_processing() == 1 && isfile(self.model.get_processing_file())
                if num_logs > 1 && self.get_combine_tdms == 0
                    disp('There are multiple TDMS logs that were not consolidated, so data processing cannot run');
                else
                    [proc_path, proc_name, proc_ext] = fileparts(self.model.get_processing_file());
                    processing_command = "process_data(fly_results_folder, self.model.get_processing_file())";
                    eval(processing_command);
                end
                if self.model.get_do_plotting() == 1 && (strcmp(self.model.get_plotting_file(),'') || ~isfile(self.model.get_plotting_file()))
                    %The settings file for data analysis is empty or
                    %doesn't exist.
                    if ~isempty(self.view)
                        self.create_error_box("data analysis was not run because the settings file could not be found. Please run manually.");
                    else
                        disp('data analysis settings file could not be found. Please run manually.');
                    end
                elseif self.model.get_do_plotting() == 1 && isfile(self.model.get_plotting_file())
                    [plot_path, plot_comm, ext] = fileparts(self.model.get_plotting_file());
                    if strcmp(ext,'.mat')
                        self.run_single_fly_DA(self.model.get_plotting_file(), fly_results_folder, trial_options, experiment_folder);
                    else
                        %Do old analysis.
                        self.run_pdf_report(fly_results_folder, trial_options, processed_filename);
                    end
                end
            end

            if ~isempty(self.view)
                self.view.set_progress_title('Finished.');
                drawnow;
            end
        end

        function num_logs = check_number_logs(~, fly_folder)
            files = dir(fly_folder);
            files = files(~ismember({files.name},{'.','..'}));
            subdir_idx = [files.isdir]; %look for subfolders
            num_logs = sum(subdir_idx);
        end

        function convert_multiple_logs(~, fly_folder)
            files = dir(fly_folder);
            files = files(~ismember({files.name},{'.','..'}));
            subdir_idx = [files.isdir]; %look for subfolders
            folders = files(subdir_idx);
            for fold = 1:length(folders)
                tdms_folder_path = fullfile(fly_folder, folders(fold).name);
                G4_TDMS_folder2struct(tdms_folder_path);
            end
        end

        function Log = consolidate_log_structs(self, fly_folder)
            files = dir(fly_folder);
            files = files(~ismember({files.name},{'.','..'}));
            file_idx = ~[files.isdir];
            files = files(file_idx);
            tdms_idx = [];
            for f = 1:length(files)
                if contains(files(f).name, "TDMS")
                    tdms_idx(end +1) = f;
                end
            end
            log_files = files(tdms_idx);

            % make sure the log files are sorted by timestamp
            log_files_sorted = self.sort_logs_timestamp(log_files);

            % take data from each log file and smush it all together in one
            % big struct that follows the exact same layout as the smaller
            % ones.
            Log1 = load(fullfile(fly_folder,log_files_sorted(1).name));
            LogFinal = Log1;
            clear('Log1');
            for logfile = 2:length(log_files_sorted)
                LogTemp = load(fullfile(fly_folder,log_files_sorted(logfile).name));
                LogFinal = stitch_log(self, LogFinal, LogTemp.Log);
                clear('LogTemp');
            end
            Log = LogFinal.Log;
        end

        function finLog = stitch_log(~, finLog, tempLog)
            % ADC
            switch size(tempLog.ADC.Time,1)
                case 1
                    finLog.Log.ADC.Time = [finLog.Log.ADC.Time(1,:), tempLog.ADC.Time(1,:)];
                    finLog.Log.ADC.Volts = [finLog.Log.ADC.Volts(1,:), tempLog.ADC.Volts(1,:)];
                case 2
                    finLog.Log.ADC.Time = [finLog.Log.ADC.Time(1,:), tempLog.ADC.Time(1,:); finLog.Log.ADC.Time(2,:), tempLog.ADC.Time(2,:)];
                    finLog.Log.ADC.Volts = [finLog.Log.ADC.Volts(1,:), tempLog.ADC.Volts(1,:); finLog.Log.ADC.Volts(2,:), tempLog.ADC.Volts(2,:)];
                case 3
                    finLog.Log.ADC.Time = [finLog.Log.ADC.Time(1,:), tempLog.ADC.Time(1,:); finLog.Log.ADC.Time(2,:), tempLog.ADC.Time(2,:); finLog.Log.ADC.Time(3,:), tempLog.ADC.Time(3,:)];
                    finLog.Log.ADC.Volts = [finLog.Log.ADC.Volts(1,:), tempLog.ADC.Volts(1,:); finLog.Log.ADC.Volts(2,:), tempLog.ADC.Volts(2,:); finLog.Log.ADC.Volts(3,:), tempLog.ADC.Volts(3,:)];
                case 4
                    finLog.Log.ADC.Time = [finLog.Log.ADC.Time(1,:), tempLog.ADC.Time(1,:); finLog.Log.ADC.Time(2,:), tempLog.ADC.Time(2,:); finLog.Log.ADC.Time(3,:), tempLog.ADC.Time(3,:); finLog.Log.ADC.Time(4,:), tempLog.ADC.Time(4,:)];
                    finLog.Log.ADC.Volts = [finLog.Log.ADC.Volts(1,:), tempLog.ADC.Volts(1,:); finLog.Log.ADC.Volts(2,:), tempLog.ADC.Volts(2,:); finLog.Log.ADC.Volts(3,:), tempLog.ADC.Volts(3,:); finLog.Log.ADC.Volts(4,:), tempLog.ADC.Volts(4,:)];
            end

            % AO
            if ~isempty(tempLog.AO.Time)
                switch size(tempLog.AO.Time,1)
                    case 1
                        finLog.Log.AO.Time = [finLog.Log.AO.Time(1,:), tempLog.AO.Time(1,:)];
                        finLog.Log.AO.Volts = [finLog.Log.AO.Volts(1,:), tempLog.AO.Volts(1,:)];
                    case 2
                        finLog.Log.AO.Time = [finLog.Log.AO.Time(1,:), tempLog.AO.Time(1,:); finLog.Log.AO.Time(2,:), tempLog.AO.Time(2,:)];
                        finLog.Log.AO.Volts = [finLog.Log.AO.Volts(1,:), tempLog.AO.Volts(1,:); finLog.Log.AO.Volts(2,:), tempLog.AO.Volts(2,:)];
                    case 3
                        finLog.Log.AO.Time = [finLog.Log.AO.Time(1,:), tempLog.AO.Time(1,:); finLog.Log.AO.Time(2,:), tempLog.AO.Time(2,:); finLog.Log.AO.Time(3,:), tempLog.AO.Time(3,:)];
                        finLog.Log.AO.Voltes = [finLog.Log.AO.Volts(1,:), tempLog.AO.Volts(1,:); finLog.Log.AO.Volts(2,:), tempLog.AO.Volts(2,:); finLog.Log.AO.Volts(3,:), tempLog.AO.Volts(3,:)];
                    case 4
                        finLog.Log.AO.Time = [finLog.Log.AO.Time(1,:), tempLog.AO.Time(1,:); finLog.Log.AO.Time(2,:), tempLog.AO.Time(2,:); finLog.Log.AO.Time(3,:), tempLog.AO.Time(3,:); finLog.Log.AO.Time(4,:), tempLog.AO.Time(4,:)];
                        finLog.Log.AO.Volts = [finLog.Log.AO.Volts(1,:), tempLog.AO.Volts(1,:); finLog.Log.AO.Volts(2,:), tempLog.AO.Volts(2,:); finLog.Log.AO.Volts(3,:), tempLog.AO.Volts(3,:); finLog.Log.AO.Volts(4,:), tempLog.AO.Volts(4,:)];
                end
            end

            % Frames
            finLog.Log.Frames.Time = [finLog.Log.Frames.Time(1,:), tempLog.Frames.Time(1,:)];
            finLog.Log.Frames.Position = [finLog.Log.Frames.Position(1,:), tempLog.Frames.Position(1,:)];

            % Commands
            finLog.Log.Commands.Time = [finLog.Log.Commands.Time(1,:), tempLog.Commands.Time(1,:)];
            finLog.Log.Commands.Name = {finLog.Log.Commands.Name{1,:}, tempLog.Commands.Name{1,:}};
            if ~isempty(tempLog.Commands.Data)
                finLog.Log.Commands.Data = [finLog.Log.Commands.Data(1,:), tempLog.Commands.Data(1,:)];
            else
                finLog.Log.Commands.Data = [];
            end
        end

        function [sorted_log_files] = sort_logs_timestamp(self, log_files)
             %This function assumes log_files has already had non-log files
             %removed. It also assumes the log file names follow the
             %pattern 'G4_TDMS_Logs_mm_dd_yyyy_hh-hh-mm-ss' and it only
             %sorts by time (it assumes all log files are from the same
             %day) The first hh is military time (15 for 3 pm), the second
             %hh is converted (so 03 for 3 pm) so we only use the first hh,
             %mm, and ss for sorting.
             timestamps = {};
            for fi = 1:length(log_files)
                timestamps{fi} = log_files(fi).name(end-14:end-4);
                nums_to_sort(fi, 1:3) = [str2num(timestamps{fi}(1:2)), str2num(timestamps{fi}(7:8)), str2num(timestamps{fi}(10:11))];

            end
            [~, sorted_idx] = sortrows(nums_to_sort);
            sorted_log_files = log_files(sorted_idx);
        end

        function update_flyName_reminder(self)
           if ~isempty(self.view)
                self.create_error_box("If you are changing flies, please remember to update the fly name.");
           end
        end

        function create_timing_file(self, fly_path)
            filename = 'times_between_trials.mat';
            postTrialTimes = self.model.get_postTrialTimes();
            save(fullfile(fly_path, filename), 'postTrialTimes');
        end

        function all_tdms_folders2structs(self, fly_path)
            % Take in the path to the folder, find all sub folders with tdms files
            % in them, and then run G4_TDMS_folder2struct on each, resulting in the
            % same number of Log .mat files.
%             if strcmpi(fly_path(end),'\')==1
%                 fly_path = fly_path(1:end-1);
%             end
            files = dir(fly_path);
            files = files(~ismember({files.name},{'.','..'}));
            subdir_idx = [files.isdir]; %look for subfolders
            subfolders = files(subdir_idx);
            for fold = length(subfolders):-1:1
                subfiles = dir(fullfile(fly_path, subfolders(fold).name));
                subfiles = subfiles(~ismember({subfiles.name},{'.','..'}));
                if ~contains([subfiles.name], '.tdms')
                    subfolders(fold) = [];
                end
            end
            for folder = 1:length(subfolders)
                G4_TDMS_folder2struct(fullfile(fly_path, subfolders(folder).name));

            end

            % Now the folder has a Log file for each condition. Load all Log files
            % and combine them into one Log file
            newfiles = dir(fly_path);
            newfiles = newfiles(~ismember({newfiles.name},{'.', '..'}));
            for file = length(newfiles):-1:1
                if ~contains(newfiles(file).name, 'G4_TDMS_Logs_')
                    newfiles(file) = [];
                end
            end

            % Create main Log struct to hold all data
            Log = struct;
            LogInd = load(fullfile(fly_path, newfiles(1).name));

            Log = LogInd.Log; % Adds all correct struct fields and data for the first trial

            for l = 2:length(newfiles)
                LogInd =  load(fullfile(fly_path, newfiles(l).name));
                % Go through each field/value in the Log struct and combine with
                % the existing
                Log.ADC.Time = [Log.ADC.Time LogInd.Log.ADC.Time];
                Log.ADC.Volts = [Log.ADC.Volts LogInd.Log.ADC.Volts];
                Log.AO.Time = [Log.AO.Time LogInd.Log.AO.Time];
                Log.AO.Volts = [Log.AO.Volts LogInd.Log.AO.Volts];
                Log.Frames.Time = [Log.Frames.Time LogInd.Log.Frames.Time];
                Log.Frames.Position = [Log.Frames.Position LogInd.Log.Frames.Position];
                Log.Commands.Time = [Log.Commands.Time LogInd.Log.Commands.Time];
                Log.Commands.Name = [Log.Commands.Name LogInd.Log.Commands.Name];
                Log.Commands.Data = [Log.Commands.Data LogInd.Log.Commands.Data];
            end
            save(fullfile(fly_path, 'G4_TDMS_Logs_final.mat'), 'Log');
        end

        function move_excess_tdms(self, fly_path)
            new_path = fullfile(fly_path, 'Trial_TDMS_Files');
            mkdir(new_path);

            files = dir(fly_path);
            files = files(~ismember({files.name},{'.','..'}));
            subdir_idx = [files.isdir]; %look for subfolders
            subfolders = files(subdir_idx);

            for fold = length(subfolders):-1:1
                subfiles = dir(fullfile(fly_path, subfolders(fold).name));
                subfiles = subfiles(~ismember({subfiles.name},{'.','..'}));
                if ~isempty(subfiles)
                    if ~contains([subfiles.name], '.tdms')
                        subfolders(fold) = [];
                    end
                else
                    subfolders(fold) = [];
                end
            end

            for f = 1:length(subfolders)
                movefile(fullfile(fly_path, subfolders(f).name), fullfile(new_path, subfolders(f).name));
            end

            onlyfiles = files(~subdir_idx);
            for file = length(onlyfiles):-1:1
                if ~contains([onlyfiles(file).name], 'G4_TDMS_Logs_')
                    onlyfiles(file) = [];
                elseif contains([onlyfiles(file).name], 'G4_TDMS_Logs_final')
                    onlyfiles(file) = [];
                end
            end

            for files = 1:length(onlyfiles)
                movefile(fullfile(fly_path, onlyfiles(files).name), fullfile(new_path, onlyfiles(files).name));
            end
        end

        function prepare_test_exp(self)
         
            % self.model.set_run_file(self.settings.test_run_protocol_file);
            self.model.set_plotting_file(self.settings.test_plotting_file);
            self.model.set_processing_file(self.settings.test_processing_file);
        end

        function [original_exp_path, real_fly_name] = run_test(self, original_experiment, original_fly_name)
            self.model.set_num_tests_conducted(self.model.get_num_tests_conducted() + 1);
            %repeat = 1;
            if ~exist('original_experiment','var')
                original_experiment = self.doc.save_filename;
            end
            original_exp_path = original_experiment;
            [real_file_path, ~, ~] = fileparts(original_experiment);
            if ~exist('original_fly_name','var')
                original_fly_name = self.model.get_fly_name();
            end
            real_fly_name = original_fly_name;

            %Get filepath to the test protocol
            if self.model.get_experiment_type() == 1
               path_to_experiment = self.settings.test_protocol_file_flight;
            elseif self.model.get_experiment_type() == 2
                %Get path to camera test file
                path_to_experiment = self.settings.test_protocol_file_camWalk;
            else
                %Get path to chip test file
                path_to_experiment = self.settings.test_protocol_file_chipWalk;
            end

            % Open test g4p file
            self.open_g4p_file(path_to_experiment);

            %Set test specific values
            self.model.set_fly_name(['trial',num2str(self.model.get_num_tests_conducted())]);

            if ~isempty(self.view)
                self.update_view_if_exists();
            end

%             while repeat == 1
            self.run();

            [test_exp_path, ~, ~] = fileparts(self.doc.save_filename);
            if exist(fullfile(test_exp_path,self.model.get_date_folder(), self.model.get_fly_save_name()))
                movefile(fullfile(test_exp_path,self.model.get_date_folder(), self.model.get_fly_save_name(),'*'),fullfile(real_file_path,self.model.get_date_folder(), self.model.get_fly_save_name(),self.model.get_fly_name),'f');
                %rmdir(fullfile(test_exp_path,'Results', self.model.get_fly_name()));
                pause(.5);
                rmdir(fullfile(test_exp_path,self.model.get_date_folder()),'s');
            else
                self.model.set_num_tests_conducted(self.model.get_num_tests_conducted() - 1);
            end
            if exist(fullfile(test_exp_path,'Log Files'))
                rmdir(fullfile(test_exp_path,'Log Files'), 's');
            end
        end

        function repeat = check_if_repeat(self)
            if ~isempty(self.view)
                answer = questdlg('Would you like to repeat the test protocol?', 'Repeat', 'Yes', 'No', 'No');
                if strcmp(answer, 'Yes')
                    repeat = 1;
                else
                    repeat = 0;
                end
            else
                answer = input('Would you like to repeat the test? Enter "Y" for yes or "N" for no.','s');
                if strcmp(answer,"Y")
                    repeat = 1;
                else
                    repeat = 0;
                end
            end
        end

        % After a fly is run, take the
        function create_fly_specific_g4p()
        end

        function reopen_original_experiment(self, filepath, fly_name)
            

            %self.model.set_run_file(self.settings.run_protocol_file);
            self.model.set_plotting_file(self.settings.plotting_file);
            self.model.set_processing_file(self.settings.processing_file);

            self.open_g4p_file(filepath);
            self.model.set_fly_name(fly_name);
            self.update_view_if_exists();
        end


        function update_streamed_data(self, tcp_data, trialType, rep, cond, trialnum)
            self.fb_model.read_tcp_data(tcp_data, trialType);

            %Load raw data into feedback model and translate it into datasets
            [bad_slope, bad_flier] = self.fb_model.check_if_bad(cond, rep, trialType);
            if strcmp(trialType, 'rescheduled')
                if bad_slope == 0 && bad_flier == 0
                    self.fb_model.remove_bad_condition(rep, cond);

                else
                    self.add_bad_trial_marker_rerun(trialnum);

                end
            else
                if bad_slope == 1 || bad_flier == 1
                    self.add_to_exp_length(cond);
                end    
            end
            if ~isempty(self.view)
                self.fb_view.update_feedback_view(self.fb_model, trialType, [trialnum cond rep], bad_slope, bad_flier);
                %update plots on GUI for streamed data
            end
        end

        function num = get_num_bad_conds(self)

            bad_conds = self.fb_model.get_bad_trials();
            num = length(bad_conds);

        end

        function browse_file(self, which_file)

            %% fixfocus citation
            %% Jorg Woehl (2024). fixfocus (https://github.com/JorgWoehl/fixfocus/releases/tag/v1.2), GitHub. Retrieved June 4, 2024. 
            ff = fixfocus();
            [file, path] = uigetfile('*.m');
            delete(ff);
            if ~ischar(file) && ~isstring(file)
                return;
            else
                filepath = fullfile(path,file);
            end
            if ~isfile(filepath)
                errormsg = "The file you entered does not exist.";
                self.create_error_box(errormsg);
                return;
            end
            if strcmp(which_file, 'run')
                self.model.set_run_file(filepath);
            elseif strcmp(which_file, 'plot')
                self.model.set_plotting_file(filepath);
            elseif strcmp(which_file, 'proc')
                self.model.set_processing_file(filepath);
            elseif strcmp(which_file, 'CL_cust')
                self.update_custom_CL_analysis(filepath);
            elseif strcmp(which_file, 'OL_cust')
                self.update_custom_OL_analysis(filepath);
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
                "experiment_type", "rearing_protocol", "light_cycle", "convert_tdms", "do_plotting", "do_processing", "plotting_file", "processing_file", "run_protocol_file", ...
                "comments", "fly_results_folder", "trials_rerun"};
            if ~isempty(self.view)
                waitfor(msgbox("Please add any final comments, then click OK to continue. Anything you change in the metadata after clicking OK will not be saved." ...
                    + newline + newline + " If you're changing flies for the next experiment, don't forget to update the fly name after clicking OK.", "Reminder"));
                self.model.set_metadata_comments(self.view.comments_box.Value);
            end

            [experiment_path, ~, ~] = fileparts(self.doc.save_filename);
            if self.is_aborted == 0
                fly_folder = fullfile(experiment_path, self.model.get_date_folder(), self.model.get_fly_save_name());
            else
                aborted_filename = ['Aborted_exp_data',self.get_timestamp()];
                fly_folder = fullfile(experiment_path, 'Aborted_Experiments', aborted_filename);
            end

            model_metadata = {self.model.get_experimenter(), self.doc.experiment_name, self.model.get_timestamp(), self.model.get_fly_name(), self.model.get_fly_genotype(), ...
                self.model.get_fly_age(), self.model.get_fly_sex(), self.model.get_experiment_temp(), ...
                self.model.get_experiment_type(), self.model.get_rearing_protocol(), self.model.get_light_cycle(), self.model.get_convert_tdms(), self.model.get_do_plotting(), self.model.get_do_processing(), ...
                self.model.get_plotting_file(), self.model.get_processing_file(), self.model.get_run_protocol_file(), self.model.get_metadata_comments(), fly_folder, ...
                self.fb_model.bad_trials_before_reruns};

            metadata = struct;
            for i = 1:length(metadata_names)
                metadata.(metadata_names{i}) = model_metadata{i};
            end
            
            if not(isfolder(fly_folder))
                mkdir(fly_folder);
            end
            metadata_save_filename = fullfile(fly_folder, 'metadata.mat');
            save(metadata_save_filename, 'metadata');
        end

        function [saved] = check_if_saved(self)
             saved = 1;
             if strcmp(self.doc.save_filename,'') == 1
                 saved = 0;
                if ~isempty(self.view)
                    self.create_error_box("Please load an experiment before running.");
                else
                    disp('Failed: No saved experiment is loaded.');
                end
            end
        end

        function [success] = create_folder(self, path, foldername)
            [success, msg] = mkdir(path, foldername);
            if success == 0
                disp(msg);
            end
        end

        function [hasFiles] = check_for_files(self, folderpath)
            hasFiles = 0;
            items = dir(folderpath);
            for i = 1:length(items)
                itemnames{i} = items(i).name;
            end
            for i = 1:length(items)
                folders(i) = items(i).isdir;
            end
            folders(~folders) = [];
            if length(itemnames) > length(folders)
                hasFiles = 1;
                if ~isempty(self.view)
                    self.create_error_box('Results folder of that fly name already has data in it\n');
                else
                    disp('Failed: That fly already has data in the results folder.');
                end
            end
        end

        function [active_ao_channels] = get_active_ao(self)
            pretrial = self.doc.pretrial;
            block_trials = self.doc.block_trials;
            intertrial = self.doc.intertrial;
            posttrial = self.doc.posttrial;

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
            %correctly to be passed to the controller
            j = 1;
            active_ao_channels = [];
            for channel = 1:4
                if channels(channel) == 1
                    active_ao_channels(j) = channel_nums(channel);
                    j = j + 1;
                end
            end
        end

        function [parameters] = get_parameters_struct(self)
            pretrial = self.doc.pretrial;
            intertrial = self.doc.intertrial;
            posttrial = self.doc.posttrial;
            block_trials = self.doc.block_trials;

            %This function returns an array, active_ao_channels, with the
            %numbers of the active ao channels (ie [0 2 3] means ao
            %channels 1, 3, and 4 are active.
            active_ao_channels = self.get_active_ao();

            %Create an array for each section with the indices of their
            %aofunctions (no ao function returns an index of 0)

            [pretrial_ao_indices, intertrial_ao_indices, ao_indices, ...
                posttrial_ao_indices] = self.get_active_ao_indices(active_ao_channels);

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
            parameters.fly_name = self.model.get_fly_name();
            parameters.is_chan1 = self.doc.is_chan1;
            parameters.is_chan2 = self.doc.is_chan2;
            parameters.is_chan3 = self.doc.is_chan3;
            parameters.is_chan4 = self.doc.is_chan4;
            parameters.chan1_rate = self.doc.chan1_rate;
            parameters.chan2_rate = self.doc.chan2_rate;
            parameters.chan3_rate = self.doc.chan3_rate;
            parameters.chan4_rate = self.doc.chan4_rate;

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

            parameters.exp_order = exp_order;
        end

        function [pre, inter, block, post] = get_active_ao_indices(self, active_ao_channels)
            pre = [];
            inter = [];
            block = [];
            post = [];
            for i = 1:length(active_ao_channels)
                channel_num = active_ao_channels(i);
                pre(i) = self.doc.get_ao_index(self.doc.pretrial{channel_num + 4});
                inter(i) = self.doc.get_ao_index(self.doc.intertrial{channel_num + 4});
                post(i) = self.doc.get_ao_index(self.doc.posttrial{channel_num + 4});
            end
            for m = 1:length(active_ao_channels)
                channel_num = active_ao_channels(m);
                for k = 1:length(self.doc.block_trials(:,1))
                    block(k,m) = self.doc.get_ao_index(self.doc.block_trials{k, channel_num + 4});
                end
            end
            %Fill in zeros for the ao indices for inactive channels            
            [pre, inter, block, post] = self.fill_inactive_ao_indices(active_ao_channels, pre, inter, block, post);
        end

        function [pre, inter, block, post] = fill_inactive_ao_indices(self, active_ao_channels, pre, inter, block, post)
            if ~isempty(active_ao_channels)
                if sum(ismember(active_ao_channels,0)) == 0
                    new_pre = [0 pre];
                    new_inter = [0 inter];
                    new_post = [0 post];
                    for trial = 1:length(self.doc.block_trials(:,1))
                        new_block(trial,:) = [0 block(trial,:)];
                    end
                    pre = new_pre;
                    inter = new_inter;
                    post = new_post;
                    block = new_block;
                end
                if sum(ismember(active_ao_channels,1)) == 0
                    new_pre = [];
                    new_inter = [];
                    new_post = [];
                    new_block = [];
                    if length(pre) >= 2
                        new_pre = [pre(1) 0 pre(2:end)];
                        new_inter = [inter(1) 0 inter(2:end)];
                        new_post = [post(1) 0 post(2:end)];
                        for trial = 1:length(self.doc.block_trials(:,1))
                            new_block(trial,:) = [block(trial,1) 0  block(trial,2:end)];
                        end
                    else
                        new_pre = [pre(1) 0];
                        new_inter = [inter(1) 0];
                        new_post = [post(1) 0];

                        for trial = 1:length(self.doc.block_trials(:,1))
                            new_block(trial,:) = [block(trial,1) 0];
                        end
                    end
                    pre = new_pre;
                    inter = new_inter;
                    post = new_post;
                    block = new_block;
                end

                if sum(ismember(active_ao_channels,2)) == 0
                    new_pre = [];
                    new_inter = [];
                    new_post = [];
                    new_block = [];
                    if length(pre) >= 3
                        new_pre = [pre(1:2) 0 pre(end)];
                        new_inter = [inter(1:2) 0 inter(end)];
                        new_post = [post(1:2) 0 post(end)];
                        for trial = 1:length(self.doc.block_trials(:,1))
                            new_block(trial,:) = [block(trial,1:2) 0  block(trial,end)];
                        end
                    else
                        new_pre = [pre(1:2) 0];
                        new_inter = [inter(1:2) 0];
                        new_post = [post(1:2) 0];
                        for trial = 1:length(self.doc.block_trials(:,1))
                            new_block(trial,:) = [block(trial,1:2) 0];
                        end
                    end
                    pre = new_pre;
                    inter = new_inter;
                    post = new_post;
                    block = new_block;
                end

                if sum(ismember(active_ao_channels,3)) == 0
                    new_pre = [];
                    new_inter = [];
                    new_post = [];
                    new_block = [];

                    new_pre = [pre(1:3) 0];
                    new_inter = [inter(1:3) 0];
                    new_post = [post(1:3) 0];
                    for trial = 1:length(self.doc.block_trials(:,1))
                        new_block(trial,:) = [block(trial,1:3) 0];
                    end
                    pre = new_pre;
                    inter = new_inter;
                    post = new_post;
                    block = new_block;
                end
            else
                pre = [0 0 0 0];
                inter = [0 0 0 0];
                post = [0 0 0 0];
                for trial = 1:length(self.doc.block_trials(:,1))
                    block(trial,:) = [0 0 0 0];
                end
            end
        end

        function reschedule_bad_condition(self, cond)
            added_conds = [self.model.rescheduled_conditions cond];
            self.model.set_rescheduled_conditions(added_conds);
        end

        function run_single_fly_DA(self, settings, save_path, trial_options, exp_folder)
            [~, settings_filename, settings_ext] = fileparts(settings);
 %           [~, proc_name, ~] = fileparts(proc_file);

            %Load variables from the generic single-fly settings file.
            load(settings);
            process_settings = load(exp_settings.path_to_processing_settings);
            proc_settings = process_settings.settings;

            %Check to make sure the variables were loaded correclty, return
            %if not.
            if exist('exp_settings') ~= 1
                if ~isempty(self.view)
                    self.create_error_box("Unable to read all variables from the settings file. Please check it is formatted correctly.");
                else
                    disp("Data analysis not performed. Settings file incomplete.");
                end
                return;
            end
            if exist('save_settings') ~= 1
                if ~isempty(self.view)
                    self.create_error_box("Unable to read all variables from the settings file. Please check it is formatted correctly.");
                else
                    disp("Data analysis not performed. Settings file incomplete.");
                end
                return;
            end
            if exist('proc_settings') ~= 1
                if ~isempty(self.view)
                    self.create_error_box("Unable to find processing info in settings file. Make sure data analysis settings file is up to date.");
                else
                    disp("Data analysis not performed. Settings file missing processing info.");
                end
                return;
            end

            %Update settings to reflect this particular fly.
            %exp_settings.path_to_processing_settings = proc_file;
            exp_settings.genotypes = [string(self.model.get_fly_genotype())];
            exp_settings.exp_folder = {save_path};
            exp_settings.fly_path = save_path;
            save_settings.save_path = save_path;
            save_settings.report_path = fullfile(save_path, 'DA_report.pdf');

            new_settings_file = [settings_filename, settings_ext];
            new_settings_path = fullfile(save_path, new_settings_file);

            %Save a new data analysis settings .mat file in this fly's
            %results folder.
            save(new_settings_path,'exp_settings', 'histogram_plot_settings', ...
                'histogram_annotation_settings','CL_hist_plot_settings','proc_settings',...
                'timeseries_plot_settings', 'TC_plot_settings', 'MP_plot_settings', ...
                'pos_plot_settings', 'save_settings','comp_settings', 'gen_settings');

            da = create_data_analysis_tool(new_settings_path, '-single', '-hist', '-tsplot');
            da.run_analysis();
        end

        function trial_options = get_trial_options(self)
            if ~isempty(self.doc.pretrial{1})
                is_pretrial = 1;
            else
                is_pretrial = 0;
            end
            if ~isempty(self.doc.intertrial{1})
                is_intertrial = 1;
            else
                is_intertrial = 0;
            end
            if ~isempty(self.doc.posttrial{1})
                is_posttrial = 1;
            else
                is_posttrial = 0;
            end

            trial_options = [is_pretrial, is_intertrial, is_posttrial];
        end

        function [trials] = get_num_trials(self)
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
        end

        function run_pdf_report(self, fly_results_folder, trial_options, processed_filename)
            [plot_path, plot_name, plot_ext] = fileparts(self.model.get_plotting_file());
            plotting_command = plot_name + "(metadata.fly_results_folder, metadata.trial_options)";
            plot_file = strcat(plot_name, plot_ext);
            %Put all metadata in a struct to be passed to the
            %function which creates the pdf.

            metadata = struct;
            metadata.experimenter = self.model.get_experimenter();
            metadata.experiment_name = self.doc.experiment_name;
            metadata.run_protocol_file = self.model.get_run_protocol_file();

            if self.model.get_experiment_type() == 1
                metadata.experiment_type = "Flight";
            elseif self.model.get_experiment_type() == 2
                metadata.experiment_type = "Camera Walk";
            elseif self.model.get_experiment_type() == 3
                metadata.experiment_type = "Chip Walk";
            end

            metadata.fly_name = self.model.get_fly_name();
            metadata.fly_genotype = self.model.get_fly_genotype();
            if ~isempty(self.view)
                metadata.timestamp = self.view.date_and_time_box.Value;
            else
                metadata.timestamp = char(datetime('now', 'Format', 'MM-dd-yyyy HH:mm:SS'));
            end
            metadata.fly_age = self.model.get_fly_age();
            metadata.fly_sex = self.model.get_fly_sex();
            metadata.experiment_temp = self.model.get_experiment_temp();
            metadata.rearing_protocol = self.model.get_rearing_protocol();
            metadata.plotting_file = self.model.get_plotting_file();
            metadata.processing_file = self.model.get_processing_file();
            if self.model.get_do_plotting() == 1
                metadata.do_plotting = "Yes";
            elseif self.model.get_do_plotting() == 0
                metadata.do_plotting = "No";
            end
            if self.model.get_do_processing() == 1
                metadata.do_processing = "Yes";
            elseif self.model.get_do_processing() == 0
                metadata.do_processing = "No";
            end
            metadata.plotting_command = plotting_command;

            metadata.fly_results_folder = fly_results_folder;
            metadata.trial_options = trial_options;
            metadata.comments = self.model.get_metadata_comments();
            metadata.light_cycle = self.model.get_light_cycle();

            %assigns the metadata struct to metadata in the base
            %workspace so publish can use it.
            assignin('base','metadata',metadata);
            assignin('base','fly_results_folder',fly_results_folder);
            assignin('base','trial_options',trial_options);
            assignin('base','processed_filename', processed_filename);

            %publishes the output (but not code) "create_pdf_script" to
            %a pdf file.
            options.codeToEvaluate = sprintf('%s(%s,%s,%s,%s)',plot_name,'fly_results_folder','trial_options','metadata','processed_filename');
            options.format = 'pdf';
            options.outputDir = sprintf('%s',fly_results_folder);
            options.showCode = false;
            publish(plot_file,options);

            plot_filename = strcat(plot_name,'.pdf');
            new_plot_filename = strcat(self.model.get_fly_name(),'.pdf');
            pdf_path = fullfile(fly_results_folder,plot_filename);
            new_pdf_path = fullfile(fly_results_folder,new_plot_filename);
            movefile(pdf_path, new_pdf_path);
        end

        function set_is_ended_early(self, new_val)
            if new_val == 0 || new_val == 1
                self.is_ended_early = new_val;
            else
                disp("There was an error with the button to end an experiment early. Please try again");
                self.is_ended_early = 0;
            end
        end

        function value = get_is_ended_early(self)
            value = self.is_ended_early;
        end

        function ts = get_timestamp(self)
            ts = self.model.get_timestamp();
        end

        function num_attempts = get_num_attempts(self)
            num_attempts = self.model.get_num_attempts_bad_conds();
        end

        function OL_function = get_custom_OL_function(self)
            OL_function = self.fb_model.get_OL_function();
        end

        function CL_function = get_custom_CL_function(self)
            CL_function = self.fb_model.get_CL_function();
        end

        function run_file_desc = get_run_file_desc(self)
            run_file_desc = self.model.get_run_file_desc();
        end

        function value = get_combine_tdms(self)
            value = self.model.get_combine_tdms();
        end

        function update_combine_tdms(self, value)
            self.model.set_combine_tdms(value);
        end

        function value = get_convert_tdms(self)
            value = self.model.get_convert_tdms();
        end

        %% Getters

        function value = get_model(self)
            value = self.model;
        end
        function value = get_doc(self)
            value = self.doc;
        end
        function value = get_settings_con(self)
            value = self.settings_con;
        end
        function value = get_view(self)
            value = self.view;
        end
        function value = get_fb_model(self)
            value = self.fb_model;
        end
        function value = get_fb_view(self)
            value = self.fb_view;
        end
        function value = get_current_mode(self)
            value = self.current_mode;
        end
        function value = get_current_pat(self)
            value = self.current_pat;
        end
        function value = get_current_pos(self)
            value = self.current_pos;
        end
        function value = get_current_ao1(self)
            value = self.current_ao1;
        end
        function value = get_current_ao2(self)
            value = self.current_ao2;
        end
        function value = get_current_ao3(self)
            value = self.current_ao3;
        end
        function value = get_current_ao4(self)
            value = self.current_ao4;
        end
        function value = get_current_frInd(self)
            value = self.current_frInd;
        end
        function value = get_current_frRate(self)
            value = self.current_frRate;
        end
        function value = get_current_gain(self)
            value = self.current_gain;
        end
        function value = get_current_offset(self)
            value = self.current_offset;
        end
        function value = get_current_duration(self)
            value = self.current_duration;
        end
        function value = get_elapsed_time(self)
            value = self.elapsed_time;
        end
        function value = get_remaining_time(self)
            value = self.remaining_time(self);
        end
        function value = get_is_aborted(self)
            value = self.is_aborted;
        end
        function value = get_is_paused(self)
            value = self.is_paused;
        end
        function value = get_settings(self)
            value = self.settings;
        end

        %% Setters

        function set_model(self, value)
            self.model = value;
        end
        function set_doc(self, value)
            self.doc = value;
        end
        function set_settings_con(self, value)
            self.settings_con = value;
        end
        function set_view(self, value)
            self.view = value;
        end
        function set_fb_model(self, value)
            self.fb_model = value;
        end
        function set_fb_view(self, value)
            self.fb_view = value;
        end
        function set_current_mode(self, value)
            self.current_mode = value;
        end
        function set_current_pat(self, value)
            self.current_pat = value;
        end
        function set_current_pos(self, value)
            self.current_pos = value;
        end
        function set_current_ao1(self, value)
            self.current_ao1 = value;
        end
        function set_current_ao2(self, value)
            self.current_ao2 = value;
        end
        function set_current_ao3(self, value)
            self.current_ao3 = value;
        end
        function set_current_ao4(self, value)
            self.current_ao4 = value;
        end
        function set_current_frInd(self, value)
            self.current_frInd = value;
        end
        function set_current_frRate(self, value)
            self.current_frRate = value;
        end
        function set_current_gain(self, value)
            self.current_gain = value;
        end
        function set_current_offset(self, value)
            self.current_offset = value;
        end
        function set_current_duration(self, value)
            self.current_duration = value;
        end
        function set_elapsed_time(self, value)
            self.elapsed_time = value;
        end
        function set_remaining_time(self, value)
            self.remaining_time = value;
        end
        function set_is_aborted(self, value)
            self.is_aborted = value;
        end
        function set_is_paused(self, value)
            self.is_paused = value;
        end
        function set_settings(self, value)
            self.settings = value;
        end

    end
end