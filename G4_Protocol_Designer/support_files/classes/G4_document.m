classdef G4_document < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        top_folder_path_
        top_export_path_
        Patterns_
        Pos_funcs_
        Ao_funcs_
        binary_files_
        save_filename_
        currentExp_
        experiment_name_
        
        %Variables saved to .g4p files
        pretrial_
        block_trials_
        intertrial_
        posttrial_
        repetitions_
        is_randomized_
        num_rows_
        is_chan1_
        chan1_rate_
        is_chan2_
        chan2_rate_
        is_chan3_
        chan3_rate_
        is_chan4_
        chan4_rate_
        trial_data
        
        %Data to save to configuration file
        configData_
        
    end
    
    
    properties (Dependent)
        top_folder_path
        top_export_path
        Patterns
        Pos_funcs
        Ao_funcs
        binary_files
        save_filename
        currentExp
        experiment_name
        
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
        
        configData
        
    end
    
    methods

%CONSTRUCTOR--------------------------------------------------------------        
        function self = G4_document()

%Set these properties to empty values until they are needed
            
            self.top_folder_path = '';
            self.top_export_path = '';
            self.Patterns = struct;
            self.Pos_funcs = struct;
            self.Ao_funcs = struct;
            self.binary_files.pats = struct;
            self.binary_files.funcs = struct;
            self.binary_files.ao = struct;
            self.save_filename = '';
            self.currentExp = struct;
            self.experiment_name = '';
            self.trial_data = G4_trial_model();
            
%Make table parameters into a cell array so they work with the tables more easily

            self.pretrial = self.trial_data.trial_array;
            self.intertrial = self.trial_data.trial_array;
            self.block_trials = self.trial_data.trial_array;
            self.posttrial = self.trial_data.trial_array;
            
%Get the path to the configuration file from settings and set the config data to the data within the configuration file

            settings_data = strtrim(regexp( fileread('G4_Protocol_Designer_settings.m'),'\n','split'));
            path_line = find(contains(settings_data,'Configuration File Path:'));
            path_index = strfind(settings_data{path_line},'Path: ');
            path = settings_data{path_line}(path_index+6:end);
            self.configData = strtrim(regexp( fileread(path),'\n','split'));
            
%Find line with number of rows and get value -------------------------------------------
            numRows_line = find(contains(self.configData,'Number of Rows'));
            self.num_rows = str2num(self.configData{numRows_line}(end));
            
%Determine channel sample rates--------------------------------------------

            rate1_line = find(contains(self.configData,'ADC0'));
            rate1 = strtrim(self.configData{rate1_line});
            
            %Figure out how many digits are in the last half of this line
            %in the config file, in order to determine the sample rate
            
            digits1 = isstrprop(rate1,'digit');
            count1 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            
            %Only look at the last half of digits, meaning only numbers in
            %the last half of the line. This way numbers in the title don't skew results (ie,
            %in ACD0 Rate (Hz) = 1000 we want to ignore the first 0)
            
            for i = round(length(digits1)/2):length(digits1)
            
                if digits1(i) == 1
                    count1 = count1 + 1;
                end
            
            end
            self.chan1_rate = str2num(rate1((end-count1+1):end));
            
%Do the same for channels 2, 3, and 4--------------------------------------

            rate2_line = find(contains(self.configData,'ADC1'));
            rate2 = strtrim(self.configData{rate2_line});
            
            digits2 = isstrprop(rate2,'digit');
            count2 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            for i = round(length(digits2)/2):length(digits2)
            
                if digits2(i) == 1
                    count2 = count2 + 1;
                end
            
            end
            self.chan2_rate = str2num(rate2((end-count2+1):end));
            
            rate3_line = find(contains(self.configData,'ADC2'));
            rate3 = strtrim(self.configData{rate3_line});
            
            digits3 = isstrprop(rate3,'digit');
            count3 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            for i = round(length(digits3)/2):length(digits3)
            
                if digits3(i) == 1
                    count3 = count3 + 1;
                end
            
            end
            
            self.chan3_rate = str2num(rate3((end-count3+1):end));
            
            rate4_line = find(contains(self.configData,'ADC3'));
            rate4 = strtrim(self.configData{rate4_line});
            
            digits4 = isstrprop(rate4,'digit');
            count4 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            for i = round(length(digits4)/2):length(digits4)
            
                if digits4(i) == 1
                    count4 = count4 + 1;
                end
            
            end
            
             self.chan4_rate = str2num(rate4((end-count4+1):end));
            
            self.repetitions = 1;
            self.is_randomized = 0;
            self.is_chan1 = 0;
           
            self.is_chan2 = 0;
           
            self.is_chan3 = 0;
            
            self.is_chan4 = 0;
        
        end
        
%SETTING INDIVIDUAL TRIAL PROPERTIES---------------------------------------

        function set_block_trial_property(self, index, new_value)
            
%Adding a new row

            if index(1) > size(self.block_trials,1)
                self.block_trials = [self.block_trials;new_value];
%                 block_data = self.block_trials;
            
            else

%If the user edited the pattern or position function, make sure the file dimensions match
                if index(2) == 1 && ~strcmp(num2str(new_value),'')
                    if ~isnumeric(new_value)
                        new_value = str2num(new_value);
                    end
                    if new_value < 1 || new_value > 7
                        waitfor(errordlg("Mode must be 1-7 or left empty."));
                        return;
                    end
                end
                
                if index(2) == 2 && ~strcmp(string(new_value),'')
                    patfield = new_value;
                    if ~isfield(self.Patterns, patfield)
                        waitfor(errordlg("That filename does not match any imported files."));
                        return;
                    end
                    patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                    patRows = length(self.Patterns.(patfield).pattern.Pats(:,1,1))/16;
                    numrows = self.num_rows;
                
                    if ~strcmp(string(self.block_trials{index(1),3}),'')

                        posfield = self.block_trials{index(1),3};
                        funcDim = max(self.Pos_funcs.(posfield).pfnparam.func);

                    else

                        patDim = 0;
                        funcDim = 0;

                    end

                elseif index(2) == 3 && ~strcmp(string(new_value),'') && ~strcmp(string(self.block_trials{index(1),2}),'')

                    posfield = new_value;
                    if ~isfield(self.Pos_funcs, posfield)
                        waitfor(errordlg("That filename does not match any imported files."));
                        return;
                    end
                    patfield = self.block_trials{index(1),2};
                    patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                    funcDim = max(self.Pos_funcs.(posfield).pfnparam.func);
                    patRows = 0;
                    numrows = 0;
                else
                    patDim = 0;
                    funcDim = 0;
                    patRows = 0;
                    numrows = 0;
                end
                
                if index(2) > 3 && index(2) < 8 && ~strcmp(string(new_value),'')
                    if ~isfield(self.Ao_funcs, new_value)
                        waitfor(errordlg("That filename does not match any imported files."));
                        return;
                    end
                end
                
                if index(2) == 8 && ~strcmp(num2str(new_value),'')
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

                    associated_pattern = self.block_trials{index(1),2};
                    if ~isempty(associated_pattern)
                        num_pat_frames = length(self.Patterns.(associated_pattern).pattern.Pats(1,1,:));
                        if chars == 0
                            if str2num(new_value) > num_pat_frames
                                waitfor(errordlg("Please make sure your frame index is within the bounds of your pattern."));
                                return
                            end
                        end
                    end
                    if  chars == 1 && ~strcmp(new_value,'r')
                        waitfor(errordlg("Invalid frame index. Please enter a number or 'r'"));
                        return;
                    end
                end
                
            
            %Make sure frame rate is > 0
            
            if index(2) == 9 && ~strcmp(num2str(new_value),'')
               if ~isnumeric(new_value)
                   new_value = str2num(new_value);
               end
                if new_value <= 0 
                    waitfor(errordlg("Your frame rate must be above 0"));
                    return;
                end
               
            end
                    
            %Make sure gain/offset are numerical
            
            if index(2) == 10 || index(2) == 11 && ~strcmp(num2str(new_value),'')
               
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                
            end
            
            if index(2) == 12 && ~strcmp(num2str(new_value),'')
               
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if new_value < 0
                    waitfor(errordlg("You duration must be zero or greater"));
                    return;
                end
                
            end

            if patRows ~= numrows
                waitfor(errordlg("Watch out! This pattern will not run on the size screen you have selected."));
            end
            if patDim < funcDim
                 waitfor(errordlg("Please make sure the dimension of your pattern and position functions match"));
            else

%Set value
                 self.block_trials{index(1), index(2)} = new_value;
            end
            end
        end
        
%%%%%%%%%%%%%%%%%%%Consider making the dimension checking a single separate
%%%%%%%%%%%%%%%%%%%function

%Same as above for pretrial, intertrial, and posttrial

        function set_pretrial_property(self, index, new_value)
            %If the user edited the pattern or position function, make sure
            %the file dimensions match
            if index == 1 && ~isempty(new_value)
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if new_value < 1 || new_value > 7
                    waitfor(errordlg("Mode must be 1-7 or left empty."));
                    return;
                end
            end
            
            
            if index == 2 && strcmp(string(new_value),'') == 0
                patfield = new_value;
                if ~isfield(self.Patterns, patfield)
                    waitfor(errordlg("That filename does not match any imported files."));
                    return;
                end
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.Patterns.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.num_rows;
                if strcmp(string(self.pretrial{3}),'') == 0
                    
                    posfield = self.pretrial{3};
                    funcDim = max(self.Pos_funcs.(posfield).pfnparam.func);
                    
                else
                    
                    patDim = 0;
                    funcDim = 0;
                    
                end
                    
            elseif index == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.pretrial{2}),'') == 0

                posfield = new_value;
                if ~isfield(self.Pos_funcs, posfield)
                    waitfor(errordlg("That filename does not match any imported files."));
                    return;
                end
                patfield = self.pretrial{2};
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                funcDim = max(self.Pos_funcs.(posfield).pfnparam.func);
                patRows = 0;
                numrows = 0;
            else
                patDim = 0;
                funcDim = 0;
                patRows = 0;
                numrows = 0;
            end
            
            if index > 3 && index < 8 && ~strcmp(string(new_value),'')
                if ~isfield(self.Ao_funcs, new_value)
                    waitfor(errordlg("That filename does not match any imported files."));
                    return;
                end
            end
            
            %%add error checking here for rest of parameters.
            
            %Make sure frame index isn't out of bounds
            if index == 8 && ~strcmp(num2str(new_value),'')
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
                associated_pattern = self.pretrial{2};
                if ~isempty(associated_pattern)
                    num_pat_frames = length(self.Patterns.(associated_pattern).pattern.Pats(1,1,:));
                    if chars == 0
                        if str2num(new_value) > num_pat_frames
                            waitfor(errordlg("Please make sure your frame index is within the bounds of your pattern."));
                            return
                        end
                    end
                end
                if  chars == 1 && ~strcmp(new_value,'r')
                    waitfor(errordlg("Invalid frame index. Please enter a number or 'r'"));
                    return;
                end
            end
            
            %Make sure frame rate is > 0
            
            if index == 9 && ~strcmp(num2str(new_value),'')
               if ~isnumeric(new_value)
                   new_value = str2num(new_value);
               end
                if new_value <= 0 
                    waitfor(errordlg("Your frame rate must be above 0"));
                    return;
                end
            end
                    
            %Make sure gain/offset are numerical
            
            if index == 10 || index == 11 && ~strcmp(num2str(new_value),'')
               
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                
            end
            
            if index == 12 && ~strcmp(num2str(new_value),'')
               
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if new_value < 0
                    waitfor(errordlg("You duration must be zero or greater"));
                    return;
                end
            end
               
            if patRows ~= numrows
                waitfor(errordlg("Watch out! This pattern will not run on the size screen you have selected."));
            end

            if patDim < funcDim
                 waitfor(errordlg("Please make sure the dimension of your pattern and position functions match"));
            else

            self.pretrial{index} =  new_value ;

            end
            
        end
        
        function set_intertrial_property(self, index, new_value)
%             %If the user edited the pattern or position function, make sure
            %the file dimensions match
            
            if index == 1 && ~isempty(new_value)
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if new_value < 1 || new_value > 7
                    waitfor(errordlg("Mode must be 1-7 or left empty."));
                    return;
                end
            end
            
           if index == 2 && strcmp(string(new_value),'') == 0
                patfield = new_value;
                if ~isfield(self.Patterns, patfield)
                    waitfor(errordlg("That filename does not match any imported files."));
                    return;
                end
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.Patterns.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.num_rows;
                if strcmp(string(self.intertrial{3}),'') == 0
                    
                    posfield = self.intertrial{3};
                    funcDim = max(self.Pos_funcs.(posfield).pfnparam.func);
                    
                else
                    
                    patDim = 0;
                    funcDim = 0;
                    
                end
                    
            elseif index == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.intertrial{2}),'') == 0

                posfield = new_value;
                if ~isfield(self.Pos_funcs, posfield)
                    waitfor(errordlg("That filename does not match any imported files."));
                    return;
                end
                patfield = self.intertrial{2};
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                funcDim = max(self.Pos_funcs.(posfield).pfnparam.func);
                patRows = 0;
                numrows = 0;
            else
                patDim = 0;
                funcDim = 0;
                patRows = 0;
                numrows = 0;
           end
            
           if index > 3 && index < 8 && ~strcmp(string(new_value),'')
                if ~isfield(self.Ao_funcs, new_value)
                    waitfor(errordlg("That filename does not match any imported files."));
                    return;
                end
           end
            
           if index == 8 && ~strcmp(num2str(new_value),'')
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
                associated_pattern = self.intertrial{2};
                if ~isempty(associated_pattern)
                    num_pat_frames = length(self.Patterns.(associated_pattern).pattern.Pats(1,1,:));
                    if chars == 0
                        if str2num(new_value) > num_pat_frames
                            waitfor(errordlg("Please make sure your frame index is within the bounds of your pattern."));
                            return
                        end
                    end
                end
                if  chars == 1 && ~strcmp(new_value,'r')
                    waitfor(errordlg("Invalid frame index. Please enter a number or 'r'"));
                    return;
                end
            end
            
            
            %Make sure frame rate is > 0
            
            if index == 9 && ~strcmp(num2str(new_value),'')
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if new_value <= 0 
                    waitfor(errordlg("Your frame rate must be above 0"));
                    return;
                end
            end
                    
            %Make sure gain/offset are numerical
            
            if index == 10 || index == 11 && ~strcmp(num2str(new_value),'')
               
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                    
                end
                
            end
            
            if index == 12 && ~strcmp(num2str(new_value),'')
               if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if new_value < 0
                    waitfor(errordlg("You duration must be zero or greater"));
                    return;
                end
            end 
           
            if patRows ~= numrows
                waitfor(errordlg("Watch out! This pattern will not run on the size screen you have selected."));
            end

            if patDim < funcDim
                 waitfor(errordlg("Please make sure the dimension of your pattern and position functions match"));
            else
            self.intertrial{index} =  new_value ;
            end
       
%             end
        end
        
        function set_posttrial_property(self, index, new_value)
            
            if index == 1 && ~isempty(new_value)
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if new_value < 1 || new_value > 7
                    waitfor(errordlg("Mode must be 1-7 or left empty."));
                    return;
                end
            end

            %If the user edited the pattern or position function, make sure
            %the file dimensions match
            if index == 2 && strcmp(string(new_value),'') == 0
                patfield = new_value;
                if ~isfield(self.Patterns, patfield)
                    waitfor(errordlg("That filename does not match any imported files."));
                    return;
                end
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.Patterns.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.num_rows;
                if strcmp(string(self.posttrial{3}),'') == 0
                    
                    posfield = self.posttrial{3};
                    funcDim = max(self.Pos_funcs.(posfield).pfnparam.func);
                    
                else
                    
                    patDim = 0;
                    funcDim = 0;
                    
                end
                    
            elseif index == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.posttrial{2}),'') == 0

                posfield = new_value;
                if ~isfield(self.Pos_funcs, posfield)
                    waitfor(errordlg("That filename does not match any imported files."));
                    return;
                end
                patfield = self.posttrial{2};
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                funcDim = max(self.Pos_funcs.(posfield).pfnparam.func);
                patRows = 0;
                numrows = 0;
            else
                patDim = 0;
                funcDim = 0;
                patRows = 0;
                numrows = 0;
            end
            
            if index > 3 && index < 8 && ~strcmp(string(new_value),'')
                if ~isfield(self.Ao_funcs, new_value)
                    waitfor(errordlg("That filename does not match any imported files."));
                    return;
                end
            end
            
            if index == 8 && ~strcmp(num2str(new_value),'')
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
                associated_pattern = self.posttrial{2};
                if ~isempty(associated_pattern)
                    num_pat_frames = length(self.Patterns.(associated_pattern).pattern.Pats(1,1,:));
                    if chars == 0
                        if str2num(new_value) > num_pat_frames
                            waitfor(errordlg("Please make sure your frame index is within the bounds of your pattern."));
                            return
                        end
                    end
                end
                if  chars == 1 && ~strcmp(new_value,'r')
                    waitfor(errordlg("Invalid frame index. Please enter a number or 'r'"));
                    return;
                end
            end
            
            %Make sure frame rate is > 0
            
            if index == 9 && ~strcmp(num2str(new_value),'')
               if ~isnumeric(new_value)
                   new_value = str2num(new_value);
               end
                if new_value <= 0 
                    waitfor(errordlg("Your frame rate must be above 0"));
                    return;
                end
            end
                    
            %Make sure gain/offset are numerical
            
            if index == 10 || index == 11 && ~strcmp(num2str(new_value),'')
               
                if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                
                end
                
            end
            
            if index == 12 && ~strcmp(num2str(new_value),'')
               if ~isnumeric(new_value)
                    new_value = str2num(new_value);
                end
                if new_value < 0
                    waitfor(errordlg("You duration must be zero or greater"));
                    return;
                end
            end
            
            if patRows ~= numrows
                waitfor(errordlg("Watch out! This pattern will not run on the size screen you have selected."));
            end

            if patDim < funcDim
                 waitfor(errordlg("Please make sure the dimension of your pattern and position functions match"));
            else
            self.posttrial{index} =  new_value ;
            end

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
                if strcmp(self.block_trials{i,3},'') == 0
                    func_list{func_count} = self.block_trials{i,3};
                    func_count = func_count + 1;
                end
                if strcmp(self.block_trials{i,4},'') == 0
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

           if strcmp(self.pretrial{3},'') == 0
               func_list{end+1} = self.pretrial{3};
           end
           if strcmp(self.posttrial{3},'') == 0
               func_list{end+1} = self.posttrial{3};
           end
           if strcmp(self.intertrial{3},'') == 0
               func_list{end+1} = self.intertrial{3};
           end

           for i = 4:7
               if strcmp(self.pretrial{i},'') == 0
                   ao_list{end+1} = self.pretrial{i};
               end
           end
           for i = 4:7
               if strcmp(self.posttrial{i},'') == 0
                   ao_list{end+1} = self.posttrial{i};
               end
           end
           for i = 4:7
               if strcmp(self.intertrial{i},'') == 0
                   ao_list{end+1} = self.intertrial{i};
               end
           end

           if ~strcmp(func_list{1},'')

                func_list = unique(func_list);
                empty_cells = cellfun(@isempty, func_list);
                for i = 1:length(empty_cells)
                    if empty_cells(i) == 1
                        func_list(i) = [];
                    end
                end
                
           else
               func_list = {''};
           end
           if ~strcmp(ao_list,'')
               ao_list = unique(ao_list);
               empty_aocells = cellfun(@isempty, ao_list);
                for i = 1:length(empty_aocells)
                    if empty_aocells(i) == 1
                        ao_list(i) = [];
                    end
                end
           else
               ao_list = {''};
           end
           pat_list = unique(pat_list);
           empty_patcells = cellfun(@isempty, pat_list);
            for i = 1:length(empty_patcells)
                if empty_patcells(i) == 1
                    pat_list(i) = [];
                end
            end
        end
        
        function [pats, funcs, aos] = get_bin_list(self, pat_list, func_list, ao_list)
            all_pat_bins = fieldnames(self.binary_files.pats);
            all_func_bins = fieldnames(self.binary_files.funcs);
            all_ao_bins = fieldnames(self.binary_files.ao);
            pats = { };
            funcs = { };
            aos = { };
            
            
            for i = 1:length(pat_list)

                id = num2str(self.Patterns.(pat_list{i}).pattern.param.ID);
                add_zeros = 4 - numel(id);
                for j = 1:add_zeros
                    id = strcat("0",id);
                end

                index = find(contains(all_pat_bins,id));
                pats{end+1} = all_pat_bins{index};
                
            end
            
            if ~strcmp(func_list{1},'')
                for i = 1:length(func_list)

                    id = num2str(self.Pos_funcs.(func_list{i}).pfnparam.ID);
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
                    id = num2str(self.Ao_funcs.(ao_list{i}).afnparam.ID);
                    add_zeros = 4 - numel(id);
                    for j = 1:add_zeros
                        id = strcat("0",id);
                    end
                    index = find(contains(all_ao_bins, id));
                    aos{end+1} = all_ao_bins{index};
                end
            
            end
        
        end
        
%UPDATE THE CONFIG FILE----------------------------------------------------

        function update_config_file(self)
            %open config file
            %change appropriate rate
            %save and close config file
            config = self.configData;

            settings_data = strtrim(regexp( fileread('G4_Protocol_Designer_Settings.m'),'\n','split'));
            filepath_line = find(contains(settings_data,'Configuration File Path:'));
            exp = 'Path:';
            startIndex = regexp(settings_data{filepath_line},exp);
            start_filepath_index = startIndex + 6;
            config_filepath = settings_data{filepath_line}(start_filepath_index:end);
            fid = fopen(config_filepath,'wt');
            %for i = 1:length(config(:))
                fprintf(fid, '%s\n', config{:});
                %fprintf(fid, '\n');
           % end
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
                waitfor(errordlg(Expmsg));
                export_successful = 0;
                return;
            
            elseif patstatus == 0
                waitfor(errordlg(patmsg));
                export_successful = 0;
                return;
            
            elseif funcstatus == 0
                waitfor(errordlg(funcmsg));
                export_successful = 0;
                return; 
                
            elseif aostatus == 0
                waitfor(errordlg(aomsg));
                export_successful = 0;
                return; 
                
            else
                
               [pat_list, func_list, ao_list] = self.get_file_list();
               [pat_bin_list, func_bin_list, ao_bin_list] = self.get_bin_list(pat_list, func_list, ao_list);
               if ~strcmp(func_list{1},'')

                    num_funcs = length(func_list);
                    for m = 1:num_funcs
                        field = func_list{m};
                        filename = strcat(field, '.mat');
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
                    
                        field = ao_list{n};
                        filename = strcat(field, '.mat');
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
               for k = 1:num_pats
                    
                    field = pat_list{k};
                    filename = strcat(field,'.mat');
                    pattNames{k} = filename;
                    filepath = fullfile(patpath, filename);
                    pattern = self.Patterns.(field).pattern;
                    save(filepath, 'pattern');
                    
               end
               
               num_bins = length(pat_bin_list);
               for j = 1:num_bins
                   
                    patname = pat_bin_list{j}; 
                    fullpatname = strcat(patname,'.pat');
                    patternList{j} = fullpatname;
                    patfilepath = fullfile(patpath, fullpatname);
                    fileID = fopen(patfilepath,'w');
                    fwrite(fileID, self.binary_files.pats.(patname))
                    fclose(fileID);
                    
               end


%                 
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
                    field = pat_list{j};
                    newcurrentExp.pattern.x_num(j) = self.Patterns.(field).pattern.x_num;
                    newcurrentExp.pattern.y_num(j) = self.Patterns.(field).pattern.y_num;
                    newcurrentExp.pattern.gs_val(j) = self.Patterns.(field).pattern.gs_val;
                    newcurrentExp.pattern.arena_pitch(j) = self.Patterns.(field).pattern.param.arena_pitch;
                    pat_list{j} = strcat(field, '.mat');
                    
                end
                newcurrentExp.pattern.pattNames = pattNames;
                newcurrentExp.pattern.patternList = patternList;%list of .pat files
                newcurrentExp.pattern.num_patterns = num_pats;
                
                %newcurrentExp.function
                if ~strcmp(func_list{1},'')
                    for k = 1:num_funcs
                        field = func_list{k};
                        newcurrentExp.function.functionSize{k} = self.Pos_funcs.(field).pfnparam.size;
                        func_list{k} = strcat(field, '.mat');
                        newcurrentExp.function.functionName{k} = func_list{k};
                        func_bin_list{k} = strcat(func_bin_list{k},'.pfn');
                    end
                   % newcurrentExp.function.functionName = num2cell(func_list);
                    newcurrentExp.function.functionList = func_bin_list;%.pfn files
                    newcurrentExp.function.numFunc = num_funcs;
                end
                
                if ~strcmp(ao_list{1},'')
                    for p = 1:num_ao
                        field = ao_list{p};
                        newcurrentExp.aoFunction.aoFunctionSize{p} = self.Ao_funcs.(field).afnparam.size;  
                        ao_list{p} = strcat(field, '.mat');
                        ao_bin_list{p} = strcat(ao_bin_list{p},'.afn');
                    end
                    newcurrentExp.aoFunction.aoFunctionName = ao_list;
                    newcurrentExp.aoFunction.aoFunctionList = ao_bin_list;%.afn files
                    newcurrentExp.aoFunction.numaoFunc = num_ao;
                end
                

                self.currentExp = newcurrentExp;
                currentExp = self.currentExp;
                currentExpFile = 'currentExp.mat';
                filepath = fullfile(Exppath, currentExpFile);

                save(filepath, 'currentExp');
                
                export_successful = 1;
               
                
                
            end
            
            end
        
        
        function [opened_data] = open(self, filepath)
            
  
            opened_data = load(filepath, '-mat');
            self.save_filename = filepath;
   
        end
        
        function saveas(self, path, prog)
            
            homemade_ext = '.g4p';

        %Replace .mat extension with homemade one
            
            [savepath, name, ext] = fileparts(path);
            savename = strcat(name, homemade_ext);
            self.top_export_path = fullfile(savepath, self.experiment_name);
        %Get path to file you want to save including new extension    
            save_file = fullfile(self.top_export_path, savename);
            self.save_filename = save_file;
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
                        self.top_folder_path = temp_path;
                        
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
                waitfor(errordlg("Export was unsuccessful. Please delete files to be overwritten manually and try again."));
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
                waitfor(errordlg("You have not yet saved a new file. Please use 'save as'"));
            else
                export_successful = self.export();
                if export_successful == 0
                    waitfor(errordlg("Export was unsuccessful. Please delete folders to be replaced and use save as."));
                    
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
                
                waitfor(errordlg("Please make sure you are importing a .mat file"));
                return;
            end
            
            fileData = load(file_full);
            
            if isempty(fieldnames(fileData))
                waitfore(errordlg("I see no structure inside this .mat file. Please make sure it is formatted correctly."));
                return;
            end
            type = fieldnames(fileData);
            if strcmp(type{1},'pattern') == 1

                patRows = length(fileData.pattern.Pats(:,1,1))/16;
                if patRows ~= self.num_rows
                    waitfor(errordlg("Please make sure the patterns you import match the number of rows you have selected."));
                    return;
                end
                if isfield(self.Patterns, name) == 1
                    waitfor(errordlg("A pattern of that name has already been imported."));
                    return;
                else
                    self.Patterns.(name) = fileData;
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
                
                if isfield(self.Pos_funcs, name) == 1
                    waitfor(errordlg("A Position Function of that name has already been imported."));
                    return;
                else
                    self.Pos_funcs.(name) = fileData;
                    success_message = "One Position function imported successfully.";
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
                
                if isfield(self.Ao_funcs, name) == 1
                    waitfor(errordlg("An Analog Output Function of that name has already been imported."));
                    return;
                else
                    self.Ao_funcs.(name) = fileData;
                    success_message = "One AO Function imorted successfully.";
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
                self.currentExp = load(file_full);
                bin_ext = '';
                fileid = 0;
                
            else
                
                waitfor(errordlg("Please make sure your file is a pattern, position function, ao function, or currentExp file, and is formatted correctly."));
                return;
            
            end
            if fileid == 0
                waitfor(msgbox(success_message));
                return;
            end
            
            binary_path = fullfile(path, fileid1);
            binary_path2 = fullfile(path, fileid2);
            if ~isfile(binary_path) && ~isfile(binary_path2)
                waitfor(errordlg("Your file was imported, but no associated binary file was found."));
                return;
            end
            if isfile(binary_path) && isfile(binary_path2)
                waitfor(errordlg("Your file was imported, but there two binary files in this location with this ID."));
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
                    waitfor(errordlg("Your file was imported, but the .pat file was not. A pattern with that ID has already been imported."));
                    return;
                end
                self.binary_files.pats.(field_name) = binData;
            elseif strcmp(bin_ext,'.pfn')
                field_name = strcat('fun',fileid);
                if isfield(self.binary_files.funcs, field_name)
                    waitfor(errordlg("Your file was imported but the .pfn file was not. A function with that ID has already been imported."));
                    return;
                end
                self.binary_files.funcs.(field_name) = binData;

            elseif strcmp(bin_ext,'.afn')
                field_name = strcat('ao',fileid);
                if isfield(self.binary_files.ao, field_name)
                    waitfor(errordlg("Your file was imported but the .afn file was not. An AO function with that ID has already been imported."));
                    return;
                end
                self.binary_files.ao.(field_name) = binData;


            end
            
            waitfor(msgbox(success_message));

        end

        
        function [file_names, folder_names] = get_file_folder_names(self,path)
            
            all = dir(path);
            isub = [all(:).isdir];
            folder_names = {all(isub).name};
            folder_names(ismember(folder_names,{'.','..'})) = [];
            folder_names(ismember(folder_names,{'Results','Log Files'})) = [];
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
                                waitfor(errordlg("Please make sure the patterns you import match the number of rows you have selected."));
                                return;
                            end
                            if isfield(self.Patterns, name) == 1
                                skipped_patterns = skipped_patterns + 1;
                            else
                                self.Patterns.(name) = load(full_file_path);
                                imported_patterns = imported_patterns + 1;
                            end
                        elseif strcmp(type{1},'pfnparam') == 1
                            if isfield(self.Pos_funcs, name) == 1
                                skipped_functions = skipped_functions + 1;
                            else
                                self.Pos_funcs.(name) = load(full_file_path);
                                imported_functions = imported_functions + 1;
                            end
                        elseif strcmp(type{1},'afnparam') == 1
                            if isfield(self.Ao_funcs, name) == 1
                                skipped_aos = skipped_aos + 1;
                            else
                                self.Ao_funcs.(name) = load(full_file_path);
                                imported_aos = imported_aos + 1;
                            end

                        elseif strcmp(type{1},'currentExp') == 1
                            if isempty(fieldnames(self.currentExp)) == 0
                                currentExp_replaced = 1;
                            end
                            self.currentExp = load(full_file_path);
                            [folderpath, foldname] = fileparts(filepath);
                            self.experiment_name = foldname;
                            
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
%Import a folder, called from the controller and calls more specific import functions for each type of folder ---------------------------------        
        function import_folder(self, path)
            
           % prog = waitbar(0, 'Importing...', 'WindowStyle', 'modal'); %start waiting bar
            self.top_folder_path = path;
            [file_names, folder_names] = self.get_file_folder_names(path);
            
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
                                next_folders_list{end+1} = folders{j};
                            end
                            
                        end
                    end
                    
                    if isempty(next_folders_list)
                        no_more_subfolders = 1;
                    end
                    
                else
                    no_more_subfolders = 1;
                end
                %waitbar(1,prog,'Finishing...');
                %close(prog);
            end
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
 
                waitfor(msgbox(success_statement, 'Import Successful'));
            


% 

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
        
%GET THE INDEX OF A GIVEN PATTERN, POS, OR AO NAME-------------------------

      function [index] = get_pattern_index(self, pat_name)
            if strcmp(pat_name,'') == 1
                index = 0;
            else
                pat_name = strcat(pat_name,'.mat');
                currentExp_file = fullfile(self.top_export_path, 'currentExp.mat');
                saved_currentExp = load(currentExp_file);
                fields = saved_currentExp.currentExp.pattern.pattNames;
                index = find(strcmp(fields, pat_name));

            end    
        end

        function [index] = get_posfunc_index(self, pos_name)
            if strcmp(pos_name,'') == 1
                index = 0;
            else
                pos_name = strcat(pos_name,'.mat');
                currentExp_file = fullfile(self.top_export_path, 'currentExp.mat');
                saved_currentExp = load(currentExp_file);
                fields = saved_currentExp.currentExp.function.functionName;
                index = find(strcmp(fields, pos_name));
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
        
        %Setters
        
        function set.top_folder_path(self, value)
            self.top_folder_path_ = value;
        end
        
        function set.top_export_path(self, value)
            self.top_export_path_ = value;
        end
        
        function set.Patterns(self, value)
            self.Patterns_ = value;
        end
        
        function set.Pos_funcs(self, value)
            self.Pos_funcs_ = value;
        end
        
        function set.Ao_funcs(self, value)
            self.Ao_funcs_ = value;
        end
        
        function set.save_filename(self, value)
            self.save_filename_ = value;
        end
        
        function set.currentExp(self, value)
            self.currentExp_ = value;
        end
        
        function set.experiment_name(self, value)
            self.experiment_name_ = value;
        end
        
        function set.pretrial(self, value)
            self.pretrial_ = value;
        end
        
        function set.intertrial(self, value)
            self.intertrial_ = value;
        end
        
        function set.block_trials(self, value)
            self.block_trials_ = value;
        end
        
        function set.posttrial(self, value)
            self.posttrial_ = value;
        end
        
        function set.repetitions(self, value)
            self.repetitions_ = value;
        end
        
        function set.is_randomized(self, value)
            self.is_randomized_ = value;
        end
        
        function set.num_rows(self, value)
            self.num_rows_ = value;
        end
        
         function set.is_chan1(self, value)
            self.is_chan1_ = value;
        end
        
        function set.is_chan2(self, value)
            self.is_chan2_ = value;
        end
        
        function set.is_chan3(self, value)
            self.is_chan3_ = value;
        end
        
        function set.is_chan4(self, value)
            self.is_chan4_ = value;
        end
        
        function set.chan1_rate(self, value)
            self.chan1_rate_ = value;
        end
        
        function set.chan2_rate(self, value)
            self.chan2_rate_ = value;
        end
        
        function set.chan3_rate(self, value)
            self.chan3_rate_ = value;
        end
        
        function set.chan4_rate(self, value)
            self.chan4_rate_ = value;
        end
        
        function set.configData(self, value)
            self.configData_ = value;
        end
        
        function set.binary_files(self, value)
            self.binary_files_ = value;
        end
        
        %Getters
        
        
        function value = get.top_folder_path(self)
            value = self.top_folder_path_;
        end
        
        function value = get.top_export_path(self)
            value = self.top_export_path_;
        end
        
        function value = get.Patterns(self)
            value = self.Patterns_;
        end
        
        function value = get.Pos_funcs(self)
            value = self.Pos_funcs_;
        end
        
        function value = get.Ao_funcs(self)
            value = self.Ao_funcs_;
        end
        
        function value = get.save_filename(self)
            value = self.save_filename_;
        end
        
        function value = get.currentExp(self)
            value = self.currentExp_;
        end
        
        function value = get.experiment_name(self)
            value = self.experiment_name_;
        end
        
        function output = get.pretrial(self)
            output = self.pretrial_;
        end
        
        function output = get.block_trials(self)
            output = self.block_trials_;
        end
        
        function output = get.intertrial(self)
            output = self.intertrial_;
        end
        
        function output = get.posttrial(self)
            output = self.posttrial_;
        end
        
        function output = get.repetitions(self)
            output = self.repetitions_;
        end
        
        function output = get.is_randomized(self)
            output = self.is_randomized_;
        end
        
        function output = get.is_chan1(self)
            output = self.is_chan1_;
        end
        
        function output = get.chan1_rate(self)
            output = self.chan1_rate_;
        end
        
        function output = get.is_chan2(self)
            output = self.is_chan2_;
        end
        
        function output = get.chan2_rate(self)
            output = self.chan2_rate_;
        end
        
        function output = get.is_chan3(self)
            output = self.is_chan3_;
        end
        
        function output = get.chan3_rate(self)
            output = self.chan3_rate_;
        end
        
        function output = get.is_chan4(self)
            output = self.is_chan4_;
        end
        
        function output = get.chan4_rate(self)
           output = self.chan4_rate_;
        end
        
        function output = get.num_rows(self)
            output = self.num_rows_;
        end
        
        function output = get.configData(self)
            output = self.configData_;
        end
        
        function output = get.binary_files(self)
            output = self.binary_files_;
        end
        

    end

end
     


