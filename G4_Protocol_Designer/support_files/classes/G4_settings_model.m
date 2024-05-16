classdef G4_settings_model < handle

    properties
        
        settings_filepath
        settings_data
        % config_filepath_
        % metadata_sheet_key_
        % gids_
        % default_run_protocol_
        % default_plot_protocol_
        % default_proc_protocol_
        % flight_test_protocol_
        % cam_walk_test_protocol_
        % chip_walk_test_protocol_
        % test_run_protocol_
        % test_process_file_
        % test_plot_file_
        % uneditable_cell_color_
        % uneditable_cell_text_

        
        list_of_setting_strings
        list_of_settings_needed
        list_of_metadata_fields
        list_of_gid_strings
        
        lines_to_match

        settings
    
    end

    % properties (Dependent)
    % 
    %     settings_filepath
    %     settings_data
    %     % config_filepath
    %     % metadata_sheet_key
    %     % gids
    %     % default_run_protocol
    %     % default_plot_protocol
    %     % default_proc_protocol
    %     % flight_test_protocol
    %     % cam_walk_test_protocol
    %     % chip_walk_test_protocol
    %     % test_run_protocol
    %     % test_process_file
    %     % test_plot_file
    %     % uneditable_cell_color
    %     % uneditable_cell_text
    % 
    %     list_of_setting_strings
    %     list_of_settings_needed
    %     list_of_metadata_fields
    %     list_of_gid_strings
    % 
    %     lines_to_match
    % 
    % end
    
    
    methods
        
        %% Constructor
        function self = G4_settings_model(varargin)
            
            self.settings = G4_Protocol_Designer_Settings();
            %% THESE THINGS must be updated accordingly if the settings file is changed
            
            %This struct must include every occupied line from the settings file
            self.lines_to_match = struct;
            
            %These two cell arrays will constitute the fields and values of
            %hte lines_to_match struct. They must be in matching order. 
            % fields = {'config', 'key', 'run', 'proc', 'plot', 'flight', ...
            %     'cam', 'chip', 'testrun', 'testproc', 'testplot', 'color', 'text', 'usersGID', 'ageGID', ...
            %     'sexGID', 'genoGID', 'tempGID', 'rearingGID', 'lightGID', };
            % lines = {'Configuration_Filepath', 'Google_Sheet_Key',  ...
            %     'run_protocol_file', 'processing_file', 'plotting_file', ...
            %     'test_protocol_file_flight', 'test_protocol_file_camWalk', ...
            %     'test_protocol_file_chipWalk', 'test_run_protocol_file', ...
            %     'test_processing_file', 'test_plotting_file', 'Uneditable_Cell_Color', ...
            %     'Uneditable_Cell_Text','Users_Sheet_GID', ...
            %     'Fly_Age_Sheet_GID', 'Fly_Sex_Sheet_GID', 'Fly_Geno_Sheet_GID', ...
            %     'Experiment_Temp_Sheet_GID', 'Rearing_Protocol_Sheet_GID', 'Light_Cycle_Sheet_GID',};

            %These strings must match the corresponding variable name in
            %the settings function.
            %self.list_of_setting_strings = lines(1:13);
            %self.list_of_gid_strings = lines(14:end);
            
            %These strings must match the class property names they
            %correspond to.
            % self.list_of_settings_needed = {'config_filepath', 'metadata_sheet_key', ...
            %     'default_run_protocol', 'default_proc_protocol', 'default_plot_protocol', ...
            %      'flight_test_protocol', 'cam_walk_test_protocol', 'chip_walk_test_protocol', ...
            %      'test_run_protocol', 'test_process_file', 'test_plot_file', ...
            %      'uneditable_cell_color', 'uneditable_cell_text'};
             
             %These names used as struct fields to store all the GID values
             %- if metadata fields are added or subtracted, change this to
             %match
            %self.list_of_metadata_fields = {'experimenter', 'fly_age', 'fly_sex', 'fly_geno', 'exp_temp', 'rearing', 'light_cycle'};
            
            %% Below here should not be changed------------------------------
            settings_filename = 'G4_Protocol_Designer_Settings.m';
            self.settings_filepath = fileparts(which(settings_filename));
            self.settings_filepath = fullfile(self.settings_filepath, settings_filename);
            self.settings_data = strtrim(regexp( fileread(settings_filename),'\n','split'));
            % self.gids = struct;

            %Set all non - GID property values
            % if length(self.list_of_setting_strings) ~= length(self.list_of_settings_needed)
            %     error("The list of items to pull from the settings file does not match with the number of settings needed. Please check G4_settings_model.m");
            % 
            % end
            % for i = 1:length(self.list_of_setting_strings)
            %     [path, index] = self.get_setting(self.list_of_setting_strings{i});
            %     self.(self.list_of_settings_needed{i}) = strtrim(self.settings_data{path}(index:end));
            % end
            % 
            %Put all GID values for metadata tabs in the Google Sheets in a
            %struct called gids, with fieldnames reflecting the metadata
            %field.
            % if length(self.list_of_gid_strings) ~= length(self.list_of_metadata_fields)
            %     error("The number of GID values to pull from the settings file doesn't match the number of metadata fields needed. Check G4_settings_model.m");
            % end
            % for i = 1:length(self.list_of_metadata_fields)
            %     [path, index] = self.get_setting(self.list_of_gid_strings{i});
            %     self.gids.(self.list_of_metadata_fields{i}) = strtrim(self.settings_data{path}(index:end));
            % end
            % 
            %create a lines to match struct so one function can set any
            %setting in the file
            % for i = 1:length(fields)
            %     self.lines_to_match.(fields{i}) = lines{i};
            % end
            
        end
        
        % function [path, index] = get_setting(self, string_to_find)
        % 
        %     last_five = string_to_find(end-5:end);
        %     path = find(contains(self.settings_data, string_to_find));
        %     index = strfind(self.settings_data{path},last_five) + 5;
        % 
        % end
        
        %Sets the new value to the appropriate setting property and then
        %calls the function to update the file. Value must be a character
        %array or a number.
        function set_new_setting(self, line_to_match, value)
            line_to_match = ['settings.', line_to_match, ' = '];
            line = contains(self.settings_data,line_to_match);
            if ischar(value)
                value = ['"',value,'"'];
            else
                value = num2str(value);
            end
            new_line = [line_to_match, value, ';'];
            self.settings_data{line} = new_line;
            self.update_settings_file();
            self.settings = G4_Protocol_Designer_Settings();
        
        end

        function update_settings_file(self)
           
            fid = fopen(self.settings_filepath,'wt');
            fprintf(fid, '%s\n', self.settings_data{:});
            fclose(fid);
            
        end
        
       

    end

end