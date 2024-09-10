classdef G4_conductor_model < handle

    properties

        fly_name
        fly_save_name
        fly_genotype
        fly_age
        fly_sex
        experiment_temp
        experimenter
        rearing_protocol
        light_cycle
        metadata_comments
        experiment_type
        do_plotting
        do_processing
        plotting_file
        processing_file
        run_protocol_file
        run_protocol_file_desc
        run_protocol_file_list
        run_protocol_num
        google_sheet_key
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
        combine_tdms
        convert_tdms
        orig_expected_time
        settings
    end

    methods

        %CONSTRUCTOR--------------------------------------------------------------
        function self = G4_conductor_model()

            self.set_settings(G4_Protocol_Designer_Settings());
            fn = fieldnames(self.settings);
            for i = 1:numel(fn)
                if isstring(self.settings.(fn{i}))
                    self.settings.(fn{i}) = convertStringsToChars(self.settings.(fn{i}));
                end
            end

            self.set_run_protocol_file(self.settings.run_protocol_file);
            self.set_processing_file(self.settings.processing_file);
            self.set_plotting_file(self.settings.plotting_file);
            self.set_google_sheet_key(self.settings.Google_Sheet_Key);
           
            %This list must be in the same order as the gid strings list.
            list_of_metadata_fields = {'experimenter', 'fly_age', 'fly_sex', 'fly_geno', 'exp_temp', 'rearing', 'light_cycle'};
            self.set_list_of_gids({self.settings.Users_Sheet_GID, self.settings.Fly_Age_Sheet_GID, ...
                self.settings.Fly_Sex_Sheet_GID, self.settings.Fly_Geno_Sheet_GID, ...
                self.settings.Experiment_Temp_Sheet_GID, self.settings.Rearing_Protocol_Sheet_GID, ...
                self.settings.Light_Cycle_Sheet_GID});
            
            %The list of available run protocols to display
            self.set_run_protocol_file_list({'Simple', 'Streaming', 'Log Reps Separately',  ...
                'Streaming + Log Reps'});

            %%run functions to 1)read the metadata options from the google
            %%sheet and 2) create a metadata_lists cell array with the list
            %%of options for each metadata field.
            self.create_metadata_array();
            self.create_metadata_options(list_of_metadata_fields);

            %%Set initial values of properties - default to first item on
            %%each metadata list.
            self.set_fly_name('');
            self.set_metadata_comments('');
            self.set_fly_genotype(self.metadata_options.fly_geno{1});
            self.set_fly_age(self.metadata_options.fly_age{1});
            self.set_fly_sex(self.metadata_options.fly_sex{1});
            self.set_experiment_temp(self.metadata_options.exp_temp{1});
            self.set_experimenter(self.metadata_options.experimenter{1});
            self.set_rearing_protocol(self.metadata_options.rearing{1});
            self.set_light_cycle(self.metadata_options.light_cycle{1});
            self.set_experiment_type('Flight');
            %self.experiment_types = {'Flight','Camera walk', 'Chip walk'};
            self.set_do_plotting(1);
            self.set_do_processing(1);
            self.set_num_tests_conducted(0);
            self.set_aborted_count(0);
            self.set_fly_save_name([self.fly_genotype,'-',char(datetime('now', 'Format', 'HH_mm_SS'))]);
            self.set_date_folder(datetime('now', 'Format', 'MM_dd_yyyy'));
            self.set_timestamp(datetime('now', 'Format', 'MM-dd-yyyyHH_mm_SS'));
            self.set_num_attempts_bad_conds(1);
            self.set_run_file('Simple');
            self.set_combine_tdms(1);
            self.set_convert_tdms(1);
            self.set_postTrialTimes([]);
        end

        %%methods

        function create_metadata_array(self)
            %Use GetGoogleSpreadsheet to get a cell array of each sheet.
            ma = {};
            for i = 1:length(self.list_of_gids)
                ma{i} = GetGoogleSpreadsheet(self.google_sheet_key, self.list_of_gids{i});
            end
            self.set_metadata_array(ma);
        end

        %Get the index of a desired metadata heading from the Google Sheets------
        function create_metadata_options(self, list)
            mo = struct;
            for i = 1:length(list)
                mo.(list{i}) = self.metadata_array{i}(2:end,1);
            end
            self.set_metadata_options(mo);
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
                    filename = 'G4_default_run_protocol_streaming.m';
                case 3
                    filename = 'G4_run_protocol_blockLogging.m';               
                case 4
                    filename = 'G4_run_protocol_streaming_blockLogging.m';

                otherwise
                    disp("Invalid run protocol selected.");
            end
        end

        function set_run_file(self, run_file_string)
            self.run_protocol_file_desc = run_file_string;
            list_index = find(strcmp(self.run_protocol_file_list, run_file_string));
            self.run_protocol_num = list_index;
           
            filename = self.get_run_filename();
            self.run_protocol_file = filename;
        end

        function reset_num_tests_conducted(self)
            self.set_num_tests_conducted(0);
        end

        function reset_aborted_count(self)
            self.set_aborted_count(0);
        end

        function update_fly_save_name(self)
            self.set_fly_save_name([self.fly_genotype,'-',char(datetime('now', 'Format', 'HH_mm_SS'))]);
        end

        %% Setters

        function  set_fly_save_name(self, new_val)
            self.fly_save_name = new_val;
        end

        function set_fly_name(self, new_val)
            self.fly_name = new_val;
            self.reset_num_tests_conducted();
            self.reset_aborted_count();
        end

        function set_experimenter(self, new_val)
            self.experimenter = new_val;
        end

        function set_fly_genotype(self, new_val)
            self.fly_genotype = new_val;
            self.update_fly_save_name();
        end

        function set_do_plotting(self, new_val)
            self.do_plotting = new_val;
            if self.do_plotting
                self.set_do_processing(1);
            end
        end

        function set_do_processing(self, new_val)
            self.do_processing = new_val;
            if self.do_processing == 0
                self.set_do_plotting(0);
            else
                self.set_convert_tdms(1);
            
            end
        end

        function set_convert_tdms(self, new_val)
            self.convert_tdms = new_val;
            if self.convert_tdms == 0
                self.set_do_processing(0);
                
            end
        end

        function set_plotting_file(self, filepath)
            self.plotting_file = filepath;
        end

        function set_processing_file(self, filepath)
            self.processing_file = filepath;
        end

        function set_experiment_type(self, new_val)
            self.experiment_type = new_val;
        end

        function set_fly_age(self, new_val)
            self.fly_age = new_val;
        end

        function set_fly_sex(self, new_val)
            self.fly_sex = new_val;
        end

        function set_experiment_temp(self, new_val)
            self.experiment_temp = new_val;
        end

        function set_rearing_protocol(self, new_val)
            self.rearing_protocol = new_val;
        end

        function set_light_cycle(self, new_val)
            self.light_cycle = new_val;
        end

        function set_metadata_comments(self, new_val)
            self.metadata_comments = new_val;
        end

        function set_expected_time(self, new_val)
            self.expected_time = new_val;
        end

        function set_orig_expected_time(self, new_val)
            self.orig_expected_time = new_val;
        end

        function set_timestamp(self, varargin)
            if ~isempty(varargin)
                new_val = varargin{1};
                if ~ischar(new_val)
                    new_val = char(new_val);
                end
                self.timestamp = new_val;
            else
                self.timestamp = char(datetime('now', 'Format', 'MM-dd-yyyyHH_mm_SS'));
            end
        end

        function set_num_tests_conducted(self, new_val)
            self.num_tests_conducted = new_val;
        end

        function set_aborted_count(self, new_val)
            self.aborted_count = new_val;
        end

        function set_num_attempts_bad_conds(self, new_val)
            self.num_attempts_bad_conds = new_val;
        end

        function set_postTrialTimes(self, new_val)
            self.postTrialTimes = new_val;
        end

        function set_combine_tdms(self, new_val)
            self.combine_tdms = new_val;
        end

        function set_run_protocol_file(self, new_val)
            self.run_protocol_file = new_val;
        end
        
        function set_run_protocol_file_desc(self, new_val)
            self.run_protocol_file_desc = new_val;
        end

        function set_run_protocol_file_list(self, new_val)
            self.run_protocol_file_list = new_val;
        end

        function set_run_protocol_num(self, new_val)
            self.run_protocol_num = new_val;
        end

        function set_google_sheet_key(self, new_val)
            self.google_sheet_key = new_val;
        end

        function set_list_of_gids(self, new_val)
            self.list_of_gids = new_val;
        end

        function set_metadata_array(self, new_val)
            self.metadata_array = new_val;
        end

        function set_metadata_options(self, new_val)
            self.metadata_options = new_val;
        end

        function set_date_folder(self, new_val)
            if ~ischar(new_val)
                new_val = char(new_val);
            end
            self.date_folder = new_val;
        end

        function set_settings(self, new_val)
            self.settings = new_val;
        end


        %% Getters

        function value = get_num_attempts_bad_conds(self)
            value = self.num_attempts_bad_conds;
        end

        function value = get_timestamp(self)
            value = self.timestamp;
        end

        function value = get_run_file_desc(self)
            value =  self.run_protocol_file_desc;
        end

        function value = get_combine_tdms(self)
            value = self.combine_tdms;
        end

        function value = get_convert_tdms(self)
            value = self.convert_tdms;
        end

        function value = get_fly_name(self)
            value =  self.fly_name;
        end
        
        function value =  get_fly_save_name(self)
            value = self.fly_save_name;
        end

        function value = get_fly_genotype(self)
            value  = self.fly_genotype;
        end

        function value = get_fly_age(self)
            value = self.fly_age;
        end

        function value = get_fly_sex(self)
            value = self.fly_sex;
        end

        function value = get_experiment_temp(self)
            value = self.experiment_temp;
        end

        function value  = get_experimenter(self)
            value = self.experimenter;
        end

        function value = get_rearing_protocol(self)
            value = self.rearing_protocol;
        end

        function value = get_light_cycle(self)
            value = self.light_cycle;
        end

        function value = get_metadata_comments(self)
            value = self.metadata_comments;
        end

        function value = get_experiment_type(self)
            value = self.experiment_type;
        end

        function value = get_do_plotting(self)
            value = self.do_plotting;
        end

        function value = get_do_processing(self)
            value = self.do_processing;
        end

        function value = get_plotting_file(self)
            value = self.plotting_file;
        end

        function value =  get_processing_file(self)
            value = self.processing_file;
        end

        function value =  get_run_protocol_file(self)
            value = self.run_protocol_file;
        end

        function value = get_run_protocol_file_list(self)
            value = self.run_protocol_file_list;
        end

        function value =  get_run_protocol_num(self)
            value = self.run_protocol_num;
        end

        function value  = get_google_sheet_key(self)
            value = self.google_sheet_key;
        end

        function value  = get_list_of_gids(self)
            value = self.list_of_gids;
        end

        function value = get_metadata_array(self)
            value = self.metadata_array;
        end

        function value =  get_metadata_options(self)
            value = self.metadata_options;
        end

        function value =  get_num_tests_conducted(self)
            value = self.num_tests_conducted;
        end

        function value = get_expected_time(self)
            value = self.expected_time;
        end

        function value = get_aborted_count(self)
            value =  self.aborted_count;
        end

        function  value = get_date_folder(self)
            value = self.date_folder;
        end

        function value = get_postTrialTimes(self)
            value = self.postTrialTimes;
        end

        function value = get_orig_expected_time(self)
            value = self.orig_expected_time;
        end

        function value  =  get_settings(self)
            value =  self.settings;
        end
        

    end
end