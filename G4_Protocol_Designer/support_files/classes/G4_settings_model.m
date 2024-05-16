classdef G4_settings_model < handle

    properties
        
        settings_filepath
        settings_data
        settings
    
    end

    methods
        
        %% Constructor
        function self = G4_settings_model(varargin)
            
            self.settings = G4_Protocol_Designer_Settings(); 
            settings_filename = 'G4_Protocol_Designer_Settings.m';
            self.settings_filepath = fileparts(which(settings_filename));
            self.settings_filepath = fullfile(self.settings_filepath, settings_filename);
            self.settings_data = strtrim(regexp( fileread(settings_filename),'\n','split'));
           
        end

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