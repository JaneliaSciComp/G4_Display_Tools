classdef G4_conductor_model < handle
    
    properties
        
        fly_name_;
        fly_save_name_;
        fly_genotype_;
        experimenter_;
        fly_age_;
        fly_sex_;
        experiment_temp_;
        experiment_type_;
        rearing_protocol_
        light_cycle_
        metadata_comments_
        do_plotting_;
        do_processing_;
        plotting_file_;
        processing_file_;
        run_protocol_file_;
        run_protocol_file_desc_
        run_protocol_file_list_
        run_protocol_num_
        google_sheet_key_;
        list_of_gids_;
        metadata_array_
        metadata_options_
       num_tests_conducted_
       expected_time_
       timestamp_
       aborted_count_
       date_folder_

       num_attempts_bad_conds_

       postTrialTimes_

       
        
    end
    
    properties (Dependent)
        
        fly_name;
        fly_save_name;
        fly_genotype;
        fly_age;
        fly_sex;
        experiment_temp;
        experimenter;
        rearing_protocol
        light_cycle
        metadata_comments
        experiment_type;
        do_plotting;
        do_processing;
        plotting_file;
        processing_file;
        run_protocol_file;
        run_protocol_file_desc
        run_protocol_file_list
        run_protocol_num
        google_sheet_key;
        list_of_gids
        metadata_array
        metadata_options
        num_tests_conducted
        expected_time
        timestamp
        aborted_count
        date_folder
        num_attempts_bad_conds

        postTrialTimes
       
    end
    
    
    methods
        
%CONSTRUCTOR--------------------------------------------------------------

        function self = G4_conductor_model()
            
            %%User adjusted lists based on settings file and metadata Google Sheets
            list_of_setting_strings = {'Default run protocol file: ', 'Default processing file: ', ...
                'Default plotting file: ', 'Metadata Google Sheet key: '}; %These strings must match the string
            %preceding the corresponding value in the settings file -
            %including the space after the :
            
            %These strings must match the class property names they
            %correspond to.
            list_of_settings_needed = {'run_protocol_file', 'processing_file', 'plotting_file', 'google_sheet_key'};
            
            for i = 1:length(list_of_setting_strings)
                [settings_data, path, index] = self.get_setting(list_of_setting_strings{i});
                self.(list_of_settings_needed{i}) = strtrim(settings_data{path}(index:end));
            end
            
            %This list must be in the same order as the gid strings list. 
            list_of_metadata_fields = {'experimenter', 'fly_age', 'fly_sex', 'fly_geno', 'exp_temp', 'rearing', 'light_cycle'};
           
            list_of_gid_strings = {'Users Sheet GID: ','Fly Age Sheet GID: ', 'Fly Sex Sheet GID: ', ...
                'Fly Geno Sheet GID: ', 'Experiment Temp Sheet GID: ', 'Rearing Protocol Sheet GID: ', 'Light Cycle Sheet GID: '};
            self.list_of_gids = {};
            for i = 1:length(list_of_gid_strings)
                [settings_data, path, index] = self.get_setting(list_of_gid_strings{i});
                self.list_of_gids{i} = strtrim(settings_data{path}(index:end));
            end

            %The list of available run protocols to display
            self.run_protocol_file_list = {'Simple', 'Combined Command', 'Streaming', 'Log Reps Separately', 'CC + Streaming', ...
                'CC + Log Reps', 'Streaming + Log Reps', 'CC + Streaming + Log Reps'};

            %%run functions to 1)read the metadata options from the google
            %%sheet and 2) create a metadata_lists cell array with the list
            %%of options for each metadata field. 
            self.get_metadata_array();
            self.create_metadata_options(list_of_metadata_fields);
            
            %%Set initial values of properties - default to first item on
            %%each metadata list.
            self.fly_name = '';
            self.metadata_comments = '';
            self.fly_genotype = self.metadata_options.fly_geno{1};
            self.fly_age = self.metadata_options.fly_age{1};
            self.fly_sex = self.metadata_options.fly_sex{1};
            self.experiment_temp = self.metadata_options.exp_temp{1};
            self.experimenter = self.metadata_options.experimenter{1};
            self.rearing_protocol = self.metadata_options.rearing{1};
            self.light_cycle = self.metadata_options.light_cycle{1};
            self.experiment_type = 1;
            self.do_plotting = 1;
            self.do_processing = 1;
            self.num_tests_conducted = 0;
            self.aborted_count = 0;
            self.fly_save_name = [self.fly_genotype,'-',datestr(now, 'HH_MM_SS')];
            self.date_folder = datestr(now, 'mm_dd_yyyy');
            self.timestamp = datestr(now, 'mm-dd-yyyyHH_MM_SS');
            self.num_attempts_bad_conds = 1;
            self.run_protocol_num = 1;
            

            self.postTrialTimes = [];
 
        end
        
        %%methods
        
        function get_metadata_array(self)
        
            %Use GetGoogleSpreadsheet to get a cell array of each sheet.
            
            self.metadata_array = {};
            for i = 1:length(self.list_of_gids)
                self.metadata_array{i} = GetGoogleSpreadsheet(self.google_sheet_key, self.list_of_gids{i});
            end
            
        end

        %Get the index of a desired metadata heading from the Google Sheets------  
        function create_metadata_options(self, list)
            
            for i = 1:length(list)

                self.metadata_options.(list{i}) = self.metadata_array{i}(2:end,1);
            end
            
        end

        
        function [settings_data, path, index] = get_setting(self, string_to_find)
            last_five = string_to_find(end-5:end);
            settings_data = strtrim(regexp( fileread('G4_Protocol_Designer_settings.m'),'\n','split'));
            path = find(contains(settings_data, string_to_find));
            index = strfind(settings_data{path},last_five) + 5;
        
        end
        
        function [fly_name] = create_fly_name(self, filepath)
            
            results_folder = fullfile(filepath,self.date_folder);
            if ~exist(results_folder)
                fly_name = 'fly001';
            else

                %count number of folders in the results folder
                items = dir(results_folder);
                folders = items([items(:).isdir]==1);
                cleaned_folders = folders(~ismember({folders(:).name},{'.','..'}));

                num_folders = length(cleaned_folders);
                repeat = 7;
                while repeat == 7
                    if num_folders + 1 < 10
                        num_string = ['00',num2str(num_folders+1)];
                    elseif num_folders + 1 >= 10 && num_folders + 1 <= 99
                        num_string = ['0',num2str(num_folders+1)];
                    else
                        num_string = num2str(num_folders + 1);
                    end

                    fly_name = ['fly',num_string];
                    repeat = exist(fullfile(results_folder, fly_name),'dir');
                    if repeat == 7
                        num_folders = num_folders + 1;
                    end
                end
            end  
        end

        function filename = get_run_filename(self)
            
            switch self.run_protocol_num

                case 1

                    filename = 'G4_default_run_protocol.m';

                case 2 

                    filename = 'G4_run_protocol_combinedCommand.m';

                case 3

                    filename = 'G4_default_run_protocol_streaming.m';

                case 4

                    filename = '';
                    disp("This run protocol coming soon");

                case 5

                    filename = 'G4_run_protocol_CC_streaming.m';

                case 6

                    filename = 'G4_run_protocol_CC_blockLogging.m';

                case 7

                    filename = '';
                    disp("This run protocol coming soon");

                case 8

                    filename = '';
                    disp("This run protocol coming soon");

                otherwise
                    disp("Invalid run protocol selected.");
            end

        end
        
        %% Functions to update model values
        
        function update_fly_save_name(self)
            
            self.fly_save_name = [self.fly_genotype,'-',datestr(now, 'HH_MM_SS')];
            
        end
        
        function set_fly_name(self, new_val)
            self.fly_name = new_val;
            self.reset_num_tests_conducted();
            self.reset_aborted_count();
            
        end
        
        function set_experimenter(self, new_val)
            self.experimenter = self.metadata_options.experimenter{new_val};
        end
        
        function set_fly_genotype(self, new_val)
            self.fly_genotype = self.metadata_options.fly_geno{new_val};
            self.update_fly_save_name();
        end
        
        function set_do_plotting(self, new_val)
            self.do_plotting = new_val;
        end
        
        function set_do_processing(self, new_val)
            self.do_processing = new_val;
        end
        
        function set_plot_file(self, filepath)
            self.plotting_file = filepath;
        end
        
        function set_proc_file(self, filepath)
            self.processing_file = filepath;
        end
        
        function set_run_file(self, list_index)
            self.run_protocol_num = list_index;
            self.run_protocol_file_desc = self.run_protocol_file_list{list_index};
            filename = self.get_run_filename();
            self.run_protocol_file = filename;
        end
        
        function set_experiment_type(self, new_val)
            self.experiment_type = new_val;
        end
        
        function set_fly_age(self, new_val)
            self.fly_age = self.metadata_options.fly_age{new_val};
        end
        
        function set_fly_sex(self, new_val)
            self.fly_sex = self.metadata_options.fly_sex{new_val};
        end
        
        function set_temp(self, new_val)
            self.experiment_temp = self.metadata_options.exp_temp{new_val};
        end
        
        function set_rearing(self, new_val)
            self.rearing_protocol = self.metadata_options.rearing{new_val};
        end
        
        function set_light_cycle(self, new_val)
            self.light_cycle = self.metadata_options.light_cycle{new_val};
        end
        
        function set_metadata_comments(self, new_val)
            self.metadata_comments = new_val;
        end
        
        function set_expected_time(self, new_val)
            self.expected_time = new_val;
        end
        
        function set_timestamp(self)
            self.timestamp = datestr(now, 'mm-dd-yyyyHH_MM_SS');
        end
        
        function reset_num_tests_conducted(self)
            self.num_tests_conducted = 0;
        end
        
        function reset_aborted_count(self)
            self.aborted_count = 0;
        end
        

        function set_num_attempts_bad_conds(self, new_val)
            self.num_attempts_bad_conds = new_val;
        end

        function set_postTrialTimes(self, new_val)
            self.postTrialTimes = new_val;
        end
        
        function value = get_num_attempts_bad_conds(self)
            value = self.num_attempts_bad_conds;
        end

        function value = get_timestamp(self)
            value = self.timestamp;
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

        function value = get.run_protocol_file_list(self)
            value = self.run_protocol_file_list_;
        end

        function value = get.run_protocol_file_desc(self)
            value = self.run_protocol_file_desc_;
        end

        function value = get.run_protocol_num(self)
            value = self.run_protocol_num_;
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
        function output = get.metadata_array(self)
            output = self.metadata_array_;
        end
        
   
        function value = get.google_sheet_key(self)
            value = self.google_sheet_key_;
        end
        
        function output = get.num_tests_conducted(self)
            output = self.num_tests_conducted_;
        end
        
        function output = get.list_of_gids(self)
            output = self.list_of_gids_;
        end
        function output = get.metadata_options(self)
            output = self.metadata_options_;
        end
        function output = get.rearing_protocol(self)
            output = self.rearing_protocol_;
        end
        
        function output = get.metadata_comments(self)
            output = self.metadata_comments_;
        end
        
        function output = get.light_cycle(self)
            output = self.light_cycle_;
        end
        
        function value = get.expected_time(self)
            value = self.expected_time_;
        end
        
        function value = get.timestamp(self)
            value = self.timestamp_;
        end
        
        function value = get.aborted_count(self)
            value = self.aborted_count_;
        end
        
        function value = get.fly_save_name(self)
            value = self.fly_save_name_;
        end
        
        function value = get.date_folder(self)
            value = self.date_folder_;
        end
        
        function value = get.num_attempts_bad_conds(self)
            value = self.num_attempts_bad_conds_;
        end
        function value = get.postTrialTimes(self)
            value = self.postTrialTimes_;
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

        function set.run_protocol_file_list(self, value)
            self.run_protocol_file_list_ = value;
        end

        function set.run_protocol_file_desc(self, value)
            self.run_protocol_file_desc_ = value;
        end

        function set.run_protocol_num(self, value)
            self.run_protocol_num_ = value;
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
        function set.metadata_array(self, value)
            self.metadata_array_ = value;
        end

        
        function set.google_sheet_key(self, value)
            self.google_sheet_key_ = value;
        end
        
        function set.num_tests_conducted(self, value)
            self.num_tests_conducted_ = value;
        end
        
        function set.list_of_gids(self, value)
            self.list_of_gids_ = value;
        end

        function set.metadata_options(self, value)
            self.metadata_options_ = value;
        end
        
        function set.rearing_protocol(self, value)
            self.rearing_protocol_ = value;
        end
        
        function set.metadata_comments(self, value)
            self.metadata_comments_ = value;
        end
        
        function set.light_cycle(self, value)
            self.light_cycle_ = value;
        end
        
        function set.expected_time(self, value)
            self.expected_time_ = value;
        end
        
        function set.timestamp(self, value)
            self.timestamp_ = value;
        end
        
        function set.aborted_count(self, value)
            self.aborted_count_ = value;
        end
        
        function set.fly_save_name(self, value)
            self.fly_save_name_ = value;
        end
        
        function set.date_folder(self, value)
            self.date_folder_ = value;
        end
        
        function set.num_attempts_bad_conds(self, value)
            self.num_attempts_bad_conds_ = value;
        end

        function set.postTrialTimes(self, value)
            self.postTrialTimes_ = value;
        end
        
        

        
        
        
       
    end
    
    
end