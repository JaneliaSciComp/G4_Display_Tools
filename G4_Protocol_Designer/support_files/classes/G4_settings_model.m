classdef G4_settings_model < handle

    properties
        
        settings_filepath
        settings_data
        settings
    
    end

    methods
        
        %% Constructor
        function self = G4_settings_model(varargin)
            
           % self.settings = G4_Protocol_Designer_Settings(); 
            settings_filename = 'G4_Protocol_Designer_Settings.txt';            
            self.settings_filepath = fileparts(which(settings_filename));
            self.settings_filepath = fullfile(self.settings_filepath, settings_filename);
            self.settings_data = strtrim(regexp( fileread(settings_filename),'\n','split'));
            self.settings_data = self.settings_data((~cellfun('isempty',self.settings_data)));
            self.settings = get_settings();
           
        end

        function set_new_setting(self, line_to_match, value)

            if ischar(value)
                value = ['"',value,'"'];
            else
                value = num2str(value);
            end
            self.settings.(line_to_match) = value;

            line_to_match = ['settings.', line_to_match, ' = '];
            line = contains(self.settings_data,line_to_match);

            self.settings_data{line} = new_line;
            self.update_settings_file();

        
        end

        function update_settings_file(self)
           
            fid = fopen(self.settings_filepath,'wt');
            fprintf(fid, '%s\n', self.settings_data{:});
            fclose(fid);
            
        end

        function setts = get_settings_from_file(self)
            
            for line = 1:length(self.settings_data)
                space = strfind(self.settings_data{line}, ' ');
                first_space = space(1);
                var = self.settings_data{line}(1:first_space-1);
                val_ind = first_space + 3; 
                value = self.settings_data{line}(val_ind:end);
                self.settings.(var) = value; 
            end
            
        end
        
       

        end

        % Setters

        

end