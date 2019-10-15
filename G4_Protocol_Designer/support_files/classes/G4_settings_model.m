classdef G4_settings_model < handle

    properties
        
        settings_filepath_
        settings_data_
        config_filepath_
        metadata_sheet_key_
        gids_
        default_run_protocol_
        default_plot_protocol_
        default_proc_protocol_
        flight_test_protocol_
        cam_walk_test_protocol_
        chip_walk_test_protocol_
        uneditable_cell_color_
        uneditable_cell_text_
        overlapping_graphs_
        
        list_of_setting_strings_
        list_of_settings_needed_
        list_of_metadata_fields_
        list_of_gid_strings_
        
        lines_to_match_
    
    end

    properties (Dependent)
        
        settings_filepath
        settings_data
        config_filepath
        metadata_sheet_key
        gids
        default_run_protocol
        default_plot_protocol
        default_proc_protocol
        flight_test_protocol
        cam_walk_test_protocol
        chip_walk_test_protocol
        uneditable_cell_color
        uneditable_cell_text
        overlapping_graphs
        
        list_of_setting_strings
        list_of_settings_needed
        list_of_metadata_fields
        list_of_gid_strings
        
        lines_to_match
   
    end
    
    
    methods
        
        %% Constructor
        function self = G4_settings_model(varargin)
            
            %% THESE THINGS must be updated accordingly if the settings file is changed
            
            %This struct must include every occupied line from the settings file
            self.lines_to_match = struct;
            
            %These two cell arrays will constitute the fields and values of
            %hte lines_to_match struct. They must be in matching order. 
            fields = {'config', 'key', 'run', 'proc', 'plot', 'flight', ...
                'cam', 'chip', 'overlap', 'color', 'text', 'usersGID', 'ageGID', ...
                'sexGID', 'genoGID', 'tempGID', 'rearingGID', 'lightGID', };
            lines = {'Configuration File Path: ', 'Metadata Google Sheet key: ',  ...
                'Default run protocol file: ', 'Default processing file: ', 'Default plotting file: ', ...
                'Flight test protocol file: ', 'Camera walk test protocol file: ', ...
                'Chip walk test protocol file: ', 'Overlapping graphs: ', 'Color to fill uneditable cells: ', ...
                'Text to fill uneditable cells: ','Users Sheet GID: ', ...
                'Fly Age Sheet GID: ', 'Fly Sex Sheet GID: ', 'Fly Geno Sheet GID: ', ...
                'Experiment Temp Sheet GID: ', 'Rearing Protocol Sheet GID: ', 'Light Cycle Sheet GID: ',};

            %These strings must match the string
            %preceding the corresponding value in the settings file -
            %including the space after the :
            self.list_of_setting_strings = lines(1:11);
            self.list_of_gid_strings = lines(12:end);
            
            %These strings must match the class property names they
            %correspond to.
            self.list_of_settings_needed = {'config_filepath', 'metadata_sheet_key', ...
                'default_run_protocol', 'default_proc_protocol', 'default_plot_protocol', ...
                 'flight_test_protocol', 'cam_walk_test_protocol', 'chip_walk_test_protocol', ...
                 'overlapping_graphs', 'uneditable_cell_color', 'uneditable_cell_text'};
             
             %These names used as struct fields to store all the GID values
             %- if metadata fields are added or subtracted, change this to
             %match
            self.list_of_metadata_fields = {'experimenter', 'fly_age', 'fly_sex', 'fly_geno', 'exp_temp', 'rearing', 'light_cycle'};
            
            %% Below here should not be changed------------------------------
            settings_filename = 'G4_Protocol_Designer_Settings.m';
            self.settings_filepath = fileparts(which(settings_filename));
            self.settings_filepath = fullfile(self.settings_filepath, settings_filename);
            self.settings_data = strtrim(regexp( fileread(settings_filename),'\n','split'));
            self.gids = struct;

            %Set all non - GID property values
            if length(self.list_of_setting_strings) ~= length(self.list_of_settings_needed)
                error("The list of items to pull from the settings file does not match with the number of settings needed. Please check G4_settings_model.m");
                
            end
            for i = 1:length(self.list_of_setting_strings)
                [path, index] = self.get_setting(self.list_of_setting_strings{i});
                self.(self.list_of_settings_needed{i}) = strtrim(self.settings_data{path}(index:end));
            end
            
            %Put all GID values for metadata tabs in the google sheet in a
            %struct called gids, with fieldnames reflecting the metadata
            %field.
            if length(self.list_of_gid_strings) ~= length(self.list_of_metadata_fields)
                error("The number of GID values to pull from the settings file doesn't match the number of metadata fields needed. Check G4_settings_model.m");
            end
            for i = 1:length(self.list_of_metadata_fields)
                [path, index] = self.get_setting(self.list_of_gid_strings{i});
                self.gids.(self.list_of_metadata_fields{i}) = strtrim(self.settings_data{path}(index:end));
            end
            
            %create a lines to match struct so one function can set any
            %setting in the file
            for i = 1:length(fields)
                self.lines_to_match.(fields{i}) = lines{i};
            end
            
        end
        
        function [path, index] = get_setting(self, string_to_find)
            
            last_five = string_to_find(end-5:end);
            path = find(contains(self.settings_data, string_to_find));
            index = strfind(self.settings_data{path},last_five) + 5;
        
        end
        
        %Sets the new value to the appropriate setting property and then
        %calls the function to update the file
        function set_new_setting(self, line_to_match, value)

            line = contains(self.settings_data,line_to_match);
            new_line = [line_to_match, value];
            self.settings_data{line} = new_line;
            self.update_settings_file();
        
        end

        function update_settings_file(self)
           
            fid = fopen(self.settings_filepath,'wt');
            fprintf(fid, '%s\n', self.settings_data{:});
            fclose(fid);
            
        end
        
        %% Setters
        function set.settings_filepath(self, value)
            self.settings_filepath_ = value;
        end
        function set.settings_data(self, value)
            self.settings_data_ = value;
        end
        function set.config_filepath(self, value)
            self.config_filepath_ = value;
        end
        function set.metadata_sheet_key(self, value)
            self.metadata_sheet_key_ = value;
        end
        function set.gids(self, value)
            self.gids_ = value;
        end
        function set.default_run_protocol(self, value)
            self.default_run_protocol_ = value;
        end
        function set.default_plot_protocol(self, value)
            self.default_plot_protocol_ = value;
        end
        function set.default_proc_protocol(self, value)
            self.default_proc_protocol_ = value;
        end
        function set.flight_test_protocol(self, value)
            self.flight_test_protocol_ = value;
        end
        function set.cam_walk_test_protocol(self, value)
            self.cam_walk_test_protocol_ = value;
        end
        function set.chip_walk_test_protocol(self, value)
            self.chip_walk_test_protocol_ = value;
        end
        function set.uneditable_cell_color(self, value)
            self.uneditable_cell_color_ = value;
        end
        function set.uneditable_cell_text(self, value)
            self.uneditable_cell_text_ = value;
        end
        function set.overlapping_graphs(self, value)
            self.overlapping_graphs_ = value;
        end
        function set.list_of_setting_strings(self, value)
            self.list_of_setting_strings_ = value;
        end
        function set.list_of_settings_needed(self, value)
            self.list_of_settings_needed_ = value;
        end
        function set.list_of_metadata_fields(self, value)
            self.list_of_metadata_fields_ = value;
        end
        function set.list_of_gid_strings(self, value)
            self.list_of_gid_strings_ = value;
        end
        function set.lines_to_match(self, value)
            self.lines_to_match_ = value;
        end

        %% Getters
        
        function value = get.settings_filepath(self)
            value = self.settings_filepath_;
        end
        function value = get.settings_data(self)
            value = self.settings_data_;
        end
        function value = get.config_filepath(self)
            value = self.config_filepath_;
        end
        function value = get.metadata_sheet_key(self)
            value = self.metadata_sheet_key_;
        end
        function value = get.gids(self)
            value = self.gids_;
        end
        function value = get.default_run_protocol(self)
            value = self.default_run_protocol_;
        end
        function value = get.default_plot_protocol(self)
            value = self.default_plot_protocol_;
        end
        function value = get.default_proc_protocol(self)
            value = self.default_proc_protocol_;
        end
        function value = get.flight_test_protocol(self)
            value = self.flight_test_protocol_;
        end
        function value = get.cam_walk_test_protocol(self)
            value = self.cam_walk_test_protocol_;
        end
        function value = get.chip_walk_test_protocol(self)
            value = self.chip_walk_test_protocol_;
        end
        function value = get.uneditable_cell_color(self)
            value = self.uneditable_cell_color_;
        end
        function value = get.uneditable_cell_text(self)
            value = self.uneditable_cell_text_;
        end
        function value = get.overlapping_graphs(self)
            value = self.overlapping_graphs_;
        end
        function value = get.list_of_setting_strings(self)
            value = self.list_of_setting_strings_;
        end
        function value = get.list_of_settings_needed(self)
            value = self.list_of_settings_needed_;
        end
        function value = get.list_of_metadata_fields(self)
            value = self.list_of_metadata_fields_;
        end
        function value = get.list_of_gid_strings(self)
            value = self.list_of_gid_strings_;
        end
        function value = get.lines_to_match(self)
            value = self.lines_to_match_;
        end
       

    end

end