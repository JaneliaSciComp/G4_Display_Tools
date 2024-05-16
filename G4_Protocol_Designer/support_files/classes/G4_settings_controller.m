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
            self.view.config_filepath_textbox.String = self.model.settings.Configuration_Filepath;
            self.view.sheet_key_textbox.String = self.model.settings.Google_Sheet_Key;
            self.view.experimenter_gid_textbox.String = self.model.settings.Users_Sheet_GID;
            self.view.age_gid_textbox.String = self.model.settings.Fly_Age_Sheet_GID;
            self.view.sex_gid_textbox.String = self.model.settings.Fly_Sex_Sheet_GID;
            self.view.geno_gid_textbox.String = self.model.settings.Fly_Geno_Sheet_GID;
            self.view.temp_gid_textbox.String = self.model.settings.Experiment_Temp_Sheet_GID;
            self.view.rearing_gid_textbox.String = self.model.settings.Rearing_Protocol_Sheet_GID;
            self.view.light_gid_textbox.String = self.model.settings.Light_Cycle_Sheet_GID;
            self.view.run_protocol_textbox.String = self.model.settings.run_protocol_file;
            self.view.plot_protocol_textbox.String = self.model.settings.plotting_file;
            self.view.proc_protocol_textbox.String = self.model.settings.processing_file;
            self.view.flight_test_textbox.String = self.model.settings.test_protocol_file_flight;
            self.view.walkCam_test_textbox.String = self.model.settings.test_protocol_file_camWalk;
            self.view.walkChip_test_textbox.String = self.model.settings.test_protocol_file_chipWalk;
            self.view.test_run_textbox.String = self.model.settings.test_run_protocol_file;
            self.view.test_process_textbox.String = self.model.settings.test_processing_file;
            self.view.test_plot_textbox.String = self.model.settings.test_plotting_file;
            self.view.disabled_color_textbox.String = self.model.settings.Uneditable_Cell_Color;
            self.view.disabled_text_textbox.String = self.model.settings.Uneditable_Cell_Text;
        end
        
        %% Functions to check input values are correct. If valid, these 
        %  functions then call the model to set the new values
        function failed = check_valid_config(self, filepath)
            failed = 0;
            if ~isempty(filepath)
                if ischar(filepath)
                     if isfile(filepath)
                        self.model.set_new_setting('Configuration_Filepath', filepath);
                     else
                         self.create_error_box("The configuration file does not exist.");
                         failed = 1;
                     end
                else
                    self.create_error_box("The configuration file input is not a character array.");
                    failed = 1;
                end
            else
                self.create_error_box("The configuration file input cannot be empty.");
                failed = 1;
            end
        end
        
        function failed = check_valid_run_file(self, filepath)
            failed = 0;
            if ~isempty(filepath)
                if ischar(filepath)
                    if isfile(filepath)
                        self.model.set_new_setting('run_protocol_file', filepath);
                    else
                        self.create_error_box("The file path for 'Default Run Protocol' does not exist.");
                        failed = 1;
                    end
                else
                    self.create_error_box("The default run protocol input is not a character array.");
                    failed = 1;
                end
            else
                self.model.set_new_setting('run_protocol_file', filepath);
                
            end
        end
        
        function failed = check_valid_plot_file(self, filepath)
            failed = 0;
            if ~isempty(filepath)
                if ischar(filepath)
                    if isfile(filepath)
                        self.model.set_new_setting('plotting_file', filepath);
                    else
                        self.create_error_box("The file path for 'Default Plotting Protocol' does not exist.");
                        failed = 1;
                    end
                else
                    self.create_error_box("The default plotting file input is not a character array.");
                    failed = 1;
                end
            else
                self.model.set_new_setting('plotting_file', filepath);
                
            end
        end
        
        function failed = check_valid_proc_file(self, filepath)
            failed = 0;
            if ~isempty(filepath)
                if ischar(filepath)
                    if isfile(filepath)
                        self.model.set_new_setting('processing_file', filepath);
                    else
                        self.create_error_box("The file path for 'Default Processing Protocol' does not exist.");
                        failed = 1;
                    end
                else
                    self.create_error_box("The default processing file input is not a character array.");
                    failed = 1;
                end
            else
                self.model.set_new_setting('processing_file', filepath);
            end
        end
        
        function failed = check_valid_flight_file(self, filepath)
            failed = 0;
            if ~isempty(filepath)
                if ischar(filepath)
                    if isfile(filepath)
                        self.model.set_new_setting('test_protocol_file_flight', filepath);
                    else
                        self.create_error_box("The file path for 'Default Flight Test Protocol' does not exist.");
                        failed = 1;
                    end
                else
                    self.create_error_box("The flight test protocol input is not a character array.");
                    failed = 1;
                end
            else
                self.model.set_new_setting('test_protocol_file_flight', filepath);
            end
        end
        
        function failed = check_valid_camWalk_file(self, filepath)
            failed = 0;
            if ~isempty(filepath)
                if ischar(filepath)
                    if isfile(filepath)
                        self.model.set_new_setting('test_protocol_file_camWalk', filepath);
                    else
                        self.create_error_box("The file path for 'Default Camera Walk Test Protocol' does not exist.");
                        failed = 1;
                    end
                else
                    self.create_error_box("The camera walk test protocol input is not a character array.");
                    failed = 1;
                end
            else
                self.model.set_new_setting('test_protocol_file_camWalk', filepath);
            end
        end
        
        function failed = check_valid_chipWalk_file(self, filepath)
            failed = 0;
             if ~isempty(filepath)
                if ischar(filepath)
                    if isfile(filepath)
                        self.model.set_new_setting('test_protocol_file_chipWalk', filepath);
                    else
                        self.create_error_box("The file path for 'Default Chip Walk Test Protocol' does not exist.");
                        failed = 1;
                    end
                else
                    self.create_error_box("The chip walk test protocol input is not a character array.");
                    failed = 1;
                end
             else
                 self.model.set_new_setting('test_protocol_file_chipWalk', filepath);
            end
        end
        
        function failed = check_valid_test_run(self, filepath)
            failed = 0;
            if ~isempty(filepath)
                if ischar(filepath)
                    if isfile(filepath)
                        self.model.set_new_setting('test_run_protocol_file', filepath);
                    else
                        self.create_error_box("The file path for 'Default Run Protocol for Test' does not exist.");
                        failed = 1;
                    end
                else
                    self.create_error_box("The default test run protocol input is not a character array.");
                    failed = 1;
                end
            else
                self.model.set_new_setting('test_run_protocol_file', filepath);
            end
        end
        
        function failed = check_valid_test_process(self, filepath)
            failed = 0;
            if ~isempty(filepath)
                if ischar(filepath)
                    if isfile(filepath)
                        self.model.set_new_setting('test_processing_file', filepath);
                    else
                        self.create_error_box("The file path for 'Default Processing File for Test' does not exist.");
                        failed = 1;
                    end
                else
                    self.create_error_box("The default test processing file input is not a character array.");
                    failed = 1;
                end
            else
                self.model.set_new_setting('test_processing_file', filepath);
            end
        end
        
        function failed = check_valid_test_plot(self, filepath)
            failed = 0;
            if ~isempty(filepath)
                if ischar(filepath)
                    if isfile(filepath)
                        self.model.set_new_setting('test_plotting_file', filepath);
                    else
                        self.create_error_box("The file path for 'Default Plotting File for Test' does not exist.");
                        failed = 1;
                    end
                else
                    self.create_error_box("The default test plotting file input is not a character array.");
                    failed = 1;
                end
            else
                self.model.set_new_setting('test_plotting_file', filepath);
            end
        end

        function failed = check_valid_color(self, string)
            failed = 0;
            if regexp(string, '\<#[a-zA-Z0-9]{6}\>')
                self.model.set_new_setting('Uneditable_Cell_Color', string);
            else
                self.create_error_box("Make sure your color is in 6 digit hexidecimal color code format (e.g. '#CC3300').");
                failed = 1;
            end
        end
        
        %% These functions set new values like those above, but have no constraints on the values
        function failed = check_valid_text(self, string)
            failed = 0;
            self.model.set_new_setting('Uneditable_Cell_Text', string);            
        end
        
        function failed = check_valid_key(self, string)
            failed = 0;
            self.model.set_new_setting('Google_Sheet_Key', string);           
        end
        
        function failed = check_valid_usersGID(self, string)
            failed = 0;
            self.model.set_new_setting('Users_Sheet_GID', string)
        end
        
        function failed = check_valid_ageGID(self, string)
            failed = 0;
            self.model.set_new_setting('Fly_Age_Sheet_GID', string)
        end
        
        function failed = check_valid_sexGID(self, string)
            failed = 0;
            self.model.set_new_setting('Fly_Sex_Sheet_GID', string)
        end
        
        function failed = check_valid_genoGID(self, string)
            failed = 0;
            self.model.set_new_setting('Fly_Geno_Sheet_GID', string)
        end
        
        function failed = check_valid_tempGID(self, string)
            failed = 0;
            self.model.set_new_setting('Experiment_Temp_Sheet_GID', string)
        end
        
        function failed = check_valid_rearingGID(self, string)
            failed = 0;
            self.model.set_new_setting('Rearing_Protocol_Sheet_GID', string)
        end
        
        function failed = check_valid_lightGID(self, string)
            failed = 0;
            self.model.set_new_setting('Light_Cycle_Sheet_GID', string)
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