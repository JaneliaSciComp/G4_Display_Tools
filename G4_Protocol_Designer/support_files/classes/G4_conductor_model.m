classdef G4_conductor_model < handle
    
    properties
        
        fly_name_;
        fly_genotype_;
        experimenter_;
        fly_age_;
        fly_sex_;
        experiment_temp_;
        experiment_type_;
        do_plotting_;
        do_processing_;
        plotting_file_;
        processing_file_;
        run_protocol_file_;
        google_sheet_link_;
        metadata_indices_;
         metadata_lists_;
       metadata_variables_;
       metadata_values_;
        
    end
    
    properties (Dependent)
        
        fly_name;
        fly_genotype;
        fly_age;
        fly_sex;
        experiment_temp;
        experimenter;
        experiment_type;
        do_plotting;
        do_processing;
        plotting_file;
        processing_file;
        run_protocol_file;
        google_sheet_link;
        metadata_indices;
         metadata_lists;
       metadata_variables;
       metadata_values;
        
    end
    
    
    methods
        
%CONSTRUCTOR--------------------------------------------------------------

        function self = G4_conductor_model()
            
            %%User adjusted lists based on settings file and metadata google sheet
            list_of_setting_strings = {'Default run protocol file: ', 'Default processing file: ', ...
                'Default plotting file: ', 'Metadata Google Sheet link: '}; %These strings must match the string
            %preceding the corresponding value in the settings file -
            %including the space after the :
            
            %These strings must match the class property names they
            %correspond to.
            list_of_settings_needed = {'run_protocol_file', 'processing_file', 'plotting_file', 'google_sheet_link'};
            
            %Same requirements as above
            list_of_index_strings = {'Experimenter: ', 'Fly Age: ', ...
                'Fly Sex: ', 'Fly Genotype: ', 'Experiment Temp: '};
            list_of_index_fields = {'users', 'age', 'sex', 'geno', 'temp'};

            %%use previous lists to set the model properties
            for i = 1:length(list_of_setting_strings)
                [settings_data, path, index] =  self.get_setting(list_of_setting_strings{i});
                
                self.(list_of_settings_needed{i}) = settings_data{path}(index:end);
                
            end
            
            for i = 1:length(list_of_index_strings)
                [settings_data, path, index] = self.get_setting(list_of_index_strings{i});
                self.metadata_indices.(list_of_index_fields{i}) = str2num(settings_data{path}(index:end));
            end
            
            self.google_sheet_link = [self.google_sheet_link,'/export?exportFormat=csv'];

            %%run functions to 1)read the metadata options from the google
            %%sheet and 2) create a metadata_lists cell array with the list
            %%of options for each metadata field. 
            self.get_metadata_values();
            self.get_metadata_lists();
            
            %%Set initial values of properties - default to first item on
            %%each metadata list.
            self.fly_name = '';
            self.fly_genotype = self.metadata_lists{self.metadata_indices.geno}{1};
            self.fly_age = self.metadata_lists{self.metadata_indices.age}{1};
            self.fly_sex = self.metadata_lists{self.metadata_indices.sex}{1};
            self.experiment_temp = self.metadata_lists{self.metadata_indices.temp}{1};
            self.experimenter = self.metadata_lists{self.metadata_indices.users}{1};
            self.experiment_type = 1;
            self.do_plotting = 1;
            self.do_processing = 1;
           
            
            
            
        end
        
        %%methods
        
        function get_metadata_values(self)
        
            
            
            metadata_table = webread(self.google_sheet_link);

            self.metadata_variables = metadata_table.Properties.VariableNames;
            self.metadata_values = {};
            for i = 1:width(metadata_table)
                for j = 1:height(metadata_table)
                    self.metadata_values{j,i} = metadata_table.(self.metadata_variables{i}){j};
                    if iscell(self.metadata_values{j,i})        
                        self.metadata_values{j,i} = self.metadata_values{j,i}{i};
                    end
                end
            end

        end

%Get the index of a desired metadata heading from the google sheet------        
        function get_metadata_lists(self)
            self.metadata_lists = {};
            fields = fieldnames(self.metadata_indices);
            
            for i = 1:length(fields)
                
                self.metadata_lists{i} = self.metadata_values(:,self.metadata_indices.(fields{i}));
                self.metadata_lists{i}(cellfun('isempty', self.metadata_lists{i})) = [];
                self.metadata_indices.(fields{i}) = i;
            end
            
            
            
        
        end
        
        function [settings_data, path, index] = get_setting(self, string_to_find)
            last_five = string_to_find(end-5:end);
            settings_data = strtrim(regexp( fileread('G4_Protocol_Designer_settings.m'),'\n','split'));
            path = find(contains(settings_data, string_to_find));
            index = strfind(settings_data{path},last_five) + 5;
        
        end
        
        
        
        
        
%GETTERS------------------------------------------------------------------
        
        function value = get.fly_name(self)
            value = self.fly_name_;
        end
        
        function value = get.fly_genotype(self)
            value = self.fly_genotype_;
        end
        
        function value = get.experimenter(self)
            value = self.experimenter_;
        end
        
        function value = get.experiment_type(self)
            value = self.experiment_type_;
        end
        
        function value = get.do_plotting(self)
            value = self.do_plotting_;
        end
        
        function value = get.do_processing(self)
            value = self.do_processing_;
        end
        
        function value = get.plotting_file(self)
            value = self.plotting_file_;
        end
        
        function value = get.processing_file(self)
            value = self.processing_file_;
        end
        
        function value = get.run_protocol_file(self)
            value = self.run_protocol_file_;
        end
        
        function value = get.fly_age(self)
            value = self.fly_age_;
        end
        
        function value = get.fly_sex(self)
            value = self.fly_sex_;
        end
        function value = get.experiment_temp(self)
            value = self.experiment_temp_;
        end
        function output = get.metadata_indices(self)
            output = self.metadata_indices_;
        end
        
        function output = get.metadata_variables(self)
            output = self.metadata_variables_;
        end
        function output = get.metadata_values(self)
            output = self.metadata_values_;
        end
        function output = get.metadata_lists(self)
            output = self.metadata_lists_;
        end
        
        function value = get.google_sheet_link(self)
            value = self.google_sheet_link_;
        end


%SETTERS------------------------------------------------------------------

        function set.fly_name(self, value)
            self.fly_name_ = value;
        end
        
        function set.fly_genotype(self, value)
            self.fly_genotype_ = value;
        end
        
        function set.experimenter(self, value)
            self.experimenter_ = value;
        end
        
        function set.experiment_type(self, value)
            self.experiment_type_ = value;
        end
        
        function set.do_plotting(self, value)
            self.do_plotting_ = value;
        end
        
        function set.do_processing(self, value)
            self.do_processing_ = value;
        end
        
        function set.plotting_file(self, value)
            self.plotting_file_ = value;
        end
        
        function set.processing_file(self, value)
            self.processing_file_ = value;
        end
        
        function set.run_protocol_file(self, value)
            self.run_protocol_file_ = value;
        end
        function set.fly_age(self, value)
            self.fly_age_ = value;
        end
        function set.fly_sex(self, value)
            self.fly_sex_ = value;
        end
        function set.experiment_temp(self, value)
            self.experiment_temp_ = value;
        end
        function set.metadata_indices(self, value)
            self.metadata_indices_ = value;
        end
        function set.metadata_variables(self, value)
            self.metadata_variables_ = value;
        end
        function set.metadata_values(self, value)
            self.metadata_values_ = value;
        end
            
        function set.metadata_lists(self, value)
            self.metadata_lists_ = value;
        end
        function set.google_sheet_link(self, value)
            self.google_sheet_link_ = value;
        end


        
       
    end
    
    
end