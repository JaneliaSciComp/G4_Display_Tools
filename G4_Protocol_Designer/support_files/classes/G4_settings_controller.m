classdef G4_settings_controller < handle
    
    properties
        
        model_
        view_

    end
  
    properties (Dependent)
        
        model
        view

    end

    methods

        %% Constructor
        function self = G4_settings_controller(varargin)
            %Create the model and wait for the window to be opened. 
            self.model = G4_settings_model();
        end
        
        function layout_view(self)
            %Run this when the user clicks the settings option in the
            %designer to open up the settings window
            
            self.view = G4_settings_view(self);
            
            %Don't forget to clear this out somehow when they close the
            %settings window
        end
        
        function close_window(self)
            close(self.view.fig);
        end
        
        
        function update_view(self)
            self.view.config_filepath_textbox.String = self.model.config_filepath;
            self.view.sheet_key_textbox.String = self.model.metadata_sheet_key;
            self.view.experimenter_gid_textbox.String = self.model.gids.experimenter;
            self.view.age_gid_textbox.String = self.model.gids.fly_age;
            self.view.sex_gid_textbox.String = self.model.gids.fly_sex;
            self.view.geno_gid_textbox.String = self.model.gids.fly_geno;
            self.view.temp_gid_textbox.String = self.model.gids.exp_temp;
            self.view.rearing_gid_textbox.String = self.model.gids.rearing;
            self.view.light_gid_textbox.String = self.model.gids.light_cycle;
            self.view.run_protocol_textbox.String = self.model.default_run_protocol;
            self.view.plot_protocol_textbox.String = self.model.default_plot_protocol;
            self.view.proc_protocol_textbox.String = self.model.default_proc_protocol;
            self.view.flight_test_textbox.String = self.model.flight_test_protocol;
            self.view.walkCam_test_textbox.String = self.model.cam_walk_test_protocol;
            self.view.walkChip_test_textbox.String = self.model.chip_walk_test_protocol;
            self.view.test_run_textbox.String = self.model.test_run_protocol;
            self.view.test_process_textbox.String = self.model.test_process_file;
            self.view.test_plot_textbox.String = self.model.test_plot_file;
            self.view.disabled_color_textbox.String = self.model.uneditable_cell_color;
            self.view.disabled_text_textbox.String = self.model.uneditable_cell_text;
        end
        
        %% Functions to check input values are correct. If valid, these 
        %  functions then call the model to set the new values
        function check_valid_config(self, filepath)
             if isfile(filepath)
                self.model.config_filepath = filepath;
                self.model.set_new_setting(self.model.lines_to_match.config, filepath);
             else
                 self.create_error_box("The configuration file does not exist.");
             end
        end
        
        function check_valid_run_file(self, filepath)
            if isfile(filepath)
                self.model.default_run_protocol = filepath;
                self.model.set_new_setting(self.model.lines_to_match.run, filepath);
            else
                self.create_error_box("The file path for 'Default Run Protocol' does not exist.");
            end
        end
        
        function check_valid_plot_file(self, filepath)
            if isfile(filepath)
                self.model.default_plot_protocol = filepath;
                self.model.set_new_setting(self.model.lines_to_match.plot, filepath);
            else
                self.create_error_box("The file path for 'Default Plotting Protocol' does not exist.");
            end
        end
        
        function check_valid_proc_file(self, filepath)
            if isfile(filepath)
                self.model.default_proc_protocol = filepath;
                self.model.set_new_setting(self.model.lines_to_match.proc, filepath);
            else
                self.create_error_box("The file path for 'Default Processing Protocol' does not exist.");
            end
        end
        
        function check_valid_flight_file(self, filepath)
            if any(regexpi(filepath, "insert.*here")) || isfile(filepath)
                self.model.flight_test_protocol = filepath;
                self.model.set_new_setting(self.model.lines_to_match.flight, filepath);
            else
                self.create_error_box("The file path for 'Default Flight Test Protocol' does not exist.");
            end
        end
        
        function check_valid_camWalk_file(self, filepath)
            if any(regexpi(filepath, "insert.*here")) || isfile(filepath)
                self.model.cam_walk_test_protocol = filepath;
                self.model.set_new_setting(self.model.lines_to_match.cam, filepath);
            else
                self.create_error_box("The file path for 'Default Camera Walk Test Protocol' does not exist.");
            end
        end
        
        function check_valid_chipWalk_file(self, filepath)
            if any(regexpi(filepath, "insert.*here")) || isfile(filepath)
                self.model.chip_walk_test_protocol = filepath;
                self.model.set_new_setting(self.model.lines_to_match.chip, filepath)
            else
                self.create_error_box("The file path for 'Default Chip Walk Test Protocol' does not exist.");
            end
        end
        
        function check_valid_test_run(self, filepath)
            if isfile(filepath)
                self.model.test_run_protocol = filepath;
                self.model.set_new_setting(self.model.lines_to_match.testrun, filepath);
            else
                self.create_error_box("The file path for 'Default Run Protocol for Test' does not exist.");
            end
        end
        
        function check_valid_test_process(self, filepath)
            if isfile(filepath)
                self.model.test_process_file = filepath;
                self.model.set_new_setting(self.model.lines_to_match.testproc, filepath);
            else
                self.create_error_box("The file path for 'Default Processing File for Test' does not exist.");
            end
        end
        
        function check_valid_test_plot(self, filepath)
            if isfile(filepath)
                self.model.test_plot_file = filepath;
                self.model.set_new_setting(self.model.lines_to_match.testplot, filepath);
            else
                self.create_error_box("The file path for 'Default Plotting File for Test' does not exist.");
            end
        end

        function check_valid_color(self, string)
            if regexp(string, '\<#[a-zA-Z0-9]{6}\>')
                self.model.uneditable_cell_color = string;
                self.model.set_new_setting(self.model.lines_to_match.color, string);
            else
                self.create_error_box("Make sure your color is in 6 digit hexidecimal color code format (e.g. '#CC3300').");
            end
        end
        
        %% These functions set new values like those above, but have no constraints on the values
        function check_valid_text(self, string)
            self.model.uneditable_cell_text = string;
            self.model.set_new_setting(self.model.lines_to_match.text, string);            
        end
        
        function check_valid_key(self, string)
            self.model.metadata_sheet_key = string;
            self.model.set_new_setting(self.model.lines_to_match.key, string);           
        end
        
        function check_valid_usersGID(self, string)
            self.model.gids.experimenter = string;
            self.model.set_new_setting(self.model.lines_to_match.usersGID, string)
        end
        
        function check_valid_ageGID(self, string)
            self.model.gids.fly_age = string;
            self.model.set_new_setting(self.model.lines_to_match.ageGID, string)
        end
        
        function check_valid_sexGID(self, string)
            self.model.gids.fly_sex = string;
            self.model.set_new_setting(self.model.lines_to_match.sexGID, string)
        end
        
        function check_valid_genoGID(self, string)
            self.model.gids.fly_geno = string;
            self.model.set_new_setting(self.model.lines_to_match.genoGID, string)
        end
        
        function check_valid_tempGID(self, string)
            self.model.gids.exp_temp = string;
            self.model.set_new_setting(self.model.lines_to_match.tempGID, string)
        end
        
        function check_valid_rearingGID(self, string)
            self.model.gids.rearing = string;
            self.model.set_new_setting(self.model.lines_to_match.rearingGID, string)
        end
        
        function check_valid_lightGID(self, string)
            self.model.gids.light_cycle = string;
            self.model.set_new_setting(self.model.lines_to_match.lightGID, string)
        end

        %% General error message produced when something isn't valid
        
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
        
        %% General browse function
        function new_file = browse(self,varargin)
            if ~isempty(varargin)
                [file, path] = uigetfile(varargin{1});
            else
                [file, path] = uigetfile;
            end
            
            if file == 0
                new_file = 0;
            else
                new_file = fullfile(path,file);
            end
    
        end


        
        %% Setters
        
        function set.model(self, value)
            self.model_ = value;
        end
        function set.view(self, value)
            self.view_ = value;
        end
        
        %% Getters
        
        function value = get.model(self)
            value = self.model_;
        end
        function value = get.view(self)
            value = self.view_;
        end
        
        
        
        
        
    end
    
    
    
    
end