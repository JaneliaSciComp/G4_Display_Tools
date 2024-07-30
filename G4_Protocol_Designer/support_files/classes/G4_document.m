classdef G4_document < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties

        top_folder_path
        top_export_path
        Patterns
        Pos_funcs
        Ao_funcs
        imported_pattern_names
        imported_posfunc_names
        imported_aofunc_names
        binary_files
        save_filename
        currentExp
        experiment_name
        est_exp_length

        pretrial
        block_trials
        intertrial
        posttrial
        repetitions
        is_randomized
        num_rows
        is_chan1
        chan1_rate
        is_chan2
        chan2_rate
        is_chan3
        chan3_rate
        is_chan4
        chan4_rate
        trial_data
        configData

        %Shared data on recently opened .g4p files
        recent_g4p_files
        recent_files_filepath

        pattern_locations
        function_locations
        aoFunc_locations
        settings

    end

    methods

%CONSTRUCTOR--------------------------------------------------------------
        function self = G4_document()

            self.set_settings(G4_Protocol_Designer_Settings());
            fn = fieldnames(self.settings);
            for i = 1:numel(fn)
                if isstring(self.settings.(fn{i}))
                    self.settings.(fn{i}) = convertStringsToChars(self.settings.(fn{i}));
                end
            end


            %%constructor sets rest of variables
            %Set these properties to empty values until they are needed
            self.set_top_folder_path('');
            self.set_top_export_path('');
            self.Patterns = struct;
            self.Pos_funcs = struct;
            self.Ao_funcs = struct;
            self.set_imported_pattern_names({});
            self.set_imported_posfunc_names({});
            self.set_imported_aofunc_names({});
            self.binary_files.pats = struct;
            self.binary_files.funcs = struct;
            self.binary_files.ao = struct;
            self.set_save_filename('');
            self.currentExp = struct;
            self.set_experiment_name('');
            self.set_trial_data(G4_trial_model());
            self.set_est_exp_length(0);

            %Make table parameters into a cell array so they work with the tables more easily
            self.set_pretrial(self.trial_data.trial_array);
            self.set_intertrial(self.trial_data.trial_array);
            self.set_block_trials(self.trial_data.trial_array);
            self.set_posttrial(self.trial_data.trial_array);

            %Find line with number of rows and get value -------------------------------------------
            [self.configData, numRows_line, ~] = self.get_setting(self.settings.Configuration_Filepath, 'Number of Rows');
  
            if ~isempty(self.configData)
                self.set_num_rows(str2num(self.configData{numRows_line}(end)));
            end


            %Determine channel sample rates--------------------------------------------
            if ~isempty(self.configData)
                self.set_chan1_rate(self.get_ending_number_from_file(self.configData, 'ADC0'));
                self.set_chan2_rate(self.get_ending_number_from_file(self.configData, 'ADC1'));
                self.set_chan3_rate(self.get_ending_number_from_file(self.configData, 'ADC2'));
                self.set_chan4_rate(self.get_ending_number_from_file(self.configData, 'ADC3'));
            else
                self.set_chan1_rate(1000);
                self.set_chan2_rate(1000);
                self.set_chan3_rate(1000);
                self.set_chan4_rate(1000);
            end
            
            %Set rest of default property values
            self.set_repetitions(1);
            self.set_is_randomized(0);
            if self.chan1_rate == 0
                self.set_is_chan1(0);
            else
                self.set_is_chan1(1);
            end
            if self.chan2_rate == 0
                self.set_is_chan2(0);
            else
                self.set_is_chan2(1);
            end
            if self.chan3_rate == 0
                self.set_is_chan3(0);
            else
                self.set_is_chan3(1);
            end
            if self.chan4_rate == 0
                self.set_is_chan4(0);
            else
                self.set_is_chan4(1);
            end

            %Get the recently opened .g4p files
            %Get info from log of recently opened .g4p files
            recent_files_filename = 'recently_opened_g4p_files.m';
            filepath = fileparts(which(recent_files_filename));
            self.set_recent_files_filepath(fullfile(filepath, recent_files_filename));
            self.set_recent_g4p_files(strtrim(regexp( fileread(self.recent_files_filepath),'\n','split')));
            self.set_recent_g4p_files(self.recent_g4p_files(~cellfun('isempty',self.recent_g4p_files)));
        end

%SETTING INDIVIDUAL TRIAL PROPERTIES---------------------------------------

        function set_trial_property(self, x, y, new_value, trialtype)

            if strcmp(trialtype, 'block')
                propName  = 'block_trials';

                if x > size(self.block_trials, 1)
                    posfield = self.get_posfunc_field_name(new_value{3});
                    self.set_block_trial(x, new_value);
                    return;
                end
            elseif strcmp(trialtype, 'pre')
                propName = 'pretrial';
            elseif strcmp(trialtype, 'inter')
                propName = 'intertrial';
            elseif strcmp(trialtype, 'post')
                propName = 'posttrial';
            else
                self.create_error_box("There was an issue with your trial selection. Please try again.");
                return;
            end
                
            if self.check_if_cell_disabled(new_value)
                self.set_uneditable_trial_property([x,y], new_value, propName);
                return;
            end

            if y == 1 && ~strcmp(num2str(new_value),'')
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if ~isempty(new_value) && (new_value < 1 || new_value > 7)
                    self.create_error_box("Mode must be 1-7 or left empty.", 'Mode Error');
                    return;
                end
            end

            if y == 2 && ~strcmp(string(new_value),'') && ~isempty(new_value)
                patfile = new_value;
                patfield = self.get_pattern_field_name(patfile);
                if strcmp(patfield, '')
                    self.create_error_box("That trial pat filename does not match any imported files.", 'pattern name', 'modal');
                    return;
                end
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.Patterns.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.num_rows;
                if ~strcmp(string(self.(propName){x,3}),'') && ~self.check_if_cell_disabled(self.(propName){x,3})
                    posfile = self.(propName){x,3};
                    posfield = self.get_posfunc_field_name(posfile);
                    funcDim = max(self.Pos_funcs.(posfield).pfnparam.func);
                else
                    patDim = 0;
                    funcDim = 0;
                end

            elseif y == 3 && ~strcmp(string(new_value),'') && ~isempty(new_value) && ~strcmp(string(self.(propName){x,2}),'')

                posfile = new_value;
                posfield = self.get_posfunc_field_name(posfile);
                if strcmp(posfield,'') && ~strcmp(new_value,'')
                    self.create_error_box("That trial position filename does not match any imported files.", 'position function name');
                    return;
                end

                patfile = self.(propName){x,2};
                patfield = self.get_pattern_field_name(patfile);
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                funcDim = max(self.Pos_funcs.(posfield).pfnparam.func);
                patRows = 0;
                numrows = 0;

                if self.Pos_funcs.(posfield).pfnparam.gs_val == 1
                    self.(propName){x,12} = round(self.Pos_funcs.(posfield).pfnparam.size/2000,1);
                else
                    self.(propName){x,12} = round(self.Pos_funcs.(posfield).pfnparam.size/1000,1);
                end
            else
                patDim = 0;
                funcDim = 0;
                patRows = 0;
                numrows = 0;
            end

            if y > 3 && y < 8 && ~strcmp(string(new_value),'') && ~isempty(new_value)
                aofile = new_value;
                aofield = self.get_aofunc_field_name(aofile);
                if strcmp(aofield,'')
                    self.create_error_box("That trial AO filename does not match any imported files.", 'AO function filename');
                    return;
                end
            end

            if y == 8 && ~strcmp(num2str(new_value),'')
                if isnumeric(new_value)
                    new_value = num2str(new_value);
                end
                nums = isstrprop(new_value,'digit');
                chars = 0;
                for i = 1:length(nums)
                    if nums(i) == 0
                        chars = 1;
                    end
                end

                associated_pattern = self.(propName){x,2};
                if ~isempty(associated_pattern)
                    patfield = self.get_pattern_field_name(associated_pattern);
                    num_pat_frames = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                    if chars == 0
                        if str2num(new_value) > num_pat_frames
                            self.create_error_box("Please make sure your frame index is within the bounds of your pattern.", 'Frame index error');
                            return
                        end
                    end
                end
                if  chars == 1 && ~strcmp(new_value,'r')
                    self.create_error_box("Invalid frame index. Please enter a number or 'r'", 'Frame Index Error');
                    return;
                end
            end

            %Make sure frame rate is > 0
            if y == 9 && ~strcmp(num2str(new_value),'')
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if new_value <= 0
                    self.create_error_box("Your frame rate must be above 0");
                    return;
                end
            end

            %Make sure gain/offset are numerical
            if y == 10 || y == 11 && ~strcmp(num2str(new_value),'')
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
            end

            if y == 12 && ~strcmp(num2str(new_value),'')
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if new_value < 0
                    self.create_error_box("You duration must be zero or greater");
                    return;
                end
                %I believe the controller now accepts more than one decimal
                %place? 
%                 %round to 1 decimal place, since the controller only takes
%                 %numbers to 1 decimal place.
%                 new_value = round(new_value, 1);
            end

            if patRows ~= numrows
                self.create_error_box("Watch out! This pattern will not run on the size screen you have selected.");
            end
            if patDim < funcDim
                self.create_error_box("Please make sure the dimension of your pattern and position functions match");
            else

                %Set value
                self.(propName){x, y} = new_value;
            end

        end

        function set_block_trial(self, index, new_val)
            if ~isempty(new_val)
                self.block_trials(index, :) = new_val;
            else
                self.block_trials(index, :) = [];
            end

        end

        function set_uneditable_trial_property(self, index, new_value,  propName)
            self.(propName){index(1), index(2)} = new_value;
        end
        

        function set_recent_files(self, filepath)
            on_list = find(strcmp(self.recent_g4p_files,filepath));
            if on_list == 1
                %do nothing, the top most recent filew as chosen and everything stays in the same spot
                return;
            elseif on_list > 1
                for i = on_list:-1:2
                    self.recent_g4p_files{i} = self.recent_g4p_files{i-1};
                end
            elseif isempty(on_list)
                for i = length(self.recent_g4p_files)+1:-1:2
                    self.recent_g4p_files{i} = self.recent_g4p_files{i-1};
                end
            end
            self.recent_g4p_files{1} = filepath;
            if length(self.recent_g4p_files) > 4
                for i = 5:length(self.recent_g4p_files)
                    self.recent_g4p_files(i) = [];
                end
            end
        end

        function update_recent_files_file(self)
            fid = fopen(self.recent_files_filepath,'wt');
            fprintf(fid, '%s\n', self.recent_g4p_files{:});
            fclose(fid);
        end

%SET THE CONFIGURATION FILE DATA-------------------------------------------

        function set_config_data(self, new_value, channel)
             if channel == 1
                new = "ADC0 Rate (Hz) = " + num2str(new_value);
                rate1_line = find(contains(self.configData,'ADC0'));
                self.configData{rate1_line} = new;
                self.configData{rate1_line} = convertStringsToChars(self.configData{rate1_line});
            end

            if channel == 2
                new = "ADC1 Rate (Hz) = " + num2str(new_value);
                rate2_line = find(contains(self.configData,'ADC1'));
                self.configData{rate2_line} = new;
                self.configData{rate2_line} = convertStringsToChars(self.configData{rate2_line});
            end

            if channel == 3
                new = "ADC2 Rate (Hz) = " + num2str(new_value);
                rate3_line = find(contains(self.configData,'ADC2'));
                self.configData{rate3_line} = new;
                self.configData{rate3_line} = convertStringsToChars(self.configData{rate3_line});
            end

            if channel == 4
                new = "ADC3 Rate (Hz) = " + num2str(new_value);
                rate4_line = find(contains(self.configData,'ADC3'));
                self.configData{rate4_line} = new;
                self.configData{rate4_line} = convertStringsToChars(self.configData{rate4_line});
            end

            if channel == 0
                new = "Number of Rows = " + num2str(new_value);
                numRows_line = find(contains(self.configData,'Number of Rows'));
                self.configData{numRows_line} = new;
                self.configData{numRows_line} = convertStringsToChars(self.configData{numRows_line});
            end
        end


%Find and return three lists of all the pattern, function, and ao files used in the experiment being saved/exported
        function [pat_list, func_list, ao_list] = get_file_list(self)

            pat_list = {''};
            func_list = {''};
            ao_list = {''};

            func_count = 1;
            ao_count = 1;
            for i = 1:length(self.block_trials(:,1))
                pat_list{i} = self.block_trials{i,2};
                if ~strcmp(self.block_trials{i,3},'')
                    func_list{func_count} = self.block_trials{i,3};
                    func_count = func_count + 1;
                end
                if ~strcmp(self.block_trials{i,4},'')
                    ao_list{ao_count} = self.block_trials{i,4};
                    ao_count = ao_count + 1;
                end
                if strcmp(self.block_trials{i,5},'') == 0
                    ao_list{ao_count} = self.block_trials{i,5};
                    ao_count = ao_count + 1;
                end
                if strcmp(self.block_trials{i, 6},'') == 0
                    ao_list{ao_count} = self.block_trials{i,6};
                    ao_count = ao_count + 1;
                end
                if strcmp(self.block_trials{i,7},'') == 0
                    ao_list{ao_count} = self.block_trials{i,7};
                    ao_count = ao_count + 1;
                end
           end

           pat_list{end + 1} = self.pretrial{2};
           pat_list{end + 1} = self.posttrial{2};
           pat_list{end + 1} = self.intertrial{2};

            if ~strcmp(self.pretrial{3},'')
                func_list{func_count} = self.pretrial{3};
                func_count = func_count + 1;
            end

            if ~strcmp(self.posttrial{3},'')
                func_list{func_count} = self.posttrial{3};
                func_count = func_count + 1;
            end

            if ~strcmp(self.intertrial{3},'')
                func_list{func_count} = self.intertrial{3};
                func_count = func_count + 1;
            end

            for i = 4:7
                if ~strcmp(self.pretrial{i},'')
                    ao_list{ao_count} = self.pretrial{i};
                    ao_count = ao_count + 1;
                end
            end

            for i = 4:7
                if strcmp(self.posttrial{i},'') == 0
                    ao_list{end+1} = self.posttrial{i};
                end
            end

            for i = 4:7
                if strcmp(self.intertrial{i},'') == 0
                    ao_list{ao_count} = self.intertrial{i};
                    ao_count = ao_count + 1;
                end
            end

            if ~strcmp(func_list{1},'')
                empty_cells = cellfun(@isempty, func_list);
                for i = length(empty_cells):-1:1
                    if empty_cells(i) == 1
                        func_list(i) = [];
                    end
                end
                func_list = unique(func_list);
            else
                func_list = {''};
            end

            if ~strcmp(ao_list,'')
                empty_aocells = cellfun(@isempty, ao_list);
                for i = length(empty_aocells):-1:1
                    if empty_aocells(i) == 1
                        ao_list(i) = [];
                    end
                end
                ao_list = unique(ao_list);
            else
                ao_list = {''};
            end

            empty_patcells = cellfun(@isempty, pat_list);
            for i = length(empty_patcells):-1:1
                if empty_patcells(i) == 1
                    pat_list(i) = [];
                end
            end
           pat_list = unique(pat_list);
        end

        function [pats, funcs, aos] = get_bin_list(self, pat_list, func_list, ao_list)
            all_pat_bins = fieldnames(self.binary_files.pats);
            all_func_bins = fieldnames(self.binary_files.funcs);
            all_ao_bins = fieldnames(self.binary_files.ao);
            pats = { };
            funcs = { };
            aos = { };

            for i = 1:length(pat_list)
                field = self.get_pattern_field_name(pat_list{i});
                id = num2str(self.Patterns.(field).pattern.param.ID);
                add_zeros = 4 - numel(id);
                for j = 1:add_zeros
                    id = strcat("0",id);
                end
                index = find(contains(all_pat_bins,id));
                pats{end+1} = all_pat_bins{index};
            end

            if ~strcmp(func_list{1},'')
                for i = 1:length(func_list)
                    field = self.get_posfunc_field_name(func_list{i});

                    id = num2str(self.Pos_funcs.(field).pfnparam.ID);
                    add_zeros = 4 - numel(id);
                    for j = 1:add_zeros
                        id = strcat("0",id);
                    end
                    index = find(contains(all_func_bins, id));
                    funcs{end+1} = all_func_bins{index};
                end
            end
            if ~strcmp(ao_list{1},'')
                for i = 1:length(ao_list)
                    field = self.get_aofunc_field_name(ao_list{i});
                    id = num2str(self.Ao_funcs.(field).afnparam.ID);
                    add_zeros = 4 - numel(id);
                    for j = 1:add_zeros
                        id = strcat("0",id);
                    end
                    index = find(contains(all_ao_bins, id));
                    aos{end+1} = all_ao_bins{index};
                end
            end
        end


%GIVEN THE PATTERN'S FIELD NAME, GET THE FILE NAME------------------------
        function [field_name] = get_pattern_field_name(self, filename)
            if isempty(fieldnames(self.Patterns))
                field_name = '';
            else
                imported_pattern_fields = fieldnames(self.Patterns);
                for i = 1:length(imported_pattern_fields)
                    is_match(i) = strcmp(self.Patterns.(imported_pattern_fields{i}).filename, filename);
                end

                idx = find(is_match,1);
                if ~isempty(idx)
                    field_name = imported_pattern_fields{idx};
                else
                    field_name = '';
                end
            end
        end

        function [field_name] = get_posfunc_field_name(self, filename)
            if isempty(fieldnames(self.Pos_funcs))
                field_name = '';
            else
                imported_func_fields = fieldnames(self.Pos_funcs);
                for i = 1:length(imported_func_fields)
                    is_match(i) = strcmp(self.Pos_funcs.(imported_func_fields{i}).filename, filename);
                end
                idx = find(is_match,1);
                if ~isempty(idx)
                    field_name = imported_func_fields{idx};
                else
                    field_name = '';
                end
            end
        end

        function [field_name] = get_aofunc_field_name(self, filename)
            if isempty(fieldnames(self.Ao_funcs))
                field_name = '';
            else
                imported_ao_fields = fieldnames(self.Ao_funcs);
                for i = 1:length(imported_ao_fields)
                    is_match(i) = strcmp(self.Ao_funcs.(imported_ao_fields{i}).filename, filename);
                end
                idx = find(is_match,1);
                if ~isempty(idx)
                    field_name = imported_ao_fields{idx};
                else
                    field_name = '';
                end
            end
        end

%GIVEN THE PATTERN'S FILE NAME, GET THE FIELD NAME
        function [filename] =  get_pattern_filename(self, field_name)
            filename = self.Patterns.(field_name).filename;
        end

%UPDATE THE CONFIG FILE----------------------------------------------------
        function update_config_file(self)
            %open config file
            %change appropriate rate
            %save and close config file
            config = self.configData;

            config_filepath = self.settings.Configuration_Filepath;

            if ~isfile(config_filepath)
                error("The configuration file " + config_filepath + " does not exist. Double check your settings.");
            end
            
            fid = fopen(config_filepath,'wt');
            
            if fid < 0
                error("You don't have the required writing permissions to '" + config_filepath + "'. Change file permission and try again.");
            end

            fprintf(fid, '%s\n', config{:});
            fclose(fid);
        end

%EXPORT--------------------------------------------------------------------
        function [export_successful] = export(self)


            Exppath = self.top_export_path;
            [Expstatus, Expmsg] = mkdir(Exppath);

            patpath = fullfile(Exppath,'Patterns');
            [patstatus, patmsg] = mkdir(patpath);

            funcpath = fullfile(Exppath, 'Functions');
            [funcstatus, funcmsg] = mkdir(funcpath);

            aopath = fullfile(Exppath, 'Analog Output Functions');
            [aostatus, aomsg] = mkdir(aopath);

            if Expstatus == 0
                self.create_error_box(Expmsg);
                export_successful = 0;
                return;
            elseif patstatus == 0
                self.create_error_box(patmsg);
                export_successful = 0;
                return;
            elseif funcstatus == 0
                self.create_error_box(funcmsg);
                export_successful = 0;
                return;
            elseif aostatus == 0
                self.create_error_box(aomsg);
                export_successful = 0;
                return;
            else

               [pat_list, func_list, ao_list] = self.get_file_list();
               [pat_bin_list, func_bin_list, ao_bin_list] = self.get_bin_list(pat_list, func_list, ao_list);

               if ~strcmp(func_list{1},'')

                    num_funcs = length(func_list);
                    for m = 1:num_funcs
                        file = func_list{m};
                        field = self.get_posfunc_field_name(file);

                        filename = strcat(file, '.mat');
                        filepath = fullfile(funcpath, filename);
                        pfnparam = self.Pos_funcs.(field).pfnparam;
                        save(filepath, 'pfnparam');
                    end
                    num_pfn = length(func_bin_list);

                    for n = 1:num_pfn
                        pfnName = func_bin_list{n};
                        filename = strcat(pfnName,'.pfn');
                        filepath = fullfile(funcpath, filename);
                        newpfn = fopen(filepath,'w');
                        fwrite(newpfn,self.binary_files.funcs.(pfnName));
                        fclose(newpfn);
                    end
               end

               if ~strcmp(ao_list{1},'')
                   num_ao = length(ao_list);
                   for n = 1:num_ao
                        file = ao_list{n};
                        field = self.get_aofunc_field_name(file);
                        filename = strcat(file, '.mat');
                        filepath = fullfile(aopath, filename);
                        afnparam = self.Ao_funcs.(field).afnparam;
                        save(filepath, 'afnparam');
                   end
                   num_afn = length(ao_bin_list);

                   for i = 1:num_afn
                       afnName = ao_bin_list{i};
                       filename = strcat(afnName, '.afn');
                       filepath = fullfile(aopath, filename);
                       newafn = fopen(filepath, 'w');
                       fwrite(newafn, self.binary_files.ao.(afnName));
                       fclose(newafn);
                   end
               end

               num_pats = length(pat_list);
               pattNames = cell(num_pats);
               for k = 1:num_pats
                    file = pat_list{k};
                    field = self.get_pattern_field_name(file);
                    filename = strcat(file,'.mat');
                    pattNames{k} = filename;
                    filepath = fullfile(patpath, filename);
                    pattern = self.Patterns.(field).pattern;
                    save(filepath, 'pattern');
               end

               num_bins = length(pat_bin_list);
               patternList = cell(num_bins);
               for j = 1:num_bins
                    patname = pat_bin_list{j};
                    fullpatname = strcat(patname,'.pat');
                    patternList{j} = fullpatname;
                    patfilepath = fullfile(patpath, fullpatname);
                    fileID = fopen(patfilepath,'w');
                    fwrite(fileID, self.binary_files.pats.(patname))
                    fclose(fileID);
                end

                %Initialize entire currentExp structure so fields do not
                %get out of order

                newcurrentExp.pattern.pattNames = { };
                newcurrentExp.pattern.patternList = { };
                newcurrentExp.pattern.x_num = [];
                newcurrentExp.pattern.y_num = [];
                newcurrentExp.pattern.gs_val = [];
                newcurrentExp.pattern.arena_pitch = [];
                newcurrentExp.pattern.num_patterns = 0;

                newcurrentExp.function.functionName = {};
                newcurrentExp.function.functionList = {};
                newcurrentExp.function.functionSize = [];
                newcurrentExp.function.numFunc = 0;

                newcurrentExp.aoFunction.aoFunctionName = {};
                newcurrentExp.aoFunction.aoFunctionList = {};
                newcurrentExp.aoFunction.aoFunctionSize = [];
                newcurrentExp.aoFunction.numaoFunc = 0;

                %Develop newcurrentExp file from values in the used patterns,
                %funcs, and aofuncs

                %newcurrentExp.pattern
                for j = 1:num_pats
                    file = pat_list{j};
                    field = self.get_pattern_field_name(file);
                    newcurrentExp.pattern.x_num(j) = self.Patterns.(field).pattern.x_num;
                    newcurrentExp.pattern.y_num(j) = self.Patterns.(field).pattern.y_num;
                    if isfield(self.Patterns.(field).pattern, 'gs_val')
                        newcurrentExp.pattern.gs_val(j) = self.Patterns.(field).pattern.gs_val;
                    else
                        newcurrentExp.pattern.gs_val(j) = [];
                    end
                    if isfield(self.Patterns.(field).pattern.param, 'arena_pitch')
                        newcurrentExp.pattern.arena_pitch(j) = self.Patterns.(field).pattern.param.arena_pitch;
                    else
                        newcurrentExp.pattern.arena_pitch(j) = 0;
                    end
                    pat_list{j} = strcat(file, '.mat');

                end
                newcurrentExp.pattern.pattNames = pattNames;
                newcurrentExp.pattern.patternList = patternList;%list of .pat files
                newcurrentExp.pattern.num_patterns = num_pats;

                %newcurrentExp.function
                if ~strcmp(func_list{1},'')
                    for k = 1:num_funcs
                        file = func_list{k};
                        field = self.get_posfunc_field_name(file);
                        newcurrentExp.function.functionSize{k} = self.Pos_funcs.(field).pfnparam.size;
                        func_list{k} = strcat(file, '.mat');
                        newcurrentExp.function.functionName{k} = func_list{k};
                        func_bin_list{k} = strcat(func_bin_list{k},'.pfn');
                    end
                   % newcurrentExp.function.functionName = num2cell(func_list);
                    newcurrentExp.function.functionList = func_bin_list;%.pfn files
                    newcurrentExp.function.numFunc = num_funcs;
                end

                if ~strcmp(ao_list{1},'')
                    for p = 1:num_ao
                        file = ao_list{p};
                        field = self.get_aofunc_field_name(file);
                        newcurrentExp.aoFunction.aoFunctionSize{p} = self.Ao_funcs.(field).afnparam.size;
                        ao_list{p} = strcat(file, '.mat');
                        ao_bin_list{p} = strcat(ao_bin_list{p},'.afn');
                    end
                    newcurrentExp.aoFunction.aoFunctionName = ao_list;
                    newcurrentExp.aoFunction.aoFunctionList = ao_bin_list;%.afn files
                    newcurrentExp.aoFunction.numaoFunc = num_ao;
                end

                self.set_currentExp(newcurrentExp);
                currentExp = self.currentExp;
                currentExpFile = 'currentExp.mat';
                filepath = fullfile(Exppath, currentExpFile);

                save(filepath, 'currentExp');

                export_successful = 1;
            end
        end


        function [opened_data] = open(self, filepath)
            opened_data = load(filepath, '-mat');
            self.set_save_filename(filepath);
        end

        function saveas(self, path, prog)

            homemade_ext = '.g4p';
            % Replace .mat extension with homemade one

            [savepath, name, ~] = fileparts(path);
            savename = strcat(name, homemade_ext);
            self.set_top_export_path(fullfile(savepath, self.experiment_name));
            % Get path to file you want to save including new extension
            save_file = fullfile(self.top_export_path, savename);
            self.set_save_filename(save_file);
            if isfile(save_file)
                question = 'This file already exists. Are you sure you want to replace it?';
                replace = questdlg(question);
                if strcmp(replace, 'Yes') == 1
                    confirm = strcat('Are you sure you want to replace ', savename, '?');
                    confirmation = questdlg(confirm);
                    if strcmp(confirmation,'Yes') == 1
                        recycle('on');
                        delete(save_file);
                        temp_path = strcat(self.top_export_path, 'temp');
                        movefile(self.top_export_path, temp_path);
                        self.set_top_folder_path(temp_path);
                    else
                        return;
                    end
                else
                    return;
                end
            else
                temp_path = '';
            end

            waitbar(.5, prog, 'Exporting...');
            export_successful = self.export();% 0 - export was unable to complete 1- export completed successfully 2-user canceled and export not attempted
            if export_successful == 0
                self.create_error_box("Export was unsuccessful. Please delete files to be overwritten manually and try again.");
                return;
            elseif export_successful == 2
                return;
            else
                exp_parameters = self.create_parameters_structure();
                save(self.save_filename, 'exp_parameters');
                if strcmp(temp_path,'') == 0
                    rmdir(temp_path,'s');
                end
            end
            waitbar(1, prog, 'Save Successful');
            close(prog);
        end

        function save(self)
            if isempty(self.save_filename) == 1
                self.create_error_box("You have not yet saved a new file. Please use 'save as'");
            else
                export_successful = self.export();
                if export_successful == 0
                    self.create_error_box("Export was unsuccessful. Please delete folders to be replaced and use save as.");
                elseif export_successful == 2
                    return;
                else
                exp_parameters = self.create_parameters_structure();
                save(self.save_filename, 'exp_parameters');
                end
            end
        end

%Import a file, called from controller when a file instead of folder is imported------------------------------------------------------
        function import_single_file(self, file, path)
            file_full = fullfile(path, file);
            [filepath, name, ext] = fileparts(file_full);
            if strcmp(ext, '.mat') == 0
                self.create_error_box("Please make sure you are importing a .mat file");
                return;
            end

            fileData = load(file_full);

            if isempty(fieldnames(fileData))
                self.create_error_box("I see no structure inside this .mat file. Please make sure it is formatted correctly.");
                return;
            end
            type = fieldnames(fileData);
            if strcmp(type{1},'pattern') == 1

                patRows = length(fileData.pattern.Pats(:,1,1))/16;
                if patRows ~= self.num_rows
                    self.create_error_box("Please make sure the patterns you import match the number of rows you have selected.");
                    return;
                end
                pat_already_present = sum(count(self.imported_pattern_names,name)); %if 0, it's not present, if 1 it is.
                if pat_already_present > 1
                    self.create_error_box("This pattern name is present multiple times in the imported patterns.");
                    return;
                elseif pat_already_present == 1
                    self.create_error_box("A pattern of that name has already been imported.");
                    return;
                else
                    self.imported_pattern_names{end+1} = name;
                    fieldname = "Pattern" + length(self.imported_pattern_names);
                    fileData.filename = name;
                    self.Patterns.(fieldname) = fileData;
                    self.pattern_locations.(fieldname) = filepath;
                    success_message = "One Pattern file imported successfully.";

                    %If they are importing an individual file, we must try
                    %to find the associated binary file in the same folder.
                    %It will be named by the id field of the .mat file.
                    %This will help us recreate the binary file name.
                    bin_ext = '.pat';
                    id = num2str(fileData.pattern.param.ID);
                    num_zeroes_to_add = 4 - numel(id);
                    fileid = '';
                    for i = 1:num_zeroes_to_add
                        fileid = strcat(fileid,'0');
                    end
                    fileid = strcat(fileid, id);
                    fileid1 = strcat('pat',fileid,bin_ext);%pat0001.pat
                    fileid2 = strcat(fileid, bin_ext);%0001.pat
                end
                %add to Patterns
            elseif strcmp(type{1},'pfnparam') == 1

                pos_already_present = sum(count(self.imported_posfunc_names,name)); %if 0, it's not present, if 1 it is.
                if pos_already_present > 1
                    self.create_error_box("This position function is present multiple times in the imported functions.");
                    return;
                elseif pos_already_present == 1
                    self.create_error_box("A position function of that name has already been imported.");
                    return;
                else
                    self.imported_posfunc_names{end+1} = name;
                    fieldname = "Function" + length(self.imported_posfunc_names);
                    fileData.filename = name;
                    self.Pos_funcs.(fieldname) = fileData;
                    self.function_locations.(fieldname) = filepath;
                    success_message = "One Position Function imported successfully.";

                    %create binary file name

                    bin_ext = '.pfn';
                    id = num2str(fileData.pfnparam.ID);
                    num_zeroes_to_add = 4 - numel(id);
                    fileid = '';
                    for i = 1:num_zeroes_to_add
                        fileid = strcat(fileid,'0');
                    end
                    fileid = strcat(fileid, id);
                    fileid1 = strcat('fun',fileid,bin_ext); %fun0001.pfn
                    fileid2 = strcat(fileid, bin_ext);%0001.pfn
                end
                %add to ao functions
            elseif strcmp(type{1},'afnparam') == 1

                ao_already_present = sum(count(self.imported_aofunc_names,name)); %if 0, it's not present, if 1 it is.
                if ao_already_present > 1
                    self.create_error_box("This ao function is present multiple times in the imported functions.");
                    return;
                elseif ao_already_present == 1
                    self.create_error_box("An AO function of that name has already been imported.");
                    return;
                else
                    self.imported_aofunc_names{end+1} = name;
                    fieldname = "AOFunction" + length(self.imported_aofunc_names);
                    fileData.filename = name;
                    self.Ao_funcs.(fieldname) = fileData;
                    self.aoFunc_locations.(fieldname) = import_loc;
                    success_message = "One AO Function imorted successfully.";

                    %create binary file name
                    bin_ext = '.afn';
                    id = num2str(fileData.afnparam.ID);
                    num_zeroes_to_add = 4 - numel(id);
                    fileid = '';
                    for i = 1:num_zeroes_to_add
                        fileid = strcat(fileid,'0');
                    end
                    fileid = strcat(fileid, id);
                    fileid1 = strcat('ao',fileid,bin_ext); %ao0001.afn
                    fileid2 = strcat(fileid, bin_ext);%0001.afn
                end
                %add to pos funcs

            elseif strcmp(type{1},'currentExp') == 1
                if ~isempty(fieldnames(self.currentExp))
                    success_message = "One currentExp file imported, replacing the previous one.";
                else
                    success_message = "One currentExp file imported.";
                end
                self.set_currentExp(load(file_full));
                bin_ext = '';
                fileid = 0;
            else
                self.create_error_box("Please make sure your file is a pattern, position function, ao function, or currentExp file, and is formatted correctly.");
                return;
            end
            if fileid == 0
                waitfor(msgbox(success_message));
                return;
            end

            binary_path = fullfile(path, fileid1);
            binary_path2 = fullfile(path, fileid2);
            if ~isfile(binary_path) && ~isfile(binary_path2)
                self.create_error_box("Your file was imported, but no associated binary file was found.");
                return;
            end
            if isfile(binary_path) && isfile(binary_path2)
                self.create_error_box("Your file was imported, but there two binary files in this location with this ID.");
                return;
            end
            if isfile(binary_path)
                bin = fopen(binary_path);
                binData = fread(bin);
                fclose(bin);
                bin_file = fileid1;
            elseif isfile(binary_path2)
                bin = fopen(binary_path2);
                binData = fread(bin);
                fclose(bin);
                bin_file = fileid2;
            end

            if strcmp(bin_ext,'.pat')
                field_name = strcat('pat', fileid);
                if isfield(self.binary_files.pats, field_name)
                    
                    highestID_imported = self.get_highest_ID_imported('pattern');
                    new_ID = highestID_imported + 1;
                    fileData.pattern.param.ID = new_ID;

                    num_zeroes_to_add = 4 - numel(num2str(new_ID));
                    new_fileid = '';
                    for i = 1:num_zeroes_to_add
                        new_fileid = strcat(new_fileid,'0');
                    end
                    new_fileid = strcat(new_fileid,num2str(new_ID));
                    new_field_name = strcat('pat',new_fileid);
                    self.binary_files.pats.(new_field_name) = binData;
                    fieldname = "Pattern" + length(self.imported_pattern_names);
                    self.Patterns.(fieldname) = fileData;

                    warndlg("The file you tried to import has had a new ID assigned to it of " + num2str(new_ID) + " because its ID matched another imported pattern.");
                    %return;
                else
                    self.binary_files.pats.(field_name) = binData;
                end
            elseif strcmp(bin_ext,'.pfn')
                field_name = strcat('fun',fileid);
                if isfield(self.binary_files.funcs, field_name)

                    highestID_imported = self.get_highest_ID_imported('pos');
                    new_ID = highestID_imported + 1;
                    fileData.pfnparam.ID = new_ID;

                    num_zeroes_to_add = 4 - numel(num2str(new_ID));
                    new_fileid = '';
                    for i = 1:num_zeroes_to_add
                        new_fileid = strcat(new_fileid,'0');
                    end
                    new_fileid = strcat(new_fileid,num2str(new_ID));
                    new_field_name = strcat('fun',new_fileid);
                    self.binary_files.funcs.(new_field_name) = binData;
                    fieldname = "Function" + length(self.imported_posfunc_names);
                    self.Pos_funcs.(fieldname) = fileData;

                    warndlg("The file you tried to import has had a new ID assigned to it of " + num2str(new_ID) + " because its ID matched another imported position function.");

%                     self.create_error_box("Your file was imported but the .pfn file was not. A function with that ID has already been imported."));
%                     return;
                else
                    self.binary_files.funcs.(field_name) = binData;
                end
            elseif strcmp(bin_ext,'.afn')
                field_name = strcat('ao',fileid);
                if isfield(self.binary_files.ao, field_name)

                    highestID_imported = self.get_highest_ID_imported('ao');
                    new_ID = highestID_imported + 1;
                    fileData.afnparam.ID = new_ID;

                    num_zeroes_to_add = 4 - numel(num2str(new_ID));
                    new_fileid = '';
                    for i = 1:num_zeroes_to_add
                        new_fileid = strcat(new_fileid,'0');
                    end
                    new_fileid = strcat(new_fileid,num2str(new_ID));
                    new_field_name = strcat('ao',new_fileid);
                    self.binary_files.ao.(new_field_name) = binData;
                    fieldname = "AOFunction" + length(self.imported_aofunc_names);
                    self.Ao_funcs.(fieldname) = fileData;

                    warndlg("The file you tried to import has had a new ID assigned to it of " + num2str(new_ID) + " because its ID matched another imported AO function.");


                else
                    self.binary_files.ao.(field_name) = binData;
                end
            end

            waitfor(msgbox(success_message));
        end

        function [highest_ID] = get_highest_ID_imported(self, filetype)
            if strcmp(filetype,'pattern')
                fn = fieldnames(self.Patterns);

                for i = 1:length(fn)
                    ids(i) = self.Patterns.(fn{i}).pattern.param.ID;
                end
                highest_ID = max(ids);
            elseif strcmp(filetype,'pos')
                fn = fieldnames(self.Pos_funcs);

                for i = 1:length(fn)
                    ids(i) = self.Pos_funcs.(fn{i}).pfnparam.ID;
                end
                highest_ID = max(ids);
            elseif strcmp(filetype,'ao')
                fn = fieldnames(self.Ao_funcs);
                for i = 1:length(fn)
                    ids(i) = self.Ao_funcs.(fn{i}).afnparam.ID;
                end
                highest_ID = max(ids);
            end
        end


        function [file_names, folder_names] = get_file_folder_names(self, path)
            all = dir(path);
            isub = [all(:).isdir];
            folder_names = {all(isub).name};
            folder_names(ismember(folder_names,{'.','..'})) = [];
            %folder_names(ismember(folder_names,{'Results','Log Files'})) = [];
            folder_names = folder_names(ismember(folder_names,{'Analog Output Functions', 'Functions', 'Patterns'}));
            for i = 1:length(isub)
                if isub(i) == 1
                    isub(i) = 0;
                else
                    isub(i) = 1;
                end
            end
            file_names = {all(isub).name};
            file_names(ismember(file_names,{'.','..'})) = [];
        end

        function [imported_pat_binaries, imported_pfn_binaries, imported_afn_binaries, ...
                        imported_patterns, imported_functions, imported_aos, ...
                        skipped_pat_binaries, skipped_pfn_binaries, skipped_afn_binaries, currentExp_replaced, ...
                        skipped_patterns, skipped_functions, skipped_aos, unrecognized_files] = ...
                        import_files(self, path, file_names, imported_pat_binaries, imported_pfn_binaries, imported_afn_binaries, ...
                        imported_patterns, imported_functions, imported_aos, ...
                        skipped_pat_binaries, skipped_pfn_binaries, skipped_afn_binaries, ...
                        currentExp_replaced, skipped_patterns, skipped_functions, skipped_aos, unrecognized_files)

                for i = 1:length(file_names)
                    full_file_path = fullfile(path, file_names{i});
                    [filepath, name, ext] = fileparts(full_file_path);
                    %[file_loc, ~] = fileparts(filepath);
                    if strcmp(ext, '.pat') == 1
                        fullname = strcat(name,ext);
                        pat = fopen(full_file_path);
                        patData = fread(pat);
                        fclose(pat);
                        if length(name) < 5
                            name = strcat('pat',name);
                        end

                        if isfield(self.binary_files.pats, name) == 1
                            skipped_pat_binaries = skipped_pat_binaries + 1;
                        else
                            self.binary_files.pats.(name) = patData;
                            imported_pat_binaries = imported_pat_binaries + 1;
                        end
                    elseif strcmp(ext, '.pfn') == 1
                        fullname = strcat(name,ext);
                        pfn = fopen(full_file_path);
                        pfnData = fread(pfn);
                        fclose(pfn);
                        if isfield(self.binary_files.funcs, name) == 1
                            skipped_pfn_binaries = skipped_pfn_binaries + 1;
                        else
                            self.binary_files.funcs.(name) = pfnData;
                            imported_pfn_binaries = imported_pfn_binaries + 1;
                        end
                    elseif strcmp(ext, '.afn') == 1
                        fullname = strcat(name,ext);
                        afn = fopen(full_file_path);
                        afnData = fread(afn);
                        fclose(afn);
                        if isfield(self.binary_files.ao, name) == 1
                            skipped_afn_binaries = skipped_afn_binaries + 1;
                        else
                            self.binary_files.ao.(name) = afnData;
                            imported_afn_binaries = imported_afn_binaries + 1;
                        end
                    elseif strcmp(ext, '.mat') == 1
                        type = fieldnames(load(full_file_path));

                        if strcmp(type{1},'pattern') == 1
                            patData = load(full_file_path);
                            patRows = length(patData.pattern.Pats(:,1,1))/16;
                            if patRows ~= self.num_rows
                                
                                self.create_error_box("Please make sure the patterns you import match the size screen you have selected (3 row or 4 row).", 'Screen size error');
                                
                                return;
                            end

                            pat_already_present = sum(count(self.imported_pattern_names,name)); %if 0, it's not present, if 1 it is.

                            if pat_already_present >= 1
                                skipped_patterns = skipped_patterns + 1;
                            else
                                self.imported_pattern_names{end+1} = name;
                                patfield = "Pattern" + length(self.imported_pattern_names);
                                patData.filename = name;
                                self.Patterns.(patfield) = patData;
                                self.pattern_locations.(patfield) = filepath;
                                imported_patterns = imported_patterns + 1;
                            end
                        elseif strcmp(type{1},'pfnparam') == 1
                            posData = load(full_file_path);
                            pos_already_present = sum(count(self.imported_posfunc_names, name));
                            if pos_already_present >= 1
                                skipped_functions = skipped_functions + 1;
                            else
                                self.imported_posfunc_names{end+1} = name;
                                posfield = "Function" + length(self.imported_posfunc_names);
                                posData.filename = name;
                                self.Pos_funcs.(posfield) = posData;
                                self.function_locations.(posfield) = filepath;
                                imported_functions = imported_functions + 1;
                            end
                        elseif strcmp(type{1},'afnparam') == 1
                            aoData = load(full_file_path);
                            ao_already_present = sum(count(self.imported_aofunc_names, name));
                            if ao_already_present >= 1
                                skipped_aos = skipped_aos + 1;
                            else
                                self.imported_aofunc_names{end+1} = name;
                                aofield = "AOFunction" + length(self.imported_aofunc_names);
                                aoData.filename = name;
                                self.Ao_funcs.(aofield) = aoData;
                                self.aoFunc_locations.(aofield) = filepath;
                                imported_aos = imported_aos + 1;
                            end
                        elseif strcmp(type{1},'currentExp') == 1
                            if isempty(fieldnames(self.currentExp)) == 0
                                currentExp_replaced = 1;
                            end
                            self.set_currentExp(load(full_file_path));
                            [folderpath, foldname] = fileparts(filepath);
                            self.set_experiment_name(foldname);
                        else
                            disp("Unrecognized field")
                            disp(strcat(name,ext))
                            unrecognized_files = unrecognized_files + 1;
                        end
                    elseif strcmp(ext,'.g4p')
                        %do nothing, this is the file you opened.
                    else
                        disp("Unrecognized ext")
                        disp(strcat(name,ext))
                        unrecognized_files = unrecognized_files + 1;
                    end
                end
        end
% Import a folder, called from the controller and calls more specific import functions for each type of folder ---------------------------------
        function success_statement = import_folder(self, path)
            % prog = waitbar(0, 'Importing...', 'WindowStyle', 'modal'); %start waiting bar
            self.set_top_folder_path(path);
            [file_names, folder_names] = self.get_file_folder_names(path);
            for fold = length(folder_names):-1:1
                if ~isempty(regexp(folder_names{fold}, '\d\d*_\d\d*_\d\d\d\d', 'once')) && regexp(folder_names{fold}, '\d\d*_\d\d*_\d\d\d\d')==1
                    folder_names(fold) = [];
                end
            end

            no_more_subfolders = 0;
            imported_patterns = 0;
            imported_functions = 0;
            imported_aos = 0;
            imported_pat_binaries = 0;
            imported_pfn_binaries = 0;
            imported_afn_binaries = 0;
            skipped_pat_binaries = 0;
            skipped_pfn_binaries = 0;
            skipped_afn_binaries = 0;
            skipped_patterns = 0;
            skipped_functions = 0;
            skipped_aos = 0;
            unrecognized_files = 0;
            currentExp_replaced = 0;

            while no_more_subfolders == 0
                if ~isempty(file_names)
                    %waitbar(.25, prog);
                    [imported_pat_binaries, imported_pfn_binaries, imported_afn_binaries, ...
                        imported_patterns, imported_functions, imported_aos, ...
                        skipped_pat_binaries, skipped_pfn_binaries, skipped_afn_binaries, currentExp_replaced, ...
                        skipped_patterns, skipped_functions, skipped_aos, unrecognized_files] = ...
                        self.import_files(path, file_names, imported_pat_binaries, imported_pfn_binaries, imported_afn_binaries, ...
                        imported_patterns, imported_functions, imported_aos, ...
                        skipped_pat_binaries, skipped_pfn_binaries, skipped_afn_binaries, ...
                        currentExp_replaced, skipped_patterns, skipped_functions, skipped_aos, unrecognized_files);
                end

                if ~isempty(folder_names)
                    next_folders_list = {};
                    %waitbar(.5, prog);
                    for i = 1:length(folder_names)
                        newpath = fullfile(path, folder_names{i});
                        [filenames, folders] = self.get_file_folder_names(newpath);

                        [imported_pat_binaries, imported_pfn_binaries, imported_afn_binaries, ...
                        imported_patterns, imported_functions, imported_aos, ...
                        skipped_pat_binaries, skipped_pfn_binaries, skipped_afn_binaries, currentExp_replaced, ...
                        skipped_patterns, skipped_functions, skipped_aos, unrecognized_files] = ...
                        self.import_files(newpath, filenames, imported_pat_binaries, imported_pfn_binaries, imported_afn_binaries, ...
                        imported_patterns, imported_functions, imported_aos, ...
                        skipped_pat_binaries, skipped_pfn_binaries, skipped_afn_binaries, ...
                        currentExp_replaced, skipped_patterns, skipped_functions, skipped_aos, unrecognized_files);

                        if ~isempty(folders)
                            for j = 1:length(folders)
                                next_folders_list{end+1} = strcat(folder_names{i},'\',folders{j});
                            end
                        end
                    end
                    if isempty(next_folders_list)
                        no_more_subfolders = 1;
                    end
                else
                    no_more_subfolders = 1;
                    next_folders_list = {};
                end
                folder_names = next_folders_list;
                %waitbar(1,prog,'Finishing...');
                %close(prog);
            end
            if [imported_patterns imported_functions imported_aos currentExp_replaced] == 0
                success_statement = "Nothing was imported.";
            else
                success_statement = "Import Successful!" + newline;    
                if imported_patterns ~= 0
                    patterns_imported_statement = imported_patterns + " patterns imported and " + skipped_patterns + " patterns skipped.";
                    success_statement = success_statement + patterns_imported_statement + newline;
                end
                if imported_functions ~= 0
                    functions_imported_statement = imported_functions + " position functions imported and " + skipped_functions + " functions skipped.";
                    success_statement = success_statement + functions_imported_statement + newline;
                end
                if imported_aos ~= 0
                    aos_imported_statement = imported_aos + " AO functions imported and " + skipped_aos + " AO functions skipped.";
                    success_statement = success_statement + aos_imported_statement + newline;
                end
                if unrecognized_files ~= 0
                    unrecognized_files_statement = unrecognized_files + " unrecognized files.";
                    success_statement = success_statement + unrecognized_files_statement + newline;
                end
                if currentExp_replaced ~= 0
                    currentExp_statement = "Previously loaded currentExp file was replaced.";
                    success_statement = success_statement + currentExp_statement;
                end
                if imported_patterns == 0 && skipped_patterns ~= 0
                    patterns_imported_statement = skipped_patterns + " patterns skipped.";
                    success_statement = success_statement + patterns_imported_statement + newline;
                end
                if imported_functions == 0 && skipped_functions ~= 0
                    functions_imported_statement = skipped_functions + " functions skipped.";
                    success_statement = success_statement + functions_imported_statement + newline;
                end
                if imported_aos == 0 && skipped_aos ~= 0
                    aos_imported_statement = skipped_aos + " AO functions skipped.";
                    success_statement = success_statement + aos_imported_statement + newline;
                end
            end

%
        end

        function replace_greyed_cell_values(self)

            for i = 1:length(self.pretrial)
                if strcmp(self.pretrial{i},self.get_uneditable_text())
                    if i >= 2 && i <= 7
                        self.pretrial{i} = '';
                    else
                        self.pretrial{i} = [];
                    end
                end
            end
            for i = 1:length(self.intertrial)
                if strcmp(self.intertrial{i},self.get_uneditable_text())
                    if i >= 2 && i <= 7
                        self.intertrial{i} = '';
                    else
                        self.intertrial{i} = [];
                    end
                end
            end
            for i = 1:length(self.posttrial)
                if strcmp(self.posttrial{i},self.get_uneditable_text())
                    if i >= 2 && i <= 7
                        self.posttrial{i} = '';
                    else
                        self.posttrial{i} = [];
                    end
                end
            end
            for i = 1:length(self.block_trials(:,1))
                for j = 1:length(self.block_trials(1,:))
                    if strcmp(self.block_trials{i,j},self.get_uneditable_text())
                        if j == 3
                            self.block_trials{i,j} = '';
                        else
                            self.block_trials{i,j} = [];
                        end
                    end
                end
            end
        end

        function [text] = get_uneditable_text(self)
            text = self.settings.Uneditable_Cell_Text;
        end

        function [color] = get_uneditable_color(self)
            color =  self.settings.Uneditable_Cell_Color;
        end

%CREATE STRUCTURE TO SAVE TO .G4P FILE WHEN SAVING------------------------
        function [vars] = create_parameters_structure(self)
            vars.block_trials = self.block_trials();
            vars.pretrial = self.pretrial();
            vars.intertrial = self.intertrial();
            vars.posttrial = self.posttrial();
            vars.is_randomized = self.is_randomized();
            vars.repetitions = self.repetitions();
            vars.is_chan1 = self.is_chan1();
            vars.is_chan2 = self.is_chan2();
            vars.is_chan3 = self.is_chan3();
            vars.is_chan4 = self.is_chan4();
            vars.chan1_rate = self.chan1_rate();
            vars.chan2_rate = self.chan2_rate();
            vars.chan3_rate = self.chan3_rate();
            vars.chan4_rate = self.chan4_rate();
            vars.num_rows = self.num_rows();
            vars.experiment_name = self.experiment_name;
        end

        function [is_disabled] = check_if_cell_disabled(self, cell_value)
            if strcmp(cell_value, self.settings.Uneditable_Cell_Text)
                is_disabled = 1;
            else
                is_disabled = 0;
            end
        end

        function [total_dur] = calc_exp_length(self)
            total_dur = 0;
            if ~isempty(self.pretrial{12})
                total_dur = total_dur + self.pretrial{12};
            end
            if ~isempty(self.posttrial{12})
                total_dur = total_dur + self.posttrial{12};
            end
            if ~isempty(self.intertrial{12})
                for i = 1:length(self.block_trials(:,1))
                    total_dur = total_dur + (self.block_trials{i,12} + self.intertrial{12})*self.repetitions;
                end
                total_dur = total_dur - self.intertrial{12};
            else
                for i = 1:length(self.block_trials(:,1))
                    total_dur = total_dur + (self.block_trials{i,12}*self.repetitions);
                end
            end
        end



%GET THE INDEX OF A GIVEN PATTERN, POS, OR AO NAME-------------------------
      function [index] = get_pattern_index(self, pat_name)
            if strcmp(pat_name,'') == 1
                index = 0;
            else
                
                if ~isempty(self.top_export_path)
                    pat_name = strcat(pat_name,'.mat');
                    currentExp_file = fullfile(self.top_export_path, 'currentExp.mat');
                    saved_currentExp = load(currentExp_file);
                    fields = saved_currentExp.currentExp.pattern.pattNames;
                    index = find(strcmp(fields, pat_name));
                else
                     pat_field = self.get_pattern_field_name(pat_name);
                     pat_location = self.pattern_locations.(pat_field);
                    % pat_number = str2num(erase(pat_field, 'Pattern'));
                    % for num = 1:pat_number
                    %     loc_list{num} = self.pattern_locations.(strcat('Pattern', num2str(pat_number)));
                    % end
                    % index = sum(contains(loc_list, pat_location));

                    %Get file names of patterns in location
                    all = dir(pat_location);
                    isub = [all(:).isdir];
                    for i = 1:length(isub)
                        if isub(i) == 1
                            isub(i) = 0;
                        else
                            isub(i) = 1;
                        end
                    end
                    file_names = {all(isub).name};
                    file_names(ismember(file_names,{'.','..'})) = [];
                    index = find(contains(file_names, strcat(pat_name, '.mat')));


                end
            end
        end

        function [index] = get_posfunc_index(self, pos_name)
            if strcmp(pos_name,'') == 1
                index = 0;
            else
                if ~isempty(self.top_export_path)
                    pos_name = strcat(pos_name,'.mat');
                    currentExp_file = fullfile(self.top_export_path, 'currentExp.mat');
                    saved_currentExp = load(currentExp_file);
                    fields = saved_currentExp.currentExp.function.functionName;
                    index = find(strcmp(fields, pos_name));
                else
                    pos_field = self.get_posfunc_field_name(pos_name);
                    pos_location = self.function_locations.(pos_field);
                    all = dir(pos_location);
                    isub = [all(:).isdir];
                    for i = 1:length(isub)
                        if isub(i) == 1
                            isub(i) = 0;
                        else
                            isub(i) = 1;
                        end
                    end
                    file_names = {all(isub).name};
                    file_names(ismember(file_names,{'.','..'})) = [];
                    index = find(contains(file_names, strcat(pos_name, '.mat')));
                end
            end
        end

        function [index] = get_ao_index(self, ao_name)
            if strcmp(ao_name,'') == 1
                index = 0;
            else
               
                ao_name = strcat(ao_name, '.mat');
                currentExp_file = fullfile(self.top_export_path, 'currentExp.mat');
                saved_currentExp = load(currentExp_file);
                fields = saved_currentExp.currentExp.aoFunction.aoFunctionName;
                index = find(strcmp(fields, ao_name));
            

            end
        end

        function [settings_data, path, index] = get_setting(self, file, string_to_find)
            last_five = string_to_find(end-5:end);
            try
                settings_data = strtrim(regexp( fileread(file),'\n','split'));
            catch 
                warning('A filepath from your settings file could not be found. Check settings for accuracy.');
                settings_data = [];
            end
            if ~isempty(settings_data)
                path = find(contains(settings_data, string_to_find));
                index = strfind(settings_data{path},last_five) + 5;
            else
                path = [];
                index = 0;
            end
        end

        function [digit] = get_ending_number_from_file(self, file, string_to_find)
            if sum(~strcmp(file, self.configData)) == 0
                data = self.configData;
            else
                data = strtrim(regexp( fileread(file),'\n','split'));
            end

            index = find(contains(data,string_to_find));
            line = strtrim(self.configData{index});

            %Figure out how many digits are in the last half of this line
            %in the config file, in order to determine the sample rate

            digits = isstrprop(line,'digit');
            count = 0; %the count of 1's in digits, each signifying a number in the rate1 string

            %Only look at the last half of digits, meaning only numbers in
            %the last half of the line. This way numbers in the title don't skew results (ie,
            %in ACD0 Rate (Hz) = 1000 we want to ignore the first 0)

            for i = round(length(digits)/2):length(digits)
                if digits(i) == 1
                    count = count + 1;
                end
            end
            digit = str2num(line((end-count+1):end));

        end

        %% Color inactive cells depending on the current mode of the trial
        %
        % Reads 1st column from trial values, modifies properties via
        % set_*_property()
%         function insert_greyed_cells(self)
% 
%             pretrial_mode = self.pretrial{1};
%             intertrial_mode = self.intertrial{1};
%             posttrial_mode = self.posttrial{1};
%             pre_indices_to_color = [];
%             inter_indices_to_color = [];
%             post_indices_to_color = [];
%             indices_to_color = [];
%             if ~isempty(pretrial_mode)
%                 if pretrial_mode == 1
%                     pre_indices_to_color = [9, 10, 11];
%                 elseif pretrial_mode == 2
%                     pre_indices_to_color = [3, 10, 11];
%                 elseif pretrial_mode == 3
%                     pre_indices_to_color = [3, 9, 10, 11];
%                 elseif pretrial_mode == 4
%                     pre_indices_to_color = [3, 9];
%                 elseif pretrial_mode == 5 || pretrial_mode == 6
%                     pre_indices_to_color = 9;
%                 elseif pretrial_mode == 7
%                     pre_indices_to_color = [3, 9, 10, 11];
%                 end
%             end
% 
%             if ~isempty(intertrial_mode)
%                 if intertrial_mode == 1
%                     inter_indices_to_color = [9, 10, 11];
%                 elseif intertrial_mode == 2
%                     inter_indices_to_color = [3, 10, 11];
%                 elseif intertrial_mode == 3
%                     inter_indices_to_color = [3, 9, 10, 11];
%                 elseif intertrial_mode == 4
%                     inter_indices_to_color = [3, 9];
%                 elseif intertrial_mode == 5 || intertrial_mode == 6
%                     inter_indices_to_color = 9;
%                 elseif intertrial_mode == 7
%                     inter_indices_to_color = [3, 9, 10, 11];
%                 end
%             end
% 
%             if ~isempty(posttrial_mode)
%                 if posttrial_mode == 1
%                     post_indices_to_color = [9, 10, 11];
%                 elseif posttrial_mode == 2
%                     post_indices_to_color = [3, 10, 11];
%                 elseif posttrial_mode == 3
%                     post_indices_to_color = [3, 9, 10, 11];
%                 elseif posttrial_mode == 4
%                     post_indices_to_color = [3, 9];
%                 elseif posttrial_mode == 5 || posttrial_mode == 6
%                     post_indices_to_color = 9;
%                 elseif posttrial_mode == 7
%                     post_indices_to_color = [3, 9, 10, 11];
%                 end
%             end
% 
%             for i = 1:length(pre_indices_to_color)
%                 self.set_trial_property(1, pre_indices_to_color(i), self.get_uneditable_text(), 'pre');
%             end
%             for i = 1:length(inter_indices_to_color)
%                 self.set_trial_property(1, inter_indices_to_color(i),self.get_uneditable_text(), 'inter');
% 
%             end
%             for i = 1:length(post_indices_to_color)
%                 self.set_trial_property(1, post_indices_to_color(i),self.get_uneditable_text(), 'post');
%             end
% 
%             for i = 1:length(self.block_trials(:,1))
%                 mode = self.block_trials{i,1};
%                 if ~isempty(mode)
%                     if mode == 1
%                         indices_to_color = [9, 10, 11];
%                     elseif mode == 2
%                         indices_to_color = [3, 10, 11];
%                     elseif mode == 3
%                         indices_to_color = [3, 9, 10, 11];
%                     elseif mode == 4
%                         indices_to_color = [3, 9];
%                     elseif mode == 5 || mode == 6
%                         indices_to_color = 9;
%                     elseif mode == 7
%                         indices_to_color = [3, 9, 10, 11];
%                     end
%                 end
%                 for j = 1:length(indices_to_color)
%                     self.set_trial_property(i,indices_to_color(j),self.get_uneditable_text(), 'block');
%                     
% 
%                 end
%             end
%         end

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

        %% Setters
        function set_top_folder_path(self, value)
            self.top_folder_path = value;
        end

        function set_top_export_path(self, value)
            self.top_export_path = value;
        end

        function set_Patterns(self, value)
            self.Patterns = value;
        end

        function set_Pos_funcs(self, value)
            self.Pos_funcs = value;
        end

        function set_Ao_funcs(self, value)
            self.Ao_funcs = value;
        end

        function set_save_filename(self, value)
            self.save_filename = value;
        end

        function set_currentExp(self, value)
            self.currentExp = value;
        end

        function set_experiment_name(self, value)
            % add timestamp to name if it's not empty
            if ~isempty(value)
                dateFormat = 'mm-dd-yy_HH-MM-SS';
                dated_exp_name = strcat(value, datestr(now, dateFormat));
            else
                dated_exp_name = value;
            end
            self.experiment_name = dated_exp_name;
        end

        function set_pretrial(self, value)
            self.pretrial = value;
        end

        function set_intertrial(self, value)
            self.intertrial = value;
        end

        function set_block_trials(self, value)
            self.block_trials = value;
        end

        function set_posttrial(self, value)
            self.posttrial = value;
        end

        function set_repetitions(self, value)
            self.repetitions = value;
        end

        function set_is_randomized(self, value)
            self.is_randomized = value;
        end

        function set_num_rows(self, value)
            self.num_rows = value;
        end

        function set_is_chan1(self, value)
            self.is_chan1 = value;
        end

        function set_is_chan2(self, value)
            self.is_chan2 = value;
        end

        function set_is_chan3(self, value)
            self.is_chan3 = value;
        end

        function set_is_chan4(self, value)
            self.is_chan4 = value;
        end

        function set_chan1_rate(self, value)
            if rem(value,100) ~= 0 && value ~= 0
                self.create_error_box("The value you've entered is not a multiple of 100. Please double check your entry.");
            else
                self.chan1_rate = value;
                if value == 0
                    self.set_is_chan1(0);
                else
                    self.set_is_chan1(1);
                end
            
            end
        end

        function set_chan2_rate(self, value)
            if rem(value,100) ~= 0 && value ~= 0
                self.create_error_box("The value you've entered is not a multiple of 100. Please double check your entry.");
            else
                self.chan2_rate = value;
                if value == 0
                    self.set_is_chan2(0);
                else
                    self.set_is_chan2(1);
                end
            
            end
        end

        function set_chan3_rate(self, value)
            if rem(value,100) ~= 0 && value ~= 0
                self.create_error_box("The value you've entered is not a multiple of 100. Please double check your entry.");
            else
                self.chan3_rate = value;
                if value == 0
                    self.set_is_chan3(0);
                else
                    self.set_is_chan3(1);
                end
            
            end
        end

        function set_chan4_rate(self, value)
            if rem(value,100) ~= 0 && value ~= 0
                self.create_error_box("The value you've entered is not a multiple of 100. Please double check your entry.");
            else
                self.chan4_rate = value;
                if value == 0
                    self.set_is_chan4(0);
                else
                    self.set_is_chan4(1);
                end
            
            end
        end

        function set_configData(self, value)
            self.configData = value;
        end

        function set_binary_files(self, value)
            self.binary_files = value;
        end

        function set_imported_pattern_names(self,value)
            self.imported_pattern_names = value;
        end

        function set_imported_posfunc_names(self, value)
            self.imported_posfunc_names = value;
        end

        function set_imported_aofunc_names(self, value)
            self.imported_aofunc_names = value;
        end

        function set_recent_g4p_files(self, value)
            self.recent_g4p_files = value;
        end

        function set_recent_files_filepath(self, value)
            self.recent_files_filepath = value;
        end

        function set_est_exp_length(self, value)
            self.est_exp_length = value;
        end

        function set_trial_data(self, value)
            self.trial_data = value;
        end

        function set_pattern_locations(self, value)
            self.pattern_locations = value;
        end

        function set_function_locations(self, value)
            self.function_locations = value;
        end

        function set_aoFunc_locations(self, value)
            self.aoFunc_locations = value;
        end

        function set_settings(self, value)
            self.settings = value;
        end

        %% Getters
        function value = get_top_folder_path(self)
            value = self.top_folder_path;
        end

        function value = get_top_export_path(self)
            value = self.top_export_path;
        end

        function value = get_Patterns(self)
            value = self.Patterns;
        end

        function value = get_Pos_funcs(self)
            value = self.Pos_funcs;
        end

        function value = get_Ao_funcs(self)
            value = self.Ao_funcs;
        end

        function value = get_save_filename(self)
            value = self.save_filename;
        end

        function value = get_currentExp(self)
            value = self.currentExp;
        end

        function value = get_experiment_name(self)
            cut_date_off_name = regexp(self.experiment_name,'-','split');

            if length(cut_date_off_name) > 1
                value = cut_date_off_name{1}(1:end-2);
            else
                value = self.experiment_name;
            end
        end

        function output = get_pretrial(self)
            output = self.pretrial;
        end

        function output = get_block_trials(self)
            output = self.block_trials;
        end

        function output = get_intertrial(self)
            output = self.intertrial;
        end

        function output = get_posttrial(self)
            output = self.posttrial;
        end

        function output = get_repetitions(self)
            output = self.repetitions;
        end

        function output = get_is_randomized(self)
            output = self.is_randomized;
        end

        function output = get_is_chan1(self)
            output = self.is_chan1;
        end

        function output = get_chan1_rate(self)
            output = self.chan1_rate;
        end

        function output = get_is_chan2(self)
            output = self.is_chan2;
        end

        function output = get_chan2_rate(self)
            output = self.chan2_rate;
        end

        function output = get_is_chan3(self)
            output = self.is_chan3;
        end

        function output = get_chan3_rate(self)
            output = self.chan3_rate;
        end

        function output = get_is_chan4(self)
            output = self.is_chan4;
        end

        function output = get_chan4_rate(self)
           output = self.chan4_rate;
        end

        function output = get_num_rows(self)
            output = self.num_rows;
        end

        function output = get_configData(self)
            output = self.configData;
        end

        function output = get_binary_files(self)
            output = self.binary_files;
        end

        function output = get_imported_pattern_names(self)
            output = self.imported_pattern_names;
        end

        function output = get_imported_posfunc_names(self)
            output = self.imported_posfunc_names;
        end

        function output = get_imported_aofunc_names(self)
            output = self.imported_aofunc_names;
        end

        function output = get_recent_g4p_files(self)
            output = self.recent_g4p_files;
        end

        function output = get_recent_files_filepath(self)
            output = self.recent_files_filepath;
        end

        function output = get_est_exp_length(self)
            output = self.est_exp_length;
        end

        function output = get_trial_data(self)
            output = self.trial_data;
        end

        function output = get_pattern_locations(self)
            output = self.pattern_locations;
        end

        function output = get_function_locations(self)
            output = self.function_locations;
        end

        function output = get_aoFunc_locations(self)
            output = self.aoFunc_locations;
        end

        function output = get_settings(self)
            output = self.settings;
        end

    end
end
